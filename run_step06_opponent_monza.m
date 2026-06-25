% run_step06_opponent_monza.m
% Monza 트랙 위에서 opponent car들이 일정 속도로 주행하는지 확인하는 스크립트

clear; clc; close all;

project_startup;

%% 1. processed track 불러오기
processedFile = fullfile("data", "processed_tracks", "Monza_processed.mat");

if ~isfile(processedFile)
    error("Monza_processed.mat 파일을 찾을 수 없습니다: %s", processedFile);
end

data = load(processedFile);
track = data.track;

%% 2. opponent 설정 불러오기
oppParams = opponentParams(track);

%% 3. opponent 차량 생성
opponents = updateOpponentFleet(opponents, track, dt, oppParams);

%% 4. 시뮬레이션 설정
dt = 0.05;          % [s]
tFinal = 20.0;      % [s]
time = 0:dt:tFinal;

%% 5. opponent 차량 업데이트
for k = 2:length(time)
    opponents = updateOpponentFleet(opponents, track, dt);
end

%% 6. 결과 출력
fprintf("\n=== Opponent Car Simulation Result ===\n");
fprintf("Track name: %s\n", track.name);
fprintf("Simulation time: %.2f s\n", tFinal);
fprintf("Time step: %.3f s\n", dt);
fprintf("Number of opponents: %d\n", numel(opponents));

for i = 1:numel(opponents)
    fprintf("\n%s\n", opponents(i).name);
    fprintf("  Final s: %.2f m\n", opponents(i).s);
    fprintf("  Final d: %.2f m\n", opponents(i).d);
    fprintf("  Speed: %.2f m/s (%.2f km/h)\n", ...
        opponents(i).v, opponents(i).v * 3.6);
    fprintf("  Final x: %.2f m\n", opponents(i).position(1));
    fprintf("  Final y: %.2f m\n", opponents(i).position(2));
end

%% 7. 시각화
plotOpponentCars(track, opponents);

%% 8. 결과 저장
resultFolder = fullfile("data", "results");

if ~isfolder(resultFolder)
    mkdir(resultFolder);
end

resultFile = fullfile(resultFolder, "Monza_opponent_demo.mat");

save(resultFile, "track", "oppParams", "opponents", "time");

fprintf("\n=== Opponent Demo Saved ===\n");
fprintf("Saved file: %s\n", resultFile);