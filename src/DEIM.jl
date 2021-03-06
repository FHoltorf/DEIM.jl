module DEIM

using Symbolics
"""
    interpolation_indices(U::Matrix)

Greedy search for interpolation indices, given a basis U. Returns a vector of row indices.  
"""
function interpolation_indices(U::Matrix)
    n, m = size(U)
    π = argmax(abs.(U[:,1]))[1]
    π« = [π]
    for l in 2:m
        PU = @view U[π«,1:l-1] 
        PUl = @view U[π«,l]
        ul = @view U[:,l]
        Ul = @view U[:,1:l-1]
        c = PU\PUl
        π = argmax(abs.(ul - Ul*c))[1]
        push!(π«, π)
    end
    return π«
end

"""
   DEIM_interpolation(U::Matrix, f, args...; ps = Set(), ivs = Set())

Build discrete empirical interpolator of a function f with arguments args. 
f can be any julia function that allows symbolic variables to be propagated through it 
and args shall be chosen as symbolic placeholders for the function arguments. 

Returns 
    * Ξ inv - left inverse of discrete empirical projector Ξ , so that f(args) β Ξ inv red_f(red_args)
    * red_f - Vector of symbolic expressions describing the interpolated rows of f
    * red_args - Set of arguments needed to compute red_f
"""
function DEIM_interpolation(U::Matrix, f, args...; ps = Set(), ivs = Set())
    f_symb = f(args...)
    return DEIM_interpolation(U, f_symb, ps = ps, ivs = ivs)
end

function DEIM_interpolation(U::Matrix, f::Vector{Num}; ps = Set(), ivs = Set())
    π« = interpolation_indices(U)
    red_f = f[π«] 
    red_args = Num[]
    excluded_args = union(ps, ivs)
    for expr in red_f
        vars = [var for var in Symbolics.get_variables(expr) if var β excluded_args]
        union!(red_args, vars)
    end
    return (U[π«,:]'\U')', red_f, red_args
end

export DEIM_interpolation, interpolation_indices

end
