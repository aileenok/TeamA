function opponent = updateOpponentState(opponent, track, dt, params, currentTime, targetLaps)
% updateOpponentState
% 상대 차량 1대의 상태를 한 time step 업데이트하는 함수

arguments
    opponent struct
    track struct
    dt (1,1) double {mustBePositive}
    params struct
    currentTime (1,1) double
    targetLaps (1,1) double {mustBeInteger, mustBePositive}
end

%% 이미 완주했으면 위치는 더 업데이트하지 않음
if opponent.hasFinished
    return;
end

%% 1. behaviorType에 따른 속도 업데이트
switch opponent.behaviorType

    case "constant"
        accel = 0.0;

    case "random_speed"
        accel = params.randomAccelStd * randn();
        accel = min(max(accel, -params.maxDecel), params.maxAccel);

    otherwise
        accel = 0.0;
end

%% 2. 속도 업데이트 및 제한
opponent.v = opponent.v + accel * dt;
opponent.v = min(max(opponent.v, params.minSpeed), params.maxSpeed);

%% 3. 누적 주행거리 업데이트
distanceStep = opponent.v * dt;
opponent.distanceTravelled = opponent.distanceTravelled + distanceStep;

%% 4. lap 수 계산
opponent.completedLaps = floor(opponent.distanceTravelled / track.length);

if opponent.completedLaps >= targetLaps
    opponent.hasFinished = true;
    opponent.finishTime = currentTime;
end

%% 5. s-coordinate 업데이트
opponent.s = mod(opponent.s + distanceStep, track.length);

%% 6. Frenet 좌표를 전역 좌표로 변환
opponent.position = frenetToGlobalCustom(track, opponent.s, opponent.d);

%% 7. history 저장
opponent.history.s(end+1, 1) = opponent.s;
opponent.history.d(end+1, 1) = opponent.d;
opponent.history.v(end+1, 1) = opponent.v;
opponent.history.x(end+1, 1) = opponent.position(1);
opponent.history.y(end+1, 1) = opponent.position(2);

end