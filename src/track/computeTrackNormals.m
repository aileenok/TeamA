% 센터라인 기준으로 왼/오 벡터 계산

function track = computeTrackNormals(track)
% computeTrackNormals
% Compute tangent, left normal, and right normal vectors along a closed track.
%
% Convention:
%   tangent direction follows the order of track.center points.
%   left normal  = [-ty, tx]
%   right normal = [ ty,-tx]
%
% These left/right directions are relative to the point ordering direction.

center = track.center;
n = size(center, 1);

tangent = zeros(n, 2);

for i = 1:n
    iPrev = i - 1;
    iNext = i + 1;

    if iPrev < 1
        iPrev = n;
    end

    if iNext > n
        iNext = 1;
    end

    direction = center(iNext,:) - center(iPrev,:);
    directionNorm = norm(direction);

    if directionNorm < eps
        error("Zero-length tangent detected at track point %d.", i);
    end

    tangent(i,:) = direction / directionNorm;
end

leftNormal = [-tangent(:,2), tangent(:,1)];
rightNormal = -leftNormal;

track.tangent = tangent;
track.leftNormal = leftNormal;
track.rightNormal = rightNormal;

end