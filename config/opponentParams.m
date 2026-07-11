function params = opponentParams(track)
% opponentParams
% 상대 차량(opponent car) 설정을 정의하는 함수
%
% 실행할 때마다 초기 s, d, 속도가 달라진다.
% 기존 코드에 있던 initialS = zeros(...) 재대입은 제거했다.

arguments
    track struct
end

%% 랜덤 시드
rng("shuffle");

%% 공통 설정
params.numOpponents = 3;
params.safetyRadius = 4.0;

%% 속도 범위 [m/s]
params.minSpeed = 50.0;
params.maxSpeed = 72.0;

%% lateral offset 범위 [m]
params.minD = -2.0;
params.maxD = 2.0;

%% 초기 s 범위 [m]
params.minInitialS = 200.0;
params.maxInitialS = min(track.length - 200.0, 1800.0);

%% 랜덤 초기 상태 생성
params.initialS = params.minInitialS + ...
    (params.maxInitialS - params.minInitialS) ...
    * rand(params.numOpponents, 1);

% 차량들이 뒤섞이더라도 초기 위치 자체는 겹치지 않도록 정렬
params.initialS = sort(params.initialS);

params.initialD = params.minD + ...
    (params.maxD - params.minD) ...
    * rand(params.numOpponents, 1);

params.speed = params.minSpeed + ...
    (params.maxSpeed - params.minSpeed) ...
    * rand(params.numOpponents, 1);

%% 차량 이름
params.names = strings(params.numOpponents, 1);

for i = 1:params.numOpponents
    params.names(i) = "Opponent " + i;
end

%% opponent behavior
behaviorList = ["constant", "random_speed", "random_speed"];
params.behaviorType = behaviorList(:);

%% 속도 변화 설정
params.randomAccelStd = 1.5;  % [m/s^2]
params.maxAccel = 3.0;        % [m/s^2]
params.maxDecel = 5.0;        % [m/s^2]

end
