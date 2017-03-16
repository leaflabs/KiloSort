function ops = convertWillowToRawBInary(ops)
outname  = sprintf('%s.dat', ops.original(1:end-3)); 
fidout = fopen(outname, 'w');
tic
filename = ops.original;
%D = h5read(filename,'/channel_data');
%D = int16((single(D) - 2^15));
%M = 1024;
%N = length(D)/M;
%data=reshape(D,M,N);
D = h5read(filename,'/rawMEA',[1 1],[ops.num_samples 1020]);
D = int16(D - 2^15);
fwrite(fidout, D', 'int16');
fclose(fidout);
toc
