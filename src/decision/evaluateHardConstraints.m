function [hard, dynamic] = evaluateHardConstraints( ...
    candidate, opponents, track, vehicle, decision)
% evaluateHardConstraints
% 기존 candidate 구조체를 수정하지 않고 hard constraint 결과를 별도 반환한다.
%
% Hard invalid 조건:
%   1. 기존 candidate generator에서 이미 invalid
%   2. NaN / Inf / trajectory 구조 오류
%   3. 실제 차량 크기 기반 collision overlap
%   4. 차량 body가 track boundary 밖으로 나감
%   5. (선택) dynamic hard constraint 초과

arguments
    candidate struct
    opponents struct
    track struct
    vehicle struct
    decision struct
end

opponents = opponents(:);

%% 1. 초기화
hard.isValid = true;
hard.reason = "valid";

hard.preexistingInvalid = false;
hard.structuralViolation = false;
hard.collisionViolation = false;
hard.offtrackViolation = false;
hard.longitudinalViolation = false;
hard.frictionViolation = false;
hard.steeringViolation = false;

hard.collisionTime = NaN;
hard.collisionOpponentIndex = NaN;
hard.collisionOpponentName = "";
hard.minTrackMargin = inf;

reasonList = strings(0,1);

%% 2. 기존 candidate generator 결과 존중
if ~candidate.isValid
    hard.preexistingInvalid = true;
    reasonList(end+1) = string(candidate.reason);
end

%% 3. Structural validity
requiredFields = ["time", "s", "d", "v", "x", "y"];

for fieldName = requiredFields
    if ~isfield(candidate, fieldName)
        hard.structuralViolation = true;
        reasonList(end+1) = "missing field: " + fieldName;
    end
end

if ~hard.structuralViolation
    allData = [ ...
        candidate.time(:); ...
        candidate.s(:); ...
        candidate.d(:); ...
        candidate.v(:); ...
        candidate.x(:); ...
        candidate.y(:)];

    if any(~isfinite(allData))
        hard.structuralViolation = true;
        reasonList(end+1) = "NaN or Inf detected";
    end
end

if hard.structuralViolation
    hard.isValid = false;
    hard.reason = strjoin(unique(reasonList, "stable"), "; ");
    dynamic = emptyDynamicMetrics();
    return;
end

%% 4. Dynamic metrics 계산
dynamic = computeCandidateDynamicMetrics(candidate, vehicle);

%% 5. 차량 크기 기반 hard collision
for i = 1:numel(opponents)

    oppLength = getOpponentDimension(opponents(i), "length", vehicle.length);
    oppWidth = getOpponentDimension(opponents(i), "width", vehicle.width);

    hardLong = 0.5 * (vehicle.length + oppLength) + ...
        max(decision.collisionSBuffer - vehicle.length, 0.0);

    hardLat = 0.5 * (vehicle.width + oppWidth) + ...
        max(decision.collisionDBuffer - vehicle.width, 0.0);

    for k = 1:numel(candidate.time)

        tCurrent = candidate.time(k);

        oppS = mod( ...
            opponents(i).s + opponents(i).v * tCurrent, ...
            track.length);

        oppD = opponents(i).d;

        deltaS = wrappedSignedDeltaS( ...
            candidate.s(k), oppS, track.length);

        deltaD = candidate.d(k) - oppD;

        if abs(deltaS) <= hardLong && abs(deltaD) <= hardLat
            hard.collisionViolation = true;
            hard.collisionTime = tCurrent;
            hard.collisionOpponentIndex = i;
            hard.collisionOpponentName = opponents(i).name;

            reasonList(end+1) = sprintf( ...
                "hard collision with %s at t = %.2f s", ...
                opponents(i).name, tCurrent);
            break;
        end
    end

    if hard.collisionViolation
        break;
    end
end

%% 6. Vehicle-body-aware off-track
[leftWidth, rightWidth] = getTrackWidthsAtS(track, candidate.s);

halfVehicleWidth = vehicle.width / 2;

leftAllowedD = leftWidth ...
    - halfVehicleWidth ...
    - decision.hardOfftrackBuffer;

rightAllowedD = -rightWidth ...
    + halfVehicleWidth ...
    + decision.hardOfftrackBuffer;

leftMargin = leftAllowedD - candidate.d(:);
rightMargin = candidate.d(:) - rightAllowedD;

hard.minTrackMargin = min([leftMargin; rightMargin]);

if any(leftMargin < 0) || any(rightMargin < 0)
    hard.offtrackViolation = true;
    reasonList(end+1) = sprintf( ...
        "vehicle body off-track: minimum margin = %.3f m", ...
        hard.minTrackMargin);
end

%% 7. Optional dynamic hard constraints
if decision.enableDynamicHardConstraint

    tol = decision.hardDynamicTolerance;

    if dynamic.maxAXUtil > tol
        hard.longitudinalViolation = true;
        reasonList(end+1) = sprintf( ...
            "longitudinal acceleration utilization exceeded: %.3f", ...
            dynamic.maxAXUtil);
    end

    if dynamic.maxFrictionUtil > tol
        hard.frictionViolation = true;
        reasonList(end+1) = sprintf( ...
            "friction utilization exceeded: %.3f", ...
            dynamic.maxFrictionUtil);
    end

    if dynamic.maxSteerUtil > tol
        hard.steeringViolation = true;
        reasonList(end+1) = sprintf( ...
            "steering utilization exceeded: %.3f", ...
            dynamic.maxSteerUtil);
    end
end

%% 8. 최종 판정
hard.isValid = ~( ...
    hard.preexistingInvalid || ...
    hard.structuralViolation || ...
    hard.collisionViolation || ...
    hard.offtrackViolation || ...
    hard.longitudinalViolation || ...
    hard.frictionViolation || ...
    hard.steeringViolation);

if hard.isValid
    hard.reason = "valid";
else
    hard.reason = strjoin(unique(reasonList, "stable"), "; ");
end

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

function [leftWidth, rightWidth] = getTrackWidthsAtS(track, sQuery)

sRef = track.s(:);
leftRef = track.widthLeft(:);
rightRef = track.widthRight(:);

[sRef, uniqueIdx] = unique(sRef, "stable");
leftRef = leftRef(uniqueIdx);
rightRef = rightRef(uniqueIdx);

if sRef(end) < track.length
    sRef = [sRef; track.length];
    leftRef = [leftRef; leftRef(1)];
    rightRef = [rightRef; rightRef(1)];
end

sQuery = mod(sQuery(:), track.length);

leftWidth = interp1(sRef, leftRef, sQuery, "linear");
rightWidth = interp1(sRef, rightRef, sQuery, "linear");

end

function dynamic = emptyDynamicMetrics()

dynamic.curvature = [];
dynamic.aX = [];
dynamic.aY = [];
dynamic.aXUtil = [];
dynamic.aYUtil = [];
dynamic.frictionUtil = [];
dynamic.steerRequired = [];
dynamic.steerUtil = [];
dynamic.yawRateDemand = [];
dynamic.slipAvailable = false;
dynamic.maxAbsAX = NaN;
dynamic.maxAY = NaN;
dynamic.maxAXUtil = NaN;
dynamic.maxAYUtil = NaN;
dynamic.maxFrictionUtil = NaN;
dynamic.maxSteerUtil = NaN;
dynamic.maxAbsYawRateDemand = NaN;

end
