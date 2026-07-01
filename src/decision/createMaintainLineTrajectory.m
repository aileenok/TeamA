function candidate = createMaintainLineTrajectory(track, ego, leadInfo, decision)
% createMaintainLineTrajectory
% MAINTAIN_LINE 후보 생성
%
% 의미:
%   현재 lateral line을 유지한다.
%   단, 앞차와의 gap/TTC에 따라 속도는 조절한다.

arguments
    track struct
    ego struct
    leadInfo struct
    decision struct
end

targetD = ego.d;

[targetV, speedMode] = computeMaintainTargetSpeed(ego, leadInfo, decision);

candidate = createCandidateTrajectory( ...
    track, ...
    ego, ...
    "MAINTAIN_LINE", ...
    targetD, ...
    targetV, ...
    decision);

candidate.speedMode = speedMode;

end