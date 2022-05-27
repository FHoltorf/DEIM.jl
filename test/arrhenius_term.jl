using ModelingToolkit, LinearAlgebra

N = 1000
# scaled temperature profile: ν = T/T_ref with T_ref = (Ea/R)
ν(i,N,t) = (0.5 + 0.5*sin(2π*t)^2)*(3/2-exp(-i/N)) 
# arrhenius term evaluated for non-dimensionalized temperature
r(ν) = exp.(-ν.^2) 

# collect data
t_range = 0:0.01:1
R = zeros(N, length(t_range))
for (k,t) in enumerate(t_range)
    R[:, k] .= r([ν(i, N, t) for i in 1:N])
end

U, S, V = svd(R)
m = findfirst(x -> x <= 1e-8, S)

@variables temp[1:N]
temp = collect(temp)

# compute DEIM interpolation
Πinv, red_r, red_vars =  DEIM_interpolation(U[:, 1:m], r, temp)
red_var_indices = [arguments(var.val)[end] for var in red_vars]

compiled_red_f = eval(build_function(red_r, red_vars)[1])

R_red = zeros(N, length(t_range))
for (k,t) in enumerate(t_range)
    R_red[:, k] .= Πinv * compiled_red_f([ν(i, N, t) for i in red_var_indices])
end

@test norm(R - R_red) <= 1e-8