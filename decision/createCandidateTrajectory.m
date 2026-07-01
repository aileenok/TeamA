function candidate = createCandidateTrajectory( ...
    ego, track, targetD, targetV, candidateName, candidateType, decisionParams)
% createCandidateTrajectory
% Frenet 좌표 기반 후보 궤적을 생성하는 핵심 함수.
%
% ● 횡방향(d) 프로파일 : cosine ease-in/out 전환 (ego.d → targetD)
% ● 종방향(v) 프로파일 : 선형 램프 (ego.v → targetV)
% ● s 프로파일        : 속도 적분, track.length 기반 mod 처리
% ● 전역 좌표(x, y)   : frenetToGlobalCustom 으로 변환
%
% 입력:
%   ego            : ego 차량 struct  (.s, .d, .v)
%   track          : 전처리된 트랙 struct
%   targetD        : 목표 lateral offset [m]
%   targetV        : 목표 속도 [m/s]
%   candidateName  : 후보 라벨 string  (예: "maintain_line")
%   candidateType  : 후보 타입 string  (예: "maintain")
%   decisionParams : decision 파라미터 struct
%
% 출력:
%   candidate.name          string
%   candidate.type          string
%   candidate.time          [1×N]  상대 시간 [s]
%   candidate.s             [1×N]  트랙 진행거리 [m]  (mod 적용)
%   candidate.d             [1×N]  lateral offset [m]
%   candidate.v             [1×N]  속도 [m/s]
%   candidate.x             [1×N]  전역 x [m]
%   candidate.y             [1×N]  전역 y [m]
%   candidate.valid         logical
%   candidate.invalidReason string

arguments
    ego           struct
    track         struct
    targetD       (1,1) double
    targetV       (1,1) double
    candidateName string
    candidateType string
    decisionParams struct
end

N       = decisionParams.N;
dt      = decisionParams.dt;
horizon = decisionParams.horizon;

%% ── 시간 벡터 ────────────────────────────────────────────────────────────
tVec = linspace(0, horizon, N);  % [1×N]

%% ── 속도 프로파일 (선형 램프) ────────────────────────────────────────────
vVec = linspace(ego.v, targetV, N);  % [1×N]

%% ── s 프로파일 (속도 적분, closed-track mod) ─────────────────────────────
sVec    = zeros(1, N);
sVec(1) = ego.s;

for k = 2:N
    ds_step = vVec(k-1) * (tVec(k) - tVec(k-1));
    sVec(k) = mod(sVec(k-1) + ds_step, track.length);
end

%% ── 횡방향 프로파일 (cosine ease-in/out) ────────────────────────────────
% alpha ∈ [0, 1], 부드럽게 0→1 전환
alpha = (1 - cos(pi * (0:N-1) / (N-1))) / 2;  % [1×N]
dVec  = ego.d + alpha .* (targetD - ego.d);    % [1×N]

%% ── 전역 좌표 변환 ───────────────────────────────────────────────────────
xVec = zeros(1, N);
yVec = zeros(1, N);

for k = 1:N
    pos      = frenetToGlobalCustom(track, sVec(k), dVec(k));
    xVec(k)  = pos(1);
    yVec(k)  = pos(2);
end

%% ── 후보 구조체 조립 ─────────────────────────────────────────────────────
candidate.name          = candidateName;
candidate.type          = candidateType;
candidate.time          = tVec;
candidate.s             = sVec;
candidate.d             = dVec;
candidate.v             = vVec;
candidate.x             = xVec;
candidate.y             = yVec;
candidate.valid         = true;
candidate.invalidReason = "";

end
