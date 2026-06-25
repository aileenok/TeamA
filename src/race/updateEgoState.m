function ego = updateEgoState(ego, track, dt, currentTime, targetLaps)
% updateEgoState
% ego 차량 상태를 한 time step 업데이트하는 함수

arguments
    ego struct
    track struct
    dt (1,1) double {mustBePositive}
    currentTime (1,1) double
    targetLaps (1,1) double {mustBeInteger, mustBePositive}
end

%% 이미 완주했으면 위치는 더 업데이트하지 않음
if ego.hasFinished
    return;
end

%% 1. 누적 주행거리 업데이트
distanceStep = ego.v * dt;
ego.distanceTravelled = ego.distanceTravelled + distanceStep;

%% 2. lap 수 계산
ego.completedLaps = floor(ego.distanceTravelled / track.length);

if ego.completedLaps >= targetLaps
    ego.hasFinished = true;
    ego.finishTime = currentTime;
end

%% 3. s 좌표 업데이트
ego.s = mod(ego.s + distanceStep, track.length);

%% 4. Frenet 좌표를 전역 좌표로 변환
ego.position = frenetToGlobalCustom(track, ego.s, ego.d);

%% 5. history 저장
ego.history.s(end+1, 1) = ego.s;
ego.history.d(end+1, 1) = ego.d;
ego.history.v(end+1, 1) = ego.v;
ego.history.x(end+1, 1) = ego.position(1);
ego.history.y(end+1, 1) = ego.position(2);

end