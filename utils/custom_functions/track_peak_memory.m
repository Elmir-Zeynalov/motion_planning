function peak_memory_usage = track_peak_memory(OPEN, CLOSED, map)
    % Track the memory usage of the specified variables during algorithm execution

    % Get the memory usage of each input variable
    open_mem = whos('OPEN');
    closed_mem = whos('CLOSED');
    map_mem = whos('map');

    % If the variables are empty, assign their sizes as 0 bytes
    if isempty(OPEN)
        open_mem.bytes = 0;
    end
    if isempty(CLOSED)
        closed_mem.bytes = 0;
    end
    if isempty(map)
        map_mem.bytes = 0;
    end

    % Calculate the total memory used by the variables
    current_memory_usage = open_mem.bytes + closed_mem.bytes + map_mem.bytes;

    % Track peak memory usage (initialize if needed)
    persistent memory_usage_over_time;
    if isempty(memory_usage_over_time)
        memory_usage_over_time = [];
    end

    % Append the current memory usage
    memory_usage_over_time = [memory_usage_over_time; current_memory_usage];

    % Return the peak memory usage recorded so far
    peak_memory_usage = max(memory_usage_over_time);
end