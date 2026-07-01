function targets = determineOvertakeSideTargets(ego, leadOpponent, track, decisionParams)
% determineOvertakeSideTargets
% 내측/외측 추월 기동을 위한 목표 lateral offset(d)과 속도를 결정한다.
%
% 목표 d는
%   1. 앞차 d 기준 ± overtakeOffset 만큼 이동
%   2. 트랙 폭(widthLeft / widthRight) 내에서 안전 마진을 고려해 clamping
%
% d > 0 : 센터라인 기준 왼쪽 (외측)
% d < 0 : 센터라인 기준 오른쪽 (내측)
%
% 입력:
%   ego          : ego 차량 struct  (.s, .d, .v)
%   leadOpponent : 앞차 struct (없으면 [])
%   track        : 전처리된 트랙 struct
%   decisionParams: decision 파라미터 struct
%
% 출력:
%   targets.insideD   내측 추월 목표 d [m]
%   targets.outsideD  외측 추월 목표 d [m]
%   targets.insideV   내측 추월 목표 속도 [m/s]
%   targets.outsideV  외측 추월 목표 속도 [m/s]

arguments
    ego          struct
    leadOpponent          % struct 또는 []
    track        struct
    decisionParams struct
end

%% ego s 위치에서 트랙 폭 보간
sRef = mod(ego.s, track.length);
[widthL, widthR] = localInterpolateWidths(track, sRef);

%% 트랙 사용 가능 범위 (안전 마진 적용)
dMaxLeft  =  widthL - decisionParams.trackMarginLeft;
dMaxRight = -(widthR - decisionParams.trackMarginRight);

%% 기준 d: 앞차가 있으면 앞차 d, 없으면 0
if isempty(leadOpponent)
    baseD = 0.0;
else
    baseD = leadOpponent.d;
end

%% 원래 목표 d (오프셋 적용)
insideRaw  = baseD + decisionParams.overtakeInsideOffsetD;
outsideRaw = baseD + decisionParams.overtakeOutsideOffsetD;

%% 트랙 범위로 clamping
targets.insideD  = max(dMaxRight, min(dMaxLeft, insideRaw));
targets.outsideD = max(dMaxRight, min(dMaxLeft, outsideRaw));

%% 목표 속도 (현재 ego 속도 + boost)
targets.insideV  = ego.v + decisionParams.overtakeSpeedBoost;
targets.outsideV = ego.v + decisionParams.overtakeSpeedBoost;

end

%% ── 로컬 헬퍼: 트랙 폭 보간 ──────────────────────────────────────────────
function [widthL, widthR] = localInterpolateWidths(track, sRef)
% 폐곡선 연속성을 위해 s=length 지점에 첫 번째 포인트를 추가하여 보간

sData      = [track.s(:);          track.length       ];
wLeftData  = [track.widthLeft(:);  track.widthLeft(1) ];
wRightData = [track.widthRight(:); track.widthRight(1)];

widthL = interp1(sData, wLeftData,  sRef, 'linear');
widthR = interp1(sData, wRightData, sRef, 'linear');

% 보간 실패 시 최솟값으로 fallback
if isnan(widthL),  widthL = min(track.widthLeft);  end
if isnan(widthR),  widthR = min(track.widthRight); end

end
