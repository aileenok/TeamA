function animateCandidateAction2D(track, ego, opponents, candidates, selectedActionName, saveGif)
% animateCandidateAction2D
% 특정 candidate action 하나를 선택했다고 가정하고,
% ego와 opponent 차량들이 prediction horizon 동안 어떻게 움직이는지 애니메이션으로 보여준다.
%
% Action set:
%   1. MAINTAIN_LINE
%   2. OVERTAKE_INSIDE
%   3. OVERTAKE_OUTSIDE
%   4. RETURN_TO_LINE
%
% 사용 예:
%   animateCandidateAction2D(track, ego, opponents, candidates, "OVERTAKE_INSIDE", false);
%   animateCandidateAction2D(track, ego, opponents, candidates, "MAINTAIN_LINE", true);

arguments
    track struct
    ego struct
    opponents struct
    candidates struct
    selectedActionName string
    saveGif (1,1) logical = false
end

% row/column 구조체 배열 모두 처리 가능하게 정리
opponents = opponents(:);
candidates = candidates(:);

selectedActionName = string(selectedActionName);

%% 1. 선택한 candidate 찾기
candidateNames = string({candidates.name});
selectedIdx = find(candidateNames == selectedActionName, 1);

if isempty(selectedIdx)
    error("선택한 candidate action을 찾을 수 없습니다: %s", selectedActionName);
end

selected = candidates(selectedIdx);

if ~selected.isValid
    warning("선택한 candidate는 invalid입니다. 이유: %s", selected.reason);
end

t = selected.time(:);
numFrames = length(t);
numOpponents = numel(opponents);

% 실제 simulation time과 비슷한 속도로 재생하기 위한 delay
if numFrames >= 2
    playbackDelay = mean(diff(t));
else
    playbackDelay = 0.10;
end

%% 2. opponent 미래 위치 예측
% candidate collision check와 동일하게,
% opponent는 현재 속도와 현재 d를 유지한다고 가정한다.

oppPredX = zeros(numFrames, numOpponents);
oppPredY = zeros(numFrames, numOpponents);
oppPredS = zeros(numFrames, numOpponents);
oppPredD = zeros(numFrames, numOpponents);

for i = 1:numOpponents
    for k = 1:numFrames

        oppPredS(k,i) = mod(opponents(i).s + opponents(i).v * t(k), track.length);
        oppPredD(k,i) = opponents(i).d;

        xy = frenetToGlobalCustom(track, oppPredS(k,i), oppPredD(k,i));

        oppPredX(k,i) = xy(1);
        oppPredY(k,i) = xy(2);
    end
end

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

%% 4. 전체 candidate 후보를 참고용으로 표시
for i = 1:numel(candidates)

    if candidates(i).isValid
        lineStyle = '-';
        validityText = " valid";
    else
        lineStyle = '--';
        validityText = " invalid";
    end

    if i == selectedIdx
        lineWidth = 3.0;
        displayName = candidates(i).name + " selected";
    else
        lineWidth = 1.2;
        displayName = candidates(i).name + validityText;
    end

    plot(candidates(i).x, candidates(i).y, ...
        lineStyle, ...
        'LineWidth', lineWidth, ...
        'DisplayName', displayName);
end

%% 5. 애니메이션 객체 생성

% ego 현재 위치 marker
egoMarker = plot(selected.x(1), selected.y(1), ...
    'mo', 'MarkerSize', 10, 'LineWidth', 2.5, ...
    'DisplayName', 'Ego moving');

egoTrail = plot(selected.x(1), selected.y(1), ...
    'm-', 'LineWidth', 2.0, ...
    'DisplayName', 'Ego executed path');

% opponent marker와 trail
oppMarker = gobjects(numOpponents, 1);
oppTrail = gobjects(numOpponents, 1);

for i = 1:numOpponents

    oppTrail(i) = plot(oppPredX(1,i), oppPredY(1,i), ...
        '-', 'LineWidth', 1.5, ...
        'DisplayName', opponents(i).name + " predicted path");

    trailColor = oppTrail(i).Color;

    oppMarker(i) = plot(oppPredX(1,i), oppPredY(1,i), ...
        'o', 'MarkerSize', 8, 'LineWidth', 2.0, ...
        'Color', trailColor, ...
        'DisplayName', opponents(i).name);
end

%% 6. 화면 설정
grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');

title(sprintf('Candidate Rollout Animation: %s', selectedActionName), ...
    'Interpreter', 'none');

% ego 주변 후보 경로가 잘 보이도록 확대
allX = [ego.position(1); selected.x(:); oppPredX(:)];
allY = [ego.position(2); selected.y(:); oppPredY(:)];

% 참고용 candidate line도 화면 안에 들어오도록 포함
for i = 1:numel(candidates)
    allX = [allX; candidates(i).x(:)];
    allY = [allY; candidates(i).y(:)];
end

margin = 80;  % [m]

xlim([min(allX) - margin, max(allX) + margin]);
ylim([min(allY) - margin, max(allY) + margin]);

legend('Location', 'bestoutside', 'Interpreter', 'none');

%% 7. GIF 저장 설정
if saveGif

    resultFolder = fullfile("data", "results", "animations");

    if ~isfolder(resultFolder)
        mkdir(resultFolder);
    end

    safeActionName = regexprep(selectedActionName, '[^a-zA-Z0-9_]', '_');
    gifFile = fullfile(resultFolder, "Monza_candidate_" + safeActionName + ".gif");

    if isfile(gifFile)
        delete(gifFile);
    end
end

%% 8. 프레임별 업데이트
for k = 1:numFrames

    % ego update
    set(egoMarker, ...
        'XData', selected.x(k), ...
        'YData', selected.y(k));

    set(egoTrail, ...
        'XData', selected.x(1:k), ...
        'YData', selected.y(1:k));

    % opponent update
    for i = 1:numOpponents

        set(oppMarker(i), ...
            'XData', oppPredX(k,i), ...
            'YData', oppPredY(k,i));

        set(oppTrail(i), ...
            'XData', oppPredX(1:k,i), ...
            'YData', oppPredY(1:k,i));
    end

    title(sprintf('Candidate Rollout: %s | t = %.2f s', ...
        selectedActionName, t(k)), ...
        'Interpreter', 'none');

    drawnow;
    pause(playbackDelay);

    %% GIF 저장
    if saveGif

        frame = getframe(gcf);
        imageData = frame2im(frame);
        [indexedImage, colorMap] = rgb2ind(imageData, 256);

        if k == 1
            imwrite(indexedImage, colorMap, gifFile, 'gif', ...
                'LoopCount', inf, ...
                'DelayTime', playbackDelay);
        else
            imwrite(indexedImage, colorMap, gifFile, 'gif', ...
                'WriteMode', 'append', ...
                'DelayTime', playbackDelay);
        end
    end
end

if saveGif
    fprintf("\nCandidate rollout GIF saved: %s\n", gifFile);
end

end