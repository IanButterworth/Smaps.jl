# Smaps.jl
 Wrapper for smaps process memory usage reporting


```julia
 julia> using Smaps

 julia> Smaps.print(;pid = getpid(), sortby = :Size)
```

To get a dataframe
```julia
 julia> Smaps.summary(;pid = getpid())
```