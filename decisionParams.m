function params = decisionParams()
% decisionParams
% Candidate action generation parameters for the decision module.
%
% 후보 궤적 생성, 트랙 범위 체크, 충돌 체크에 사용되는 파라미터 모음.

%% ── 궤적 생성 ────────────────────────────────────────────────────────────
params.dt      = 0.1;   % [s]  궤적 이산화 time step
params.horizon = 3.0;   % [s]  플래닝 호라이즌
params.N       = 30;    % [-]  궤적 waypoint 수

%% ── 목표 lateral offset [m] ─────────────────────────────────────────────
% d > 0 : 트랙 진행 방향 기준 왼쪽
% d < 0 : 트랙 진행 방향 기준 오른쪽
params.maintainLineTargetD    =  0.0;  % 센터라인 유지
params.overtakeInsideOffsetD  = -2.5;  % 앞차 d 기준 내측(오른쪽) 오프셋
params.overtakeOutsideOffsetD =  2.5;  % 앞차 d 기준 외측(왼쪽) 오프셋
params.returnLineTargetD      =  0.0;  % 센터라인으로 복귀

%% ── 속도 파라미터 [m/s] ──────────────────────────────────────────────────
params.overtakeSpeedBoost = 5.0;    % 추월 기동 시 추가 속도
params.maxSpeedDelta      = 15.0;   % 호라이즌 동안 허용 최대 속도 변화량

%% ── 트랙 안전 마진 [m] ───────────────────────────────────────────────────
params.trackMarginLeft  = 0.5;  % 왼쪽 경계선까지의 최소 여유
params.trackMarginRight = 0.5;  % 오른쪽 경계선까지의 최소 여유

%% ── 충돌 체크 ────────────────────────────────────────────────────────────
params.safetyRadius = 4.0;  % [m]  차량 간 최소 안전 거리

%% ── 앞차 탐색 ────────────────────────────────────────────────────────────
params.lookAheadDistance = 150.0;  % [m]  전방 탐색 거리

%% ── TTC (Time-To-Collision) 임계값 ──────────────────────────────────────
params.ttcThreshold = 3.0;  % [s]  이하이면 추월 기동 고려

end
