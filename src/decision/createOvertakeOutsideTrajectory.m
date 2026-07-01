function candidate = createOvertakeOutsideTrajectory(track, ego, leadInfo, sideInfo, decision)
% createOvertakeOutsideTrajectory
% OVERTAKE_OUTSIDE 후보 생성
%
% 의미:
%   코너 바깥쪽 방향으로 lateral 이동하면서 추월을 시도한다.

arguments
    track struct
    ego struct
    leadInfo struct
    sideInfo struct
    decision struct
end

targetD = sideInfo.outsideTargetD;

if leadInfo.hasLead
    baseSpeed = max(ego.v, leadInfo.vehicle.v);
else
    baseSpeed = ego.v;
end

targetV = baseSpeed + decision.overtakeSpeedGain;
targetV = min(max(targetV, decision.minCandidateSpeed), decision.maxCandidateSpeed);

candidate = createCandidateTrajectory( ...
    track, ...
    ego, ...
    "OVERTAKE_OUTSIDE", ...
    targetD, ...
    targetV, ...
    decision);

candidate.cornerDirection = sideInfo.cornerDirection;
candidate.kappaLookahead = sideInfo.kappaLookahead;

end