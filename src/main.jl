include("map_generator.jl")
include("interface.jl")

RESOLUTION = 1000
FREQUENCY = 0.05
AMPLITUDE = 100.0

function main()
    terrain = generate_noise(RESOLUTION, FREQUENCY, AMPLITUDE)
    visualize(terrain)
end

main()