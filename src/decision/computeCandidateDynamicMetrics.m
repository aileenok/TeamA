function dynamic = computeCandidateDynamicMetrics(candidate, vehicle)
% computeCandidateDynamicMetrics
% 기존 candidate trajectory(x,y,v,time)를 바탕으로
% Simulink 연결 전 사용할 dynamic feasibility proxy를 계산한다.
%
% 계산 항목:
%   - geometric curvature
%   - longitudinal acceleration
%   - lateral acceleration demand
%   - longitudinal/lateral utilization
%   - simplified friction utilization
%   - required steering angle
%   - yaw-rate demand
%
% actual tire slip angle은 현재 candidate에 vx, vy, actual yaw rate가 없으므로
% 계산하지 않는다. Simulink 3DOF 연결 후 활성화한다.

arguments
    candidate struct
    vehicle struct
end

%% 1. 입력 정리
t = candidate.time(:);
x = candidate.x(:);
y = candidate.y(:);
v = candidate.v(:);

n = numel(t);

if n < 3
    error("Dynamic metric 계산에는 최소 3개 이상의 trajectory point가 필요합니다.");
end

if numel(x) ~= n || numel(y) ~= n || numel(v) ~= n
    error("candidate.time, x, y, v 길이가 서로 다릅니다.");
end

if any(~isfinite([t; x; y; v]))
    error("candidate trajectory에 NaN 또는 Inf가 포함되어 있습니다.");
end

if any(diff(t) <= 0)
    error("candidate.time은 strictly increasing이어야 합니다.");
end

%% 2. Geometric curvature
dx = gradient(x, t);
dy = gradient(y, t);

ddx = gradient(dx, t);
ddy = gradient(dy, t);

denominator = (dx.^2 + dy.^2).^(3/2);
kappa = zeros(size(x));

validDenominator = denominator > 1.0e-6;

kappa(validDenominator) = ...
    (dx(validDenominator) .* ddy(validDenominator) ...
    - dy(validDenominator) .* ddx(validDenominator)) ...
    ./ denominator(validDenominator);

kappa(~isfinite(kappa)) = 0.0;

if n >= 5
    kappa = smoothdata(kappa, "movmean", 5);
end

%% 3. Longitudinal acceleration
aX = gradient(v, t);

if n >= 5
    aX = smoothdata(aX, "movmean", 3);
end

%% 4. Lateral acceleration demand
aY = v.^2 .* abs(kappa);

aYLimit = vehicle.maxLateralAccel;

%% 5. Longitudinal utilization
aXUtil = zeros(size(aX));

accelIdx = aX >= 0;
brakeIdx = aX < 0;

aXUtil(accelIdx) = ...
    aX(accelIdx) / max(vehicle.maxAccel, eps);

aXUtil(brakeIdx) = ...
    -aX(brakeIdx) / max(vehicle.maxDecel, eps);

%% 6. Lateral utilization
aYUtil = aY / max(aYLimit, eps);

%% 7. Simplified friction utilization
% 실제 tire friction ellipse를 완전히 재현하는 모델이 아니라
% MATLAB candidate 단계의 feasibility proxy이다.
frictionUtil = sqrt(aXUtil.^2 + aYUtil.^2);

%% 8. Required steering angle
steerRequired = atan(vehicle.wheelbase .* kappa);
steerUtil = abs(steerRequired) / max(vehicle.maxSteer, eps);

%% 9. Yaw-rate demand
yawRateDemand = v .* kappa;

%% 10. Edge numerical noise를 줄이기 위한 평가 index
if n >= 7
    evalIdx = 3:(n-2);
else
    evalIdx = 1:n;
end

%% 11. 결과 저장
dynamic.curvature = kappa;
dynamic.aX = aX;
dynamic.aY = aY;

dynamic.aXUtil = aXUtil;
dynamic.aYUtil = aYUtil;
dynamic.frictionUtil = frictionUtil;

dynamic.steerRequired = steerRequired;
dynamic.steerUtil = steerUtil;

dynamic.yawRateDemand = yawRateDemand;
dynamic.slipAvailable = false;

dynamic.maxAbsAX = max(abs(aX(evalIdx)));
dynamic.maxAY = max(aY(evalIdx));
dynamic.maxAXUtil = max(aXUtil(evalIdx));
dynamic.maxAYUtil = max(aYUtil(evalIdx));
dynamic.maxFrictionUtil = max(frictionUtil(evalIdx));
dynamic.maxSteerUtil = max(steerUtil(evalIdx));
dynamic.maxAbsYawRateDemand = max(abs(yawRateDemand(evalIdx)));

end
