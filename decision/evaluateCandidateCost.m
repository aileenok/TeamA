function candidate = evaluateCandidateCost(candidate, ego, opponents, track, decisionParams)
% evaluateCandidateCost
% 후보 궤적의 비용을 계산한다.  ← 다음 단계에서 구현 예정
%
% 비용 구성 (예정):
%   costProgress  : 진행 거리 기반 속도 비용 (작을수록 좋음)
%   costLateral   : 센터라인 이탈 비용
%   costTTC       : TTC 기반 안전 비용
%   costCollision : 충돌 패널티
%   totalCost     : 가중합
%
% 입력:
%   candidate     : generateCandidateActions 출력 struct
%   ego           : ego 차량 struct
%   opponents     : opponent 차량 struct 배열
%   track         : 전처리된 트랙 struct
%   decisionParams: decision 파라미터 struct
%
% 출력:
%   candidate : .costProgress .costLateral .costTTC .costCollision .totalCost 추가

% TODO: 비용 함수 구현

candidate.costProgress  = 0;
candidate.costLateral   = 0;
candidate.costTTC       = 0;
candidate.costCollision = 0;
candidate.totalCost     = 0;

end
