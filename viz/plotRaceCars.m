function plotRaceCars(track, ego, opponents)
% plotRaceCars
% ego 차량과 opponent 차량들의 이동 궤적을 함께 표시하는 함수

arguments
    track struct
    ego struct
    opponents (:,1) struct
end

figure;
hold on;

%% 1. 트랙 표시
plot(track.leftBoundary(:,1), track.leftBoundary(:,2), 'b-', 'LineWidth', 1.0);
plot(track.rightBoundary(:,1), track.rightBoundary(:,2), 'r-', 'LineWidth', 1.0);
plot(track.center(:,1), track.center(:,2), 'k--', 'LineWidth', 1.0);

%% 2. ego 궤적 및 현재 위치
plot(ego.history.x, ego.history.y, 'm-', 'LineWidth', 2.0);
plot(ego.position(1), ego.position(2), 'mo', 'MarkerSize', 9, 'LineWidth', 2);
text(ego.position(1), ego.position(2), "  Ego", 'FontSize', 10);

%% 3. opponent 궤적 및 현재 위치
for i = 1:numel(opponents)
    plot(opponents(i).history.x, opponents(i).history.y, 'LineWidth', 1.3);
    plot(opponents(i).position(1), opponents(i).position(2), ...
        'o', 'MarkerSize', 7, 'LineWidth', 1.5);

    text(opponents(i).position(1), opponents(i).position(2), ...
        "  " + opponents(i).name, 'FontSize', 9);
end

grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');
title('Ego and Opponent Cars on Monza Track');

legend('Left boundary', 'Right boundary', 'Centerline', 'Ego trajectory', ...
    'Location', 'best');

end