function sim = simParams()
% simParams
% Simulation parameters for the bicycle model test.

sim.tFinal = 10.0;     % [s] total simulation time (주행 시간)
sim.dt = 0.01;         % [s] simulation time step

% Initial vehicle state: [x; y; theta]
sim.x0 = [0; 0; 0];

% Test input: [velocity; steering angle]
sim.testSpeed = 10.0;              % [m/s]
sim.testSteer = deg2rad(10);       % [rad]

end