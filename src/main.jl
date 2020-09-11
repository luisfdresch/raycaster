# Importing packages
using Colors
using Plots




# Plotting array
#plot(A)


function pack_color(r::UInt8,  g::UInt8, b::UInt8, a::UInt8 = 0xff)
    return (UInt32(a)<<24) + (UInt32(b)<<16) + (UInt32(g)<<8) + r;
end

function unpack_color( color::UInt32)
    r::UInt8 = (color >> 0) & 255
    g::UInt8 = (color >> 8) & 255
    b::UInt8 = (color >> 16) & 255
    a::UInt8 = (color >> 24) & 255
    return r, g, b, a
end

function main()
    # Defining canvas size
    width = 400
    height = 300
        
    # Creating canvas array
    A = Array{UInt32,1}(undef, height * width)
    A = fill!(A, 255)
end
