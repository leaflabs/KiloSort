function one_map_per_shank (probe_map_file, impedance_file, fpath)
%% read channel map
% now read map
num_comments = count_comments(probe_map_file);
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

% organize channels by shank
for shank = 0:max(probe_map(:,SHANK_COL))
    index = find(probe_map(:,SHANK_COL)==shank);
    if isempty(index)
        mystr = sprintf('Shank %d not found.',shank);
        disp(mystr);
        exit;
    else
        chanMap = probe_map(index,CHANNEL_COL);
        connected = get_good_channels(probe_map(index), probe_map, impedance_file);
        ycoords = probe_map(index,ROW_COL); % rows
        xcoords = probe_map(index,COL_COL); % columns
        kcoords = (shank+1)*ones(length(index),1);
        save(fullfile(fpath, sprintf('chanMap_shank%d.mat',shank)), 'chanMap', 'connected', 'xcoords', 'ycoords', 'kcoords', 'fs')
    end
end


end

function connected = get_good_channels (index, probe_map,impedance_file)
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
connected = my_z<MAX_Z & my_z>MIN_Z;
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

