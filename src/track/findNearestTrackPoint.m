function nearest = findNearestTrackPoint(track, position)
% findNearestTrackPoint
% 차량의 전역 좌표 x,y와 가장 가까운 트랙 centerline segment를 찾는 함수
%
% 입력:
%   track    : 전처리된 트랙 구조체
%              필요한 필드:
%              - track.center
%              - track.s
%              - track.ds
%              - track.length
%
%   position : [1 x 2] 또는 [2 x 1] 전역 좌표 [x, y]
%
% 출력:
%   nearest.segmentIndex : 가장 가까운 segment 시작 인덱스
%   nearest.t            : 해당 segment 내 보간 비율, 0~1
%   nearest.point        : centerline 위의 최근접 투영점 [x, y]
%   nearest.s            : 최근접 투영점의 track progress [m]
%   nearest.d            : centerline 기준 signed lateral offset [m]
%   nearest.distance     : centerline까지의 절댓값 거리 [m]
%   nearest.leftNormal   : 해당 지점의 left normal vector
%   nearest.tangent      : 해당 지점의 tangent vector

arguments
    track struct
    position (1,2) double
end

center = track.center;
s = track.s(:);
ds = track.ds(:);
trackLength = track.length;

numPoints = size(center, 1);

bestDist = inf;

bestIndex = 1;
bestT = 0;
bestPoint = center(1,:);
bestTangent = [1, 0];

for i = 1:numPoints

    % 폐곡선이므로 마지막 점 다음은 첫 번째 점
    iNext = i + 1;
    if iNext > numPoints
        iNext = 1;
    end

    p0 = center(i,:);
    p1 = center(iNext,:);

    segmentVector = p1 - p0;
    segmentLengthSquared = dot(segmentVector, segmentVector);

    if segmentLengthSquared < eps
        continue;
    end

    % position을 현재 segment 위로 투영
    t = dot(position - p0, segmentVector) / segmentLengthSquared;

    % segment 내부로 제한
    t = max(0, min(1, t));

    projection = p0 + t * segmentVector;

    diffVector = position - projection;
    dist = norm(diffVector);

    if dist < bestDist
        bestDist = dist;
        bestIndex = i;
        bestT = t;
        bestPoint = projection;
        bestTangent = segmentVector / norm(segmentVector);
    end
end

% 최근접 segment 기준 s 계산
sBase = s(bestIndex);
sOffset = bestT * ds(bestIndex);
sNearest = sBase + sOffset;

% 폐곡선 s 범위 정리
sNearest = mod(sNearest, trackLength);

% tangent 기준 left normal
leftNormal = [-bestTangent(2), bestTangent(1)];

% signed lateral offset 계산
offsetVector = position - bestPoint;
dSigned = dot(offsetVector, leftNormal);

nearest.segmentIndex = bestIndex;
nearest.t = bestT;
nearest.point = bestPoint;
nearest.s = sNearest;
nearest.d = dSigned;
nearest.distance = bestDist;
nearest.leftNormal = leftNormal;
nearest.tangent = bestTangent;

end