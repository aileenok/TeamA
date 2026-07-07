function params = decisionParams()
% decisionParams
% Candidate action generation 및 collision check에 사용하는 파라미터

%% prediction 설정
params.dt = 0.10;              % [s]
params.horizon = 10.0;         % [s] candidate rollout 시간

%% track 설정
params.trackMargin = 0.50;     % [m] track boundary에서 남겨둘 여유폭

%% MAINTAIN_LINE / TTC 설정
params.followGap = 120.0;      % [m] 이 거리 안이면 속도 조절 고려
params.safeGap = 60.0;         % [m] 이 거리 안이면 더 적극적으로 감속

params.ttcCaution = 10.0;      % [s] TTC가 이보다 작으면 감속 고려
params.ttcCritical = 5.0;      % [s] TTC가 이보다 작으면 강한 감속

params.maintainSpeedMargin = 1.0;  % [m/s] 매우 가까울 때 앞차보다 약간 느리게

%% speed 제한
params.minCandidateSpeed = 25.0;   % [m/s]
params.maxCandidateSpeed = 83.3;   % [m/s]

%% overtake 설정
params.laneChangeD = 2.5;               % [m]
params.overtakeSpeedGain = 6.0;         % [m/s]

params.laneChangeTime = 3.0;            % [s] lateral 이동 완료 시간
params.speedTransitionTime = 3.0;       % [s] 목표 속도까지 변화하는 시간

params.cornerLookaheadDistance = 250.0; % [m]
params.curvatureThreshold = 1.0e-4;     % [1/m]

%% return 설정
params.returnD = 0.0;               % [m] 기준 라인. 현재는 centerline
params.returnLineTolerance = 0.40;  % [m] 이 안이면 이미 기준 라인 근처라고 판단

%% lead vehicle 탐색 설정
params.leadLookAheadDistance = 350.0; % [m] 이 거리 안의 앞차만 lead 후보로 사용

%% collision check 설정
% 실제 충돌로 판단할 hard threshold
params.collisionSBuffer = 10.0;   % [m] 실제 충돌/매우 위험 판단용
params.collisionDBuffer = 1.9;    % [m] lateral 실제 충돌/매우 위험 판단용

% cost 계산 단계에서 사용할 warning threshold
params.warningSBuffer = 25.0;     % [m] 가까움 경고용
params.warningDBuffer = 2.2;      % [m] lateral 가까움 경고용

%% cost function 가중치 설정
% evaluateCandidateCost에서 사용하는 가중치.
% 우선순위: collision > offtrack > time > progress
params.costWeightCollision = 500.0;   % 충돌/안전 여유 위반 비용 가중치
params.costWeightOfftrack  = 300.0;   % track 경계 여유 부족 비용 가중치
params.costWeightTime      = 200.0;   % 위험 상황까지 남은 시간 비용 가중치
params.costWeightProgress  = 100.0;   % 진행 속도(progress) 비용 가중치

% offtrack cost 계산 시 목표로 하는 추가 안전 여유폭
% (trackMargin을 넘어서 이 정도 여유를 더 확보하면 offtrack cost가 0에 가까워짐)
params.offtrackSafeMargin = 1.0;      % [m]

% invalid(충돌/트랙 이탈 등) 후보에 부여하는 고정 패널티
% totalCost 비교 시 valid 후보보다 항상 나쁘게 평가되도록 하는 값
params.invalidCostPenalty = 1.0e6;

end