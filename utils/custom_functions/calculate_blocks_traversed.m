function blocks_traversed = calculate_blocks_traversed(path)
    % Initialize the block count
    blocks_traversed = 0;
    path_len = length(path);
    
    % Loop through each consecutive pair of points in the path
    for i = 1:path_len-1
        dx = abs(path(i + 1, 1) - path(i, 1));  % Difference in rows (vertical movement)
        dy = abs(path(i + 1, 2) - path(i, 2));  % Difference in columns (horizontal movement)
        
        % Count one block for each movement (diagonal or straight)
        if dx == 1 && dy == 1
            % Diagonal movement (considered one block traversed)
            blocks_traversed = blocks_traversed + 1;
        else
            % Horizontal or vertical movement
            blocks_traversed = blocks_traversed + max(dx, dy);  % Add number of cells traversed
        end
    end
end