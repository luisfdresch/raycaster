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

function drop_ppm_image( filename::String, image::Array{UInt32,1}, width, height)
    file = open(filename, "w")
    print(file, "P3\n$(width)\t$(height)\n255\n")
    for i = 1:width*height
        r, g, b, a = unpack_color(image[i])
        print(file, "$r $g $b ")

    end
    close(file)
end

function create_gradient(A::Array{UInt32,1}, width, height)
    for j = 1:height
        for i = 1:width
            r::UInt8 = floor(255*j/height)
            g::UInt8 = floor(255*i/width)
            b::UInt8 = 0 
            A[i+(j-1)*width] = pack_color(r, g, b)
        end
    end
    return A
end
 
function main()
    # Defining canvas size
    width = 400
    height = 300
        
    # Creating canvas array, initialized to red
    A = Array{UInt32,1}(undef, height * width)
    A = fill!(A, 255)
    
    # Creating gradient
    A = create_gradient(A, width, height)
    
    # Saving image to .ppm format
    drop_ppm_image("./out.ppm", A, width,  height)
    println("Done")
end
