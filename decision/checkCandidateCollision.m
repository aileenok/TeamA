function candidate = checkCandidateCollision(candidate, opponents, track, decisionParams)
% checkCandidateCollision
% 후보 궤적이 opponent 차량과 충돌하는지 확인한다.
%
% opponent 미래 위치는 등속(constant velocity) + 현재 d 유지 가정으로 추정한다.
% 각 time step에서 Euclidean 거리가 safetyRadius 미만이면 invalid로 처리.
%
% 입력:
%   candidate     : createCandidateTrajectory 출력 struct
%   opponents     : opponent 차량 struct 배열  (:,1)
%   track         : 전처리된 트랙 struct  (.length 필수)
%   decisionParams: decision 파라미터 struct  (.safetyRadius)
%
% 출력:
%   candidate : .valid / .invalidReason 업데이트된 struct

arguments
    candidate     struct
    opponents     (:,1) struct
    track         struct
    decisionParams struct
end

%% 이미 invalid이면 스킵
if ~candidate.valid
    return;
end

safetyRadius = decisionParams.safetyRadius;
N            = numel(candidate.time);
numOpponents = numel(opponents);

for i = 1:numOpponents
    for k = 1:N
        t = candidate.time(k);

        % 등속 직진으로 opponent 미래 위치 추정
        sOpp  = mod(opponents(i).s + opponents(i).v * t, track.length);
        dOpp  = opponents(i).d;

        posOpp = frenetToGlobalCustom(track, sOpp, dOpp);

        dx   = candidate.x(k) - posOpp(1);
        dy   = candidate.y(k) - posOpp(2);
        dist = sqrt(dx*dx + dy*dy);

        if dist < safetyRadius
            candidate.valid         = false;
            candidate.invalidReason = "collision_" + opponents(i).name;
            return;
        end
    end
end

end
