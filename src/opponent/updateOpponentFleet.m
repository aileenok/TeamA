function opponents = updateOpponentFleet(opponents, track, dt, params, currentTime, targetLaps)
% updateOpponentFleet
% 여러 대의 상대 차량 상태를 한 time step만큼 업데이트하는 함수

arguments
    opponents (:,1) struct
    track struct
    dt (1,1) double {mustBePositive}
    params struct
    currentTime (1,1) double
    targetLaps (1,1) double {mustBeInteger, mustBePositive}
end

for i = 1:numel(opponents)
    opponents(i) = updateOpponentState( ...
        opponents(i), track, dt, params, currentTime, targetLaps);
end

end