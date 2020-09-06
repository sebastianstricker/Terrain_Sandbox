using Makie
using AbstractPlotting.MakieLayout

MOUSE_SENSITIVITY = 0.005 # for interactive 3D-plot

function visualize(terrain::Array{<:AbstractFloat,2})
    outer_padding = 30
    scene, layout = MakieLayout.layoutscene(outer_padding, resolution = (1200, 700))

    # 3D model
    model_3D = layout[1, 1] = LScene(scene, camera = cam3d!)
    model = surface!(model_3D, terrain)
    cameracontrols(model).rotationspeed[] = MOUSE_SENSITIVITY

    # Heatmap
    hm_axe = layout[1, 2] = LAxis(scene)
    hm = heatmap!(hm_axe, terrain)
    tightlimits!.(hm_axe)           # fill full plot plane
    hm_axe.aspect = AxisAspect(1)   # locks ratio to square

    # Colorlegend
    cbar = layout[1, 3] = LColorbar(scene, hm, label = "Height")
    cbar.width = 30
    cbar.height = Relative(2/3)
    

    # Display scene
    scene
end