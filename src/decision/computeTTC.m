function [ttc, closingSpeed] = computeTTC(gap, egoSpeed, leadSpeed)
% computeTTC
% Time-To-Collision 계산
%
% gap          : ego와 lead vehicle 사이 거리 [m]
% egoSpeed     : ego 속도 [m/s]
% leadSpeed    : lead vehicle 속도 [m/s]
%
% ttc = gap / closingSpeed
% closingSpeed <= 0이면 ego가 lead vehicle을 따라잡지 않으므로 ttc = inf

closingSpeed = egoSpeed - leadSpeed;

if closingSpeed > 0
    ttc = gap / closingSpeed;
else
    ttc = inf;
end

end