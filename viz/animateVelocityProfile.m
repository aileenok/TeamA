function animateVelocityProfile(track, speedProfile, trackName)
% animateVelocityProfile
% velocity profile을 따라 차량이 트랙 위를 주행하는 애니메이션을 표시하는 함수
%
% 입력:
%   track        : 전처리된 트랙 구조체
%                  필요한 필드:
%                  - track.s
%                  - track.center
%                  - track.leftBoundary
%                  - track.rightBoundary
%                  - track.length
%
%   speedProfile : velocityProfile 함수의 출력 구조체
%                  필요한 필드:
%                  - speedProfile.s
%                  - speedProfile.v
%
%   trackName    : 트랙 이름

arguments
    track struct
    speedProfile struct
    trackName string = "Track"
end

%% 기본 데이터
sProfile = speedProfile.s(:);
vProfile = speedProfile.v(:);

trackS = track.s(:);
centerX = track.center(:,1);
centerY = track.center(:,2);

lapLength = track.length;

%% 애니메이션 설정
dt = 0.05;          % 시간 간격 [s]
sCurrent = 0;       % 현재 진행 거리 [m]
timeCurrent = 0;    % 현재 시간 [s]

% 너무 촘촘하게 그리면 느릴 수 있으므로 필요 시 조정
pauseTime = 0.001;

%% Figure 설정
figure;

plot(track.leftBoundary(:,1), track.leftBoundary(:,2), 'k', 'LineWidth', 1.0);
hold on;
plot(track.rightBoundary(:,1), track.rightBoundary(:,2), 'k', 'LineWidth', 1.0);
plot(track.center(:,1), track.center(:,2), '--', 'LineWidth', 0.8);

axis equal;
grid on;
xlabel('x [m]');
ylabel('y [m]');
title("Velocity Profile Animation: " + trackName);

%% 초기 차량 위치
xCurrent = interp1(trackS, centerX, sCurrent, 'linear', 'extrap');
yCurrent = interp1(trackS, centerY, sCurrent, 'linear', 'extrap');

carMarker = plot(xCurrent, yCurrent, 'ro', ...
    'MarkerSize', 8, ...
    'MarkerFaceColor', 'r');

infoText = title(sprintf( ...
    "%s | t = %.2f s | s = %.1f / %.1f m | v = %.1f m/s (%.1f km/h)", ...
    trackName, timeCurrent, sCurrent, lapLength, 0, 0));

%% 애니메이션 루프
while sCurrent < lapLength

    % 현재 s 위치에서 velocity profile 보간
    vCurrent = interp1(sProfile, vProfile, sCurrent, 'linear', 'extrap');

    % s 업데이트: s(k+1) = s(k) + v(s) * dt
    sCurrent = sCurrent + vCurrent * dt;
    timeCurrent = timeCurrent + dt;

    if sCurrent > lapLength
        sCurrent = lapLength;
    end

    % 현재 s에 해당하는 x, y 좌표 보간
    xCurrent = interp1(trackS, centerX, sCurrent, 'linear', 'extrap');
    yCurrent = interp1(trackS, centerY, sCurrent, 'linear', 'extrap');

    % 차량 위치 업데이트
    set(carMarker, 'XData', xCurrent, 'YData', yCurrent);

    % 제목 업데이트
    set(infoText, 'String', sprintf( ...
        "%s | t = %.2f s | s = %.1f / %.1f m | v = %.1f m/s (%.1f km/h)", ...
        trackName, timeCurrent, sCurrent, lapLength, vCurrent, vCurrent * 3.6));

    drawnow;
    pause(pauseTime);
end

fprintf("\n=== Animation Finished ===\n");
fprintf("Estimated animation lap time: %.2f s\n", timeCurrent);

end