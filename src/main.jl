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

function draw_rectangle(A::Array{UInt32,1}, width, height, x, y, dx, dy, color)
    if x+dx-1 > width || y+dy-1 > height
        print("Rectangle dimensions are invalid")
        return A
    end
    for i = x:x+dx-1
        for j = y:y+dy-1
            A[i+(j-1)*width] = color
        end
    end
    return A
end
 
function get_map()
    import_map = ( "1111111111111111",
               "1000000000000001",
               "1000000000000001",
               "1001000011111111",
               "1001000000000001",
               "1001000000000001",
               "1001111000111001",
               "1000001000100001",
               "1000001000100011",
               "1000001000100011",
               "1000001000000011",
               "1000001000000011",
               "1000001111000001",
               "1000000000000001",
               "1000000000000001",
               "1111111111111111" )
    return join(import_map)
end

function main()
    # Defining canvas size
    width = 512
    height = 512
        
    # Creating canvas array, initialized to red
    A = Array{UInt32,1}(undef, height * width)
    A = fill!(A, 255)
    
    # Creating gradient
    A = create_gradient(A, width, height)

    map_w = 16
    map_h = 16
    map_layout = get_map()
    
    # Draw rectangle
    # A = draw_rectangle(A, width, height, 50, 120, 100, 200, pack_color(0x14, 0x14, 0xff))
    
    # Draw map
    wall_w::UInt8 = width/map_w
    wall_h::UInt8 = height/map_h 
    for j = 1:map_h
        for i = 1:map_w
            if map_layout[i + (j-1)*map_w] == '1'
                A = draw_rectangle(A, width, height, 1+(i-1)*wall_w, 1+(j-1)*wall_h, wall_w, wall_h, pack_color(UInt8(floor(rand()*255)), 0x14, 0xff))
            end
        end
    end

    # Saving image to .ppm format
    drop_ppm_image("./out.ppm", A, width,  height)
    println("Done")
end
