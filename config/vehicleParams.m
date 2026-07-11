function vehicle = vehicleParams(mode)
% vehicleParams
% 프로젝트 차량의 형상 및 성능 파라미터 정의

arguments
    mode string = "race"
end

%% 공통 차량 형상
vehicle.g = 9.81;

% 프로젝트용 고속 레이싱카 형상 가정
vehicle.length = 5.50;       % [m]
vehicle.width = 1.90;        % [m]
vehicle.wheelbase = 2.80;    % [m]

switch lower(mode)

    case "conservative"

        vehicle.name = "Conservative baseline vehicle";

        vehicle.maxSteer = deg2rad(20);

        vehicle.minSpeed = 0.0;
        vehicle.maxSpeed = 60.0;

        vehicle.maxAccel = 4.0;
        vehicle.maxDecel = 8.0;

        vehicle.mu = 1.20;

    case "race"

        vehicle.name = "Race car assumption";

        vehicle.maxSteer = deg2rad(20);

        vehicle.minSpeed = 0.0;
        vehicle.maxSpeed = 83.3;

        vehicle.maxAccel = 8.0;
        vehicle.maxDecel = 14.0;

        vehicle.mu = 1.60;

    otherwise
        error("지원하지 않는 vehicle mode입니다: %s", mode);
end

%% 동역학 관련 파생 파라미터
vehicle.maxLateralAccel = vehicle.mu * vehicle.g;

% 현재는 CG가 wheelbase 중앙에 있다고 단순 가정
vehicle.cgToFront = vehicle.wheelbase / 2;
vehicle.cgToRear = vehicle.wheelbase / 2;

%% 단위 변환
vehicle.maxSpeedKph = vehicle.maxSpeed * 3.6;

end