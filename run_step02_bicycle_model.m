% run_step03_bicycle_model.m
% Step 03: Define and test the kinematic bicycle model.

clear; clc; close all;

project_startup;

vehicle = vehicleParams();
sim = simParams();

model = createBicycleModel(vehicle);

input = [sim.testSpeed; sim.testSteer];

[time, states] = simulateBicycleModel( ...
    model, ...
    sim.x0, ...
    input, ...
    sim.tFinal, ...
    sim.dt);

fprintf('\n=== Bicycle Model Test Result ===\n');
fprintf('Vehicle model: %s\n', model.name);
fprintf('Wheelbase: %.2f m\n', model.wheelbase);
fprintf('Input speed: %.2f m/s\n', input(1));
fprintf('Input steering angle: %.2f deg\n', rad2deg(input(2)));
fprintf('Final x: %.2f m\n', states(end,1));
fprintf('Final y: %.2f m\n', states(end,2));
fprintf('Final heading: %.2f deg\n', rad2deg(states(end,3)));

plotBicycleTrajectory(states, "Step 03: Kinematic Bicycle Model Test");