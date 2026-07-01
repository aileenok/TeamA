function [candidates, decisionInfo] = generateCandidateActions(track, ego, opponents, decision)
% generateCandidateActions
% 4개 candidate action 생성
%
% Action set:
%   1. MAINTAIN_LINE
%   2. OVERTAKE_INSIDE
%   3. OVERTAKE_OUTSIDE
%   4. RETURN_TO_LINE

arguments
    track struct
    ego struct
    opponents (:,1) struct
    decision struct
end

%% 1. Lead vehicle 탐색
leadInfo = findLeadOpponentForDecision(ego, opponents, track, decision);

%% 2. Inside / outside targetD 계산
sideInfo = determineOvertakeSideTargets(track, ego, leadInfo, decision);

%% 3. Action별 candidate 생성
candidateCells = cell(4, 1);

candidateCells{1} = createMaintainLineTrajectory( ...
    track, ego, leadInfo, decision);

candidateCells{2} = createOvertakeInsideTrajectory( ...
    track, ego, leadInfo, sideInfo, decision);

candidateCells{3} = createOvertakeOutsideTrajectory( ...
    track, ego, leadInfo, sideInfo, decision);

candidateCells{4} = createReturnToLineTrajectory( ...
    track, ego, leadInfo, decision);

%% 4. Track boundary check + collision check
for i = 1:numel(candidateCells)

    candidate = candidateCells{i};

    candidate = checkCandidateTrackBounds(candidate, track, decision);
    candidate = checkCandidateCollision(candidate, opponents, track, decision);

    candidates(i,1) = candidate;
end

%% 5. decisionInfo 저장
decisionInfo.leadInfo = leadInfo;
decisionInfo.sideInfo = sideInfo;

end