function ops = convertWillowToRawBInary(ops)
outname  = sprintf('%s.dat', ops.original(1:end-3)); 
fidout = fopen(outname, 'w');
tic
filename = ops.original;
D = h5read(filename,'/channel_data');
D = int16((single(D) - 2^15));
M = 1024;
N = length(D)/M;
data=reshape(D,M,N);
fwrite(fidout, data, 'int16');
fclose(fidout);
toc
