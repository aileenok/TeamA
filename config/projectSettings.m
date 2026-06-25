function settings = projectSettings()
% projectSettings
% Global project-level settings for SMYD_TeamA.

settings.projectName = "SMYD_TeamA";
settings.projectTitle = "Path Planning for Autonomous Race Cars";

% Folder settings
settings.dataFolder = fullfile("data");
settings.rawTrackFolder = fullfile("data", "raw_tracks");
settings.resultFolder = fullfile("data", "results");
settings.figureFolder = fullfile("data", "results", "figures");

% Display and saving options
settings.showFigures = true;
settings.saveFigures = false;

end