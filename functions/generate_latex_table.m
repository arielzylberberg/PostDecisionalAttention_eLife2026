function generate_latex_table(parameter_matrix, column_names, output_filename)
    % This function generates a LaTeX table from a parameter matrix and column names
    % parameter_matrix: matrix of parameter values (rows = subjects, columns = parameters)
    % column_names: cell array with the names of the columns
    % output_filename: the name of the LaTeX file to output the table to
    
    [num_subjects, num_parameters] = size(parameter_matrix);
    
    % Open the output file
    fid = fopen(output_filename, 'w');
    
    % Write LaTeX table header
    fprintf(fid, '\\begin{table}[ht]\n');
    fprintf(fid, '\\centering\n');
    fprintf(fid, '\\small\n');
    fprintf(fid, '\\begin{tabular}{|%s|}\n', repmat('c', 1, num_parameters + 1)); % Create table format based on number of columns
    fprintf(fid, '\\hline\n');
    
    % Write column headers
    fprintf(fid, 'Subject & %s \\\\\n', strjoin(column_names, ' & '));
    fprintf(fid, '\\hline\n');
    
    % Write the parameter values for each subject
    for i = 1:num_subjects
        % Print the subject index
        fprintf(fid, '%d & ', i);
        
        % Print each parameter value for the current subject
        for j = 1:num_parameters
            if j < num_parameters
                fprintf(fid, '%.3f & ', parameter_matrix(i, j)); % Print parameter value
            else
                fprintf(fid, '%.3f \\\\\n', parameter_matrix(i, j)); % Last parameter in row
            end
        end
    end
    
    % End LaTeX table
    fprintf(fid, '\\hline\n');
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\\caption{Parameter Values}\n');
    fprintf(fid, '\\end{table}\n');
    
    % Close the output file
    fclose(fid);
    
    disp('LaTeX table has been written to the file.');
end
