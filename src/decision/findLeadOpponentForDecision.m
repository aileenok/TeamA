function leadInfo = findLeadOpponentForDecision(ego, opponents, track, decision)
% findLeadOpponentForDecision
% ego 기준 가장 가까운 앞차를 찾는다.
%
% closed track이므로 단순히 opponent.s - ego.s를 쓰면 안 된다.
% 반드시 mod(opponent.s - ego.s, track.length)를 사용한다.

arguments
    ego struct
    opponents (:,1) struct
    track struct
    decision struct
end

leadInfo.hasLead = false;
leadInfo.leadIndex = NaN;
leadInfo.leadName = "";
leadInfo.vehicle = [];
leadInfo.gap = inf;
leadInfo.relativeSpeed = 0.0;
leadInfo.ttc = inf;
leadInfo.closingSpeed = 0.0;

if isempty(opponents)
    return;
end

minGap = inf;
leadIndex = NaN;

for i = 1:numel(opponents)

    gap = mod(opponents(i).s - ego.s, track.length);

    % gap이 거의 0이면 같은 위치이므로 제외
    if gap < 1.0e-6
        continue;
    end

    % 너무 멀리 있는 차량은 이번 decision에서 무시
    if gap > decision.leadLookAheadDistance
        continue;
    end

    if gap < minGap
        minGap = gap;
        leadIndex = i;
    end
end

if isnan(leadIndex)
    return;
end

leadVehicle = opponents(leadIndex);

[ttc, closingSpeed] = computeTTC(minGap, ego.v, leadVehicle.v);

leadInfo.hasLead = true;
leadInfo.leadIndex = leadIndex;
leadInfo.leadName = leadVehicle.name;
leadInfo.vehicle = leadVehicle;
leadInfo.gap = minGap;
leadInfo.relativeSpeed = ego.v - leadVehicle.v;
leadInfo.ttc = ttc;
leadInfo.closingSpeed = closingSpeed;

end