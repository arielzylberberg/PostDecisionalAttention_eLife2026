function [start, val, len, rn] = RunsCount(v)
%
% Determine the length of each val-run in v,
% where v is a vector of 'values'
% Example 1: RunsCount([2 2 2 1 1 9 8 8 3 3 3 3]) gives
% start     1     4     6     7     9
% val       2     1     9     8     3
% len       3     2     1     2     4
% Example 2: RunsCount(['aaaabbaacccbbb']);
% start     1     5     7     9    12
% val      97    98    97    99    98
% len       4     2     2     3     3
%
% Derek O'Connor 22 Sep 2011
%
 n = length(v);
 val = zeros(n,1);           % run value
 len = zeros(n,1);           % run length
 start = zeros(n,1);         % pos. in v where run starts
 start(1) = 1;
 rk = 1;                     % number in run
 rn = 1;                     % number of runs
 for k = 2:n
     if  v(k) == v(k-1)      % in run
         rk = rk+1;
     else                    % end of run
         val(rn) = v(k-1);
         len(rn) = rk;
         rk = 1;             % v(k) is start of
         rn = rn+1;          % next run
         start(rn) = k;      % position of start in v
     end
 end
 val(rn) = v(n);             % last run
 len(rn) = n - sum(len);
%

start = start(1:rn);
val = val(1:rn);
len = len(1:rn);