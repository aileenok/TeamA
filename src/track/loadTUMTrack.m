function track = loadTUMTrack(filename)
% loadTUMTrack
% Load racetrack data from the TUMFTM racetrack database.
%
% Expected file format:
%   # x_m,y_m,w_tr_right_m,w_tr_left_m
%
% Columns:
%   1: x centerline coordinate [m]
%   2: y centerline coordinate [m]
%   3: track width to the right of centerline [m]
%   4: track width to the left of centerline [m]

data = readmatrix(filename, "CommentStyle", "#");

if size(data, 2) ~= 4
    error("TUM track file must have 4 columns: x, y, widthRight, widthLeft.");
end

track.x = data(:, 1);
track.y = data(:, 2);
track.center = data(:, 1:2);

% Important:
% TUM format column 3 = right width, column 4 = left width
track.widthRight = data(:, 3);
track.widthLeft  = data(:, 4);

[~, name, ~] = fileparts(filename);
track.name = string(name);
track.source = "TUMFTM racetrack-database";

% Basic track information
pathClosed = [track.center; track.center(1,:)];
ds = sqrt(sum(diff(pathClosed).^2, 2));

track.numPoints = size(track.center, 1);
track.length = sum(ds);
track.meanPointSpacing = mean(ds);
track.meanWidthRight = mean(track.widthRight);
track.meanWidthLeft = mean(track.widthLeft);
track.meanTotalWidth = mean(track.widthRight + track.widthLeft);

end