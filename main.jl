using Makie

include("map_generator.jl")

RESOLUTION = 1000
MOUSE_SENSITIVITY = 0.005 # for interactive 3D-plot

function visualize(terrain::Array{<:AbstractFloat,2})

    scene = Scene(resolution=(1920,1080))

    # Heatmap
    birdview = heatmap(terrain, axis = (showgrid = false,))
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
    model_3D = surface(terrain)
    cameracontrols(model_3D).rotationspeed[] = MOUSE_SENSITIVITY
    
    # Arrange horizontally
    vbox(model_3D, birdview, cm, parent = scene)
    
    # Display scene
    scene
end

function main()
    terrain = generate_noise(1000, 0.05, 100.0)
    visualize(terrain)
end

main()