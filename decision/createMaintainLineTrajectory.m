function candidate = createMaintainLineTrajectory(ego, track, decisionParams)
% createMaintainLineTrajectory
% 센터라인을 유지하며 현재 속도로 주행하는 후보 궤적 생성.
%
% 목표 d : decisionParams.maintainLineTargetD  (기본값 0.0 = 센터라인)
% 목표 v : 현재 ego 속도 유지
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

targetD = decisionParams.maintainLineTargetD;
targetV = ego.v;   % 속도 유지

candidate = createCandidateTrajectory( ...
    ego, track, targetD, targetV, ...
    "maintain_line", "maintain", decisionParams);

end
