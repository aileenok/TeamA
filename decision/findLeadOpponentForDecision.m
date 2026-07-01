function leadInfo = findLeadOpponentForDecision(ego, opponents, track, decisionParams)
% findLeadOpponentForDecision
% Decision 모듈용 앞차 탐색 함수.
%
% track.length 기반 closed-track mod 연산으로
% ego 기준 전방의 가장 가까운 차량을 찾는다.
%
% 입력:
%   ego           : ego 차량 struct  (.s, .d, .v)
%   opponents     : opponent 차량 struct 배열  (:,1)
%   track         : 전처리된 트랙 struct  (.length 필수)
%   decisionParams: decision 파라미터 struct
%
% 출력:
%   leadInfo.hasLead       logical  – 유효한 앞차 존재 여부
%   leadInfo.opponent      opponent struct  (없으면 [])
%   leadInfo.leadIndex     opponents 배열에서의 인덱스  (없으면 NaN)
%   leadInfo.gap           ego→앞차 종방향 거리 [m]
%   leadInfo.relativeSpeed ego.v - lead.v  [m/s], 양수 = 접근 중
%   leadInfo.ttc           TTC [s]

arguments
    ego           struct
    opponents     (:,1) struct
    track         struct
    decisionParams struct
end

%% 초기화
leadInfo.hasLead       = false;
leadInfo.opponent      = [];
leadInfo.leadIndex     = NaN;
leadInfo.gap           = inf;
leadInfo.relativeSpeed = NaN;
leadInfo.ttc           = inf;

numOpponents = numel(opponents);

for i = 1:numOpponents

    % closed-track gap: ego → opponent (항상 양수, 전방 방향)
    gap = mod(opponents(i).s - ego.s, track.length);

    % 같은 위치로 간주되는 경우 스킵
    if gap < 1e-6
        continue;
    end

    % look-ahead 거리 이내에서 가장 가까운 앞차 선택
    if gap < decisionParams.lookAheadDistance && gap < leadInfo.gap
        leadInfo.hasLead       = true;
        leadInfo.opponent      = opponents(i);
        leadInfo.leadIndex     = i;
        leadInfo.gap           = gap;
        leadInfo.relativeSpeed = ego.v - opponents(i).v;
    end
end

%% TTC 계산
if leadInfo.hasLead
    leadInfo.ttc = computeTTC(leadInfo.gap, leadInfo.relativeSpeed);
end

end
