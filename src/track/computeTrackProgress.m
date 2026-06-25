function s = computeTrackProgress(track, position)
% computeTrackProgress
% 전역 좌표 position이 트랙을 따라 얼마나 진행했는지 s-coordinate을 계산
%
% 입력:
%   track    : 전처리된 트랙 구조체
%   position : [1 x 2] 전역 좌표 [x, y]
%
% 출력:
%   s        : track progress [m]

arguments
    track struct
    position (1,2) double
end

nearest = findNearestTrackPoint(track, position);
s = nearest.s;

end