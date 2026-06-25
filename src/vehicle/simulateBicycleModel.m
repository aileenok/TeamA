function [time, states] = simulateBicycleModel(model, x0, input, tFinal, dt)
% simulateBicycleModel
% 오일러 적분을 사용하여 운동학적 자전거 모델을 시뮬레이션합니다.
%
% 입력:
%   model  : 자전거 모델 구조체
%   x0     : 초기 상태 [x; y; theta]
%   input  : 일정한 입력값 [v; delta]
%   tFinal : 최종 시뮬레이션 시간 [s]
%   dt     : 시간 간격 [s]
%
% 출력:
%   time   : 시간 벡터
%   states : 시뮬레이션된 상태값, 각 행은 [x, y, theta]를 의미함

arguments
    model struct
    x0 (3,1) double
    input (2,1) double
    tFinal (1,1) double {mustBePositive}
    dt (1,1) double {mustBePositive}
end

time = (0:dt:tFinal)';
numSteps = length(time);

states = zeros(numSteps, 3);
states(1,:) = x0';

for k = 2:numSteps
    currentState = states(k-1,:)';
    stateDot = bicycleStateDerivative(currentState, input, model);
    nextState = currentState + stateDot * dt;

    % 진행 방향 각도가 수치적으로 너무 커지지 않도록 정규화합니다.
    nextState(3) = atan2(sin(nextState(3)), cos(nextState(3)));

    states(k,:) = nextState';
end

end