# Smaps.jl
 Wrapper for smaps process memory usage reporting


 ```julia
 julia> using Smaps

 julia> Smaps.summary(;pid = getpid(), sortby = :Size)
 ```
