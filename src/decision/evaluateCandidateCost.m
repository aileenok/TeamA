function result = evaluateCandidateCost( ...
    candidate, ego, opponents, track, vehicle, decision)
% evaluateCandidateCost
% 기존 candidate를 그대로 두고 한 후보의 hard/dynamic/cost 결과를 반환한다.
%
% result.hard
% result.dynamic
% result.cost
%
% Cost는 낮을수록 좋다.

arguments
    candidate struct
    ego struct
    opponents struct
    track struct
    vehicle struct
    decision struct
end

%% 1. Hard constraint + dynamic metrics
[hard, dynamic] = evaluateHardConstraints( ...
    candidate, opponents, track, vehicle, decision);

%% 2. Cost 기본값
cost.actionName = string(candidate.name);

cost.collisionCost = 0.0;
cost.offtrackCost = 0.0;
cost.clearanceCost = 0.0;
cost.ttcCost = 0.0;
cost.trackMarginCost = 0.0;

cost.frictionCost = 0.0;
cost.lateralAccelCost = 0.0;
cost.longitudinalCost = 0.0;
cost.steeringCost = 0.0;
cost.yawCost = 0.0;
cost.slipAngleCost = 0.0;

cost.timeCost = 0.0;
cost.progressCost = 0.0;
cost.exitSpeedCost = 0.0;
cost.futureProgressCost = 0.0;
cost.referenceLineRecoveryCost = 0.0;

cost.safetyCost = 0.0;
cost.dynamicCost = 0.0;
cost.raceAdvantageCost = 0.0;
cost.totalCost = 0.0;

%% 3. Invalid candidate
if ~hard.isValid
    cost.totalCost = decision.costInvalidPenalty;

    result.actionName = string(candidate.name);
    result.valid = false;
    result.reason = hard.reason;
    result.hard = hard;
    result.dynamic = dynamic;
    result.cost = cost;
    return;
end

%% 4. Soft safety cost
safety = computeSoftSafetyCosts( ...
    candidate, opponents, track, vehicle, decision);

cost.collisionCost = safety.collisionCost;
cost.clearanceCost = safety.clearanceCost;
cost.ttcCost = safety.ttcCost;
cost.offtrackCost = 0.0;

if hard.minTrackMargin >= decision.costDesiredTrackMargin
    cost.trackMarginCost = 0.0;
else
    cost.trackMarginCost = clamp01( ...
        (decision.costDesiredTrackMargin - hard.minTrackMargin) ...
        / max(decision.costDesiredTrackMargin, eps));
end

cost.safetyCost = ...
    decision.wCollision   * cost.collisionCost ...
  + decision.wOfftrack    * cost.offtrackCost ...
  + decision.wClearance   * cost.clearanceCost ...
  + decision.wTTC         * cost.ttcCost ...
  + decision.wTrackMargin * cost.trackMarginCost;

%% 5. Dynamic cost
softStart = decision.costDynamicSoftStart;

cost.frictionCost = softUtilizationCost( ...
    dynamic.maxFrictionUtil, softStart);

cost.lateralAccelCost = softUtilizationCost( ...
    dynamic.maxAYUtil, softStart);

cost.longitudinalCost = softUtilizationCost( ...
    dynamic.maxAXUtil, softStart);

cost.steeringCost = softUtilizationCost( ...
    dynamic.maxSteerUtil, softStart);

% 현재 actual yaw/slip state가 없으므로 비활성
cost.yawCost = 0.0;
cost.slipAngleCost = 0.0;

cost.dynamicCost = ...
    decision.wFriction      * cost.frictionCost ...
  + decision.wLateralAccel  * cost.lateralAccelCost ...
  + decision.wLongitudinal  * cost.longitudinalCost ...
  + decision.wSteering      * cost.steeringCost ...
  + decision.wYaw           * cost.yawCost ...
  + decision.wSlip          * cost.slipAngleCost;

%% 6. Race advantage cost
t = candidate.time(:);
v = candidate.v(:);

progressCum = cumtrapz(t, v);
progress = progressCum(end);

maxPossibleProgress = vehicle.maxSpeed * decision.horizon;

cost.progressCost = clamp01( ...
    1.0 - progress / max(maxPossibleProgress, eps));

%% 6-1. Time cost
% 같은 horizon이라 단순 horizon time은 모든 후보가 같으므로 의미가 없다.
% 대신 고정 target distance까지 도달하는 시간을 비교한다.
targetDistance = decision.costTimeTargetDistance;

if progress < targetDistance
    cost.timeCost = 1.0;
else
    [uniqueProgress, uniqueIdx] = unique(progressCum, "stable");
    uniqueTime = t(uniqueIdx);

    if numel(uniqueProgress) < 2
        cost.timeCost = 1.0;
    else
        timeToTarget = interp1( ...
            uniqueProgress, uniqueTime, targetDistance, "linear");

        bestPossibleTime = targetDistance / max(vehicle.maxSpeed, eps);
        worstReferenceTime = targetDistance ...
            / max(decision.minCandidateSpeed, eps);

        denom = worstReferenceTime - bestPossibleTime;

        if denom <= eps
            cost.timeCost = 0.0;
        else
            cost.timeCost = clamp01( ...
                (timeToTarget - bestPossibleTime) / denom);
        end
    end
end

%% 6-2. Exit speed
cost.exitSpeedCost = clamp01( ...
    1.0 - candidate.v(end) / max(vehicle.maxSpeed, eps));

%% 6-3. Future progress proxy
futureT = decision.costFutureLookAheadTime;

futureProgressEstimate = ...
    progress + candidate.v(end) * futureT;

maxFutureProgress = ...
    vehicle.maxSpeed * (decision.horizon + futureT);

cost.futureProgressCost = clamp01( ...
    1.0 - futureProgressEstimate / max(maxFutureProgress, eps));

%% 6-4. Reference-line recovery
if abs(ego.d - decision.returnD) < decision.returnLineTolerance
    cost.referenceLineRecoveryCost = 0.0;
else
    initialOffset = abs(ego.d - decision.returnD);
    finalOffset = abs(candidate.d(end) - decision.returnD);

    cost.referenceLineRecoveryCost = clamp01( ...
        finalOffset / max(initialOffset, eps));
end

cost.raceAdvantageCost = ...
    decision.wTime           * cost.timeCost ...
  + decision.wProgress       * cost.progressCost ...
  + decision.wExitSpeed      * cost.exitSpeedCost ...
  + decision.wFutureProgress * cost.futureProgressCost ...
  + decision.wRecovery       * cost.referenceLineRecoveryCost;

%% 7. Final total cost
cost.totalCost = ...
    decision.lambdaSafety  * cost.safetyCost ...
  + decision.lambdaDynamic * cost.dynamicCost ...
  + decision.lambdaRace    * cost.raceAdvantageCost;

%% 8. Result
result.actionName = string(candidate.name);
result.valid = true;
result.reason = "valid";
result.hard = hard;
result.dynamic = dynamic;
result.cost = cost;

end

function safety = computeSoftSafetyCosts( ...
    candidate, opponents, track, vehicle, decision)

opponents = opponents(:);

safety.collisionCost = 0.0;
safety.clearanceCost = 0.0;
safety.ttcCost = 0.0;

minTTC = inf;

for i = 1:numel(opponents)

    oppLength = getOpponentDimension( ...
        opponents(i), "length", vehicle.length);

    oppWidth = getOpponentDimension( ...
        opponents(i), "width", vehicle.width);

    hardLong = 0.5 * (vehicle.length + oppLength) ...
        + max(decision.collisionSBuffer - vehicle.length, 0.0);

    hardLat = 0.5 * (vehicle.width + oppWidth) ...
        + max(decision.collisionDBuffer - vehicle.width, 0.0);

    for k = 1:numel(candidate.time)

        tCurrent = candidate.time(k);

        oppS = mod( ...
            opponents(i).s + opponents(i).v * tCurrent, ...
            track.length);

        oppD = opponents(i).d;

        deltaS = wrappedSignedDeltaS( ...
            candidate.s(k), oppS, track.length);

        deltaD = candidate.d(k) - oppD;

        absDS = abs(deltaS);
        absDD = abs(deltaD);

        closingSpeed = max( ...
            candidate.v(k) - opponents(i).v, 0.0);

        warningLong = hardLong ...
            + decision.costMinLongitudinalWarning ...
            + closingSpeed * decision.costTauSafety;

        warningLat = hardLat ...
            + decision.costLateralWarningExtra;

        %% Collision risk cost
        normalizedDistance = sqrt( ...
            (absDS / max(warningLong, eps))^2 ...
          + (absDD / max(warningLat, eps))^2);

        currentCollisionCost = ...
            max(0.0, 1.0 - normalizedDistance)^2;

        safety.collisionCost = max( ...
            safety.collisionCost, currentCollisionCost);

        %% Clearance cost
        longitudinalClearance = max(absDS - hardLong, 0.0);
        lateralClearance = max(absDD - hardLat, 0.0);

        desiredLongClearance = max(warningLong - hardLong, 1.0e-6);
        desiredLatClearance = max(warningLat - hardLat, 1.0e-6);

        normalizedClearance = sqrt( ...
            (longitudinalClearance / desiredLongClearance)^2 ...
          + (lateralClearance / desiredLatClearance)^2);

        currentClearanceCost = max(0.0, 1.0 - normalizedClearance);

        safety.clearanceCost = max( ...
            safety.clearanceCost, currentClearanceCost);

        %% TTC
        forwardGap = mod( ...
            oppS - candidate.s(k), track.length);

        opponentIsAhead = forwardGap < track.length / 2;
        lateralRelevant = absDD < warningLat;

        if opponentIsAhead && lateralRelevant && closingSpeed > 1.0e-6
            ttc = forwardGap / closingSpeed;
            minTTC = min(minTTC, ttc);
        end
    end
end

if ~isfinite(minTTC)
    safety.ttcCost = 0.0;
elseif minTTC <= decision.costTTCCritical
    safety.ttcCost = 1.0;
elseif minTTC >= decision.costTTCWarning
    safety.ttcCost = 0.0;
else
    safety.ttcCost = ...
        (decision.costTTCWarning - minTTC) ...
        / (decision.costTTCWarning - decision.costTTCCritical);
end

safety.collisionCost = clamp01(safety.collisionCost);
safety.clearanceCost = clamp01(safety.clearanceCost);
safety.ttcCost = clamp01(safety.ttcCost);

end

function value = getOpponentDimension(opponent, fieldName, fallback)

if isfield(opponent, fieldName)
    value = opponent.(fieldName);
else
    value = fallback;
end

end

function deltaS = wrappedSignedDeltaS(s1, s2, trackLength)

deltaS = mod(s1 - s2 + trackLength/2, trackLength) ...
    - trackLength/2;

end

function y = softUtilizationCost(utilization, softStart)

y = clamp01( ...
    (utilization - softStart) ...
    / max(1.0 - softStart, eps));

end

function y = clamp01(x)

y = min(max(x, 0.0), 1.0);

end
