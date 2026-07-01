function selectedActionName = selectCandidateForAnimation(candidates)
% selectCandidateForAnimation
% 애니메이션으로 확인할 candidate를 자동 선택한다.
%
% 현재는 cost-based decision 전 단계이므로,
% valid candidate 중 우선순위에 따라 선택한다.

candidateNames = string({candidates.name});
candidateValid = [candidates.isValid];

priorityList = [ ...
    "OVERTAKE_INSIDE", ...
    "OVERTAKE_OUTSIDE", ...
    "MAINTAIN_LINE", ...
    "RETURN_TO_LINE"];

for i = 1:numel(priorityList)

    actionName = priorityList(i);

    idx = find(candidateNames == actionName & candidateValid, 1);

    if ~isempty(idx)
        selectedActionName = actionName;

        fprintf("\n=== Selected Candidate for Animation ===\n");
        fprintf("Selected action: %s\n", selectedActionName);
        fprintf("Reason: first valid action based on priority list\n");

        return;
    end
end

% 모든 후보가 invalid면 디버깅 목적으로 첫 번째 후보 표시
selectedActionName = candidateNames(1);

warning("모든 candidate가 invalid입니다. 디버깅을 위해 첫 번째 candidate를 표시합니다: %s", ...
    selectedActionName);

end