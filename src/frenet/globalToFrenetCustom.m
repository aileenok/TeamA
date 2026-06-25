function frenetState = globalToFrenetCustom(track, position)
% globalToFrenetCustom
% 전역 좌표 [x, y]를 트랙 기준 Frenet 좌표 [s, d]로 변환
%
% 입력:
%   track    : 전처리된 트랙 구조체
%   position : [1 x 2] 전역 좌표 [x, y]
%
% 출력:
%   frenetState.s       : 트랙 진행거리 [m]
%   frenetState.d       : centerline 기준 좌우 offset [m]
%   frenetState.xyRef   : centerline 위의 최근접 점 [x, y]
%   frenetState.segment : 최근접 segment index
%   frenetState.t       : segment 내 보간 비율

arguments
    track struct
    position (1,2) double
end

nearest = findNearestTrackPoint(track, position);

frenetState.s = nearest.s;
frenetState.d = nearest.d;
frenetState.xyRef = nearest.point;
frenetState.segment = nearest.segmentIndex;
frenetState.t = nearest.t;
frenetState.tangent = nearest.tangent;
frenetState.leftNormal = nearest.leftNormal;

end