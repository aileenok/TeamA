function lapTime = computeLapTime(speedProfile)
% computeLapTime
% velocity profile을 이용해 한 바퀴 lap time을 계산하는 함수
%
% 입력:
%   speedProfile.ds : 각 구간 길이 [m]
%   speedProfile.v  : 각 지점 속도 [m/s]
%
% 출력:
%   lapTime : 예상 lap time [s]

arguments
    speedProfile struct
end

ds = speedProfile.ds(:);
v = speedProfile.v(:);

if length(ds) ~= length(v)
    error("ds와 velocity의 길이가 같아야 합니다.");
end

% 0으로 나누는 상황 방지
minSpeed = 0.1;
vSafe = max(v, minSpeed);

% 각 구간 시간 = 구간 길이 / 해당 구간 속도
lapTime = sum(ds ./ vSafe);

end