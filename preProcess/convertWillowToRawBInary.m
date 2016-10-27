function ops = convertWillowToRawBInary(ops)
outname  = fullfile(ops.root, sprintf('%s.dat', ops.original(1:end-3))); 
fidout = fopen(outname, 'w');
tic
filename = fullfile(ops.root, ops.original);
D = h5read(filename,'/channel_data');
M = 1024;
N = length(D)/M;
data=double(reshape(D,M,N));
sample_index = h5read(filename,'/sample_index');
fwrite(fidout, data, 'int16');
fclose(fidout);
toc
