function model = createBicycleModel(vehicle)
% createBicycleModel
% 간단한 운동학적 자전거 모델 구조체를 생성합니다.
%
% 상태 변수:
%   state = [x; y; theta]
%
% 입력 변수:
%   input = [v; delta]
%
% 각 변수의 의미:
%   x     : 전역 좌표계 기준 x 위치 [m]
%   y     : 전역 좌표계 기준 y 위치 [m]
%   theta : 차량 진행 방향 각도 [rad]
%   v     : 차량 속도 [m/s]
%   delta : 앞바퀴 조향각 [rad]

model.name = "Kinematic Bicycle Model";

model.wheelbase = vehicle.wheelbase;
model.maxSteer = vehicle.maxSteer;
model.minSpeed = vehicle.minSpeed;
model.maxSpeed = vehicle.maxSpeed;

model.stateNames = ["x", "y", "theta"];
model.inputNames = ["velocity", "steeringAngle"];

end