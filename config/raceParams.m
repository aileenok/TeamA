function params = raceParams()
% raceParams
% 레이스 시뮬레이션 기본 설정

%% 시간 설정
params.dt = 0.05;          % [s] time step

% 기존 tFinal 방식도 남겨둠
% 짧은 테스트나 디버깅용으로 사용 가능
params.tFinal = 20.0;      % [s]

% 모든 차량이 완주하면 종료하는 방식에서 사용할 안전 제한 시간
params.maxTime = 180.0;    % [s]

%% 레이스 종료 조건
params.targetLaps = 1;     % 모든 차량이 1바퀴 완주하면 종료

%% ego 차량 초기 상태
params.egoInitialS = 0.0;  % [m]
params.egoInitialD = 0.0;  % [m]
params.egoSpeed = 65.0;    % [m/s]

%% 앞차 판단 기준
params.lookAheadDistance = 300.0;  % [m]
params.safeGap = 30.0;             % [m]

end