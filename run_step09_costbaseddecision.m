% run_step09_costbaseddecision.m
% Cost-based tactical decision v1
%
% 기존 step08 candidate pipeline을 그대로 사용한다.
% 새 cost 코드는 candidate 생성 로직을 바꾸지 않고 평가만 수행한다.

clear;
clc;
close all;

project_startup;

%% 1. Processed track 불러오기
processedFile = fullfile( ...
    "data", ...
    "processed_tracks", ...
    "Monza_processed.mat");

if ~isfile(processedFile)
    error("Monza_processed.mat 파일을 찾을 수 없습니다: %s", processedFile);
end

data = load(processedFile);

if ~isfield(data, "track")
    error("Monza_processed.mat 내부에 track 변수가 없습니다.");
end

track = data.track;

fprintf("Track loaded: Monza\n");
fprintf("Track length: %.2f m\n", track.length);

%% 2. Parameter
race = raceParams();
decision = decisionParams();
vehicle = vehicleParams("race");
oppParams = opponentParams(track);

%% 3. 차량 생성
ego = createEgoCar(track, race);
opponents = createOpponentFleet(track, oppParams);

%% 4. Cost decision 테스트용 traffic pack
% step08과 같은 유형의 레이싱 traffic pack을 사용한다.
[opponents, scenarioName] = arrangeOpponentPackForCostDemo( ...
    opponents, track, ego);

fprintf("\n=== Cost Decision Traffic Scenario ===\n");
fprintf("Scenario: %s\n", scenarioName);

for i = 1:numel(opponents)
    gap = mod(opponents(i).s - ego.s, track.length);

    fprintf( ...
        "%s | gap = %6.2f m | d = %5.2f m | v = %6.2f m/s\n", ...
        opponents(i).name, ...
        gap, ...
        opponents(i).d, ...
        opponents(i).v);
end

%% 5. 기존 candidate action 생성
[candidates, decisionInfo] = generateCandidateActions( ...
    track, ...
    ego, ...
    opponents, ...
    decision);

leadInfo = decisionInfo.leadInfo;

fprintf("\n=== Ego / Lead State ===\n");
fprintf("Ego | s = %.2f m | d = %.2f m | v = %.2f m/s\n", ...
    ego.s, ego.d, ego.v);

if leadInfo.hasLead
    fprintf("Lead vehicle: %s\n", leadInfo.leadName);
    fprintf("Gap: %.2f m\n", leadInfo.gap);
    fprintf("Relative speed: %.2f m/s\n", leadInfo.relativeSpeed);
    fprintf("TTC: %.2f s\n", leadInfo.ttc);
else
    fprintf("Lead vehicle: none\n");
end

%% 6. Hard constraint + cost 계산
[costTable, costResults] = evaluateAllCandidateCosts( ...
    candidates, ...
    ego, ...
    opponents, ...
    track, ...
    vehicle, ...
    decision);

%% 7. Best action 선택
currentAction = "MAINTAIN_LINE";

[bestCandidate, bestIndex, selectionInfo] = selectBestCandidate( ...
    candidates, ...
    costTable, ...
    currentAction, ...
    decision);

%% 8. 결과 출력
fprintf("\n=== Candidate Cost Summary ===\n");

disp(costTable(:, [ ...
    "actionName", ...
    "valid", ...
    "totalCost", ...
    "safetyCost", ...
    "dynamicCost", ...
    "raceAdvantageCost", ...
    "reason" ...
    ]));

fprintf("\n=== Candidate Dynamic Metrics ===\n");

for i = 1:numel(costResults)

    fprintf("\n[%s]\n", ...
        string(costResults(i).actionName));

    fprintf("Valid              : %d\n", ...
        costResults(i).valid);

    fprintf("Max AX utilization : %.3f\n", ...
        costResults(i).dynamic.maxAXUtil);

    fprintf("Max AY utilization : %.3f\n", ...
        costResults(i).dynamic.maxAYUtil);

    fprintf("Max friction util  : %.3f\n", ...
        costResults(i).dynamic.maxFrictionUtil);

    fprintf("Max steering util  : %.3f\n", ...
        costResults(i).dynamic.maxSteerUtil);

    fprintf("Dynamic cost       : %.4f\n", ...
        costResults(i).cost.dynamicCost);

end

%% 9. Best candidate
if isnan(bestIndex)
    fprintf("\n=== Best Candidate ===\n");
    fprintf("No valid candidate selected.\n");
    fprintf("Reason: %s\n", selectionInfo.reason);

    warning("Valid candidate가 없으므로 animation을 실행하지 않습니다.");
    return;
end

bestCost = costResults(bestIndex).cost;

fprintf("\n=== Best Candidate ===\n");
fprintf("Action: %s\n", bestCandidate.name);
fprintf("Index: %d\n", bestIndex);
fprintf("Total cost: %.4f\n", bestCost.totalCost);
fprintf("Safety cost: %.4f\n", bestCost.safetyCost);
fprintf("Dynamic cost: %.4f\n", bestCost.dynamicCost);
fprintf("Race advantage cost: %.4f\n", bestCost.raceAdvantageCost);
fprintf("Selection reason: %s\n", selectionInfo.reason);

%% 10. 시각화
plotCandidateActions(track, ego, opponents, candidates);

animateCandidateAction2D( ...
    track, ...
    ego, ...
    opponents, ...
    candidates, ...
    string(bestCandidate.name), ...
    false);

%% 11. 결과 저장
resultFolder = fullfile("data", "results");

if ~isfolder(resultFolder)
    mkdir(resultFolder);
end

resultFile = fullfile(resultFolder, "Monza_cost_decision_v1.mat");

save(resultFile, ...
    "track", ...
    "ego", ...
    "opponents", ...
    "scenarioName", ...
    "decisionInfo", ...
    "candidates", ...
    "costTable", ...
    "costResults", ...
    "bestCandidate", ...
    "bestIndex", ...
    "selectionInfo", ...
    "race", ...
    "decision", ...
    "vehicle", ...
    "oppParams");

fprintf("\nSaved file: %s\n", resultFile);

%% Local functions

function [opponents, scenarioName] = ...
    arrangeOpponentPackForCostDemo(opponents, track, ego)
% step08과 같은 종류의 traffic pack을 cost test용으로 만든다.

if numel(opponents) < 3
    error("이 demo는 opponent 3대를 기준으로 작성되었습니다.");
end

rng("shuffle");
scenarioId = randi(3);

switch scenarioId
    case 1
        scenarioName = "compact_pack";
        baseGap = [75; 120; 170];
        baseD = [0.0; 1.5; -1.5];
        speedOffset = [-9; -6; -3];

    case 2
        scenarioName = "two_wide_traffic";
        baseGap = [95; 125; 210];
        baseD = [-1.4; 1.4; 0.0];
        speedOffset = [-8; -7; -2];

    otherwise
        scenarioName = "stretched_traffic";
        baseGap = [85; 165; 250];
        baseD = [0.0; -1.6; 1.6];
        speedOffset = [-10; -5; 0];
end

gapNoiseRange = 12.0;
dNoiseRange = 0.25;
speedNoiseStd = 1.5;

for i = 1:3
    gap = baseGap(i) + gapNoiseRange * (2 * rand() - 1);

    d = baseD(i) + dNoiseRange * randn();
    d = min(max(d, -2.2), 2.2);

    v = ego.v + speedOffset(i) + speedNoiseStd * randn();
    v = min(max(v, 45.0), 75.0);

    opponents(i) = resetOpponentForCostDemo( ...
        opponents(i), ...
        track, ...
        ego.s + gap, ...
        d, ...
        v);
end

shuffleIdx = randperm(3);
opponents(1:3) = opponents(shuffleIdx);

end

function opponent = resetOpponentForCostDemo( ...
    opponent, track, s0, d0, v0)

opponent.s = mod(s0, track.length);
opponent.d = d0;
opponent.v = v0;

opponent.position = frenetToGlobalCustom( ...
    track, opponent.s, opponent.d);

opponent.history.s = opponent.s;
opponent.history.d = opponent.d;
opponent.history.v = opponent.v;
opponent.history.x = opponent.position(1);
opponent.history.y = opponent.position(2);

opponent.distanceTravelled = 0.0;
opponent.completedLaps = 0;
opponent.hasFinished = false;
opponent.finishTime = NaN;

end
