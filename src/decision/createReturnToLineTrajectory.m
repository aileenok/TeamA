function candidate = createReturnToLineTrajectory(track, ego, leadInfo, decision)
% createReturnToLineTrajectory
% RETURN_TO_LINE 후보 생성
%
% 의미:
%   추월 후 기준 라인으로 복귀한다.
%   현재는 기준 라인을 d = 0으로 둔다.
%
% 주의:
%   ego가 이미 기준 라인 근처라면 MAINTAIN_LINE과 거의 같아질 수 있다.
%   이 경우는 cost 단계에서 불리하게 처리하거나,
%   필요하면 여기서 invalid 처리할 수 있다.

arguments
    track struct
    ego struct
    leadInfo struct
    decision struct
end

targetD = decision.returnD;

% 복귀 중에도 앞차가 가까우면 속도 조절이 필요하므로
% MAINTAIN_LINE의 속도 정책을 같이 사용한다.
[targetV, speedMode] = computeMaintainTargetSpeed(ego, leadInfo, decision);

candidate = createCandidateTrajectory( ...
    track, ...
    ego, ...
    "RETURN_TO_LINE", ...
    targetD, ...
    targetV, ...
    decision);

candidate.speedMode = speedMode;

% 이미 기준 라인 근처라면 정보 표시만 해둔다.
% 지금은 invalid로 만들지 않는다.
candidate.alreadyNearReferenceLine = abs(ego.d - decision.returnD) < decision.returnLineTolerance;

end