function [targetV, speedMode] = computeMaintainTargetSpeed(ego, leadInfo, decision)
% computeMaintainTargetSpeed
% MAINTAIN_LINE 후보의 목표 속도를 결정한다.
%
% 의미:
%   - 앞차가 없으면 현재 속도 유지
%   - 앞차가 있지만 충분히 멀면 현재 속도 유지
%   - gap/TTC가 작아지면 앞차 속도에 맞춰 감속
%   - 매우 가까우면 앞차보다 약간 느리게 설정

arguments
    ego struct
    leadInfo struct
    decision struct
end

speedMode = "free";

if ~leadInfo.hasLead
    targetV = ego.v;
    targetV = clampSpeed(targetV, decision);
    return;
end

leadV = leadInfo.vehicle.v;
gap = leadInfo.gap;
ttc = leadInfo.ttc;

if gap < decision.safeGap || ttc < decision.ttcCritical
    % 매우 가까움: 앞차보다 약간 느리게
    targetV = leadV - decision.maintainSpeedMargin;
    speedMode = "critical_slowdown";

elseif gap < decision.followGap || ttc < decision.ttcCaution
    % 주의 구간: ego 속도와 앞차 속도 사이로 완만하게 조정
    targetV = 0.5 * ego.v + 0.5 * leadV;
    speedMode = "caution_adjust";

else
    % 아직 충분히 멀면 현재 속도 유지
    targetV = ego.v;
    speedMode = "free";
end

targetV = clampSpeed(targetV, decision);

end

function v = clampSpeed(v, decision)
% 속도 제한

v = min(max(v, decision.minCandidateSpeed), decision.maxCandidateSpeed);

end