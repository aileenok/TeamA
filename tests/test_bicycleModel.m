% test_bicycleModel.m
% 운동학적 자전거 모델의 기본 동작을 확인하기 위한 테스트입니다.

clear; clc; close all;

project_startup;

vehicle = vehicleParams();
model = createBicycleModel(vehicle);

x0 = [0; 0; 0];
tFinal = 5.0;
dt = 0.01;
speed = 10.0;

%% Test 1: 조향각이 0일 때 직진 주행 테스트
inputStraight = [speed; 0.0];
[~, statesStraight] = simulateBicycleModel(model, x0, inputStraight, tFinal, dt);

finalY = statesStraight(end,2);

fprintf('\nTest 1: Straight driving\n');
fprintf('Final y position: %.6f m\n', finalY);

if abs(finalY) < 1e-6
    fprintf('PASS: Vehicle drives straight when steering angle is zero.\n');
else
    fprintf('FAIL: Vehicle does not drive straight.\n');
end

%% Test 2: 조향각이 0이 아닐 때 곡선 주행 테스트
inputTurn = [speed; deg2rad(10)];
[~, statesTurn] = simulateBicycleModel(model, x0, inputTurn, tFinal, dt);

finalYTurn = statesTurn(end,2);

fprintf('\nTest 2: Curved driving\n');
fprintf('Final y position: %.6f m\n', finalYTurn);

if abs(finalYTurn) > 1e-3
    fprintf('PASS: Vehicle turns when steering angle is nonzero.\n');
else
    fprintf('FAIL: Vehicle did not turn sufficiently.\n');
end

%% 두 주행 궤적을 함께 그래프로 표시
figure;
plot(statesStraight(:,1), statesStraight(:,2), 'LineWidth', 2);
hold on;
plot(statesTurn(:,1), statesTurn(:,2), 'LineWidth', 2);
grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');
title('Bicycle Model Test: Straight vs Turning');
legend('Straight input', 'Turning input', 'Location', 'best');