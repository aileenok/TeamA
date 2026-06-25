% 기존 트랙 데이터에서 왼/오 바운더리 계산

function track = computeTrackBoundaries(track)
% computeTrackBoundaries
% Compute left and right track boundaries from centerline and track widths.
%
% Required fields:
%   track.center
%   track.widthLeft
%   track.widthRight
%   track.leftNormal
%   track.rightNormal
%
% Output fields:
%   track.leftBoundary
%   track.rightBoundary

if ~isfield(track, "leftNormal") || ~isfield(track, "rightNormal")
    error("Track normals are missing. Run computeTrackNormals(track) first.");
end

center = track.center;

widthLeft = track.widthLeft(:);
widthRight = track.widthRight(:);

leftBoundary = center + widthLeft .* track.leftNormal;
rightBoundary = center + widthRight .* track.rightNormal;

track.leftBoundary = leftBoundary;
track.rightBoundary = rightBoundary;

end