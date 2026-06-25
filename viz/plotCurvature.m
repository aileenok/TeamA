function plotCurvature(s, kappa, trackName)
% plotCurvature
% 트랙 진행거리 s에 따른 곡률을 시각화하는 함수
%
% 입력:
%   s         : 누적 진행거리 [m]
%   kappa     : 곡률 [1/m]
%   trackName : 트랙 이름

arguments
    s (:,1) double
    kappa (:,1) double
    trackName string = "Track"
end

figure;

plot(s, kappa, 'LineWidth', 1.5);
grid on;

xlabel('Track progress s [m]');
ylabel('Curvature \kappa [1/m]');
title("Curvature Profile: " + trackName);

yline(0, 'k--', 'LineWidth', 1.0);

fprintf('\n=== Curvature Summary ===\n');
fprintf('Track name: %s\n', trackName);
fprintf('Max abs curvature: %.5f [1/m]\n', max(abs(kappa)));
fprintf('Mean abs curvature: %.5f [1/m]\n', mean(abs(kappa)));
fprintf('Min radius: %.2f [m]\n', 1 / max(abs(kappa)));

end