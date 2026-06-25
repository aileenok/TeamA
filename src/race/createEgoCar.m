function ego = createEgoCar(track, raceParams)
% createEgoCar
% ego 차량 초기 상태를 생성하는 함수
%
% ego 상태는 Frenet 좌표 s,d와 전역 좌표 x,y를 함께 저장한다.

arguments
    track struct
    raceParams struct
end

ego.id = 0;
ego.name = "Ego";

ego.s = mod(raceParams.egoInitialS, track.length);
ego.d = raceParams.egoInitialD;
ego.v = raceParams.egoSpeed;

ego.position = frenetToGlobalCustom(track, ego.s, ego.d);

ego.history.s = ego.s;
ego.history.d = ego.d;
ego.history.v = ego.v;
ego.history.x = ego.position(1);
ego.history.y = ego.position(2);

ego.distanceTravelled = 0.0;
ego.completedLaps = 0;
ego.hasFinished = false;
ego.finishTime = NaN;

end