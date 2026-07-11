function [candidates, decisionInfo] = generateCandidateActions( ...
    track, ego, opponents, decision)
% generateCandidateActions
% 기존 candidate action 생성 구조를 그대로 사용해 4개 후보를 만든다.
%
% Action set:
%   1. MAINTAIN_LINE
%   2. OVERTAKE_INSIDE
%   3. OVERTAKE_OUTSIDE
%   4. RETURN_TO_LINE
%
% 기존 helper 재사용:
%   findLeadOpponentForDecision
%   determineOvertakeSideTargets
%   createMaintainLineTrajectory
%   createOvertakeInsideTrajectory
%   createOvertakeOutsideTrajectory
%   createReturnToLineTrajectory
%   checkCandidateTrackBounds
%   checkCandidateCollision

arguments
    track struct
    ego struct
    opponents struct
    decision struct
end

opponents = opponents(:);

%% 1. Lead vehicle 탐색
leadInfo = findLeadOpponentForDecision( ...
    ego, ...
    opponents, ...
    track, ...
    decision);

%% 2. Inside / Outside target 계산
sideInfo = determineOvertakeSideTargets( ...
    track, ...
    ego, ...
    leadInfo, ...
    decision);

%% 3. 4개 candidate 생성
candidate1 = createMaintainLineTrajectory( ...
    track, ego, leadInfo, decision);

candidate2 = createOvertakeInsideTrajectory( ...
    track, ego, leadInfo, sideInfo, decision);

candidate3 = createOvertakeOutsideTrajectory( ...
    track, ego, leadInfo, sideInfo, decision);

candidate4 = createReturnToLineTrajectory( ...
    track, ego, leadInfo, decision);

% createCandidateTrajectory가 모든 action 공통 필드를 미리 만들기 때문에
% 네 candidate는 동일한 struct schema를 가진다.
candidates = [ ...
    candidate1; ...
    candidate2; ...
    candidate3; ...
    candidate4];

%% 4. Action availability 검사
% 앞차가 없으면 추월 후보는 생성 자체는 하되 선택 불가능 처리
if ~leadInfo.hasLead
    candidates(2).isValid = false;
    candidates(2).reason = "action unavailable: no lead vehicle";

    candidates(3).isValid = false;
    candidates(3).reason = "action unavailable: no lead vehicle";
end

% 이미 기준 라인 근처이면 RETURN_TO_LINE은 의미가 없음
if candidates(4).alreadyNearReferenceLine
    candidates(4).isValid = false;
    candidates(4).reason = ...
        "action unavailable: ego already near reference line";
end

%% 5. 기존 track boundary / collision 검사
for i = 1:numel(candidates)

    if candidates(i).isValid
        candidates(i) = checkCandidateTrackBounds( ...
            candidates(i), ...
            track, ...
            decision);
    end

    if candidates(i).isValid
        candidates(i) = checkCandidateCollision( ...
            candidates(i), ...
            opponents, ...
            track, ...
            decision);
    end
end

%% 6. Decision info
% run_step08에서 이미 사용하는 출력 구조를 유지한다.
decisionInfo.leadInfo = leadInfo;
decisionInfo.sideInfo = sideInfo;

end
