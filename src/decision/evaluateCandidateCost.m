function candidate = evaluateCandidateCost(candidate, ego, opponents, track, decision)
% evaluateCandidateCost
% 후보 궤적의 비용을 계산한다.
%
% 비용 구성:
%   costCollision : 충돌/안전 여유(safety buffer) 위반 비용
%                   - hard collision(이미 isValid=false)이면 최대 가중치 부여
%                   - warning buffer 안에 들어온 경우, buffer를 얼마나
%                     침범했는지(s/d 방향 모두)를 정규화하여 벌점 부여
%   costOfftrack  : track 경계 여유 부족 비용
%                   - checkCandidateTrackBounds가 계산해 둔 leftLimit/rightLimit
%                     대비 실제 d 궤적이 얼마나 여유가 있는지를 기반으로 계산
%   costTime      : 위험 상황(충돌/안전 경고)까지 남은 시간 기반 비용
%                   - 같은 gap이라도 그 상황이 horizon 초반에 발생할수록
%                     대응 시간이 부족하므로 더 큰 비용을 부여
%   costProgress  : 진행 속도 기반 비용
%                   - horizon 동안 실제로 이동한 거리(=평균 속도)가
%                     maxCandidateSpeed 기준으로 얼마나 못 미치는지를 비용화
%   totalCost     : 위 네 비용의 합
%                   - invalid 후보는 invalidCostPenalty를 추가로 더해
%                     valid 후보보다 항상 나쁘게 평가되도록 한다.
%
% 입력:
%   candidate : generateCandidateActions / checkCandidateCollision /
%               checkCandidateTrackBounds를 거친 candidate struct
%   ego       : ego 차량 struct (인터페이스 일관성을 위해 유지, 직접 사용은
%               하지 않음 - candidate 자체가 이미 ego 기준으로 생성된 궤적)
%   opponents : opponent 차량 struct 배열 (인터페이스 일관성을 위해 유지,
%               충돌/안전 관련 정보는 checkCandidateCollision에서 candidate에
%               이미 기록되어 있으므로 중복 계산하지 않는다)
%   track     : 전처리된 트랙 struct (인터페이스 일관성을 위해 유지)
%   decision  : decisionParams() 출력 struct (cost 가중치 포함)
%
% 출력:
%   candidate : .costCollision .costOfftrack .costTime .costProgress .totalCost 갱신

arguments
    candidate struct
    ego struct
    opponents (:,1) struct
    track struct
    decision struct
end

%% 0. 초기화
candidate.costCollision = 0.0;
candidate.costOfftrack  = 0.0;
candidate.costTime      = 0.0;
candidate.costProgress  = 0.0;

%% 1. Collision cost
% checkCandidateCollision에서 기록해 둔 collisionRisk / safetyRisk 정보를 재사용한다.
if candidate.collisionRisk
    % hard collision: 이미 isValid = false로 처리된 상태.
    % cost 단계에서도 항상 최악으로 평가되도록 가중치를 그대로 부여한다.
    candidate.costCollision = decision.costWeightCollision;

elseif candidate.safetyRisk
    % warning buffer 안에는 들어왔지만 hard collision은 아닌 경우.
    % warningBuffer -> collisionBuffer로 가까워질수록 0 -> 1로 커지는 severity를 계산한다.
    sRange = decision.warningSBuffer - decision.collisionSBuffer;
    dRange = decision.warningDBuffer - decision.collisionDBuffer;

    sSeverity = (decision.warningSBuffer - candidate.warningSGap) / max(sRange, eps);
    dSeverity = (decision.warningDBuffer - candidate.warningDGap) / max(dRange, eps);

    sSeverity = min(max(sSeverity, 0.0), 1.0);
    dSeverity = min(max(dSeverity, 0.0), 1.0);

    % hard collision 판정(둘 다 가까워야 위험)과 같은 논리로 곱해서 사용.
    proximitySeverity = sSeverity * dSeverity;

    candidate.costCollision = decision.costWeightCollision * proximitySeverity^2;
end

%% 2. Offtrack cost
% checkCandidateTrackBounds가 채워 둔 leftLimit/rightLimit(시간별 벡터)을 이용해
% 궤적이 트랙 경계로부터 얼마나 여유가 있는지 계산한다.
if isempty(candidate.leftLimit) || isempty(candidate.rightLimit)
    % 방어적 처리: track bounds 정보가 없으면 offtrack cost는 0으로 둔다.
    candidate.costOfftrack = 0.0;
else
    d = candidate.d(:);

    marginToLeft  = candidate.leftLimit(:)  - d;
    marginToRight = d - candidate.rightLimit(:);

    % 각 시점에서 더 가까운 경계까지의 여유폭
    marginToEdge = min(marginToLeft, marginToRight);
    minMargin = min(marginToEdge);

    if minMargin < 0
        % 이미 checkCandidateTrackBounds에서 isValid = false 처리된 상황.
        candidate.costOfftrack = decision.costWeightOfftrack;
    else
        % 여유가 offtrackSafeMargin보다 부족한 만큼 비용을 부여한다.
        shortage = max(decision.offtrackSafeMargin - minMargin, 0.0) ...
            / max(decision.offtrackSafeMargin, eps);

        candidate.costOfftrack = decision.costWeightOfftrack * shortage^2;
    end
end

%% 3. Time cost
% 같은 gap이라도 그 상황이 horizon 초반에 발생하면 대응할 시간이 부족하므로
% 더 큰 비용을 부여한다. (collision/offtrack cost는 "얼마나 가까운가",
% time cost는 "언제 그 상황이 오는가"를 반영한다.)
if candidate.collisionRisk
    riskTime = min(candidate.collisionTime, decision.horizon);
    urgency = 1.0 - riskTime / decision.horizon;

    % hard collision은 안전 위반 자체가 확정된 상태이므로 추가 가중을 둔다.
    candidate.costTime = decision.costWeightTime * (1.0 + urgency);

elseif candidate.safetyRisk
    riskTime = min(candidate.safetyTime, decision.horizon);
    urgency = 1.0 - riskTime / decision.horizon;

    candidate.costTime = decision.costWeightTime * urgency;
end

%% 4. Progress cost
% horizon 동안 실제로 이동한 거리(속도 프로파일의 적분)를 계산하고,
% maxCandidateSpeed로 horizon 내내 달렸을 때의 최대 진행 거리와 비교한다.
totalProgress = trapz(candidate.time, candidate.v);
maxProgress = decision.maxCandidateSpeed * candidate.time(end);

progressRatio = totalProgress / max(maxProgress, eps);
progressRatio = min(max(progressRatio, 0.0), 1.0);

candidate.costProgress = decision.costWeightProgress * (1.0 - progressRatio);

%% 5. Total cost
candidate.totalCost = candidate.costCollision + candidate.costOfftrack ...
    + candidate.costTime + candidate.costProgress;

if ~candidate.isValid
    % invalid 후보(hard collision, track boundary violation 등)는
    % totalCost 비교에서 항상 valid 후보보다 나쁘게 평가되도록 고정 패널티를 더한다.
    candidate.totalCost = candidate.totalCost + decision.invalidCostPenalty;
end

end
