% run_step02_load_monza_track.m
% Step 02: Load and plot Monza track data.

clear; clc; close all;

project_startup;

trackFile = fullfile( ...
    "data", ...
    "external", ...
    "tum_racetrack_database", ...
    "tracks", ...
    "Monza.csv");

track = loadTUMTrack(trackFile);

fprintf('\n=== Monza Track Data Loaded ===\n');
fprintf('Track name: %s\n', track.name);
fprintf('Source: %s\n', track.source);
fprintf('Number of points: %d\n', track.numPoints);
fprintf('Approx. track length: %.2f m\n', track.length);
fprintf('Mean point spacing: %.2f m\n', track.meanPointSpacing);
fprintf('Mean right width: %.2f m\n', track.meanWidthRight);
fprintf('Mean left width: %.2f m\n', track.meanWidthLeft);
fprintf('Mean total width: %.2f m\n', track.meanTotalWidth);

plotTrack(track);