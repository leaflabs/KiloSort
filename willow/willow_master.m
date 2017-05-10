function [] = willow_master( mydir, mystr, num_samples )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Example
% mystr = 'awake_planet_earth_offset_216000000_count_1800000';

% default options are in parenthesis after the comment

addpath(genpath('/home/jkinney/src/KiloSort')) % path to kilosort folder
addpath(genpath('/home/jkinney/src/npy-matlab')) % path to npy-matlab scripts

pathToYourConfigFile = '/home/jkinney/src/KiloSort/willow/'; % take from Github folder and put it somewhere else (together with the master_file)
run(fullfile(pathToYourConfigFile, 'willow_config.m'))

tic; % start timer
%

%mystr = 'awake_gratings_and_grass_offset_133200014_count_1800000';
%mystr = 'awake_planet_earth_offset_216000000_count_1800000';
ops.datatype            = 'h5';  % binary ('dat', 'bin') or 'openEphys' or 'h5'
%ops.fbinary             = sprintf('/home/jkinney/Desktop/60secs_automerge/%s/%s.dat',mystr,mystr); % will be created for converted willow data                     
%ops.original            = sprintf('/home/jkinney/Desktop/60secs_automerge/%s/%s.h5',mystr,mystr);
ops.fbinary             = sprintf('%s/%s.dat',mydir,mystr); % will be created for converted willow data                     
ops.original            = sprintf('%s/%s.h5',mydir,mystr);
%ops.original            = sprintf('%s/%s/%s.h5',mydir,mystr,mystr);
ops.keep_N = 1;
ops.num_samples         = num_samples;

ops.no_write = true;

if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

if strcmp(ops.datatype , 'h5')
   ops = convertWillowToRawBInary(ops);  % convert willow h5 snapshot data
end

for shank = 0:4
    %     ops.chanMap = sprintf('/home/jkinney/src/KiloSort/willow/channel_map/chanMap_shank%d.mat',shank);
    %     ops.root    = sprintf('/home/jkinney/Desktop/60secs_automerge/shank%d',shank); % 'openEphys' only: where raw files are
    %     ops.fproc   = sprintf('/home/jkinney/Desktop/60secs_automerge/shank%d/temp_wh.dat',shank); % residual from RAM of preprocessed data
    ops.chanMap = sprintf('/home/jkinney/src/KiloSort/willow/channel_map/every_%d_row/chanMap_shank%d.mat',ops.keep_N,shank);
    if ops.GPU==1
        ops.root    = sprintf('%s/%s/GPU/shank%d',mydir,mystr,shank); % 'openEphys' only: where raw file    s are
        %ops.root    = sprintf('/home/jkinney/Desktop/60secs_automerge/%s/GPU/shank%d',mystr,shank); % 'openEphys' only: where raw file    s are
    else
        ops.root    = sprintf('%s/%s/CPU/shank%d',mydir,mystr,shank); % 'openEphys' only: where raw file    s are
    end
    if ~exist(ops.root)
        mkdir(ops.root);
        disp(['Made directory' ops.root]);
    end
    ops.fproc   = sprintf('%s/temp_wh.dat',ops.root); % residual from RAM of preprocessed data
    %
    [rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
    rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
    rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)
    
    % AutoMerge. rez2Phy will use for clusters the new 5th column of st3 if you run this)
    rez = merge_posthoc2(rez);
    
    % save matlab results file
    save(fullfile(ops.root,  'rez.mat'), 'rez', '-v7.3');
    
    % save python results file for Phy
    rezToPhy(rez, ops.root);
    
end

%keyboard

% remove temporary file
%delete(ops.fproc);
%%
end
