% run_step03_track_boundary.m
% Step 03: Load Monza track and plot centerline with boundaries.

clear; clc; close all;

project_startup;

trackFile = fullfile( ...
    "data", ...
    "external", ...
    "tum_racetrack_database", ...
    "tracks", ...
    "Monza.csv");

% 1. Load track
track = loadTrack(trackFile, "TUM");

% 2. Preprocess track
track = preprocessTrack(track);

% 3. Compute normal vectors
track = computeTrackNormals(track);

% 4. Compute left/right boundaries
track = computeTrackBoundaries(track);

% 5. Plot result
plotTrack(track);

fprintf('\n=== Monza Boundary Check ===\n');
fprintf('Track name: %s\n', track.name);
fprintf('Number of points: %d\n', track.numPoints);
fprintf('Track length: %.2f m\n', track.length);
fprintf('Mean left width: %.2f m\n', mean(track.widthLeft));
fprintf('Mean right width: %.2f m\n', mean(track.widthRight));
fprintf('Mean total width: %.2f m\n', mean(track.widthLeft + track.widthRight));