function peak_memory_usage = track_peak_memory(OPEN, CLOSED, map, EXPAND, reset)
    % Track the memory usage of the specified variables during algorithm execution
    % 'reset' parameter allows resetting of the peak memory between iterations

    % Persistent variable to store peak memory
    persistent peak_memory_usage_over_time;
    
    % Reset peak memory tracking if requested
    if reset
        peak_memory_usage_over_time = [];  % Clear the memory tracking
    end

    % Get the memory usage of each input variable
    open_mem = whos('OPEN');
    closed_mem = whos('CLOSED');
    map_mem = whos('map');
    expand_mem = whos('EXPAND');

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
    if isempty(EXPAND)
        expand_mem.bytes = 0;
    end

    % Calculate the total memory used by the variables
    current_memory_usage = open_mem.bytes + closed_mem.bytes + map_mem.bytes + expand_mem.bytes;

    % Initialize peak memory tracking if empty
    if isempty(peak_memory_usage_over_time)
        peak_memory_usage_over_time = current_memory_usage;  % Initialize with current memory usage
    end

    % Update peak memory usage if current usage is higher
    if current_memory_usage > peak_memory_usage_over_time
        peak_memory_usage_over_time = current_memory_usage;
    end

    % Return the peak memory usage recorded so far
    peak_memory_usage = peak_memory_usage_over_time;
end