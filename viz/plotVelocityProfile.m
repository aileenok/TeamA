function plotVelocityProfile(speedProfile, trackName)
% plotVelocityProfile
% 트랙 진행거리 s에 따른 속도 profile을 시각화하는 함수
%
% 입력:
%   speedProfile.s      : 트랙 진행거리 [m]
%   speedProfile.vCurve : 곡률만 고려한 최대 속도 [m/s]
%   speedProfile.v      : 가속/감속 제한까지 반영한 최종 속도 [m/s]
%   trackName           : 트랙 이름

arguments
    speedProfile struct
    trackName string = "Track"
end

s = speedProfile.s;
vCurve = speedProfile.vCurve;
v = speedProfile.v;

figure;

plot(s, vCurve, '--', 'LineWidth', 1.0);
hold on;
plot(s, v, 'LineWidth', 1.8);

grid on;

xlabel('Track progress s [m]');
ylabel('Velocity [m/s]');
title("Velocity Profile: " + trackName);

legend('Curvature-limited speed', 'Final velocity profile', ...
    'Location', 'best');

fprintf("\n=== Velocity Profile Summary ===\n");
fprintf("Track name: %s\n", trackName);
fprintf("Max speed: %.2f m/s\n", max(v));
fprintf("Min speed: %.2f m/s\n", min(v));
fprintf("Mean speed: %.2f m/s\n", mean(v));
fprintf("Max speed: %.2f km/h\n", max(v) * 3.6);
fprintf("Min speed: %.2f km/h\n", min(v) * 3.6);
fprintf("Mean speed: %.2f km/h\n", mean(v) * 3.6);

end