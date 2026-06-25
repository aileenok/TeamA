% project_startup.m
% SMYD_TeamA MATLAB 프로젝트 환경을 초기화합니다.
%
% 이 스크립트는 프로젝트 폴더들을 MATLAB 검색 경로에 추가하여
% config, src, viz, tests 폴더 안의 함수들을 프로젝트 내부 어디에서든
% 호출할 수 있도록 합니다.

clear; clc;

projectRoot = fileparts(mfilename('fullpath'));

addpath(genpath(fullfile(projectRoot, 'config')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'viz')));
addpath(genpath(fullfile(projectRoot, 'tests')));

fprintf('SMYD_TeamA project initialized.\n');
fprintf('Project root: %s\n', projectRoot);