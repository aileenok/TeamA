% run_single_car_baseline.m
% Monza 트랙에서 single-car centerline baseline velocity profile과 lap time 계산

clear; clc; close all;

project_startup;

%% 1. processed track 불러오기
processedFile = fullfile("data", "processed_tracks", "Monza_processed.mat");

if ~isfile(processedFile)
    error("Monza_processed.mat 파일을 찾을 수 없습니다: %s", processedFile);
end

data = load(processedFile);
track = data.track;

%% 2. 차량 파라미터 불러오기
vehicle = vehicleParams("race"); %% 검증용 모드는 "conservative"

%% 3. velocity profile 계산
speedProfile = velocityProfile(track, vehicle);

%% 4. lap time 계산
lapTime = computeLapTime(speedProfile);

%% 5. 결과 출력
fprintf("\n=== Single-Car Baseline Result ===\n");
fprintf("Track name: %s\n", track.name);
fprintf("Track length: %.2f m\n", track.length);
fprintf("Lap time: %.2f s\n", lapTime);
fprintf("Lap time: %.2f min\n", lapTime / 60);
fprintf("Max speed: %.2f m/s (%.2f km/h)\n", ...
    max(speedProfile.v), max(speedProfile.v) * 3.6);
fprintf("Min speed: %.2f m/s (%.2f km/h)\n", ...
    min(speedProfile.v), min(speedProfile.v) * 3.6);
fprintf("Mean speed: %.2f m/s (%.2f km/h)\n", ...
    mean(speedProfile.v), mean(speedProfile.v) * 3.6);

%% 6. 결과 시각화
plotTrack(track);

% curvatureForVelocity가 있으면 그것을 plot하고,
% 없으면 기본 curvature를 사용
if isfield(track, "curvatureForVelocity")
    plotCurvature(track.s, track.curvatureForVelocity, track.name);
else
    plotCurvature(track.s, track.curvature, track.name);
end

plotVelocityProfile(speedProfile, track.name);

%% 6-1. velocity profile 기반 차량 애니메이션
animateVelocityProfile(track, speedProfile, track.name);

%% 7. 결과 저장
resultFolder = fullfile("data", "results");

if ~isfolder(resultFolder)
    mkdir(resultFolder);
end

resultFile = fullfile(resultFolder, "Monza_single_car_baseline.mat");

save(resultFile, "track", "vehicle", "speedProfile", "lapTime");

fprintf("\n=== Baseline Result Saved ===\n");
fprintf("Saved file: %s\n", resultFile);

%% 안전성 검증
tolerance = 1e-6;

if all(speedProfile.v <= speedProfile.vCurve + tolerance)
    fprintf("PASS: 최종 속도가 곡률 기반 제한 속도를 넘지 않습니다.\n");
else
    warning("일부 구간에서 최종 속도가 곡률 기반 제한 속도를 초과했습니다.");
end

if all(speedProfile.v <= vehicle.maxSpeed + tolerance)
    fprintf("PASS: 최종 속도가 차량 최고속도를 넘지 않습니다.\n");
else
    warning("최종 속도가 vehicle.maxSpeed를 초과했습니다.");
end

% 횡가속도 검증
lateralAccel = speedProfile.v.^2 .* abs(speedProfile.kappa);
lateralLimit = vehicle.mu * vehicle.g;

fprintf("Max lateral acceleration: %.2f m/s^2\n", max(lateralAccel));
fprintf("Lateral acceleration limit: %.2f m/s^2\n", lateralLimit);

if all(lateralAccel <= lateralLimit + tolerance)
    fprintf("PASS: 횡가속도가 마찰 한계 안에 있습니다.\n");
else
    warning("일부 구간에서 횡가속도가 마찰 한계를 초과했습니다.");
end