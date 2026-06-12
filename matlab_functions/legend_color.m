function htext = legend_color(labels, lineHandles)
    % LEGEND_COLOR creates a custom legend with text in the color of the lines.
    %
    % Parameters:
    %   labels - Cell array of legend labels (e.g., {'Line 1', 'Line 2'})
    %   lineHandles (optional) - Array of line handles to be labeled.
    %
    % If lineHandles is not provided, it will be fetched automatically.

    % Handle optional input
    if nargin < 2 || isempty(lineHandles)
        % Fetch all line objects in the current axes
        ax = gca;
        lineHandles = findall(ax, 'Type', 'line');
    end

    % Validate inputs
    if isempty(lineHandles)
        error('No line handles found. Please provide valid line handles or check the current axes.');
    end
    if ~iscell(labels) || length(labels) ~= length(lineHandles)
        error('Labels must be a cell array, and its length must match the number of line handles.');
    end

    % Try creating a temporary legend to get its position
    try
        tempLegend = legend(lineHandles, labels, 'Location', 'best');
        legendPos = tempLegend.Position; % Get position of the legend in figure coordinates
        delete(tempLegend); % Remove the temporary legend
    catch ME
        error('Error creating the temporary legend: %s', ME.message);
    end

    % Translate figure coordinates to axis coordinates
    ax = ancestor(lineHandles(1), 'axes');
    axPos = ax.Position; % Get axes position in normalized figure coordinates

    % Calculate normalized axis coordinates
    x = (legendPos(1) - axPos(1)) / axPos(3); % Normalize x
    y = (legendPos(2) - axPos(2)) / axPos(4) + legendPos(4); % Normalize y

    % Adjust vertical spacing
    ySpacing = legendPos(4) / length(labels) / axPos(4); % Normalize spacing

    % Plot each label at the calculated position
    for i = 1:length(lineHandles)
        lineColor = lineHandles(i).Color; % Get the color of the line
        % Add text annotation with matching color
        htext(i) = text(ax, x, y, labels{i}, 'Color', lineColor, 'FontSize', 9, ...
             'Units', 'normalized', 'HorizontalAlignment', 'left');
        y = y - ySpacing; % Update y-coordinate for the next label
    end
end
