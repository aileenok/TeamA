function candidate = checkCandidateCollision(candidate, opponents, track, decision)
% checkCandidateCollision
% candidate trajectory와 opponent predicted trajectory 사이의 충돌 위험 검사
%
% 구분:
%   collision buffer 안에 들어오면 invalid 처리
%   warning buffer 안에만 들어오면 valid는 유지하고 safetyRisk만 표시
%
% 이유:
%   레이싱 상황에서 20~25 m gap은 실제 충돌이라기보다
%   cost 단계에서 벌점으로 처리할 거리이다.

arguments
    candidate struct
    opponents (:,1) struct
    track struct
    decision struct
end

if ~candidate.isValid
    return;
end

candidate.collisionRisk = false;
candidate.collisionOpponentIndex = NaN;
candidate.collisionOpponentName = "";
candidate.collisionTime = NaN;
candidate.minCollisionSGap = inf;
candidate.minCollisionDGap = inf;

candidate.safetyRisk = false;
candidate.safetyOpponentIndex = NaN;
candidate.safetyOpponentName = "";
candidate.safetyTime = NaN;
candidate.warningSGap = inf;
candidate.warningDGap = inf;

if isempty(opponents)
    candidate.reason = "valid";
    return;
end

t = candidate.time(:);
numSteps = length(t);

for i = 1:numel(opponents)

    oppS0 = opponents(i).s;
    oppD = opponents(i).d;
    oppV = opponents(i).v;

    for k = 1:numSteps

        %% opponent 미래 위치 예측
        oppS = mod(oppS0 + oppV * t(k), track.length);

        %% ego candidate 위치
        egoS = candidate.s(k);
        egoD = candidate.d(k);

        %% closed track 기준 s 방향 거리
        rawSGap = abs(egoS - oppS);
        sGap = min(rawSGap, track.length - rawSGap);

        %% lateral 거리
        dGap = abs(egoD - oppD);

        %% 최소 gap 기록
        if sGap < candidate.minCollisionSGap
            candidate.minCollisionSGap = sGap;
            candidate.minCollisionDGap = dGap;
        end

        %% 1. hard collision check
        isHardLongitudinalClose = sGap < decision.collisionSBuffer;
        isHardLateralClose = dGap < decision.collisionDBuffer;

        if isHardLongitudinalClose && isHardLateralClose

            candidate.isValid = false;
            candidate.collisionRisk = true;
            candidate.collisionOpponentIndex = i;
            candidate.collisionOpponentName = opponents(i).name;
            candidate.collisionTime = t(k);

            candidate.reason = string(sprintf( ...
                "hard collision risk with %s at t = %.2f s, sGap = %.2f m, dGap = %.2f m", ...
                opponents(i).name, t(k), sGap, dGap));

            return;
        end

        %% 2. safety warning check
        % warning 구간은 invalid가 아니라 cost 단계에서 벌점으로 처리한다.
        isWarningLongitudinalClose = sGap < decision.warningSBuffer;
        isWarningLateralClose = dGap < decision.warningDBuffer;

        if isWarningLongitudinalClose && isWarningLateralClose

            % 첫 번째 safety risk만 기록
            if ~candidate.safetyRisk
                candidate.safetyRisk = true;
                candidate.safetyOpponentIndex = i;
                candidate.safetyOpponentName = opponents(i).name;
                candidate.safetyTime = t(k);
                candidate.warningSGap = sGap;
                candidate.warningDGap = dGap;
            end
        end
    end
end

if candidate.safetyRisk
    candidate.reason = string(sprintf( ...
        "valid with safety warning near %s at t = %.2f s, sGap = %.2f m, dGap = %.2f m", ...
        candidate.safetyOpponentName, ...
        candidate.safetyTime, ...
        candidate.warningSGap, ...
        candidate.warningDGap));
else
    candidate.reason = "valid";
end

end