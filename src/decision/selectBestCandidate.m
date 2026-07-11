function [bestCandidate, bestIndex, selectionInfo] = ...
    selectBestCandidate(candidates, costTable, currentAction, decision)
% selectBestCandidate
% costTable을 이용해 valid candidate 중 best action을 선택한다.
%
% 선택 순서:
%   1. invalid 후보 제외
%   2. totalCost 최소
%   3. totalCost가 거의 동점이면 safetyCost 최소
%   4. 그래도 동점이면 currentAction 유지
%   5. 그래도 동점이면 MAINTAIN_LINE 우선
%   6. 랜덤 선택 없음

arguments
    candidates struct
    costTable table
    currentAction string
    decision struct
end

candidates = candidates(:);
numCandidates = numel(candidates);

if height(costTable) ~= numCandidates
    error("costTable 행 수와 candidate 개수가 다릅니다.");
end

selectionInfo.emergencyFallback = false;
selectionInfo.tieBreakUsed = false;
selectionInfo.reason = "";
selectionInfo.validCandidateCount = sum(costTable.valid);

validIdx = find(costTable.valid);

%% 모든 후보 invalid
if isempty(validIdx)
    bestCandidate = struct();
    bestIndex = NaN;

    selectionInfo.emergencyFallback = true;
    selectionInfo.reason = ...
        "all candidates invalid; no candidate selected";

    warning( ...
        "모든 candidate가 invalid입니다. 일반 주행 candidate를 선택하지 않습니다.");
    return;
end

%% 1차: minimum total cost
validTotalCosts = costTable.totalCost(validIdx);
minTotalCost = min(validTotalCosts);

absoluteTolerance = max( ...
    decision.costTieRelativeTolerance ...
    * max(abs(minTotalCost), 1.0e-3), ...
    1.0e-4);

nearTieIdx = validIdx( ...
    abs(costTable.totalCost(validIdx) - minTotalCost) ...
    <= absoluteTolerance);

if numel(nearTieIdx) == 1
    bestIndex = nearTieIdx(1);
    bestCandidate = candidates(bestIndex);
    selectionInfo.reason = "minimum total cost";
    return;
end

%% 2차: safety cost
selectionInfo.tieBreakUsed = true;
minSafetyCost = min(costTable.safetyCost(nearTieIdx));

safetyTieIdx = nearTieIdx( ...
    abs(costTable.safetyCost(nearTieIdx) - minSafetyCost) ...
    <= 1.0e-6);

if numel(safetyTieIdx) == 1
    bestIndex = safetyTieIdx(1);
    bestCandidate = candidates(bestIndex);
    selectionInfo.reason = ...
        "near tie in total cost; minimum safety cost";
    return;
end

%% 3차: current action 유지
actionNames = string(costTable.actionName);

currentIdx = safetyTieIdx( ...
    actionNames(safetyTieIdx) == currentAction);

if ~isempty(currentIdx)
    bestIndex = currentIdx(1);
    bestCandidate = candidates(bestIndex);
    selectionInfo.reason = ...
        "total and safety tie; kept current action";
    return;
end

%% 4차: MAINTAIN_LINE 우선
maintainIdx = safetyTieIdx( ...
    actionNames(safetyTieIdx) == "MAINTAIN_LINE");

if ~isempty(maintainIdx)
    bestIndex = maintainIdx(1);
    bestCandidate = candidates(bestIndex);
    selectionInfo.reason = ...
        "total and safety tie; MAINTAIN_LINE fallback";
    return;
end

%% 5차: deterministic fallback
bestIndex = safetyTieIdx(1);
bestCandidate = candidates(bestIndex);
selectionInfo.reason = "deterministic first-candidate fallback";

end
