function candidateSet = generateCandidateActions(ego, opponents, track, decisionParams)
% generateCandidateActions
% Ego 차량의 후보 action 집합을 생성하고 유효성을 검사하는 메인 함수.
%
% 처리 순서:
%   1. findLeadOpponentForDecision  → 전방 가장 가까운 opponent 탐색
%   2. determineOvertakeSideTargets → 추월 방향별 목표 d, v 결정
%   3. 4가지 후보 궤적 생성:
%      (a) maintain_line    – 현재 라인 유지
%      (b) overtake_inside  – 내측(오른쪽) 추월
%      (c) overtake_outside – 외측(왼쪽) 추월
%      (d) return_to_line   – 센터라인 복귀
%   4. checkCandidateTrackBounds  → 트랙 범위 이탈 여부 확인
%   5. checkCandidateCollision    → opponent와의 충돌 여부 확인
%   6. leadInfo를 각 후보에 첨부 (비용 평가 단계에서 활용)
%
% 입력:
%   ego           : ego 차량 struct  (.s, .d, .v)
%   opponents     : opponent 차량 struct 배열  (:,1)
%   track         : 전처리된 트랙 struct
%   decisionParams: decision 파라미터 struct  (config/decisionParams.m)
%
% 출력:
%   candidateSet  : cell array {1×4}
%                   각 원소는 candidate struct
%                   .valid = true/false 로 유효 여부 표시

arguments
    ego           struct
    opponents     (:,1) struct
    track         struct
    decisionParams struct
end

candidateSet = {};

%% ── 1. 앞차 탐색 ─────────────────────────────────────────────────────────
leadInfo = findLeadOpponentForDecision(ego, opponents, track, decisionParams);

%% ── 2. 추월 방향 목표 결정 ───────────────────────────────────────────────
targets = determineOvertakeSideTargets( ...
    ego, leadInfo.opponent, track, decisionParams);

%% ── 3. 후보 궤적 생성 ────────────────────────────────────────────────────
c1 = createMaintainLineTrajectory(ego, track, decisionParams);
c2 = createOvertakeInsideTrajectory(ego, track, targets, decisionParams);
c3 = createOvertakeOutsideTrajectory(ego, track, targets, decisionParams);
c4 = createReturnToLineTrajectory(ego, track, decisionParams);

%% ── 4. 트랙 범위 확인 ────────────────────────────────────────────────────
c1 = checkCandidateTrackBounds(c1, track, decisionParams);
c2 = checkCandidateTrackBounds(c2, track, decisionParams);
c3 = checkCandidateTrackBounds(c3, track, decisionParams);
c4 = checkCandidateTrackBounds(c4, track, decisionParams);

%% ── 5. 충돌 확인 ─────────────────────────────────────────────────────────
c1 = checkCandidateCollision(c1, opponents, track, decisionParams);
c2 = checkCandidateCollision(c2, opponents, track, decisionParams);
c3 = checkCandidateCollision(c3, opponents, track, decisionParams);
c4 = checkCandidateCollision(c4, opponents, track, decisionParams);

%% ── 6. leadInfo 첨부 (비용 평가 단계에서 사용) ───────────────────────────
c1.leadInfo = leadInfo;
c2.leadInfo = leadInfo;
c3.leadInfo = leadInfo;
c4.leadInfo = leadInfo;

%% ── 7. 결과 수집 ─────────────────────────────────────────────────────────
candidateSet{end+1} = c1;
candidateSet{end+1} = c2;
candidateSet{end+1} = c3;
candidateSet{end+1} = c4;

end
