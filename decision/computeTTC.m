function ttc = computeTTC(gap, relativeSpeed)
% computeTTC
% gap과 relative speed로부터 TTC(Time-To-Collision)를 계산한다.
%
% 입력:
%   gap           : 앞차까지의 종방향 거리 [m]
%   relativeSpeed : ego.v - lead.v [m/s]
%                   양수 → ego가 앞차에 접근 중
%
% 출력:
%   ttc : 충돌 예상 시간 [s]
%         접근 중이 아니면 inf 반환

arguments
    gap           (1,1) double {mustBeNonnegative}
    relativeSpeed (1,1) double
end

if relativeSpeed <= 0
    % 속도 차이가 없거나 ego가 더 느림 → 충돌 없음
    ttc = inf;
else
    ttc = gap / relativeSpeed;
end

end
