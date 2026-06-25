function plotBicycleTrajectory(states, plotTitle)
% plotBicycleTrajectory
% Plot the simulated trajectory of the bicycle model.
%
% Input:
%   states    : simulation states, each row is [x, y, theta]
%   plotTitle : figure title

arguments
    states (:,3) double
    plotTitle string = "Bicycle Model Trajectory"
end

figure;
plot(states(:,1), states(:,2), 'LineWidth', 2);
grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');
title(plotTitle);

end