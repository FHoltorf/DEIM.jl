module DEIM

using Symbolics
"""
    interpolation_indices(U::Matrix)

Greedy search for interpolation indices, given a basis U. Returns a vector of row indices.  
"""
function interpolation_indices(U::Matrix)
    n, m = size(U)
    𝓅 = argmax(abs.(U[:,1]))[1]
    𝒫 = [𝓅]
    for l in 2:m
        PU = @view U[𝒫,1:l-1] 
        PUl = @view U[𝒫,l]
        ul = @view U[:,l]
        Ul = @view U[:,1:l-1]
        c = PU\PUl
        𝓅 = argmax(abs.(ul - Ul*c))[1]
        push!(𝒫, 𝓅)
    end
    return 𝒫
end

"""
   DEIM_interpolation(U::Matrix, f, args...; ps = Set(), ivs = Set())

Build discrete empirical interpolator of a function f with arguments args. 
f can be any julia function that allows symbolic variables to be propagated through it 
and args shall be chosen as symbolic placeholders for the function arguments. 

Returns 
    * Πinv - left inverse of discrete empirical projector Π, so that f(args) ≈ Πinv red_f(red_args)
    * red_f - Vector of symbolic expressions describing the interpolated rows of f
    * red_args - Set of arguments needed to compute red_f
"""

function DEIM_interpolation(U::Matrix, f, args...; ps = Set(), ivs = Set())
    f_symb = f(args...)
    return DEIM_interpolation(U, f_symb, ps = ps, ivs = ivs)
end

function DEIM_interpolation(U::Matrix, f::Vector{Num}; ps = Set(), ivs = Set())
    𝒫 = interpolation_indices(U)
    red_f = f[𝒫] 
    red_args = Num[]
    excluded_args = union(ps, ivs)
    for expr in red_f
        vars = [var for var in Symbolics.get_variables(expr) if var ∉ excluded_args]
        union!(red_args, vars)
    end
    return (U[𝒫,:]'\U')', red_f, red_args
end

export DEIM_interpolation, interpolation_indices

end