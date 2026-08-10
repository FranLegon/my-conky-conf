local max_down = 0
local max_up = 0

local function round_half_up(value)
    return math.floor(value + 0.5)
end

local function parse_scaled_value(value)
    local number, unit = value:match('([%d%.%,]+)%s*([%a]+)')
    if not number then
        return tonumber(value) or 0
    end

    local normalized = number:gsub('%.', ''):gsub(',', '.')
    local amount = tonumber(normalized) or 0
    local multipliers = {
        B = 1,
        KiB = 1024,
        MiB = 1024 ^ 2,
        GiB = 1024 ^ 3,
        TiB = 1024 ^ 4,
        KB = 1000,
        MB = 1000 ^ 2,
        GB = 1000 ^ 3,
        TB = 1000 ^ 4,
    }

    return amount * (multipliers[unit] or 1)
end

local function format_binary_bytes(bytes)
    if bytes >= 1024 ^ 4 then
        return string.format('%.2f TiB', bytes / (1024 ^ 4))
    elseif bytes >= 1024 ^ 3 then
        return string.format('%.2f GiB', bytes / (1024 ^ 3))
    elseif bytes >= 1024 ^ 2 then
        return string.format('%.2f MiB', bytes / (1024 ^ 2))
    elseif bytes >= 1024 then
        return string.format('%d KiB', round_half_up(bytes / 1024))
    else
        return string.format('%d B', round_half_up(bytes))
    end
end

local function format_decimal_bytes(bytes)
    if bytes >= 1000 ^ 4 then
        return string.format('%.2f TB', bytes / (1000 ^ 4))
    elseif bytes >= 1000 ^ 3 then
        return string.format('%.2f GB', bytes / (1000 ^ 3))
    elseif bytes >= 1000 ^ 2 then
        return string.format('%.2f MB', bytes / (1000 ^ 2))
    elseif bytes >= 1000 then
        return string.format('%d KB', round_half_up(bytes / 1000))
    else
        return string.format('%d B', round_half_up(bytes))
    end
end

local function format_binary_rate(kib)
    local bytes = kib * 1024
    if bytes >= 1024 ^ 3 then
        return string.format('%.2f GiB/s', bytes / (1024 ^ 3))
    elseif bytes >= 1024 ^ 2 then
        return string.format('%.2f MiB/s', bytes / (1024 ^ 2))
    elseif bytes >= 1024 then
        return string.format('%d KiB/s', round_half_up(bytes / 1024))
    else
        return string.format('%d B/s', round_half_up(bytes))
    end
end

local function format_decimal_rate(kib)
    local bytes = kib * 1024
    if bytes >= 1000 ^ 3 then
        return string.format('%.2f GB/s', bytes / (1000 ^ 3))
    elseif bytes >= 1000 ^ 2 then
        return string.format('%.2f MB/s', bytes / (1000 ^ 2))
    elseif bytes >= 1000 then
        return string.format('%d KB/s', round_half_up(bytes / 1000))
    else
        return string.format('%d B/s', round_half_up(bytes))
    end
end

local function get_conky_bytes(template)
    return parse_scaled_value(conky_parse(template))
end

function conky_get_mem()
    local total = get_conky_bytes('${memmax}')
    local used = get_conky_bytes('${mem}')
    return string.format('%s / %s', format_binary_bytes(used), format_binary_bytes(total))
end

function conky_get_mem_decimal()
    local total = get_conky_bytes('${memmax}')
    local used = get_conky_bytes('${mem}')
    return string.format('%s / %s', format_decimal_bytes(used), format_decimal_bytes(total))
end

function conky_get_swap()
    local total = get_conky_bytes('${swapmax}')
    local used = get_conky_bytes('${swap}')
    return string.format('%s / %s', format_binary_bytes(used), format_binary_bytes(total))
end

function conky_get_swap_decimal()
    local total = get_conky_bytes('${swapmax}')
    local used = get_conky_bytes('${swap}')
    return string.format('%s / %s', format_decimal_bytes(used), format_decimal_bytes(total))
end

function conky_get_fs(path)
    local total = get_conky_bytes('${fs_size ' .. path .. '}')
    local used = get_conky_bytes('${fs_used ' .. path .. '}')
    return string.format('%s / %s', format_binary_bytes(used), format_binary_bytes(total))
end

function conky_get_fs_decimal(path)
    local total = get_conky_bytes('${fs_size ' .. path .. '}')
    local used = get_conky_bytes('${fs_used ' .. path .. '}')
    return string.format('%d GB / %d GB', round_half_up(used / (1000 ^ 3)), round_half_up(total / (1000 ^ 3)))
end

function conky_get_diskio_read()
    local current = get_conky_bytes('${diskio_read}') / 1024
    return format_binary_rate(current)
end

function conky_get_diskio_read_decimal()
    local current = get_conky_bytes('${diskio_read}') / 1024
    return format_decimal_rate(current)
end

function conky_get_diskio_write()
    local current = get_conky_bytes('${diskio_write}') / 1024
    return format_binary_rate(current)
end

function conky_get_diskio_write_decimal()
    local current = get_conky_bytes('${diskio_write}') / 1024
    return format_decimal_rate(current)
end

function conky_get_totaldown(iface)
    local total = get_conky_bytes('${totaldown ' .. iface .. '}')
    return format_binary_bytes(total)
end

function conky_get_totaldown_decimal(iface)
    local total = get_conky_bytes('${totaldown ' .. iface .. '}')
    return format_decimal_bytes(total)
end

function conky_get_totalup(iface)
    local total = get_conky_bytes('${totalup ' .. iface .. '}')
    return format_binary_bytes(total)
end

function conky_get_totalup_decimal(iface)
    local total = get_conky_bytes('${totalup ' .. iface .. '}')
    return format_decimal_bytes(total)
end

function conky_get_current_down(iface)
    local current = tonumber(conky_parse('${downspeedf ' .. iface .. '}')) or 0
    return format_binary_rate(current)
end

function conky_get_downspeed_decimal(iface)
    local current = tonumber(conky_parse('${downspeedf ' .. iface .. '}')) or 0
    return format_decimal_rate(current)
end

function conky_get_current_up(iface)
    local current = tonumber(conky_parse('${upspeedf ' .. iface .. '}')) or 0
    return format_binary_rate(current)
end

function conky_get_upspeed_decimal(iface)
    local current = tonumber(conky_parse('${upspeedf ' .. iface .. '}')) or 0
    return format_decimal_rate(current)
end

function conky_get_max_down(iface)
    local current = tonumber(conky_parse('${downspeedf ' .. iface .. '}')) or 0
    if current > max_down then
        max_down = current
    end
    return format_binary_rate(max_down)
end

function conky_get_max_up(iface)
    local current = tonumber(conky_parse('${upspeedf ' .. iface .. '}')) or 0
    if current > max_up then
        max_up = current
    end
    return format_binary_rate(max_up)
end

function conky_get_max_down_decimal(iface)
    return format_decimal_rate(max_down)
end

function conky_get_max_up_decimal(iface)
    return format_decimal_rate(max_up)
end

local function shell_quote(value)
    return "'" .. tostring(value):gsub("'", [['\'']]) .. "'"
end

local function trim(value)
    return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

local process_cache = {
    cpu = { updates = -1, processes = {} },
    mem = { updates = -1, processes = {} },
}

local function get_grouped_processes(sort_key, limit)
    local command = string.format(
        "ps -eo comm=,%s= --no-headers | awk '{ key = $1; value = $2 + 0; data[key] += value } END { for (key in data) printf \"%%s\t%%.1f\\n\", key, data[key] }' | sort -k2,2nr -k1,1 | head -n %d",
        sort_key,
        limit
    )
    local handle = io.popen(command)
    if not handle then
        return {}
    end

    local processes = {}
    for line in handle:lines() do
        local name, value = line:match('^(.-)%s+([%d%.]+)$')
        if name and value then
            processes[#processes + 1] = {
                name = trim(name),
                value = tonumber(value) or 0,
            }
        end
    end
    handle:close()
    return processes
end

local function get_cached_grouped_processes(sort_key)
    local cache_key = sort_key == 'pcpu' and 'cpu' or 'mem'
    local current_updates = tonumber(conky_parse('${updates}')) or 0
    local cache = process_cache[cache_key]

    if cache.updates ~= current_updates then
        cache.processes = get_grouped_processes(sort_key, 5)
        cache.updates = current_updates
    end

    return cache.processes
end

local function get_grouped_process_field(sort_key, index, field)
    local processes = get_cached_grouped_processes(sort_key)
    local process = processes[tonumber(index) or 0]
    if not process then
        return ''
    end
    if field == 'name' then
        return process.name
    end
    return string.format('%.1f%%', process.value)
end

function conky_get_top_cpu_name(index)
    return get_grouped_process_field('pcpu', index, 'name')
end

function conky_get_top_cpu_value(index)
    return get_grouped_process_field('pcpu', index, 'value')
end

function conky_get_top_mem_name(index)
    return get_grouped_process_field('pmem', index, 'name')
end

function conky_get_top_mem_value(index)
    return get_grouped_process_field('pmem', index, 'value')
end
