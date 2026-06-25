% 트랙 전처리 - missing value 제거,시작점-끝점 중복 제거, 트랙 길이 계산

function trackOut = preprocessTrack(trackIn)
% preprocessTrack
% Clean and prepare track data for boundary and baseline calculations.
%
% This function does not resample the track yet.
% It only:
%   1. removes invalid points
%   2. removes duplicated final point if needed
%   3. computes segment length and cumulative distance

trackOut = trackIn;

center = trackIn.center;
widthLeft = trackIn.widthLeft;
widthRight = trackIn.widthRight;

% Remove rows with NaN values
validRows = all(isfinite(center), 2) & ...
    isfinite(widthLeft) & ...
    isfinite(widthRight);

center = center(validRows, :);
widthLeft = widthLeft(validRows);
widthRight = widthRight(validRows);

% Remove duplicated final point if the last point equals the first point
if norm(center(end,:) - center(1,:)) < 1e-9
    center(end,:) = [];
    widthLeft(end) = [];
    widthRight(end) = [];
end

% Closed path for distance calculation
centerClosed = [center; center(1,:)];

ds = sqrt(sum(diff(centerClosed).^2, 2));
s = [0; cumsum(ds(1:end-1))];

trackOut.center = center;
trackOut.x = center(:,1);
trackOut.y = center(:,2);
trackOut.widthLeft = widthLeft;
trackOut.widthRight = widthRight;

trackOut.ds = ds;
trackOut.s = s;
trackOut.length = sum(ds);
trackOut.numPoints = size(center, 1);
trackOut.isClosed = true;

end