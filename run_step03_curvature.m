% run_step03_curvature.m
% Monza 트랙의 raw 곡률과 smoothing 곡률을 계산하고 저장하는 스크립트

clear; clc; close all;

project_startup;

%% 1. 트랙 파일 경로 설정
trackFile = fullfile( ...
    "data", ...
    "external", ...
    "tum_racetrack_database", ...
    "tracks", ...
    "Monza.csv");

%% 2. 트랙 로드 및 전처리
track = loadTrack(trackFile, "TUM");

track = preprocessTrack(track);
track = computeTrackNormals(track);
track = computeTrackBoundaries(track);

%% 3. 곡률 계산
smoothWindow = 21;

track = computeCurvature(track, smoothWindow);

%% velocity planning용 곡률 저장
% velocity profile 계산에서는 부호 없는 곡률 크기만 필요
track.curvatureForVelocity = track.curvatureAbs;

%% 4. Smoothed curvature 계산
% smoothing window가 너무 작으면 spike가 많이 남고,
% 너무 크면 코너가 과하게 완만해질 수 있음.
% 현재 그래프 기준으로는 25 정도가 baseline 주행용으로 적절해 보임.
smoothWindow = 25;

trackSmooth = computeCurvature(track, smoothWindow);

%% 5. raw / smooth 곡률을 하나의 track 구조체에 정리해서 저장
track.s = trackSmooth.s;

% raw 곡률: 검증 및 비교용
track.curvatureRaw = trackRaw.curvature;
track.curvatureRawAbs = abs(trackRaw.curvature);
track.curvatureRawRadius = trackRaw.curvatureRadius;

% smoothing 곡률: 주행 안정성 및 velocity profile 계산용
track.curvatureSmooth = trackSmooth.curvature;
track.curvatureSmoothAbs = abs(trackSmooth.curvature);
track.curvatureSmoothRadius = trackSmooth.curvatureRadius;

% 기존 코드 호환용 대표 곡률 필드
% 이후 velocity profile에서는 이 값을 사용하면 됨
track.curvature = track.curvatureSmooth;
track.curvatureAbs = track.curvatureSmoothAbs;
track.curvatureRadius = track.curvatureSmoothRadius;
track.curvatureForVelocity = track.curvatureSmooth;

% 곡률 계산 정보 저장
track.curvatureMethod = trackSmooth.curvatureMethod;
track.curvatureRawSmoothingWindow = rawWindow;
track.curvatureSmoothSmoothingWindow = smoothWindow;

%% 6. 결과 시각화
plotTrack(track);

figure;
plot(track.s, track.curvatureRaw, 'LineWidth', 1.2);
grid on;
xlabel('Track progress s [m]');
ylabel('Raw curvature \kappa [1/m]');
title("Raw Curvature Profile: " + track.name);
yline(0, 'k--');

figure;
plot(track.s, track.curvatureSmooth, 'LineWidth', 1.5);
grid on;
xlabel('Track progress s [m]');
ylabel('Smoothed curvature \kappa [1/m]');
title("Smoothed Curvature Profile: " + track.name);
yline(0, 'k--');

%% 7. processed track 저장
processedFolder = fullfile("data", "processed_tracks");

if ~isfolder(processedFolder)
    mkdir(processedFolder);
end

saveFile = fullfile(processedFolder, "Monza_processed.mat");

save(saveFile, "track");

%% 8. 저장 결과 출력
fprintf("\n=== Monza Curvature Processing Completed ===\n");
fprintf("Saved file: %s\n", saveFile);
fprintf("Track name: %s\n", track.name);
fprintf("Number of points: %d\n", track.numPoints);
fprintf("Track length: %.2f m\n", track.length);

fprintf("\nRaw curvature:\n");
fprintf("  Smoothing window: %d\n", rawWindow);
fprintf("  Max abs curvature: %.5f [1/m]\n", max(track.curvatureRawAbs));
fprintf("  Min radius: %.2f [m]\n", min(track.curvatureRawRadius));

fprintf("\nSmoothed curvature:\n");
fprintf("  Smoothing window: %d\n", smoothWindow);
fprintf("  Max abs curvature: %.5f [1/m]\n", max(track.curvatureSmoothAbs));
fprintf("  Min radius: %.2f [m]\n", min(track.curvatureSmoothRadius));