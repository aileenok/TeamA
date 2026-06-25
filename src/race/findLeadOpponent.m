function leadInfo = findLeadOpponent(ego, opponents, track, lookAheadDistance)
% findLeadOpponent
% ego 차량 기준으로 가장 가까운 앞차를 찾는 함수
%
% 폐곡선 트랙이므로 단순 opponent.s - ego.s가 아니라
% mod 연산으로 앞쪽 거리 gap을 계산한다.
%
% gap > 0 이면 ego 기준 앞쪽에 있음.
% gap이 가장 작고 lookAheadDistance 안에 있는 차량을 lead vehicle로 선택한다.

arguments
    ego struct
    opponents (:,1) struct
    track struct
    lookAheadDistance (1,1) double {mustBePositive}
end

numOpponents = numel(opponents);

leadInfo.hasLead = false;
leadInfo.leadIndex = NaN;
leadInfo.leadName = "";
leadInfo.gap = inf;
leadInfo.relativeSpeed = NaN;

for i = 1:numOpponents

    % ego에서 opponent까지 트랙 진행 방향 기준 거리
    gap = mod(opponents(i).s - ego.s, track.length);

    % gap이 0에 너무 가까우면 같은 위치로 간주
    if gap < 1e-6
        continue;
    end

    % look-ahead 범위 안의 가장 가까운 앞차 선택
    if gap < lookAheadDistance && gap < leadInfo.gap
        leadInfo.hasLead = true;
        leadInfo.leadIndex = i;
        leadInfo.leadName = opponents(i).name;
        leadInfo.gap = gap;
        leadInfo.relativeSpeed = ego.v - opponents(i).v;
    end
end

end