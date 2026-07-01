function bestCandidate = selectBestCandidateByCost(candidateSet)
% selectBestCandidateByCost
% valid 후보 중 totalCost가 가장 낮은 후보를 선택한다.  ← 다음 단계에서 구현 예정
%
% 입력:
%   candidateSet : generateCandidateActions 출력 cell array
%
% 출력:
%   bestCandidate : totalCost 최소 후보 struct
%                   valid 후보가 없으면 maintain_line 후보를 fallback으로 반환

% TODO: evaluateCandidateCost 구현 후 실제 선택 로직 작성

% fallback: 첫 번째 valid 후보 반환
bestCandidate = [];

for i = 1:numel(candidateSet)
    if candidateSet{i}.valid
        bestCandidate = candidateSet{i};
        return;
    end
end

% 모두 invalid이면 첫 번째(maintain_line) 반환
if isempty(bestCandidate)
    bestCandidate = candidateSet{1};
end

end
