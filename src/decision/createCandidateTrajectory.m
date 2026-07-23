function candidate = createCandidateTrajectory(track, ego, actionName, targetD, targetV, decision)
% createCandidateTrajectory
% actionName, targetD, targetV를 받아서 time-based candidate trajectory 생성
%
% 출력 candidate 필드:
%   name, time, s, d, v, x, y, yaw, xy
%   targetD, targetV
%   isValid, reason
%   collision 관련 필드
%   cost 관련 필드

arguments
    track struct
    ego struct
    actionName string
    targetD (1,1) double
    targetV (1,1) double
    decision struct
end

%% 1. 시간축 생성
t = (0:decision.dt:decision.horizon)';
N = length(t);

%% 2. lateral offset d 생성
% lateral 이동은 전체 prediction horizon 동안 무조건 수행하는 것이 아니라,
% laneChangeTime 안에 targetD에 도달하도록 한다.

laneChangeTime = min(decision.laneChangeTime, decision.horizon);

alphaD = min(t / max(laneChangeTime, eps), 1.0);
blendD = 3 * alphaD.^2 - 2 * alphaD.^3;

d = ego.d + (targetD - ego.d) .* blendD;

%% 3. speed profile 생성
% 속도도 speedTransitionTime 안에 targetV에 도달하도록 한다.

targetV = min(max(targetV, decision.minCandidateSpeed), decision.maxCandidateSpeed);

speedTransitionTime = min(decision.speedTransitionTime, decision.horizon);

alphaV = min(t / max(speedTransitionTime, eps), 1.0);
blendV = 3 * alphaV.^2 - 2 * alphaV.^3;

v = ego.v + (targetV - ego.v) .* blendV;
v = min(max(v, decision.minCandidateSpeed), decision.maxCandidateSpeed);

%% 4. s trajectory 생성
s = zeros(N, 1);
s(1) = mod(ego.s, track.length);

for k = 2:N
    ds = 0.5 * (v(k-1) + v(k)) * decision.dt;
    s(k) = mod(s(k-1) + ds, track.length);
end

%% 5. Frenet -> Global 변환
x = zeros(N, 1);
y = zeros(N, 1);

for k = 1:N
    position = frenetToGlobalCustom(track, s(k), d(k));

    x(k) = position(1);
    y(k) = position(2);
end

%% 6. Global trajectory의 reference yaw 계산
% 경로의 시간에 따른 진행 방향을 이용해 yaw를 계산한다.
%
% yaw = 0       : global +x 방향
% yaw = pi/2    : global +y 방향
% positive yaw  : 반시계방향
%
% unwrap은 pi와 -pi 경계를 지날 때 yaw가 갑자기
% 약 2*pi만큼 튀는 현상을 방지한다.

if N < 2
    error("Yaw를 계산하려면 trajectory point가 2개 이상 필요합니다.");
end

dxdt = gradient(x, t);
dydt = gradient(y, t);

yaw = atan2(dydt, dxdt);
yaw = unwrap(yaw);

%% 7. candidate 구조체 생성
candidate.name = actionName;
candidate.time = t;

candidate.s = s;
candidate.d = d;
candidate.v = v;

candidate.x = x;
candidate.y = y;
candidate.yaw = yaw;
candidate.xy = [x, y];

candidate.targetD = targetD;
candidate.targetV = targetV;

candidate.isValid = true;
candidate.reason = "valid";

%% 8. collision 관련 기본값
candidate.collisionRisk = false;
candidate.collisionOpponentIndex = NaN;
candidate.collisionOpponentName = "";
candidate.collisionTime = NaN;
candidate.minCollisionSGap = inf;
candidate.minCollisionDGap = inf;

%% 9. cost 관련 기본값
candidate.costCollision = NaN;
candidate.costProgress = NaN;
candidate.costTrack = NaN;
candidate.costControl = NaN;
candidate.costSpeed = NaN;
candidate.totalCost = NaN;

%% 10. action별 추가 정보 기본값
candidate.speedMode = "";
candidate.cornerDirection = "";
candidate.kappaLookahead = NaN;
candidate.alreadyNearReferenceLine = false;

%% 11. track boundary 정보 기본값
candidate.leftLimit = [];
candidate.rightLimit = [];

%% 12. safety warning 정보 기본값
candidate.safetyRisk = false;
candidate.safetyOpponentIndex = NaN;
candidate.safetyOpponentName = "";
candidate.safetyTime = NaN;
candidate.warningSGap = inf;
candidate.warningDGap = inf;

end