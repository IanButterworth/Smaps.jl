module Smaps

using DataFrames

function summary(pid = getpid(); sortby = :Size)
    df = DataFrame(
        mem_area = String[],
        Size = Int[],
        KernelPageSize = Int[],
        MMUPageSize = Int[],
        Rss = Int[],
        Pss = Int[],
        Shared_Clean = Int[],
        Shared_Dirty = Int[],
        Private_Clean = Int[],
        Private_Dirty = Int[],
        Referenced = Int[],
        LazyFree = Int[],
        AnonHugePages = Int[],
        ShmemPmdMapped = Int[],
        FilePmdMapped = Int[],
        Shared_Hugetlb = Int[],
        Private_Hugetlb = Int[],
        Swap = Int[],
        SwapPss = Int[],
        Locked = Int[],
    )
    open("/proc/$(pid)/smaps") do f
        for mem_area in eachline("/proc/$(pid)/maps")
            readuntil(f, strip(mem_area))
            start_pos = position(f)
            readline(f)
            row = (
                mem_area = mem_area,
                Size = get_kb(f, start_pos, "Size"),
                KernelPageSize = get_kb(f, start_pos, "KernelPageSize"),
                MMUPageSize = get_kb(f, start_pos, "MMUPageSize"),
                Rss = get_kb(f, start_pos, "Rss"),
                Pss = get_kb(f, start_pos, "Pss"),
                Shared_Clean = get_kb(f, start_pos, "Shared_Clean"),
                Shared_Dirty = get_kb(f, start_pos, "Shared_Dirty"),
                Private_Clean = get_kb(f, start_pos, "Private_Clean"),
                Private_Dirty = get_kb(f, start_pos, "Private_Dirty"),
                Referenced = get_kb(f, start_pos, "Referenced"),
                LazyFree = get_kb(f, start_pos, "LazyFree"),
                AnonHugePages = get_kb(f, start_pos, "AnonHugePages"),
                ShmemPmdMapped = get_kb(f, start_pos, "ShmemPmdMapped"),
                FilePmdMapped = get_kb(f, start_pos, "FilePmdMapped"),
                Shared_Hugetlb = get_kb(f, start_pos, "Shared_Hugetlb"),
                Private_Hugetlb = get_kb(f, start_pos, "Private_Hugetlb"),
                Swap = get_kb(f, start_pos, "Swap"),
                SwapPss = get_kb(f, start_pos, "SwapPss"),
                Locked = get_kb(f, start_pos, "Locked"),
                # TODO
                # THPeligible
                # ProtectionKey
                # VmFlags
            )
            push!(df, row)
        end
    end
    if !isnothing(sortby)
        sort!(df, sortby, rev = true)
    end
    return df
end

function get_kb(f, start_pos, field)
    line = readline(f)
    if occursin(field, line)
        try
            str_val = strip(split(line, "$(field):")[2])
            str_num = split(str_val, " kB")[1]
            parse(Int, str_num)
        catch e
            @error "Could not parse $field" line e
            return 0
        end
    else
        seek(f, start_pos)
        str = readuntil(f, "$(field):")
        try
            if count("\nSize:", str) > 1
                # if we've gone into the next entry, abort
                error("Field not found in area entry")
            end
            str_val = strip(readline(f))
            str_num = split(str_val, " kB")[1]
            parse(Int, str_num)
        catch e
            @error "Could not parse `$field`"
            return 0
        end
    end
end

end # module Smaps
