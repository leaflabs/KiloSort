% default options are in parenthesis after the comment

addpath(genpath('/home/jkinney/src/KiloSort')) % path to kilosort folder
addpath(genpath('/home/jkinney/src/npy-matlab')) % path to npy-matlab scripts

pathToYourConfigFile = '/home/jkinney/src/KiloSort/willow/'; % take from Github folder and put it somewhere else (together with the master_file)
run(fullfile(pathToYourConfigFile, 'willow_config.m'))

tic; % start timer
%

if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

if strcmp(ops.datatype , 'h5')
   ops = convertWillowToRawBInary(ops);  % convert willow h5 snapshot data
end
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

keyboard

% remove temporary file
%delete(ops.fproc);
%%
