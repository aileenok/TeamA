function vehicle = vehicleParams(mode)
% vehicleParams
% 차량 파라미터를 정의하는 함수
%
% 입력:
%   mode : 차량 파라미터 모드
%          "conservative"  - 보수적인 baseline용
%          "race"          - 레이싱카 가정 baseline용
%
% 출력:
%   vehicle : 차량 파라미터 구조체

arguments
    mode string = "race"
end

%% 공통 파라미터
vehicle.g = 9.81;     % [m/s^2] 중력가속도

switch lower(mode)

    case "conservative"
        % 보수적인 초기 검증용 파라미터
        % 알고리즘이 정상 작동하는지 확인할 때 사용

        vehicle.name = "Conservative baseline vehicle";

        vehicle.wheelbase = 1.60;          % [m]
        vehicle.maxSteer = deg2rad(25);    % [rad]

        vehicle.minSpeed = 0.0;            % [m/s]
        vehicle.maxSpeed = 60.0;           % [m/s] 약 216 km/h

        vehicle.maxAccel = 4.0;            % [m/s^2]
        vehicle.maxDecel = 8.0;            % [m/s^2]

        vehicle.mu = 1.20;                 % [-]

    case "race"
        % 레이싱카 수준을 가정한 파라미터
        % 실제 특정 차량의 공식 스펙이 아니라,
        % 프로젝트 시뮬레이션용 고성능 차량 가정값임

        vehicle.name = "Race car assumption";

        % 차체 형상
        % GT / formula 계열에 따라 달라질 수 있음.
        % 현재는 고속 레이싱카 가정값으로 사용.
        vehicle.wheelbase = 2.80;          % [m]
        vehicle.maxSteer = deg2rad(20);    % [rad]

        % 속도 제한
        vehicle.minSpeed = 0.0;            % [m/s]
        vehicle.maxSpeed = 83.3;           % [m/s] 약 300 km/h

        % 가속/감속 성능
        vehicle.maxAccel = 8.0;            % [m/s^2]
        vehicle.maxDecel = 14.0;           % [m/s^2]

        % 타이어-노면 마찰계수
        % 값이 클수록 코너에서 더 빠른 속도 허용
        vehicle.mu = 1.60;                 % [-]

    otherwise
        error("지원하지 않는 vehicle mode입니다: %s", mode);
end

%% 단위 변환 참고값
vehicle.maxSpeedKph = vehicle.maxSpeed * 3.6;

end