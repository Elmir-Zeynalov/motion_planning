function result = dijkstra(map, start, goal)
    % @file: dijkstra.m
    % @brief: Dijkstra motion planning
    % @author: Winter
    % @update: 2023.7.13
    
    % Add path to the custom functions folder
   
    addpath(genpath("../utils/custom_functions"));


    % Initialize variables
    OPEN = [];
    CLOSED = [];
    EXPAND = [];
    cost = 0;
    goal_reached = false;
    nodes_explored = 0;  % Counter for nodes explored
    neighbors_visited = 0;  % Counter for neighbor visits
    memory_usage = 0;  % Initialize memory usage

    motion = [-1, -1, 1.414; ...
        0, -1, 1; ...
        1, -1, 1.414; ...
        -1, 0, 1; ...
        1, 0, 1; ...
        -1, 1, 1.414; ...
        0, 1, 1; ...
        1, 1, 1.414];
    
    motion_num = size(motion, 1);
    node_s = [start, 0, 0, start];
    OPEN = [OPEN; node_s];
    
     % Measure initial memory usage
    initial_mem = whos('OPEN', 'CLOSED', 'map');
    memory_usage_initial = sum([initial_mem.bytes]);

    % Start timing the computation
    tic;
    
    while ~isempty(OPEN)
        % Pop the node with the smallest g-value (cost) from the OPEN set
        [~, index] = min(OPEN(:, 3));
        cur_node = OPEN(index, :);
        OPEN(index, :) = [];

        % Skip if node already exists in CLOSED set
        if loc_list(cur_node, CLOSED, [1, 2])
            continue
        end

        % Add to CLOSED set (node fully expanded)
        CLOSED = [cur_node; CLOSED];
        nodes_explored = nodes_explored + 1;  % Count node as explored

        % Update expand zone
        if ~loc_list(cur_node, EXPAND, [1, 2])
            EXPAND = [EXPAND; cur_node(1:2)];
        end

        % Goal reached
        if cur_node(1) == goal(1) && cur_node(2) == goal(2)
            goal_reached = true;
            cost = cur_node(3);
            break
        end

        % Explore neighbors
        for i = 1:motion_num
            node_n = [
                cur_node(1) + motion(i, 1), ...
                cur_node(2) + motion(i, 2), ...
                cur_node(3) + motion(i, 3), ...
                0, ...
                cur_node(1), cur_node(2)];
            
            neighbors_visited = neighbors_visited + 1;  % Count neighbor visit

            % Skip if the neighbor is already in the CLOSED set
            if loc_list(node_n, CLOSED, [1, 2])
                continue
            end

            % Skip if neighbor is an obstacle
            if map(node_n(1), node_n(2)) == 2
                continue
            end

            % Add neighbor to OPEN set
            OPEN = [OPEN; node_n];
        end

        % Track peak memory usage dynamically
        peak_memory_usage = track_peak_memory(OPEN, CLOSED, map);
    end

    % Stop timing the computation
    computation_time = toc;  % This gives the time in seconds
    % Measure final memory usage
    final_mem = whos('OPEN', 'CLOSED', 'map');
    memory_usage_final = sum([final_mem.bytes]);
    memory_usage = memory_usage_final;  % Estimate total memory usage

    % Extract path
    path = extract_path(CLOSED, start);

    % Calculate path length as the number of steps
    path_length_steps = calculate_blocks_traversed(path);

    % The final value of path_length_steps will give you the total number of grid cells traversed
   
    % Calculate Euclidean path length (optional)
    path_length_euclidean = 0;
    for i = 2:size(path, 1)
        dx = abs(path(i, 1) - path(i-1, 1));
        dy = abs(path(i, 2) - path(i-1, 2));
        if dx == 1 && dy == 1
            path_length_euclidean = path_length_euclidean + 1.414;
        else
            path_length_euclidean = path_length_euclidean + 1;
        end
    end

    % Round the Euclidean path length to 3 significant digits
    path_length_euclidean = round(path_length_euclidean, 3);

% Create a struct to return the results
result.path = path;
result.flag = goal_reached;
result.cost = cost;
result.expand = EXPAND;
result.computation_time = computation_time;
result.path_length_steps = path_length_steps;
result.path_length_euclidean = path_length_euclidean;
result.nodes_explored = nodes_explored;
result.neighbors_visited = neighbors_visited;
result.memory_usage_initial = memory_usage_initial;
result.memory_usage_final = memory_usage_final;
result.memory_usage = memory_usage;
result.peak_memory_usage = peak_memory_usage;
end

%%
function index = loc_list(node, list, range)
% @breif: locate the node in given list
num = size(list);
index = 0;

if ~num(1)
    return
else
    for i = 1:num(1)
        if isequal(node(range), list(i, range))
            index = i;
            return
        end
    end
end
end

function path = extract_path(close, start)
% @breif: Extract the path based on the CLOSED set.
path = [];
closeNum = size(close, 1);
index = 1;

while 1
    path = [path; close(index, 1:2)];

    if isequal(close(index, 1:2), start)
        break
    end

    for i = 1:closeNum
        if isequal(close(i, 1:2), close(index, 5:6))
            index = i;
            break
        end
    end
end
end