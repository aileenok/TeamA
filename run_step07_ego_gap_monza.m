% run_step07_ego_gap_monza.m
% ego 차량과 opponent 차량을 함께 주행시키고 가장 가까운 앞차를 찾는 스크립트

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
oppParams = opponentParams(track);
race = raceParams();

%% 3. 차량 생성
ego = createEgoCar(track, race);
opponents = createOpponentFleet(track, oppParams);

%% 4. 시뮬레이션 설정
dt = race.dt;

leadLog.time = [];
leadLog.hasLead = [];
leadLog.leadIndex = [];
leadLog.gap = [];
leadLog.relativeSpeed = [];

%% 5. 시뮬레이션 실행
% 레이스 종료 조건 기반 시뮬레이션
dt = race.dt;
currentTime = 0.0;

time = currentTime;

while currentTime < race.maxTime

    %% 모든 차량이 완주했는지 확인
    allOpponentsFinished = all([opponents.hasFinished]);
    allCarsFinished = ego.hasFinished && allOpponentsFinished;

    if allCarsFinished
        break;
    end

    %% 현재 시점에서 가장 가까운 앞차 찾기
    leadInfo = findLeadOpponent(ego, opponents, track, race.lookAheadDistance);

    leadLog.time(end+1,1) = currentTime;
    leadLog.hasLead(end+1,1) = leadInfo.hasLead;
    leadLog.leadIndex(end+1,1) = leadInfo.leadIndex;
    leadLog.gap(end+1,1) = leadInfo.gap;
    leadLog.relativeSpeed(end+1,1) = leadInfo.relativeSpeed;

    %% 시간 업데이트
    currentTime = currentTime + dt;

    %% 차량 상태 업데이트
    ego = updateEgoState(ego, track, dt, currentTime, race.targetLaps);

    opponents = updateOpponentFleet( ...
        opponents, track, dt, oppParams, currentTime, race.targetLaps);

    time(end+1,1) = currentTime;
end

%% 6. 최종 앞차 정보 출력
fprintf("\n=== Race Finish Result ===\n");
fprintf("Target laps: %d\n", race.targetLaps);
fprintf("Total simulation time: %.2f s\n", currentTime);

fprintf("\nEgo:\n");
fprintf("  Finished: %d\n", ego.hasFinished);
fprintf("  Finish time: %.2f s\n", ego.finishTime);
fprintf("  Completed laps: %d\n", ego.completedLaps);

for i = 1:numel(opponents)
    fprintf("\n%s:\n", opponents(i).name);
    fprintf("  Finished: %d\n", opponents(i).hasFinished);
    fprintf("  Finish time: %.2f s\n", opponents(i).finishTime);
    fprintf("  Completed laps: %d\n", opponents(i).completedLaps);
end

%% 7. 시각화
plotRaceCars(track, ego, opponents);

%% 8. gap plot
figure;
plot(leadLog.time, leadLog.gap, 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Gap to lead opponent [m]');
title('Gap to Lead Opponent');

yline(race.safeGap, 'r--', 'Safe gap');

%% 9. 결과 저장
resultFolder = fullfile("data", "results");

if ~isfolder(resultFolder)
    mkdir(resultFolder);
end

resultFile = fullfile(resultFolder, "Monza_ego_gap_demo.mat");

save(resultFile, "track", "ego", "opponents", "race", "oppParams", "leadLog");

fprintf("\n=== Ego Gap Demo Saved ===\n");
fprintf("Saved file: %s\n", resultFile);

%% 애니메이션 GIF 저장
animateRace2D(track, ego, opponents, time(:), true);