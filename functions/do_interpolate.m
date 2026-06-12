function input_matrix = do_interpolate(input_matrix)


% Define your input matrix here
% input_matrix = [
%     1  1 -1 -1  0  0;
%     0 -1 -1  1  1  1;
%     1 -1  0  0 -1  0;
%     0  0  0  1 -1 -1;
% ];


% sanity check
eq = unique(input_matrix(:)) == [-1,0,1]';
if ~all(eq)==1
    error('wrong');
end

% Get matrix dimensions
[m, n] = size(input_matrix);

% Iterate through the matrix
for row = 1:m
    for col = 1:n-1
        if input_matrix(row, col) == 1 && input_matrix(row, col+1) == -1
            temp_col = col + 1;
            while temp_col <= n && input_matrix(row, temp_col) == -1
                if temp_col < n && input_matrix(row, temp_col+1) == 1
                    input_matrix(row, col:temp_col) = 1;
                end
                temp_col = temp_col + 1;
            end
        elseif input_matrix(row, col) == 0 && input_matrix(row, col+1) == -1
            temp_col = col + 1;
            while temp_col <= n && input_matrix(row, temp_col) == -1
                if temp_col < n && input_matrix(row, temp_col+1) == 0
                    input_matrix(row, col:temp_col) = 0;
                end
                temp_col = temp_col + 1;
            end
        end
    end
end

input_matrix(input_matrix==-1) = nan;

% Display the modified matrix
% disp(input_matrix);

% for i=1:size(input_matrix,1)
%     [start, val, len, rn] = RunsCount(input_matrix(i,:));
%     I = ismember(val,[0,1]);
%     dwells(i).roi = val(I);
%     dwells(i).len = len(I)*dt;
% end

end
