function plotCandidateActions(track, ego, opponents, candidates)
% plotCandidateActions
% ego 후보 행동 경로들을 트랙 위에 시각화한다.
%
% Action set:
%   1. MAINTAIN_LINE
%   2. OVERTAKE_INSIDE
%   3. OVERTAKE_OUTSIDE
%   4. RETURN_TO_LINE

arguments
    track struct
    ego struct
    opponents struct
    candidates struct
end

% row/column 구조체 배열 모두 처리 가능하게 정리
opponents = opponents(:);
candidates = candidates(:);

figure;
hold on;

%% 1. 트랙 표시
plot(track.leftBoundary(:,1), track.leftBoundary(:,2), ...
    'b-', 'LineWidth', 1.0, 'DisplayName', 'Left boundary');

plot(track.rightBoundary(:,1), track.rightBoundary(:,2), ...
    'r-', 'LineWidth', 1.0, 'DisplayName', 'Right boundary');

plot(track.center(:,1), track.center(:,2), ...
    'k--', 'LineWidth', 1.0, 'DisplayName', 'Centerline');

%% 2. ego 표시
plot(ego.position(1), ego.position(2), ...
    'mo', 'MarkerSize', 10, 'LineWidth', 2.0, ...
    'DisplayName', 'Ego');

text(ego.position(1), ego.position(2), ...
    "  Ego", 'FontSize', 10);

%% 3. opponent 표시
for i = 1:numel(opponents)

    plot(opponents(i).position(1), opponents(i).position(2), ...
        'ko', 'MarkerSize', 8, 'LineWidth', 1.5, ...
        'DisplayName', opponents(i).name);

    text(opponents(i).position(1), opponents(i).position(2), ...
        "  " + opponents(i).name, 'FontSize', 9);
end

%% 4. candidate trajectory 표시
for i = 1:numel(candidates)

    if candidates(i).isValid
        lineStyle = '-';
        displayName = candidates(i).name + " valid";
    else
        lineStyle = '--';
        displayName = candidates(i).name + " invalid";
    end

    plot(candidates(i).x, candidates(i).y, ...
        lineStyle, 'LineWidth', 2.0, ...
        'DisplayName', displayName);

    % candidate 끝점 표시
    plot(candidates(i).x(end), candidates(i).y(end), ...
        'x', 'MarkerSize', 9, 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');
end

%% 5. figure 설정
grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');
title('Candidate Actions for Ego Vehicle');

%% 6. ego 주변 확대
% 전체 Monza를 다 보이면 candidate 경로 차이가 거의 안 보이므로,
% candidate 검증용 figure에서는 ego 주변을 확대한다.

allX = ego.position(1);
allY = ego.position(2);

for i = 1:numel(opponents)
    allX = [allX; opponents(i).position(1)];
    allY = [allY; opponents(i).position(2)];
end

for i = 1:numel(candidates)
    allX = [allX; candidates(i).x(:)];
    allY = [allY; candidates(i).y(:)];
end

margin = 80;  % [m]

xlim([min(allX) - margin, max(allX) + margin]);
ylim([min(allY) - margin, max(allY) + margin]);

legend('Location', 'bestoutside', 'Interpreter', 'none');

end