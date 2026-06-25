function opponent = createOpponentCar(id, name, s0, d0, speed, behaviorType, track)
% createOpponentCar
% 상대 차량 1대를 생성하는 함수

arguments
    id (1,1) double
    name string
    s0 (1,1) double
    d0 (1,1) double
    speed (1,1) double
    behaviorType string
    track struct
end

opponent.id = id;
opponent.name = name;
opponent.behaviorType = behaviorType;

% Frenet 상태
opponent.s = mod(s0, track.length);
opponent.d = d0;
opponent.v = speed;

% 현재 전역 좌표
opponent.position = frenetToGlobalCustom(track, opponent.s, opponent.d);

% 상태 기록용
opponent.history.s = opponent.s;
opponent.history.d = opponent.d;
opponent.history.v = opponent.v;
opponent.history.x = opponent.position(1);
opponent.history.y = opponent.position(2);

opponent.distanceTravelled = 0.0;
opponent.completedLaps = 0;
opponent.hasFinished = false;
opponent.finishTime = NaN;

end