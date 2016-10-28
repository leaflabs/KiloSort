function one_map_all_shanks (probe_map_file, impedance_file, outpath)
%  create a channel map file

num_comments = count_comments(probe_map_file)
% 1st column = channel number (0-based)
CHANNEL_COL = 1;
% 2nd column = shank number (0-based)
SHANK_COL = 2;
% 3rd column = row number (0-based)
ROW_COL = 3;
% 4th column = column number (0-based)
COL_COL = 4;
probe_map = dlmread(probe_map_file,'',num_comments,0);
fs = 30000;

NchanTOT = 1024;
chanMap = []; chanMap0ind = [];
connected = [];
xcoords = []; ycoords = []; kcoords = [];

for shank = 0:max(probe_map(:,SHANK_COL))
    index = find(probe_map(:,SHANK_COL)==shank);
    if isempty(index)
        disp(sprintf('Shank %d not found', shank));
        exit;
    else
        chanMap = [chanMap; probe_map(index,CHANNEL_COL)];
        %connected = [connected; get_good_channels(index, probe_map, impedance_file)];
        connected = [connected; get_good_channels(probe_map(index), impedance_file)];
        ycoords = [ycoords; probe_map(index,ROW_COL)];   % rows
        xcoords = [xcoords; probe_map(index,COL_COL)];   % columns
        kcoords = [kcoords; (shank+1)*ones(length(index),1)];
    end
end

chanMap0ind = chanMap - 1;

% number of good channels
%Nchan = sum(numel(1, (connected==1)));
Nchan = numel(1, (connected==1));

save(fullfile(outpath, sprintf('chanMap_allshanks.mat')), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs', ...
    'NchanTOT', 'Nchan')

% kcoords is used to forcefully restrict templates to channels in the same
% channel group. An option can be set in the master_file to allow a fraction 
% of all templates to span more channel groups, so that they can capture shared 
% noise across all channels. This option is

% ops.criterionNoiseChannels = 0.2; 

% if this number is less than 1, it will be treated as a fraction of the total number of clusters

% if this number is larger than 1, it will be treated as the "effective
% number" of channel groups at which to set the threshold. So if a template
% occupies more than this many channel groups, it will not be restricted to
% a single channel group.
end

%function connected = get_good_channels (index, probe_map, impedance_file)
function connected = get_good_channels (index, impedance_file)
    % find dead channels using impedance data
    D = h5read(impedance_file,'/impedanceMeasurements');
    my_z = D(index+1);
    % Note the following assert will fail
    %    assert(length(D)==length(probe_map));
    % since D has 1024 elements
    % but probe_map has 1020, since probe had only 1020 recording sites.
    % Keep in mind that max index of 1020 is 1024, since it ended up being
    % some middle channel numbers that were skipped.
    MAX_Z = 2e6;
    MIN_Z = 1e5;
    connected = my_z < MAX_Z & my_z > MIN_Z;
end

function nc = count_comments (f)
    comment_flag = true;
    nc = 0;
    fid = fopen(f);
    tline = fgetl(fid);
    while ischar(tline)
        if tline(1)=='#'
            nc = nc + 1;
            if comment_flag == true
                disp(tline);
            end
        else
            break;
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end

