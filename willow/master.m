complete = {'1k_recording_20160402_start_115447136257_count_1843200000.h5';
'1k_recording_20160402_start_117290336257_count_1843200000.h5';
'1k_recording_20160402_start_119133536257_count_1843200000.h5';
'1k_recording_20160402_start_120976736257_count_1843200000.h5';
'1k_recording_20160402_start_122819936257_count_1843200000.h5';
'1k_recording_20160402_start_124663136257_count_1843200000.h5';
'1k_recording_20160402_start_126506336257_count_1843200000.h5';
'1k_recording_20160402_start_128349536257_count_1843200000.h5';
'1k_recording_20160402_start_130192736257_count_238963712.h5'};

fpath = '/media/jkinney/temp_data';
fname = '*.h5';
flist = dir([fpath '/' fname]);
for i=1:length(flist)
    f=flist(i);
    tmp = f.name
    if ismember(tmp,complete)
        continue;
    end
    num_samples = getNum ( tmp )
    mystr = tmp(1:end-3);
    willow_master ( fpath, mystr, num_samples )
end


function num = getNum (str)
a = find(str=='_');
b = find(str=='.');
num = str2num( str( a(end)+1 : b(end)-1 ) ) / 1024;
end