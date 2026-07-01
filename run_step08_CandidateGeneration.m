% run_step08_CandidateGeneration.m
% Candidate action generation 테스트 스크립트
%
% 4대 차량(ego + 3 opponents)의 10초 시뮬레이션을 진행하면서
% 매 vizDt마다 후보 궤적을 생성하고 시각화한다.
% 결과를 GIF로 저장한다.
%
% 저장 위치: data/results/animations/CandidateGeneration_10s.gif

clear; clc; close all;

project_startup;

%% ── 1. 전처리된 트랙 로드 ────────────────────────────────────────────────
processedFile = fullfile('data', 'processed_tracks', 'Monza_processed.mat');

if ~isfile(processedFile)
    error('Monza_processed.mat 파일을 찾을 수 없습니다: %s', processedFile);
end

data  = load(processedFile);
track = data.track;

fprintf('Track loaded: Monza  (length = %.1f m)\n', track.length);

%% ── 2. 파라미터 로드 ─────────────────────────────────────────────────────
race = raceParams();
dp   = decisionParams();

%% ── 3. 차량 초기화 ───────────────────────────────────────────────────────
% Ego: s=0, d=0, v=65 m/s  (raceParams 기본값 사용)
ego = createEgoCar(track, race);

% Opponents: ego 전방에 배치
%   Opp1 –  50 m 앞, 센터라인, 55 m/s  (slow, 곧 ego에 따라잡힘)
%   Opp2 – 120 m 앞, 왼쪽 d=+1, 60 m/s
%   Opp3 – 220 m 앞, 오른쪽 d=-1, 50 m/s

oppParams = opponentParams(track);

% 테스트용 위치 및 속도 직접 지정
oppParams.initialS    = [50;  120;  220];
oppParams.initialD    = [ 0;    1;   -1];
oppParams.speed       = [55;   60;   50];
oppParams.behaviorType = ["constant"; "constant"; "constant"];

opponents = createOpponentFleet(track, oppParams);

fprintf('Vehicles created: ego + %d opponents\n', numel(opponents));

%% ── 4. 시뮬레이션 설정 ───────────────────────────────────────────────────
simDt  = race.dt;   % 0.05 s
tEnd   = 10.0;      % [s]  테스트 시간
vizDt  = 0.1;       % [s]  시각화 / 후보 생성 주기
vizInterval = round(vizDt / simDt);

tVec = (0 : simDt : tEnd)';
numSteps = numel(tVec);

%% ── 5. Figure 초기화 ─────────────────────────────────────────────────────
fig = figure('Position', [100 100 1000 750], 'Color', 'w');
hold on;
axis equal;
grid on;

% 트랙 경계 및 센터라인
plot(track.leftBoundary(:,1),  track.leftBoundary(:,2),  'b-',  'LineWidth', 1.2, ...
    'DisplayName', 'Left boundary');
plot(track.rightBoundary(:,1), track.rightBoundary(:,2), 'r-',  'LineWidth', 1.2, ...
    'DisplayName', 'Right boundary');
plot(track.center(:,1),        track.center(:,2),         'k--', 'LineWidth', 0.8, ...
    'DisplayName', 'Centreline');

% 축 범위 고정
allX = [track.leftBoundary(:,1); track.rightBoundary(:,1)];
allY = [track.leftBoundary(:,2); track.rightBoundary(:,2)];
pad  = 80;
xlim([min(allX)-pad, max(allX)+pad]);
ylim([min(allY)-pad, max(allY)+pad]);

xlabel('x [m]');  ylabel('y [m]');

%% ── 후보 라인 핸들 ─────────────────────────────────────────────────────
% valid candidate  (실선, 채도 있는 색)
candColorValid   = {[0.1 0.7 0.1], [0.1 0.3 0.9], [0.8 0.1 0.8], [0.0 0.7 0.7]};
% invalid candidate (파선, 회색)
candColorInvalid = {[0.7 0.7 0.7], [0.7 0.7 0.7], [0.7 0.7 0.7], [0.7 0.7 0.7]};

candLabels = {'maintain\_line', 'overtake\_inside', 'overtake\_outside', 'return\_to\_line'};

hCandValid   = gobjects(4, 1);
hCandInvalid = gobjects(4, 1);

for i = 1:4
    hCandValid(i) = plot(NaN, NaN, '-', ...
        'Color', candColorValid{i}, 'LineWidth', 2.5, ...
        'DisplayName', candLabels{i});
    hCandInvalid(i) = plot(NaN, NaN, '--', ...
        'Color', candColorInvalid{i}, 'LineWidth', 1.2, ...
        'HandleVisibility', 'off');
end

%% ── 차량 마커 핸들 ───────────────────────────────────────────────────────
hEgo = plot(NaN, NaN, 'mo', 'MarkerSize', 12, ...
    'MarkerFaceColor', 'm', 'LineWidth', 1.5, 'DisplayName', 'Ego');

numOpp  = numel(opponents);
hOpp    = gobjects(numOpp, 1);
oppColors = {'r', [1.0 0.5 0.0], [0.6 0.3 0.0]};

for i = 1:numOpp
    hOpp(i) = plot(NaN, NaN, 's', ...
        'MarkerSize', 9, ...
        'MarkerFaceColor', oppColors{i}, ...
        'Color', oppColors{i}, ...
        'DisplayName', opponents(i).name);
end

%% ── 상태 텍스트 ─────────────────────────────────────────────────────────
hTitle = title('Candidate Action Generation | t = 0.00 s', 'FontSize', 12);

% 범례 표시
lgd = legend([hCandValid; hEgo; hOpp], 'Location', 'bestoutside', 'FontSize', 8);

%% ── 6. GIF 저장 설정 ────────────────────────────────────────────────────
resultFolder = fullfile('data', 'results', 'animations');
if ~isfolder(resultFolder)
    mkdir(resultFolder);
end

gifFile  = fullfile(resultFolder, 'CandidateGeneration_10s.gif');
gifDelay = 0.05;   % [s] 프레임 간격

if isfile(gifFile)
    delete(gifFile);
end

firstFrame = true;

fprintf('\nSimulation running...\n');

%% ── 7. 시뮬레이션 루프 ──────────────────────────────────────────────────
for k = 1:numSteps

    t = tVec(k);

    %% ── 시각화 주기마다 후보 생성 및 렌더링 ─────────────────────────────
    if mod(k-1, vizInterval) == 0

        %% 후보 궤적 생성
        candidateSet = generateCandidateActions(ego, opponents, track, dp);

        %% Ego 마커 업데이트
        set(hEgo, ...
            'XData', ego.position(1), ...
            'YData', ego.position(2));

        %% Opponent 마커 업데이트
        for i = 1:numOpp
            set(hOpp(i), ...
                'XData', opponents(i).position(1), ...
                'YData', opponents(i).position(2));
        end

        %% 후보 라인 업데이트
        for i = 1:min(4, numel(candidateSet))
            cand = candidateSet{i};

            if cand.valid
                set(hCandValid(i),   'XData', cand.x, 'YData', cand.y);
                set(hCandInvalid(i), 'XData', NaN,    'YData', NaN);
            else
                set(hCandValid(i),   'XData', NaN,    'YData', NaN);
                set(hCandInvalid(i), 'XData', cand.x, 'YData', cand.y);
            end
        end

        %% leadInfo 상태 출력 (그림 제목)
        leadInfo = candidateSet{1}.leadInfo;
        if leadInfo.hasLead
            titleStr = sprintf( ...
                'Candidate Generation | t=%.2fs | Lead: %s  gap=%.1fm  TTC=%.1fs', ...
                t, leadInfo.opponent.name, leadInfo.gap, leadInfo.ttc);
        else
            titleStr = sprintf('Candidate Generation | t=%.2fs | No lead vehicle', t);
        end
        set(hTitle, 'String', titleStr);

        drawnow;

        %% GIF 프레임 저장
        frame   = getframe(fig);
        imgData = frame2im(frame);
        [idx, cmap] = rgb2ind(imgData, 256);

        if firstFrame
            imwrite(idx, cmap, gifFile, 'gif', ...
                'LoopCount', inf, 'DelayTime', gifDelay);
            firstFrame = false;
        else
            imwrite(idx, cmap, gifFile, 'gif', ...
                'WriteMode', 'append', 'DelayTime', gifDelay);
        end
    end

    %% ── 차량 상태 업데이트 ───────────────────────────────────────────────
    if t < tEnd
        ego       = updateEgoState(ego, track, simDt, t, race.targetLaps);
        opponents = updateOpponentFleet( ...
            opponents, track, simDt, oppParams, t, race.targetLaps);
    end
end

%% ── 8. 결과 저장 및 출력 ────────────────────────────────────────────────
fprintf('\n=== Candidate Generation Test Complete ===\n');
fprintf('Duration     : %.1f s\n', tEnd);
fprintf('GIF saved    : %s\n', gifFile);
fprintf('Ego final s  : %.1f m\n', ego.s);

for i = 1:numOpp
    fprintf('Opp%d final s : %.1f m\n', i, opponents(i).s);
end
