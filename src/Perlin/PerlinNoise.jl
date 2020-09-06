module PerlinNoise
#=
Adapted implementation of Adrian Biagioli (https://adrianb.io/2014/08/09/perlinnoise.html) (Last Accessed: September 2020)
=#
export perlin2d, perlin3d

const p = [151,160,137,91,90,15,
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,
151,160,137,91,90,15,
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
]

smoothstep(x) = x^3 *(x*(x*6 - 15) + 10)

# Linear interpolation
function lerp(a1, a2, weight)
    return (1.0 - weight)*a1 + weight*a2
end

# Calculates dotproduct and gradient of corner(hash) in one go
function grad_dot3d(hash, x, y, z)

    # 0xF limits to the 12 possible gradient vectors.
    # Reasons for choosing them and why there are 16 options here can be found in
    # Perlin K., "Improving noise", 2002
    case = hash & 0xF 
    if case == 0x0 
        return  x + y;
    elseif case == 0x1 
        return -x + y;
    elseif case == 0x2 
        return  x - y;
    elseif case == 0x3 
        return -x - y;
    elseif case == 0x4 
        return  x + z;
    elseif case == 0x5 
        return -x + z;
    elseif case == 0x6 
        return  x - z;
    elseif case == 0x7 
        return -x - z;
    elseif case == 0x8 
        return  y + z;
    elseif case == 0x9 
        return -y + z;
    elseif case == 0xA 
        return  y - z;
    elseif case == 0xB 
        return -y - z;
    elseif case == 0xC 
        return  y + x;
    elseif case == 0xD 
        return -y + z;
    elseif case == 0xE 
        return  y - x;
    elseif case == 0xF 
        return -y - z;
    else
        throw(ArgumentError("Variable not in (0, 0xF) after bitwise-AND with '0xF'. How is this possible?"))
    end
end

# 3d Perlin noise. Careful, repeats after 256.
function perlin3d(x::AbstractFloat, y::AbstractFloat, z::AbstractFloat)
    xi = trunc(Int, x)
    yi = trunc(Int, y)
    zi = trunc(Int, z)

    # Relative position in grid cube "floored"
    xf = x - xi
    yf = y - yi
    zf = z - zi

    # Closest upper left grid corner
    xi = xi & 255
    yi = yi & 255
    zi = zi & 255

    # Interpolation weights
    xw = smoothstep(xf);
    yw = smoothstep(yf);
    zw = smoothstep(zf);

    # Find hash for all corners
    aaa = p[p[p[    xi  ]+    yi  ]+    zi  ]
    aba = p[p[p[    xi  ]+    yi+1]+    zi  ]
    aab = p[p[p[    xi  ]+    yi  ]+    zi+1]
    abb = p[p[p[    xi  ]+    yi+1]+    zi+1]
    baa = p[p[p[    xi+1]+    yi  ]+    zi  ]
    bba = p[p[p[    xi+1]+    yi+1]+    zi  ]
    bab = p[p[p[    xi+1]+    yi  ]+    zi+1]
    bbb = p[p[p[    xi+1]+    yi+1]+    zi+1]

    # calculate dotproducts and interpolate results for final value
    x1 = lerp(  grad_dot3d(aaa, xf  , yf  , zf), 
                grad_dot3d(baa, xf-1, yf  , zf),  
                xw)                       
    x2 = lerp(  grad_dot3d(aba, xf  , yf-1, zf),
                grad_dot3d(bba, xf-1, yf-1, zf),  
                xw)
    y1 = lerp(x1, x2, yw)

    x1 = lerp(  grad_dot3d(aab, xf  , yf  , zf-1),
                grad_dot3d(bab, xf-1, yf  , zf-1),
                xw)
    x2 = lerp(  grad_dot3d(abb, xf  , yf-1, zf-1),
                grad_dot3d(bbb, xf-1, yf-1, zf-1),
                xw)
    y2 = lerp(x1, x2, yw)
    
    result = lerp(y1, y2, zw) 
    return result
end

# Calculates dotproduct and gradient of corner(hash) in one go
function grad_dot2d(hash, x, y)

    # 0xF limits to the 4
    case = hash & 3
    if case == 0 
        return  x + y;
    elseif case == 1 
        return -x + y;
    elseif case == 2 
        return  x - y;
    elseif case == 3 
        return -x - y;
    else
        throw(ArgumentError("'hash & 3' returned value not in (0, 3). How is this possible?"))
    end
end

# 2d Perlin noise. Careful, repeats after 256.
function perlin2d(x::AbstractFloat, y::AbstractFloat)
    xi = trunc(Int, x)
    yi = trunc(Int, y)

    # Relative position in grid cube "floored"
    xf = x - xi
    yf = y - yi

    # Closest upper left grid corner
    xi = xi & 255
    yi = yi & 255

    # Interpolation weights
    xw = smoothstep(xf);
    yw = smoothstep(yf);

    # Find hash for all corners
    aa = p[p[  xi+1]+  yi+1]
    ab = p[p[  xi+1]+  yi+2]
    ba = p[p[  xi+2]+  yi+1]
    bb = p[p[  xi+2]+  yi+2]

    # calculate dotproducts and interpolate results for final value
    x1 = lerp(  grad_dot2d(aa, xf,   yf), 
                grad_dot2d(ba, xf-1, yf),
                xw)                       
    x2 = lerp(  grad_dot2d(ab, xf,   yf-1),
                grad_dot2d(bb, xf-1, yf-1),  
                xw)
                
    result = lerp(x1, x2, yw)
    return result
end
end