function position = frenetToGlobalCustom(track, sQuery, dQuery)
% frenetToGlobalCustom
% Frenet 좌표 [s, d]를 전역 좌표 [x, y]로 변환
%
% 입력:
%   track  : 전처리된 트랙 구조체
%   sQuery : track progress [m]
%   dQuery : centerline 기준 lateral offset [m]
%
% 출력:
%   position : [1 x 2] 전역 좌표 [x, y]
%
% 부호 기준:
%   d > 0 : 트랙 진행 방향 기준 왼쪽
%   d < 0 : 트랙 진행 방향 기준 오른쪽

arguments
    track struct
    sQuery (1,1) double
    dQuery (1,1) double
end

center = track.center;
s = track.s(:);
ds = track.ds(:);
trackLength = track.length;

numPoints = size(center, 1);

% 폐곡선 s 범위로 정리
sWrapped = mod(sQuery, trackLength);

% sWrapped가 속한 segment 찾기
segmentIndex = find(s <= sWrapped, 1, "last");

if isempty(segmentIndex)
    segmentIndex = 1;
end

% 마지막 segment는 마지막 점에서 첫 번째 점으로 연결
nextIndex = segmentIndex + 1;
if nextIndex > numPoints
    nextIndex = 1;
end

segmentLength = ds(segmentIndex);

if segmentLength < eps
    t = 0;
else
    t = (sWrapped - s(segmentIndex)) / segmentLength;
end

t = max(0, min(1, t));

p0 = center(segmentIndex,:);
p1 = center(nextIndex,:);

segmentVector = p1 - p0;

if norm(segmentVector) < eps
    tangent = [1, 0];
else
    tangent = segmentVector / norm(segmentVector);
end

leftNormal = [-tangent(2), tangent(1)];

xyRef = p0 + t * segmentVector;

position = xyRef + dQuery * leftNormal;

end