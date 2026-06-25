function params = opponentParams(track)
% opponentParams
% 상대 차량(opponent car) 설정을 정의하는 함수
%
% 실행할 때마다 opponent 차량의 초기 위치, lateral offset, 속도가
% 랜덤하게 달라지도록 설정한다.

arguments
    track struct
end

%% 랜덤 시드 설정
% 매번 실행할 때마다 다른 결과가 나오게 함
rng("shuffle");

%% 공통 설정
params.numOpponents = 3;

% 차량 간 충돌 판정에 사용할 안전 반경 [m]
params.safetyRadius = 4.0;

% opponent 속도 범위 [m/s]
% 50~72 m/s = 약 180~259 km/h
params.minSpeed = 50.0;
params.maxSpeed = 72.0;

% opponent lateral offset 범위 [m]
% d > 0 : 왼쪽, d < 0 : 오른쪽
params.minD = -2.0;
params.maxD = 2.0;

% opponent 초기 s 위치 범위
% ego가 보통 s=0에서 시작하므로, 너무 가까이 두지 않도록 200m 이후부터 배치
params.minInitialS = 200.0;
params.maxInitialS = min(track.length - 200.0, 1800.0);

%% 랜덤 초기 상태 생성
params.initialS = params.minInitialS + ...
    (params.maxInitialS - params.minInitialS) * rand(params.numOpponents, 1);

% 차량들이 너무 비슷한 위치에 몰리지 않도록 정렬
params.initialS = zeros(params.numOpponents, 1);

params.initialD = params.minD + ...
    (params.maxD - params.minD) * rand(params.numOpponents, 1);

params.speed = params.minSpeed + ...
    (params.maxSpeed - params.minSpeed) * rand(params.numOpponents, 1);

%% 차량 이름
params.names = strings(params.numOpponents, 1);

for i = 1:params.numOpponents
    params.names(i) = "Opponent " + i;
end

%% opponent behavior 설정
% constant      : 일정 속도에 가까운 주행
% random_speed  : 속도가 매 step 조금씩 변함
% defensive     : 추후 ego가 가까워지면 방어적으로 움직이는 확장용
behaviorList = ["constant", "random_speed", "random_speed"];

params.behaviorType = behaviorList(:);

%% 속도 변화 설정
params.randomAccelStd = 1.5;    % [m/s^2] 랜덤 가속도 표준편차
params.maxAccel = 3.0;          % [m/s^2] opponent 최대 가속
params.maxDecel = 5.0;          % [m/s^2] opponent 최대 감속

end