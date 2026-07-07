function candidate = createCandidateTrajectory(track, ego, actionName, targetD, targetV, decision)
% createCandidateTrajectory
% actionName, targetD, targetV를 받아서 time-based candidate trajectory 생성
%
% 출력 candidate 필드:
%   name, time, s, d, v, x, y, xy
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
% lateral 이동은 전체 horizon 10초 동안 천천히 하는 것이 아니라,
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
    xy = frenetToGlobalCustom(track, s(k), d(k));

    x(k) = xy(1);
    y(k) = xy(2);
end

%% 6. candidate 구조체 생성
candidate.name = actionName;
candidate.time = t;

candidate.s = s;
candidate.d = d;
candidate.v = v;

candidate.x = x;
candidate.y = y;
candidate.xy = [x, y];

candidate.targetD = targetD;
candidate.targetV = targetV;

candidate.isValid = true;
candidate.reason = "valid";

%% 7. collision 관련 기본값
candidate.collisionRisk = false;
candidate.collisionOpponentIndex = NaN;
candidate.collisionOpponentName = "";
candidate.collisionTime = NaN;
candidate.minCollisionSGap = inf;
candidate.minCollisionDGap = inf;

%% 8. cost 관련 기본값
% evaluateCandidateCost에서 채워진다.
%   costCollision : 충돌/안전 여유 위반 비용
%   costOfftrack  : track 경계 여유 부족 비용
%   costTime      : 위험 상황까지 남은 시간 비용
%   costProgress  : 진행 속도(progress) 비용
%   totalCost     : 위 네 비용의 가중합
candidate.costCollision = NaN;
candidate.costOfftrack = NaN;
candidate.costTime = NaN;
candidate.costProgress = NaN;
candidate.totalCost = NaN;

%% 9. action별 추가 정보 기본값
candidate.speedMode = "";
candidate.cornerDirection = "";
candidate.kappaLookahead = NaN;
candidate.alreadyNearReferenceLine = false;

%% 10. track boundary 정보 기본값
candidate.leftLimit = [];
candidate.rightLimit = [];

%% 11. safety warning 정보 기본값
candidate.safetyRisk = false;
candidate.safetyOpponentIndex = NaN;
candidate.safetyOpponentName = "";
candidate.safetyTime = NaN;
candidate.warningSGap = inf;
candidate.warningDGap = inf;

end