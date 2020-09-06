include("./Perlin/PerlinNoise.jl")
using .PerlinNoise

function generate_noise(resolution::Integer, frequency::AbstractFloat, amplitude::AbstractFloat)
    noise = zeros(Float32, resolution, resolution)

    # Perlin Noise repeats after 255
    stepsize::Float64 = 255 / (resolution-1)

    for row in 1:resolution
        for col in 1:resolution
            x = round(((col-1) * stepsize), digits=7)
            y = round(((row-1) * stepsize), digits=7)
            noise[col, row] = perlin2d(x * frequency, y * frequency)
        end
    end

    # scale to (0.0, 1.0) interval
    min = minimum(noise)
    max = maximum(noise)
    div = max - min

    f(x) = (x - min) / div
    noise = f.(noise)

    # set amplitude
    noise *= amplitude
    return noise
end