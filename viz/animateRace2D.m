function animateRace2D(track, ego, opponents, time, saveGif)
% animateRace2D
% ego 차량과 opponent 차량들의 주행 결과를 2D 애니메이션으로 표시하는 함수
%
% 입력:
%   track     : 전처리된 트랙 구조체
%   ego       : ego 차량 구조체
%   opponents : opponent 차량 구조체 배열
%   time      : 시간 벡터
%   saveGif   : GIF 저장 여부 true/false
%
% 사용 예:
%   animateRace2D(track, ego, opponents, time(:), false);
%   animateRace2D(track, ego, opponents, time(:), true);

arguments
    track struct
    ego struct
    opponents (:,1) struct
    time (:,1) double
    saveGif (1,1) logical = false
end

%% 1. 기본 확인
if ~isfield(track, "leftBoundary") || ~isfield(track, "rightBoundary") || ~isfield(track, "center")
    error("track에는 leftBoundary, rightBoundary, center 필드가 필요합니다.");
end

if ~isfield(ego, "history")
    error("ego.history가 필요합니다.");
end

numOpponents = numel(opponents);

%% 2. 전체 프레임 수 계산
% time 길이와 차량 history 길이가 다를 수 있으므로 가장 긴 history 기준으로 계산
maxHistoryLength = length(ego.history.x);

for i = 1:numOpponents
    maxHistoryLength = max(maxHistoryLength, length(opponents(i).history.x));
end

numFrames = min(length(time), maxHistoryLength);

% GIF 파일이 너무 커지는 것을 방지하기 위해 프레임 수를 적당히 줄임
% 전체 프레임이 많으면 약 500프레임 이하로 저장/재생
frameSkip = max(1, floor(numFrames / 500));

%% 3. Figure 생성
figure;
hold on;

% 트랙 그리기
plot(track.leftBoundary(:,1), track.leftBoundary(:,2), ...
    'b-', 'LineWidth', 1.0, 'DisplayName', 'Left boundary');

plot(track.rightBoundary(:,1), track.rightBoundary(:,2), ...
    'r-', 'LineWidth', 1.0, 'DisplayName', 'Right boundary');

plot(track.center(:,1), track.center(:,2), ...
    'k--', 'LineWidth', 1.0, 'DisplayName', 'Centerline');

grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');
title('2D Race Animation');

% 축 범위를 고정해서 애니메이션 중 화면이 흔들리지 않게 함
allX = [track.leftBoundary(:,1); track.rightBoundary(:,1); track.center(:,1)];
allY = [track.leftBoundary(:,2); track.rightBoundary(:,2); track.center(:,2)];

margin = 50;
xlim([min(allX)-margin, max(allX)+margin]);
ylim([min(allY)-margin, max(allY)+margin]);

%% 4. 애니메이션 객체 생성

% ego 궤적과 현재 위치
egoTrail = plot(NaN, NaN, 'm-', ...
    'LineWidth', 2.0, 'DisplayName', 'Ego trajectory');

egoMarker = plot(NaN, NaN, 'mo', ...
    'MarkerSize', 9, 'LineWidth', 2, 'DisplayName', 'Ego');

% opponent 궤적과 현재 위치
oppTrail = gobjects(numOpponents, 1);
oppMarker = gobjects(numOpponents, 1);

for i = 1:numOpponents
    oppTrail(i) = plot(NaN, NaN, '-', ...
        'LineWidth', 1.5, ...
        'DisplayName', opponents(i).name + " trajectory");

    trailColor = oppTrail(i).Color;

    oppMarker(i) = plot(NaN, NaN, 'o', ...
        'MarkerSize', 8, ...
        'LineWidth', 2, ...
        'Color', trailColor, ...
        'DisplayName', opponents(i).name);
end

legend('Location', 'bestoutside');

%% 5. GIF 저장 설정
if saveGif
    resultFolder = fullfile("data", "results", "animations");

    if ~isfolder(resultFolder)
        mkdir(resultFolder);
    end

    gifFile = fullfile(resultFolder, "Monza_race_animation.gif");

    % 기존 파일이 있으면 덮어쓰기
    if isfile(gifFile)
        delete(gifFile);
    end
end

%% 6. 프레임별 업데이트
for k = 1:frameSkip:numFrames

    % ego가 먼저 완주해서 history가 짧을 수 있으므로 마지막 index로 고정
    egoIdx = min(k, length(ego.history.x));

    set(egoTrail, ...
        'XData', ego.history.x(1:egoIdx), ...
        'YData', ego.history.y(1:egoIdx));

    set(egoMarker, ...
        'XData', ego.history.x(egoIdx), ...
        'YData', ego.history.y(egoIdx));

    % opponent 업데이트
    for i = 1:numOpponents
        oppIdx = min(k, length(opponents(i).history.x));

        set(oppTrail(i), ...
            'XData', opponents(i).history.x(1:oppIdx), ...
            'YData', opponents(i).history.y(1:oppIdx));

        set(oppMarker(i), ...
            'XData', opponents(i).history.x(oppIdx), ...
            'YData', opponents(i).history.y(oppIdx));
    end

    title(sprintf('2D Race Animation | t = %.2f s', time(k)));

    drawnow;

    %% GIF 저장
    if saveGif
        frame = getframe(gcf);
        imageData = frame2im(frame);
        [indexedImage, colorMap] = rgb2ind(imageData, 256);

        if k == 1
            imwrite(indexedImage, colorMap, gifFile, 'gif', ...
                'LoopCount', inf, ...
                'DelayTime', 0.03);
        else
            imwrite(indexedImage, colorMap, gifFile, 'gif', ...
                'WriteMode', 'append', ...
                'DelayTime', 0.03);
        end
    end
end

%% 7. 마지막 프레임 한 번 더 표시
% frameSkip 때문에 마지막 시점이 누락될 수 있어서 마지막 프레임을 강제로 표시
k = numFrames;

egoIdx = min(k, length(ego.history.x));

set(egoTrail, ...
    'XData', ego.history.x(1:egoIdx), ...
    'YData', ego.history.y(1:egoIdx));

set(egoMarker, ...
    'XData', ego.history.x(egoIdx), ...
    'YData', ego.history.y(egoIdx));

for i = 1:numOpponents
    oppIdx = min(k, length(opponents(i).history.x));

    set(oppTrail(i), ...
        'XData', opponents(i).history.x(1:oppIdx), ...
        'YData', opponents(i).history.y(1:oppIdx));

    set(oppMarker(i), ...
        'XData', opponents(i).history.x(oppIdx), ...
        'YData', opponents(i).history.y(oppIdx));
end

title(sprintf('2D Race Animation | t = %.2f s', time(k)));
drawnow;

if saveGif
    fprintf("\nRace animation saved: %s\n", gifFile);
end

end