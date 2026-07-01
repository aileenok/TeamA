function candidate = createReturnToLineTrajectory(ego, track, decisionParams)
% createReturnToLineTrajectory
% 추월 기동 후 센터라인으로 복귀하는 후보 궤적 생성.
%
% 목표 d : decisionParams.returnLineTargetD  (기본값 0.0 = 센터라인)
% 목표 v : 현재 ego 속도 유지
%
% 현재 d가 이미 목표 d에 가까우면 궤적이 거의 직선이 된다.
%
% 입력:
%   ego           : ego 차량 struct  (.s, .d, .v)
%   track         : 전처리된 트랙 struct
%   decisionParams: decision 파라미터 struct
%
% 출력:
%   candidate : createCandidateTrajectory 공통 구조체

arguments
    ego           struct
    track         struct
    decisionParams struct
end

targetD = decisionParams.returnLineTargetD;
targetV = ego.v;   % 속도 유지

candidate = createCandidateTrajectory( ...
    ego, track, targetD, targetV, ...
    "return_to_line", "return", decisionParams);

end
