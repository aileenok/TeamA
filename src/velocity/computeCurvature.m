function track = computeCurvature(track, smoothWindow)
% computeCurvature
% 폐곡선 트랙 구조체(track)의 signed curvature를 계산하고 smoothing하는 함수

arguments
    track struct
    smoothWindow (1,1) double {mustBeInteger, mustBePositive} = 11
end

%% center 좌표 확보
if isfield(track, 'center')
    center = track.center;
elseif isfield(track, 'x') && isfield(track, 'y')
    center = [track.x(:), track.y(:)];
    track.center = center;
else
    error('track.center 또는 track.x / track.y 필드가 필요합니다.');
end

n = size(center, 1);

if n < 4
    error('곡률 계산을 위해서는 최소 4개 이상의 점이 필요합니다.');
end

%% s 확보
if isfield(track, 's')
    s = track.s(:);
else
    centerClosed = [center; center(1,:)];
    dsSegment = sqrt(sum(diff(centerClosed).^2, 2));
    s = [0; cumsum(dsSegment(1:end-1))];
    track.s = s;
end

%% heading 확보 및 unwrap
if isfield(track, 'heading')
    psi = track.heading(:);
else
    centerClosedForDiff = [center(end,:); center; center(1,:)];
    dxy = centerClosedForDiff(3:end,:) - centerClosedForDiff(1:end-2,:);
    psi = atan2(dxy(:,2), dxy(:,1));
    track.heading = psi;
end

psi = unwrap(psi);

%% dpsi/ds로 곡률 계산
dpsi = gradient(psi);
ds = gradient(s);

kappa = dpsi ./ ds;

%% NaN / Inf 제거
kappa(~isfinite(kappa)) = 0;

%% 폐곡선 smoothing
if mod(smoothWindow, 2) == 0
    smoothWindow = smoothWindow + 1;
end

if smoothWindow > 1
    kappa = smoothClosedSignal(kappa, smoothWindow);
end

%% 저장
track.curvature = kappa(:);
track.curvatureAbs = abs(track.curvature);

minCurvature = 1e-6;
track.curvatureRadius = 1 ./ max(track.curvatureAbs, minCurvature);

if isfield(track, 'N')
    track = rmfield(track, 'N');
end

track.numPoints = n;
track.curvatureMethod = 'heading-based dpsi/ds with unwrap and closed-track smoothing';
track.curvatureSmoothingWindow = smoothWindow;

end

function ySmooth = smoothClosedSignal(y, windowSize)

    y = y(:);
    halfWindow = floor(windowSize / 2);

    yPadded = [
        y(end-halfWindow+1:end);
        y;
        y(1:halfWindow)
    ];

    yPadded = smoothdata(yPadded, 'movmedian', 5);
    yPaddedSmooth = smoothdata(yPadded, 'movmean', windowSize);

    ySmooth = yPaddedSmooth(halfWindow+1 : halfWindow+length(y));

end