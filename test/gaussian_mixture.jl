using ModelingToolkit, LinearAlgebra, GLMakie

n_centers = 4
center = [randn(2) for i in 1:n_centers]


gaussian_mixture(x_range,y_range) = [sum(exp(-([x;y] - center[i])'*([x;y] - center[i])/0.1) for i in 1:n_centers) for x in x_range, y in y_range]

x_range = -2:0.01:2
y_range = -2:0.01:2

data = gaussian_mixture(x_range, y_range) 

fig = Figure()
ax = Axis3(fig[1,1])
surface!(ax, x_range, y_range, data)

U, S, V = svd(data)