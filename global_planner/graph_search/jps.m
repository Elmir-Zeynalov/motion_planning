function result = jps(map, start, goal)
% @file: jps.m
% @breif: Jump Point Search motion planning
% @author: Winter
% @update: 2023.7.13

%
%   == OPEN and CLOSED ==
%   [x, y, g, h, px, py]
%   =====================
%

% initialize
OPEN = [];
CLOSED = [];
EXPAND = [];

cost = 0;
goal_reached = false;
nodes_explored = 0;  % Counter for nodes explored
neighbors_visited = 0;  % Counter for neighbors visited
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

node_s = [start, 0, h(start, goal), start];
OPEN = [OPEN; node_s];

% Reset peak memory tracking at the start of each run
track_peak_memory([], [], [], [], true);  % Reset the persistent memory tracking
% Start timing the computation
tic;

while ~isempty(OPEN(:, 1))
    % pop
    f = OPEN(:, 3) + OPEN(:, 4);
    [~, index] = min(f);
    cur_node = OPEN(index, :);
    OPEN(index, :) = [];

    % exists in CLOSED set
    if loc_list(cur_node, CLOSED, [1, 2])
        continue
    end

    % goal found
    if cur_node(1) == goal(1) && cur_node(2) == goal(2)
        CLOSED = [cur_node; CLOSED];
        goal_reached = true;
        cost = cur_node(3);
        break
    end

    jp_list = [];

    for i = 1:motion_num
        [jp, goal_reached] = jump(cur_node, motion(i, :), goal, map);
        
        % exists and not in CLOSED set
        if goal_reached && ~loc_list(jp, CLOSED, [1, 2])
            neighbors_visited = neighbors_visited + 1;  % Track neighbor visits
            jp(5:6) = cur_node(1:2);
            jp(4) = h(jp(1:2), goal);
            jp_list = [jp; jp_list];
        end
    end

    for j = 1:size(jp_list, 1)
        jp = jp_list(j, :);
        
        % update OPEN set
        OPEN = [OPEN; jp];
        EXPAND = [EXPAND; jp];

        % goal found
        if jp(1) == goal(1) && jp(2) == goal(2)
            break
        end

    end

    CLOSED = [cur_node; CLOSED];
    nodes_explored = nodes_explored + 1;  % Track nodes explored

    % Track peak memory usage dynamically inside the loop
    peak_memory_usage = track_peak_memory(OPEN, CLOSED, map, EXPAND, false);
end
% Stop timing the computation
computation_time = toc;


% extract path
path = extract_path(CLOSED, start);

% Calculate path length as the number of steps
path_length_steps = calculate_blocks_traversed(path);

% Calculate Euclidean path length (optional)
path_length_euclidean = 0;
for i = 2:size(path, 1)
    dx = abs(path(i, 1) - path(i-1, 1));
    dy = abs(path(i, 2) - path(i-1, 2));
    if dx == 1 && dy == 1
        path_length_euclidean = path_length_euclidean + sqrt(2);
    else
        path_length_euclidean = path_length_euclidean + 1;
    end
end
path_length_euclidean = round(path_length_euclidean, 3);  % Round for precision

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
result.memory_usage_initial = 0;
result.memory_usage_final = 0;
result.memory_usage = 0;
result.peak_memory_usage = peak_memory_usage;
end

%%
function h_val = h(cur_node, goal)
% @breif: heuristic function(Manhattan distance)
h_val = abs(cur_node(1) - goal(1)) + abs(cur_node(2) - goal(2));
end

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
        break;
    end

    for i = 1:closeNum
        if isequal(close(i, 1:2), close(index, 5:6))
            index = i;
            break
        end
    end
end
end

function [new_node, flag] = jump(cur_node, motion, goal, map)
flag = false;

% explore a new node
new_node = [cur_node(1) + motion(1), ...
    cur_node(2) + motion(2), ...
    cur_node(3) + motion(3), ...
    0, cur_node(1), cur_node(2)
    ];
new_node(4) = h(new_node(1:2), goal);

% obstacle
if new_node(1) <= 0 || new_node(2) <= 0 || map(new_node(1), new_node(2)) == 2
    return
end

% goal found
if new_node(1) == goal(1) && new_node(2) == goal(2)
    flag = true;
    return
end

% diagonal
if motion(1) && motion(2)
    % if exists jump point at horizontal or vertical
    x_dir = [motion(1), 0, 1];
    y_dir = [0, motion(2), 1];
    [~, flag_x] = jump(new_node, x_dir, goal, map);
    [~, flag_y] = jump(new_node, y_dir, goal, map);

    if flag_x || flag_y
        flag = true;
        return
    end
end

% if exists forced neighbor
if detect_force(new_node, motion, map)
    flag = true;
    return
else
    [new_node, flag] = jump(new_node, motion, goal, map);
    return
end
end

function flag = detect_force(cur_node, motion, map)
flag = true;
x = cur_node(1);
y = cur_node(2);
x_dir = motion(1);
y_dir = motion(2);

% horizontal
if x_dir && ~y_dir
    if map(x, y + 1) == 2 && map(x + x_dir, y + 1) ~= 2
        return
    end

    if map(x, y - 1) == 2 && map(x + x_dir, y - 1) ~= 2
        return
    end
end

% vertical
if ~x_dir && y_dir
    if map(x + 1, y) == 2 && map(x + 1, y + y_dir) ~= 2
        return
    end

    if map(x - 1, y) == 2 && map(x - 1, y + y_dir) ~= 2
        return
    end
end

% diagonal
if x_dir && y_dir
    if map(x - x_dir, y) == 2 && map(x - x_dir, y + y_dir) ~= 2
        return
    end

    if map(x, y - y_dir) == 2 && map(x + x_dir, y - y_dir) ~= 2
        return
    end
end

flag = false;
return
end
