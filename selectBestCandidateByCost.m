function bestCandidate = selectBestCandidateByCost(candidates)
% selectBestCandidateByCost
% valid 후보 중 totalCost가 가장 낮은 후보를 선택한다.
%
% 전제:
%   candidates의 각 원소는 evaluateCandidateCost를 거쳐
%   isValid, totalCost 필드가 채워져 있어야 한다.
%
% 입력:
%   candidates : generateCandidateActions 출력 struct 배열
%                (N x 1 또는 1 x N, evaluateCandidateCost 적용 후)
%
% 출력:
%   bestCandidate : valid 후보 중 totalCost 최소인 후보 struct.
%                   valid 후보가 하나도 없으면 첫 번째 후보(보통 MAINTAIN_LINE)를
%                   fallback으로 반환하고 warning을 출력한다.

arguments
    candidates struct
end

% row/column 구조체 배열 모두 처리 가능하게 정리
candidates = candidates(:);

validMask = [candidates.isValid];

if ~any(validMask)
    % 모든 후보가 invalid인 경우 디버깅을 위해 첫 번째 후보를 반환한다.
    bestCandidate = candidates(1);

    warning(("selectBestCandidateByCost: 모든 candidate가 invalid입니다. " + ...
        "fallback으로 첫 번째 candidate(%s)를 반환합니다."), candidates(1).name);

    return;
end

totalCosts = [candidates.totalCost];

% invalid 후보는 (이미 invalidCostPenalty가 더해져 있지만) 이중 안전장치로
% 비교 대상에서 완전히 배제되도록 Inf로 마스킹한다.
totalCosts(~validMask) = Inf;

[~, bestIdx] = min(totalCosts);

bestCandidate = candidates(bestIdx);

end
