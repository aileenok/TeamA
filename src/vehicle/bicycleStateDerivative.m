function stateDot = bicycleStateDerivative(state, input, model)
% bicycleStateDerivative
% 운동학적 자전거 모델의 시간에 따른 상태 변화율을 계산합니다.
%
% 상태 변수:
%   state = [x; y; theta]
%
% 입력 변수:
%   input = [v; delta]
%
% 모델 방정식:
%   x_dot     = v * cos(theta)
%   y_dot     = v * sin(theta)
%   theta_dot = v / L * tan(delta)

arguments
    state (3,1) double
    input (2,1) double
    model struct
end

theta = state(3);

v = input(1);
delta = input(2);

% 차량 제한 조건을 적용합니다.
v = min(max(v, model.minSpeed), model.maxSpeed);
delta = min(max(delta, -model.maxSteer), model.maxSteer);

L = model.wheelbase;

stateDot = zeros(3,1);
stateDot(1) = v * cos(theta);
stateDot(2) = v * sin(theta);
stateDot(3) = v / L * tan(delta);

end