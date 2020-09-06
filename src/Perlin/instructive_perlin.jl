#=
My take on perlin noise.
This standalone implementation should make understanding the concept of the algorithm a bit easier.
Not using a hash table is way less performant though.

However here the noise is truely random and not pseudo-random.
=#
using LinearAlgebra
using Makie

GRIDSIZE = 10
RESOLUTION = 1000
MOUSE_SENSITIVITY = 0.005 # for interactive 3D-plot

# 1st and 2nd derivatives are zero at x = 0; x = 1. Leads to smooth noise
smoothstep(x) = x^3 *(x*(x*6 - 15) + 10)

# Linear interpolation
function lerp(weight, a1, a2)
    return (1.0 - weight)*a1 + weight*a2
end

# Generates a random gradient for each gridpoint
function init_grid(gridsize)
    println("Generating gradients...")

    grid = zeros(Float32, gridsize, gridsize, 2)

    for row in 1:gridsize
        for col in 1:gridsize
            x = rand()*2 - 1
            y = sqrt(1-x*x)
            if rand() > 0.5
                y = -y
            end 
            grid[col, row, :] = [x, y]
        end
    end
    return grid
end

# Calculates the dot product of the gradient and the point inside the grid.
function dot_product(grid, x, y, x_grid, y_grid)

    #position vector
    r = [x - x_grid, y - y_grid]
    grad = grid[x_grid, y_grid, :]

    return dot(grad, r)
end

# x,y in range of grid size
function perlin(grid, x, y)

    #closest upper left grid corner
    x_grid = trunc(Int, x)
    y_grid = trunc(Int, y)

    #dotproducts from point to each corner
    dot1 = dot_product(grid, x, y, x_grid, y_grid)
    dot2 = dot_product(grid, x, y, x_grid+1, y_grid)
    dot3 = dot_product(grid, x, y, x_grid, y_grid+1)
    dot4 = dot_product(grid, x, y, x_grid+1, y_grid+1)

    #interpolation weight from relative position in grid square
    wx = smoothstep(x % 1)
    wy = smoothstep(y % 1)

    #interpolate dot products
    i1 = lerp(wx, dot1, dot2)
    i2 = lerp(wx, dot3, dot4)

    value = lerp(wy, i1, i2)
    return value
end

function generate_noise(gradient_grid, resolution)

    println("Calculating noise...")
    noise = zeros(Float32, resolution, resolution)

    gridsize = size(gradient_grid, 1)
    stepsize::Float64 = (gridsize - 1) / resolution

    for row in 1:resolution
        for col in 1:resolution
            x = round(1 + ((col-1) * stepsize), digits=7)
            y = round(1 + ((row-1) * stepsize), digits=7)
            noise[col, row] = perlin(gradient_grid, x, y)
        end
    end
 
    # scale
    println("scaling...")
    min = minimum(noise)
    max = maximum(noise)
    div = max - min

    f(x) = (x - min) / div
    noise = f.(noise)

    return noise
end

function visualize(noise)

    scene = Scene(resolution=(1920,1080))

    # Heatmap
    birdview = heatmap(noise, axis = (showgrid = false,))
    cm = colorlegend(
        birdview[end],       # access the plot of Scene p1
        raw = true,          # without axes or grid
        camera = campixel!,  # gives a concrete bounding box in pixels
                             # so that the `vbox` gives you the right size
        width = (            # make the colorlegend longer so it looks nicer
            30,              # the width
            900              # the height
        ))

    # Interactive 3D Model
    model_3D = surface(noise*50)
    cameracontrols(model_3D).rotationspeed[] = MOUSE_SENSITIVITY
    
    # Arrange horizontally
    vbox(model_3D, birdview, cm, parent = scene)
    
    # Display scene
    scene
end

function main()
    
    grid = init_grid(GRIDSIZE)
    noise = generate_noise(grid, RESOLUTION)
    
    visualize(noise)

end

main()