function speedProfile = velocityProfile(track, vehicle)
% velocityProfile
% 곡률 기반 최대 속도와 차량 가속/감속 제한을 반영하여
% single-car baseline용 velocity profile을 계산하는 함수
%
% 입력:
%   track   : 전처리된 트랙 구조체
%             필요한 필드:
%             - track.s
%             - track.ds
%             - track.curvatureForVelocity 또는 track.curvatureAbs
%
%   vehicle : 차량 파라미터 구조체
%             필요한 필드:
%             - vehicle.mu
%             - vehicle.g
%             - vehicle.maxSpeed
%             - vehicle.maxAccel
%             - vehicle.maxDecel
%
% 출력:
%   speedProfile : 속도 계산 결과 구조체
%             - speedProfile.s
%             - speedProfile.vCurve
%             - speedProfile.v
%             - speedProfile.kappa
%             - speedProfile.ds

arguments
    track struct
    vehicle struct
end

%% 1. 곡률 데이터 선택
% velocity 계산에는 smoothing된 곡률을 사용하는 것을 추천
if isfield(track, "curvatureForVelocity")
    kappa = track.curvatureForVelocity(:);
elseif isfield(track, "curvatureAbs")
    kappa = track.curvatureAbs(:);
else
    error("track.curvatureForVelocity 또는 track.curvatureAbs 필드가 필요합니다.");
end

kappaAbs = abs(kappa);

%% 2. 거리 정보 확보
if isfield(track, "s")
    s = track.s(:);
else
    error("track.s 필드가 필요합니다.");
end

if isfield(track, "ds")
    ds = track.ds(:);
else
    % ds가 없으면 centerline으로부터 직접 계산
    pathClosed = [track.center; track.center(1,:)];
    ds = sqrt(sum(diff(pathClosed).^2, 2));
end

numPoints = length(s);

if length(ds) ~= numPoints
    error("track.ds의 길이는 track.s와 같아야 합니다. 폐곡선 기준 N개 구간이어야 합니다.");
end

%% 3. 곡률 기반 최대 속도 계산
% kappa가 0에 가까운 직선 구간에서는 속도가 무한대로 커질 수 있으므로
% 작은 최소 곡률값을 둠
minCurvature = 1e-6;

vCurve = sqrt(vehicle.mu * vehicle.g ./ max(kappaAbs, minCurvature));

% 차량 최고속도 제한 반영
vCurve = min(vCurve, vehicle.maxSpeed);

%% 4. forward/backward pass 초기화
% 처음에는 곡률 기반 속도 제한을 그대로 사용
v = vCurve;

% 폐곡선 트랙에서는 시작점/끝점이 연결되므로
% 몇 번 반복해서 가속/감속 제한이 전체 트랙에 퍼지도록 함
numIterations = 5;

for iter = 1:numIterations

    %% Forward pass: 가속 제한 반영
    % i-1 지점 속도에서 ds만큼 이동했을 때 도달 가능한 최대 속도
    for i = 2:numPoints
        vAllowed = sqrt(v(i-1)^2 + 2 * vehicle.maxAccel * ds(i-1));
        v(i) = min(v(i), vAllowed);
    end

    % 폐곡선 연결부: 마지막 점에서 첫 점으로 이어지는 구간
    vAllowedFirst = sqrt(v(end)^2 + 2 * vehicle.maxAccel * ds(end));
    v(1) = min(v(1), vAllowedFirst);

    %% Backward pass: 감속 제한 반영
    % 다음 지점에서 필요한 속도까지 감속 가능한지 뒤에서부터 확인
    for i = numPoints-1:-1:1
        vAllowed = sqrt(v(i+1)^2 + 2 * vehicle.maxDecel * ds(i));
        v(i) = min(v(i), vAllowed);
    end

    % 폐곡선 연결부: 첫 점에서 마지막 점으로 되돌아보는 구간
    vAllowedLast = sqrt(v(1)^2 + 2 * vehicle.maxDecel * ds(end));
    v(end) = min(v(end), vAllowedLast);

end

%% 5. 결과 저장
speedProfile.s = s;
speedProfile.ds = ds;
speedProfile.kappa = kappa;
speedProfile.kappaAbs = kappaAbs;
speedProfile.vCurve = vCurve;
speedProfile.v = v;

speedProfile.maxSpeed = max(v);
speedProfile.minSpeed = min(v);
speedProfile.meanSpeed = mean(v);

end