% run_step05_frenet_monza.m
% Monza 트랙 기준 Frenet 좌표계 변환 테스트

clear; clc; close all;

project_startup;

%% 1. processed track 불러오기
processedFile = fullfile("data", "processed_tracks", "Monza_processed.mat");

if ~isfile(processedFile)
    error("Monza_processed.mat 파일을 찾을 수 없습니다: %s", processedFile);
end

data = load(processedFile);
track = data.track;

%% 2. 테스트할 점 선택
% centerline 중간 지점 하나를 선택
testIndex = round(track.numPoints * 0.25);

centerPoint = track.center(testIndex, :);
leftPoint = track.leftBoundary(testIndex, :);
rightPoint = track.rightBoundary(testIndex, :);

%% 3. global -> Frenet 변환
centerFrenet = globalToFrenetCustom(track, centerPoint);
leftFrenet = globalToFrenetCustom(track, leftPoint);
rightFrenet = globalToFrenetCustom(track, rightPoint);

fprintf("\n=== Frenet Conversion Test ===\n");

fprintf("\nCenterline point:\n");
fprintf("  s = %.2f m\n", centerFrenet.s);
fprintf("  d = %.4f m\n", centerFrenet.d);

fprintf("\nLeft boundary point:\n");
fprintf("  s = %.2f m\n", leftFrenet.s);
fprintf("  d = %.4f m\n", leftFrenet.d);

fprintf("\nRight boundary point:\n");
fprintf("  s = %.2f m\n", rightFrenet.s);
fprintf("  d = %.4f m\n", rightFrenet.d);

%% 4. Frenet -> global 변환 테스트
centerRecovered = frenetToGlobalCustom(track, centerFrenet.s, centerFrenet.d);
leftRecovered = frenetToGlobalCustom(track, leftFrenet.s, leftFrenet.d);
rightRecovered = frenetToGlobalCustom(track, rightFrenet.s, rightFrenet.d);

centerError = norm(centerRecovered - centerPoint);
leftError = norm(leftRecovered - leftPoint);
rightError = norm(rightRecovered - rightPoint);

fprintf("\n=== Reconstruction Error ===\n");
fprintf("Centerline reconstruction error: %.6f m\n", centerError);
fprintf("Left boundary reconstruction error: %.6f m\n", leftError);
fprintf("Right boundary reconstruction error: %.6f m\n", rightError);

%% 5. 정상성 판단
fprintf("\n=== Sign Check ===\n");

if abs(centerFrenet.d) < 1e-3
    fprintf("PASS: centerline d is approximately zero.\n");
else
    warning("Centerline d is not close to zero.");
end

if leftFrenet.d > 0
    fprintf("PASS: left boundary has positive d.\n");
else
    warning("Left boundary d is not positive.");
end

if rightFrenet.d < 0
    fprintf("PASS: right boundary has negative d.\n");
else
    warning("Right boundary d is not negative.");
end

%% 6. 시각화
figure;
hold on;

plot(track.leftBoundary(:,1), track.leftBoundary(:,2), 'b-', 'LineWidth', 1.2);
plot(track.rightBoundary(:,1), track.rightBoundary(:,2), 'r-', 'LineWidth', 1.2);
plot(track.center(:,1), track.center(:,2), 'k--', 'LineWidth', 1.2);

plot(centerPoint(1), centerPoint(2), 'ko', 'MarkerSize', 8, 'LineWidth', 2);
plot(leftPoint(1), leftPoint(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);
plot(rightPoint(1), rightPoint(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);

plot(centerRecovered(1), centerRecovered(2), 'kx', 'MarkerSize', 10, 'LineWidth', 2);
plot(leftRecovered(1), leftRecovered(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2);
plot(rightRecovered(1), rightRecovered(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2);

grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');
title('Frenet Conversion Test: Monza');

legend( ...
    'Left boundary', ...
    'Right boundary', ...
    'Centerline', ...
    'Center point', ...
    'Left point', ...
    'Right point', ...
    'Recovered center', ...
    'Recovered left', ...
    'Recovered right', ...
    'Location', 'best');

fprintf("\nFrenet test completed.\n");