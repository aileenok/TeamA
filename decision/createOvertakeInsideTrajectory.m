function candidate = createOvertakeInsideTrajectory(ego, track, targets, decisionParams)
% createOvertakeInsideTrajectory
% 앞차의 내측(오른쪽, d < 0)으로 추월하는 후보 궤적 생성.
%
% targets 구조체는 determineOvertakeSideTargets 로부터 얻는다.
%   targets.insideD  : 트랙 범위 내로 clamping된 목표 d
%   targets.insideV  : 목표 속도 (ego + boost)
%
% 입력:
%   ego           : ego 차량 struct  (.s, .d, .v)
%   track         : 전처리된 트랙 struct
%   targets       : determineOvertakeSideTargets 출력 struct
%   decisionParams: decision 파라미터 struct
%
% 출력:
%   candidate : createCandidateTrajectory 공통 구조체

arguments
    ego           struct
    track         struct
    targets       struct
    decisionParams struct
end

targetD = targets.insideD;
targetV = targets.insideV;

candidate = createCandidateTrajectory( ...
    ego, track, targetD, targetV, ...
    "overtake_inside", "overtake_inside", decisionParams);

end
