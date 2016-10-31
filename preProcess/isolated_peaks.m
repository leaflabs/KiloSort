function [row, col, mu] = isolated_peaks(S1, loc_range, long_range, Th)
% loc_range = [3  1];
% long_range = [30  6];
smin = my_min(S1, loc_range, [1 2]);
peaks = single(S1<smin+1e-3 & S1<Th);

% [row, col, mu] = find(peaks);
% figure(1)
% i=1;
% while i<length(row)
%     i
%     group = col(i)
%     plot(S1(:,group));
%     hold on;
%     while col(i)==group
%         plot(row(i),0,'ok');
%         if i==length(row)
%             break;
%         end
%         i = i+1
%     end
%     hold off;
%     keyboard
% end

sum_peaks = my_sum(peaks, long_range, [1 2]);
peaks = peaks .* (sum_peaks<1.2).* S1;

peaks([1:20 end-40:end], :) = 0;

[row, col, mu] = find(peaks);
% figure(1)
% i=1;
% while i<length(row)
%     i
%     group = col(i)
%     plot(S1(:,group));
%     hold on;
%     while col(i)==group
%         plot(row(i),0,'ok');
%         if i==length(row)
%             break;
%         end
%         i = i+1
%     end
%     hold off;
%     keyboard
% end
