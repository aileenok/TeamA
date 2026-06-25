function plotOpponentCars(track, opponents)
% plotOpponentCars
% 트랙 위에 opponent 차량들의 현재 위치와 이동 궤적을 표시하는 함수

arguments
    track struct
    opponents (:,1) struct
end

figure;
hold on;

%% 1. 트랙 표시
if isfield(track, "leftBoundary")
    plot(track.leftBoundary(:,1), track.leftBoundary(:,2), 'b-', 'LineWidth', 1.0);
end

if isfield(track, "rightBoundary")
    plot(track.rightBoundary(:,1), track.rightBoundary(:,2), 'r-', 'LineWidth', 1.0);
end

plot(track.center(:,1), track.center(:,2), 'k--', 'LineWidth', 1.0);

%% 2. opponent 궤적 및 현재 위치 표시
for i = 1:numel(opponents)

    % 이동 궤적
    plot(opponents(i).history.x, opponents(i).history.y, ...
        'LineWidth', 1.5);

    % 현재 위치
    plot(opponents(i).position(1), opponents(i).position(2), ...
        'o', 'MarkerSize', 8, 'LineWidth', 2);

    % 차량 이름 표시
    text(opponents(i).position(1), opponents(i).position(2), ...
        "  " + opponents(i).name, ...
        'FontSize', 10);
end

grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');
title('Opponent Cars on Monza Track');

legend('Left boundary', 'Right boundary', 'Centerline', ...
    'Location', 'best');

end