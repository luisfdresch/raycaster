# Importing packages
using Colors
using Plots

# Defining canvas size
width = 400
height = 300


# Creating canvas array
A = Array{RGB{},2}(undef, height , width)
A = fill!(A,0.0)

# Plotting array
plot(A)


function pack_color(const r::UInt8, const g::UInt8, const b::UInt8, const a::UInt8 = 255)
    return (a<<24) + (b<<16) + (g<<8) + r;
end

function unpack_color(const color::UInt32)
    r::UInt8 = (color >> 0) & 255
    g::UInt8 = (color >> 8) & 255
    b::UInt8 = (color >> 16) & 255
    a::UInt8 = (color >> 24) & 255
    return r, g, b, a
end
