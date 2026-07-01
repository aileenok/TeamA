function sideInfo = determineOvertakeSideTargets(track, ego, leadInfo, decision)
% determineOvertakeSideTargets
% 현재 위치 기준 lookahead 구간의 curvature를 보고
% inside / outside 방향과 targetD를 결정한다. >> overtake에 쓸 d 계산한다는 이야기
%
% sign convention:
%   curvature > 0 : left turn
%   curvature < 0 : right turn
%
% Frenet d convention:
%   d > 0 : left side
%   d < 0 : right side

arguments
    track struct
    ego struct
    leadInfo struct
    decision struct
end

%% 1. lookahead 구간에서 대표 curvature 찾기
kappaLookahead = getLookaheadCurvature(track, ego.s, decision);

if abs(kappaLookahead) < decision.curvatureThreshold
    % 거의 직선이면 임시 기준 사용
    % 직선에서는 inside/outside가 물리적으로 애매하므로
    % 기본적으로 right를 inside fallback으로 둔다.
    cornerDirection = "straight";
    insideSign = -1;
else
    if kappaLookahead > 0
        cornerDirection = "left";
        insideSign = +1;
    else
        cornerDirection = "right";
        insideSign = -1;
    end
end

outsideSign = -insideSign;

%% 2. 기준 d 설정
% 앞차가 있으면 앞차 lateral 위치를 기준으로 추월 공간을 만든다.
% 앞차가 없으면 ego 위치 기준으로 만든다.

if leadInfo.hasLead
    baseD = leadInfo.vehicle.d;
else
    baseD = ego.d;
end

rawInsideTargetD = baseD + insideSign * decision.laneChangeD;
rawOutsideTargetD = baseD + outsideSign * decision.laneChangeD;

%% 3. track width 안으로 targetD 제한
[leftLimit, rightLimit] = getDTrackLimits(track, ego.s, decision);

insideTargetD = min(max(rawInsideTargetD, rightLimit), leftLimit);
outsideTargetD = min(max(rawOutsideTargetD, rightLimit), leftLimit);

%% 4. 결과 저장
sideInfo.kappaLookahead = kappaLookahead;
sideInfo.cornerDirection = cornerDirection;

sideInfo.insideSign = insideSign;
sideInfo.outsideSign = outsideSign;

sideInfo.baseD = baseD;

sideInfo.rawInsideTargetD = rawInsideTargetD;
sideInfo.rawOutsideTargetD = rawOutsideTargetD;

sideInfo.insideTargetD = insideTargetD;
sideInfo.outsideTargetD = outsideTargetD;

sideInfo.leftLimit = leftLimit;
sideInfo.rightLimit = rightLimit;

end

function kappaLookahead = getLookaheadCurvature(track, s0, decision)
% lookahead 구간에서 abs(curvature)가 가장 큰 지점의 curvature를 사용한다.

if isfield(track, "curvature")
    kappa = track.curvature;
elseif isfield(track, "curvatureSmooth")
    kappa = track.curvatureSmooth;
elseif isfield(track, "curvatureForVelocity")
    kappa = track.curvatureForVelocity;
else
    kappaLookahead = 0.0;
    return;
end

sSamples = linspace(s0, s0 + decision.cornerLookaheadDistance, 80);
sSamples = mod(sSamples, track.length);

sTrack = track.s(:);
kappa = kappa(:);

% closed track interpolation을 위해 마지막에 track.length와 첫 curvature 추가
sExt = [sTrack; track.length];
kExt = [kappa; kappa(1)];

kappaSamples = interp1(sExt, kExt, sSamples, "linear");

[~, idx] = max(abs(kappaSamples));
kappaLookahead = kappaSamples(idx);

if isnan(kappaLookahead)
    kappaLookahead = 0.0;
end

end

function [leftLimit, rightLimit] = getDTrackLimits(track, sQuery, decision)
% 현재 s 위치에서 허용 가능한 d 범위 계산
%
% leftLimit  : d의 최대값
% rightLimit : d의 최소값

sWrapped = mod(sQuery, track.length);

sTrack = track.s(:);

widthLeft = track.widthLeft(:);
widthRight = track.widthRight(:);

sExt = [sTrack; track.length];
wLeftExt = [widthLeft; widthLeft(1)];
wRightExt = [widthRight; widthRight(1)];

localLeftWidth = interp1(sExt, wLeftExt, sWrapped, "linear");
localRightWidth = interp1(sExt, wRightExt, sWrapped, "linear");

leftLimit = localLeftWidth - decision.trackMargin;
rightLimit = -localRightWidth + decision.trackMargin;

end