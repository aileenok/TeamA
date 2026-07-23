<<<<<<< Updated upstream
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
=======
function params = decisionParams()
% decisionParams
% Candidate action 생성, 충돌/트랙 검사, cost-based decision에 사용하는 설정값
%
% 중요:
%   기존 프로젝트의 flat field 구조를 그대로 유지한다.
%   decision.action.xxx / decision.cost.xxx 같은 중첩 구조는 사용하지 않는다.

%% 1. Candidate trajectory 생성
params.dt = 0.10;                  % [s] candidate sampling interval
params.horizon = 3.0;              % [s] prediction horizon

% 3초 horizon 끝에 도달하는 것보다,
% 약 2.5초에 목표값에 도달하고 마지막 0.5초 동안 유지하도록 설정
params.laneChangeTime = 2.5;       % [s]
params.speedTransitionTime = 2.5;  % [s]

%% 2. Track / lateral action
params.trackMargin = 0.50;         % [m] 기존 center-point track 검사 여유
params.laneChangeD = 3.0;          % [m] 기본 lateral 추월 이동량
params.returnD = 0.0;              % [m] 현재 기준 라인(centerline)
params.returnLineTolerance = 0.80; % [m] 기준 라인 근처 판정

%% 3. Speed action
params.minCandidateSpeed = 25.0;   % [m/s]
params.maxCandidateSpeed = 83.3;   % [m/s]
params.overtakeSpeedGain = 6.0;    % [m/s]
params.maintainSpeedMargin = 1.0;  % [m/s] critical 상황에서 lead보다 느리게 설정

%% 4. MAINTAIN_LINE / TTC
params.followGap = 120.0;          % [m]
params.safeGap = 60.0;             % [m]
params.ttcCaution = 10.0;          % [s]
params.ttcCritical = 5.0;          % [s]

%% 5. Lead / corner look-ahead
params.leadLookAheadDistance = 300.0;    % [m]
params.cornerLookaheadDistance = 150.0;  % [m]
params.curvatureThreshold = 2.0e-4;      % [1/m]

%% 6. 기존 candidate hard collision / warning 검사
% vehicle.length = 5.5 m, vehicle.width = 1.9 m 가정 시
% hard longitudinal envelope ~= 5.5 + 1.0 = 6.5 m
% hard lateral envelope      ~= 1.9 + 0.3 = 2.2 m
params.collisionSBuffer = 6.50;    % [m]
params.collisionDBuffer = 2.20;    % [m]

% warning 영역은 invalid가 아니라 safety cost에 반영
params.warningSBuffer = 30.0;      % [m]
params.warningDBuffer = 3.0;       % [m]

%% 7. 추가 hard constraint 설정
params.hardOfftrackBuffer = 0.20;      % [m] 차량 body와 track boundary 사이 최소 여유
params.hardDynamicTolerance = 1.05;    % [-]

% Cost v1에서는 dynamic feasibility를 먼저 soft cost로 관찰한다.
% true로 바꾸면 가속/마찰/조향 한계 초과 candidate를 hard invalid 처리한다.
params.enableDynamicHardConstraint = false;

%% 8. Soft safety cost 설정
params.costTauSafety = 1.5;                 % [s]
params.costMinLongitudinalWarning = 5.0;    % [m]
params.costLateralWarningExtra = 0.8;       % [m]
params.costTTCWarning = 5.0;                % [s]
params.costTTCCritical = 2.0;               % [s]
params.costDesiredTrackMargin = 1.0;        % [m]

%% 9. Dynamic cost 설정
% 물리 한계 utilization 70%부터 soft cost 증가
params.costDynamicSoftStart = 0.40;

%% 10. Race advantage cost 설정
params.costTimeTargetDistance = 150.0;      % [m]
params.costFutureLookAheadTime = 1.0;       % [s]

%% 11. Safety cost 내부 가중치 (합 = 1)
params.wCollision = 0.35;
params.wOfftrack = 0.05;
params.wClearance = 0.20;
params.wTTC = 0.20;
params.wTrackMargin = 0.20;

%% 12. Dynamic cost 내부 가중치 (합 = 1)
params.wFriction = 0.40;
params.wLateralAccel = 0.25;
params.wLongitudinal = 0.20;
params.wSteering = 0.15;

% actual yaw/slip state는 아직 없으므로 현재 비활성
params.wYaw = 0.0;
params.wSlip = 0.0;

%% 13. Race advantage cost 내부 가중치 (합 = 1)
params.wTime = 0.15;
params.wProgress = 0.40;
params.wExitSpeed = 0.20;
params.wFutureProgress = 0.15;
params.wRecovery = 0.10;

%% 14. 최상위 cost 가중치
params.lambdaSafety = 0.35;
params.lambdaDynamic = 0.25;
params.lambdaRace = 0.40;

%% 15. Invalid / tie-break
params.costInvalidPenalty = 1.0e6;
params.costTieRelativeTolerance = 0.05;  % 5%

end
>>>>>>> Stashed changes
