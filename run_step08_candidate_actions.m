% run_step08_candidate_actions_monza.m
% ego 차량의 candidate action들을 생성하고 시각화하는 스크립트
%
% Action set:
%   1. MAINTAIN_LINE
%   2. OVERTAKE_INSIDE
%   3. OVERTAKE_OUTSIDE
%   4. RETURN_TO_LINE

clear; clc; close all;

project_startup;

%% 1. processed track 불러오기
processedFile = fullfile("data", "processed_tracks", "Monza_processed.mat");

if ~isfile(processedFile)
    error("Monza_processed.mat 파일을 찾을 수 없습니다: %s", processedFile);
end

data = load(processedFile);
track = data.track;

%% 2. 파라미터 불러오기
race = raceParams();
decision = decisionParams();

% candidate action 애니메이션을 10초 동안 보기 위한 설정
decision.horizon = 10.0;   % [s] candidate rollout 시간
decision.dt = 0.10;        % [s] 0.1초 간격 → 총 약 101 frame

% 현재 random opponent version 기준
oppParams = opponentParams(track);

%% 3. 차량 생성
ego = createEgoCar(track, race);
opponents = createOpponentFleet(track, oppParams);

%% 4. candidate action 테스트용 주행 상황 만들기
% 실제 레이싱 상황처럼 ego 앞쪽에 opponent 차량들이 어느 정도 모여 있는 상황을 만든다.
% 완전 랜덤이 아니라 compact pack / two-wide / stretched traffic 중 하나를 선택한다.

useRacePackDemo = true;

if useRacePackDemo
    [opponents, scenarioName] = arrangeOpponentPackForCandidateDemo( ...
        opponents, track, ego);

    fprintf("\n=== Candidate Demo Traffic Scenario ===\n");
    fprintf("Scenario: %s\n", scenarioName);

    for i = 1:numel(opponents)
        gap = mod(opponents(i).s - ego.s, track.length);

        fprintf("%s | gap = %6.2f m | d = %5.2f m | v = %6.2f m/s\n", ...
            opponents(i).name, gap, opponents(i).d, opponents(i).v);
    end
end

%% 5. Candidate action 생성
% lead vehicle 탐색, inside/outside target 계산은 generateCandidateActions 내부에서 수행한다.

[candidates, decisionInfo] = generateCandidateActions( ...
    track, ...
    ego, ...
    opponents, ...
    decision);

leadInfo = decisionInfo.leadInfo;
sideInfo = decisionInfo.sideInfo;

%% 6. candidate 결과 출력
fprintf("\n=== Candidate Action Demo ===\n");
fprintf("Ego: s = %.2f m, d = %.2f m, v = %.2f m/s\n", ...
    ego.s, ego.d, ego.v);

if leadInfo.hasLead
    fprintf("Lead vehicle: %s\n", leadInfo.leadName);
    fprintf("Gap: %.2f m\n", leadInfo.gap);
    fprintf("Relative speed ego - lead: %.2f m/s\n", leadInfo.relativeSpeed);
    fprintf("TTC: %.2f s\n", leadInfo.ttc);
else
    fprintf("Lead vehicle: none\n");
end

fprintf("Corner direction for overtake: %s\n", sideInfo.cornerDirection);
fprintf("Inside targetD: %.2f m\n", sideInfo.insideTargetD);
fprintf("Outside targetD: %.2f m\n", sideInfo.outsideTargetD);

fprintf("\n=== Generated Candidate Actions ===\n");

for i = 1:numel(candidates)
    fprintf("%-18s | valid = %d | targetD = %6.2f m | targetV = %6.2f m/s | %s\n", ...
        candidates(i).name, ...
        candidates(i).isValid, ...
        candidates(i).targetD, ...
        candidates(i).targetV, ...
        candidates(i).reason);
end

%% 7. Cost-based decision
% 각 candidate에 대해 collision / offtrack / time / progress cost를 계산하고,
% valid candidate 중 totalCost가 가장 낮은 후보를 best action으로 선택한다.

for i = 1:numel(candidates)
    candidates(i) = evaluateCandidateCost(candidates(i), ego, opponents, track, decision);
end

bestCandidate = selectBestCandidateByCost(candidates);

fprintf("\n=== Candidate Cost Breakdown ===\n");
fprintf("%-18s | %6s | %10s | %10s | %10s | %10s | %10s\n", ...
    "action", "valid", "collision", "offtrack", "time", "progress", "total");

for i = 1:numel(candidates)
    fprintf("%-18s | %6d | %10.2f | %10.2f | %10.2f | %10.2f | %10.2f\n", ...
        candidates(i).name, ...
        candidates(i).isValid, ...
        candidates(i).costCollision, ...
        candidates(i).costOfftrack, ...
        candidates(i).costTime, ...
        candidates(i).costProgress, ...
        candidates(i).totalCost);
end

fprintf("\nSelected action (cost-based): %s  (totalCost = %.2f)\n", ...
    bestCandidate.name, bestCandidate.totalCost);

%% 8. 정적 시각화
plotCandidateActions(track, ego, opponents, candidates);

%% 9. candidate action rollout 애니메이션 확인
% cost-based decision 결과(bestCandidate)를 애니메이션으로 확인한다.
% 참고: selectCandidateForAnimation은 cost 계산 전 단계에서 쓰던
%       우선순위 기반 선택 방식으로, 비교용으로 남겨둔다.
%
% legacyActionName = selectCandidateForAnimation(candidates);

selectedActionName = bestCandidate.name;

% GIF 저장 여부
% true  : data/results/animations 폴더에 GIF 저장
% false : 화면 애니메이션만 실행
saveGif = true;

animateCandidateAction2D( ...
    track, ...
    ego, ...
    opponents, ...
    candidates, ...
    selectedActionName, ...
    saveGif);

%% 10. 결과 저장
resultFolder = fullfile("data", "results");

if ~isfolder(resultFolder)
    mkdir(resultFolder);
end

resultFile = fullfile(resultFolder, "Monza_candidate_actions_demo.mat");

save(resultFile, ...
    "track", ...
    "ego", ...
    "opponents", ...
    "leadInfo", ...
    "sideInfo", ...
    "decisionInfo", ...
    "candidates", ...
    "bestCandidate", ...
    "selectedActionName", ...
    "race", ...
    "decision", ...
    "oppParams");

fprintf("\n=== Candidate Action Demo Saved ===\n");
fprintf("Saved file: %s\n", resultFile);

%% Local functions

function opponent = resetOpponentForCandidateDemo(opponent, track, s0, d0, v0)
% resetOpponentForCandidateDemo
% candidate action 테스트를 위해 opponent 1대의 상태를 수동으로 재설정한다.

opponent.s = mod(s0, track.length);
opponent.d = d0;
opponent.v = v0;

opponent.position = frenetToGlobalCustom(track, opponent.s, opponent.d);

opponent.history.s = opponent.s;
opponent.history.d = opponent.d;
opponent.history.v = opponent.v;
opponent.history.x = opponent.position(1);
opponent.history.y = opponent.position(2);

% 기존 구조체에 lap 관련 필드가 있는 경우만 초기화
if isfield(opponent, "distanceTravelled")
    opponent.distanceTravelled = 0.0;
end

if isfield(opponent, "completedLaps")
    opponent.completedLaps = 0;
end

if isfield(opponent, "hasFinished")
    opponent.hasFinished = false;
end

if isfield(opponent, "finishTime")
    opponent.finishTime = NaN;
end

end

function [opponents, scenarioName] = arrangeOpponentPackForCandidateDemo(opponents, track, ego)
% arrangeOpponentPackForCandidateDemo
% candidate action 테스트를 위해 실제 레이싱 상황처럼 opponent 차량들을 배치한다.
%
% 목적:
%   - ego 앞쪽에 차량 3대가 어느 정도 모여 있는 상황 생성
%   - 너무 무작위가 아니라, 레이싱 중 traffic pack처럼 보이도록 설정
%   - 실행할 때마다 gap, d, speed가 약간씩 달라짐
%
% 배치 기준:
%   gap : ego 기준 앞쪽 거리 [m]
%   d   : lateral offset [m]
%         d > 0 : left side
%         d < 0 : right side
%   v   : opponent speed [m/s]

numOpponents = numel(opponents);

if numOpponents < 3
    error("이 demo는 opponent 3대를 기준으로 작성되었습니다.");
end

%% 1. 실행할 때마다 약간 다른 상황이 나오도록 설정
rng("shuffle");

%% 2. 레이싱 상황 시나리오 선택
% 1: compact pack       - 세 차량이 비교적 촘촘히 모여 있음
% 2: two-wide traffic   - 앞쪽에 두 대가 나란히 있고 한 대가 조금 더 앞에 있음
% 3: stretched traffic  - 차량들이 앞쪽에 조금 늘어서 있음

scenarioId = randi(3);

switch scenarioId

    case 1
        scenarioName = "compact_pack";

        % ego 앞쪽에 3대가 촘촘히 모여 있는 상황
        baseGap = [75; 120; 170];       % [m]
        baseD   = [0.0; 1.5; -1.5];     % [m]
        speedOffset = [-9; -6; -3];     % ego보다 느린 정도 [m/s]

    case 2
        scenarioName = "two_wide_traffic";

        % 앞쪽에 두 대가 좌우로 나란히 있고, 한 대가 조금 더 앞에 있는 상황
        baseGap = [95; 125; 210];       % [m]
        baseD   = [-1.4; 1.4; 0.0];     % [m]
        speedOffset = [-8; -7; -2];     % [m/s]

    case 3
        scenarioName = "stretched_traffic";

        % 차량들이 한 줄로 조금 늘어서 있는 상황
        baseGap = [85; 165; 250];       % [m]
        baseD   = [0.0; -1.6; 1.6];     % [m]
        speedOffset = [-10; -5; 0];     % [m/s]
end

%% 3. 너무 규칙적으로 보이지 않도록 작은 랜덤 변동 추가
gapNoiseRange = 12.0;   % [m]
dNoiseRange = 0.25;     % [m]
speedNoiseStd = 1.5;    % [m/s]

for i = 1:3

    % gap은 baseGap 주변에서 약간 변동
    gap = baseGap(i) + gapNoiseRange * (2 * rand() - 1);

    % d는 baseD 주변에서 약간 변동
    d = baseD(i) + dNoiseRange * randn();

    % d가 너무 바깥으로 나가지 않게 제한
    d = min(max(d, -2.2), 2.2);

    % 속도는 ego보다 조금 느리거나 비슷하게 설정
    v = ego.v + speedOffset(i) + speedNoiseStd * randn();

    % 너무 느리거나 너무 빠르지 않게 제한
    v = min(max(v, 45.0), 75.0);

    opponents(i) = resetOpponentForCandidateDemo( ...
        opponents(i), ...
        track, ...
        ego.s + gap, ...
        d, ...
        v);
end

%% 4. opponent 순서를 약간 섞어서 항상 Opponent 1이 lead가 되지는 않게 함
% 단, 위치 자체는 그대로 유지된다.
% generateCandidateActions 내부의 findLeadOpponentForDecision이 실제 앞차를 다시 찾는다.
shuffleIdx = randperm(3);
opponents(1:3) = opponents(shuffleIdx);

end

function selectedActionName = selectCandidateForAnimation(candidates)
% selectCandidateForAnimation
% 애니메이션으로 확인할 candidate를 자동 선택한다.
%
% 현재는 cost-based decision 전 단계이므로,
% valid candidate 중 우선순위에 따라 선택한다.
%
% 우선순위:
%   1. OVERTAKE_INSIDE
%   2. OVERTAKE_OUTSIDE
%   3. MAINTAIN_LINE
%   4. RETURN_TO_LINE

candidateNames = string({candidates.name});
candidateValid = [candidates.isValid];

priorityList = [ ...
    "OVERTAKE_INSIDE", ...
    "OVERTAKE_OUTSIDE", ...
    "MAINTAIN_LINE", ...
    "RETURN_TO_LINE"];

for i = 1:numel(priorityList)

    actionName = priorityList(i);

    idx = find(candidateNames == actionName & candidateValid, 1);

    if ~isempty(idx)
        selectedActionName = actionName;

        fprintf("\n=== Selected Candidate for Animation ===\n");
        fprintf("Selected action: %s\n", selectedActionName);
        fprintf("Reason: first valid action based on priority list\n");

        return;
    end
end

% 모든 후보가 invalid라면 디버깅 목적으로 첫 번째 후보를 표시
selectedActionName = candidateNames(1);

warning("모든 candidate가 invalid입니다. 디버깅을 위해 첫 번째 candidate를 애니메이션으로 표시합니다: %s", ...
    selectedActionName);

end