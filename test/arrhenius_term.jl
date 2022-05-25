using ModelingToolkit, LinearAlgebra, GLMakie

N = 1000
# scaled temperature profile: ν = T/T_ref with T_ref = (Ea/R)
ν(i,N,t) = (0.5 + 0.5*sin(2π*t)^2)*(3/2-exp(-i/N)) 
# arrhenius term evaluated for non-dimensionalized temperature
r(ν) = exp.(-ν.^2) +  exp()

t_range = 0:0.01:1
R = zeros(N, length(t_range))
for (k,t) in enumerate(t_range)
    R[:, k] .= r([ν(i, N, t) for i in 1:N])
end

U, S, V = svd(R)
m = findfirst(x -> x <= 1e-8, S)

@variables temp[1:N]
temp = collect(temp)

Πinv, red_r, red_vars =  DEIM_interpolation(U[:, 1:m], r, temp)
red_var_indices = [arguments(var.val)[end] for var in red_vars]

compiled_red_f = eval(build_function(red_r, red_vars)[1])

R_red = zeros(N, length(t_range))
for (k,t) in enumerate(t_range)
    R_red[:, k] .= Πinv * compiled_red_f([ν(i, N, t) for i in red_var_indices])
end

@test norm(R - R_red) <= 1e-8

vis_comparison = Figure()
ax = Axis3(vis_comparison[1,1])
surface!(ax, 1:N, t_range, R, color = fill("#6d7d8a80", 1,1), transparency = true)
di, dt = 10, 1
wireframe!(ax, 1:di:N, t_range[1:dt:end], R_red[1:di:end, 1:dt:end], color = :blue, overdraw = true, tansparency = true)
