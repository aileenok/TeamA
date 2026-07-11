function [costTable, costResults] = evaluateAllCandidateCosts( ...
    candidates, ego, opponents, track, vehicle, decision)
% evaluateAllCandidateCosts
% 기존 candidates 구조체 배열을 수정하지 않고 모든 후보를 평가한다.
%
% 출력:
%   costTable   : 후보별 비교용 table
%   costResults : hard/dynamic/cost 상세 struct array

arguments
    candidates struct
    ego struct
    opponents struct
    track struct
    vehicle struct
    decision struct
end

candidates = candidates(:);
numCandidates = numel(candidates);

if numCandidates == 0
    error("평가할 candidate가 없습니다.");
end

%% Table용 변수
actionName = strings(numCandidates, 1);
valid = false(numCandidates, 1);
totalCost = zeros(numCandidates, 1);
safetyCost = zeros(numCandidates, 1);
dynamicCost = zeros(numCandidates, 1);
raceAdvantageCost = zeros(numCandidates, 1);

collisionCost = zeros(numCandidates, 1);
clearanceCost = zeros(numCandidates, 1);
ttcCost = zeros(numCandidates, 1);
trackMarginCost = zeros(numCandidates, 1);

frictionCost = zeros(numCandidates, 1);
lateralAccelCost = zeros(numCandidates, 1);
longitudinalCost = zeros(numCandidates, 1);
steeringCost = zeros(numCandidates, 1);

progressCost = zeros(numCandidates, 1);
timeCost = zeros(numCandidates, 1);
exitSpeedCost = zeros(numCandidates, 1);
futureProgressCost = zeros(numCandidates, 1);
recoveryCost = zeros(numCandidates, 1);

reason = strings(numCandidates, 1);

%% 평가
costResults = struct([]);

for i = 1:numCandidates

    result = evaluateCandidateCost( ...
        candidates(i), ...
        ego, ...
        opponents, ...
        track, ...
        vehicle, ...
        decision);

    if i == 1
        costResults = result;
    else
        costResults(i,1) = result;
    end

    actionName(i) = result.actionName;
    valid(i) = result.valid;
    reason(i) = result.reason;

    totalCost(i) = result.cost.totalCost;
    safetyCost(i) = result.cost.safetyCost;
    dynamicCost(i) = result.cost.dynamicCost;
    raceAdvantageCost(i) = result.cost.raceAdvantageCost;

    collisionCost(i) = result.cost.collisionCost;
    clearanceCost(i) = result.cost.clearanceCost;
    ttcCost(i) = result.cost.ttcCost;
    trackMarginCost(i) = result.cost.trackMarginCost;

    frictionCost(i) = result.cost.frictionCost;
    lateralAccelCost(i) = result.cost.lateralAccelCost;
    longitudinalCost(i) = result.cost.longitudinalCost;
    steeringCost(i) = result.cost.steeringCost;

    progressCost(i) = result.cost.progressCost;
    timeCost(i) = result.cost.timeCost;
    exitSpeedCost(i) = result.cost.exitSpeedCost;
    futureProgressCost(i) = result.cost.futureProgressCost;
    recoveryCost(i) = result.cost.referenceLineRecoveryCost;
end

%% Table
costTable = table( ...
    actionName, ...
    valid, ...
    totalCost, ...
    safetyCost, ...
    dynamicCost, ...
    raceAdvantageCost, ...
    collisionCost, ...
    clearanceCost, ...
    ttcCost, ...
    trackMarginCost, ...
    frictionCost, ...
    lateralAccelCost, ...
    longitudinalCost, ...
    steeringCost, ...
    progressCost, ...
    timeCost, ...
    exitSpeedCost, ...
    futureProgressCost, ...
    recoveryCost, ...
    reason);

end
