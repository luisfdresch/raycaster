# Importing packages
#using Colors
#using Plots
using Gtk



# Plotting array
#plot(A)


global player_x = 5
global player_y = 5  
global player_dir = deg2rad(45)
global player_fov = deg2rad(100) 
global c
global update_count = 0

@guarded function update_canvas(widget)
    global player_x
    global player_y
    global player_dir
    global player_fov

    ctx = Gtk.getgc(widget)
    rectangle(ctx, 0, 0, width(widget), height(widget))
    set_source_rgb(ctx, 0,0,0)
    fill(ctx)
    rectangle(ctx, player_x, player_y, 10, 10)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)
    
    #To Fix -------------------vvvvvv-------------------v-------------------------------

    map_layout = get_map()
    win_w= width(widget)
    win_h = height(widget)
    map_w = map_h = 16  
    
    # Draw map
    wall_w::UInt8 = win_w/(map_w*2)
    wall_h::UInt8 = win_h/map_h 
    for j = 1:map_h
        for i = 1:map_w
            if map_layout[i + (j-1)*map_w] == '1'
                #A = draw_rectangle(A, win_w, win_h, 1+(i-1)*wall_w, 1+(j-1)*wall_h, wall_w, wall_h, pack_color(UInt8(floor(rand()*255)), 0x14, 0xff))
                rectangle(ctx, 1+(i-1)*wall_w, 1+(j-1)*wall_h, wall_w, wall_h)
                set_source_rgb(ctx, 0.1, 0.5, 0)
                fill(ctx)
            end
        end
    end


    # Draw player's tile in map
    #A = draw_rectangle(A, win_w, win_h, 1+(floor(player_x))*wall_w, 1+(floor(player_y))*wall_h, wall_w, wall_h, pack_color(0xff, 0x14, 0x14))
    #rectangle(ctx, 1+(floor(player_x))*wall_w, 1+(floor(player_y))*wall_h, wall_w, wall_h)
    
    # Draw player position
    #A = draw_rectangle(A, win_w, win_h, 1+ (player_x)*wall_w ,1 + (player_y)*wall_h , 5, 5, player_color)
    rectangle(ctx, floor(1+ (player_x)*wall_w) ,floor(1 + (player_y)*wall_h) , 5, 5)
    set_source_rgb(ctx, 1, 1, 1)
    fill(ctx)


    # Draw FOV
    for a = 1:512
        angle = player_dir-(player_fov/2) + (a-1)*player_fov/(win_w/2)
        for c = 0:0.05:750
            cx = player_x + c*cos(angle)
            cy = player_y + c*sin(angle)
            if map_layout[1 + UInt(floor(cx)) + UInt(floor(cy))*map_w] != '0';
                #println(c)

                #Draw 3D FOV
                #A = draw_rectangle(A, win_w, win_h, win_w/2 + a, 0.5*(win_h-(win_h*(1/(c+1)))), 1 , UInt(floor(win_h*(1/(c+1)))) , pack_color(0xff, 0x00, 0x00)) 
                rectangle(ctx,   win_w/2 + a, UInt(floor(0.5*(win_h-(win_h*(1/(c+1)))))), 1 , UInt(floor(win_h*(1/(c+1)))) )
                set_source_rgb(ctx, 0.1, 0.5-1/c, 1/c)
                fill(ctx)
                            
                break
            end

            #Draw sight line in map
            pix_x::UInt = floor((cx) * wall_w)
            pix_y::UInt = floor((cy) * wall_h)
            ##A[1 + pix_x + pix_y*win_w] = player_color 
            rectangle(ctx, pix_x, pix_y, 1, 1)
            set_source_rgb(ctx, 0.75, 0.75, 0.75)
            fill(ctx)

            
        end 
    end    
## To Fix --------------------^^^^⁻---------------------------------------
    global update_count += 1
    println("Frame number: $update_count")
end

function on_key_clicked(w, event)
    newpos!(event.keyval)
    #println(player_x , " ", player_y)
    global c
    global win
    update_canvas(c)
    show(c)
    showall(win)
    reveal(w)
end

function newpos!(key)
    global player_dir
    global player_x
    global player_y
    if key == 119 #W
        global player_x +=  0.1*cos(player_dir)
        global player_y +=  0.1*sin(player_dir)
    elseif key == 97 #A
        global player_dir -= 0.10
    elseif key == 115 #S
        global player_x -= 0.10*cos(player_dir)
        global player_y -= 0.10*cos(player_dir)
    elseif key == 100 #D
        global player_dir += 0.10
    end
end

function app()
    win_w = 1024
    win_h = 512
    mapsize = (16,16)
    global c = @GtkCanvas()
    global win = GtkWindow(c, "Raycaster example", win_w, win_h)
    c.draw = update_canvas
    signal_connect(on_key_clicked, win, "key-press-event")
    showall(win)
end


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
        print("inv dim")
        return A
    end
    x = UInt(floor(x))
    y = UInt(floor(y))
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
    width::UInt = 512*2
    height::UInt = 512
        
    # Creating canvas array, initialized to red
    A = Array{UInt32,1}(undef, height * width)
    A = fill!(A, pack_color(0x00, 0x00, 0x00))

    # Setting map dimensions
    map_w = 16
    map_h = 16
    map_layout = get_map()
    
    # Player position
    player_x = 6
    player_y = 3.1
    player_color = pack_color( 0x00, 0xff, 0x00)

    # Player viewing features
    player_dir = deg2rad(45) 
    player_fov = deg2rad(120) 
    
    # Draw map
    wall_w::UInt8 = width/(map_w*2)
    wall_h::UInt8 = height/map_h 
    for j = 1:map_h
        for i = 1:map_w
            if map_layout[i + (j-1)*map_w] == '1'
                A = draw_rectangle(A, width, height, 1+(i-1)*wall_w, 1+(j-1)*wall_h, wall_w, wall_h, pack_color(UInt8(floor(rand()*255)), 0x14, 0xff))
            end
        end
    end


    # Draw player rectangle in map
    A = draw_rectangle(A, width, height, 1+(floor(player_x))*wall_w, 1+(floor(player_y))*wall_h, wall_w, wall_h, pack_color(0xff, 0x14, 0x14))

    # Draw player
    A = draw_rectangle(A, width, height, 1+ (player_x)*wall_w ,1 + (player_y)*wall_h , 5, 5, player_color)

    # Draw FOV
    for a = 1:512
        angle = player_dir-(player_fov/2) + (a-1)*player_fov/(width/2)
        for c = 0:0.05:750
            cx = player_x + c*cos(angle)
            cy = player_y + c*sin(angle)
            if map_layout[1 + UInt(floor(cx)) + UInt(floor(cy))*map_w] != '0';
                println(c)

                #Draw 3D FOV
                A = draw_rectangle(A, width, height, width/2 + a, 0.5*(height-(height*(1/(c+1)))), 1 , UInt(floor(height*(1/(c+1)))) , pack_color(0xff, 0x00, 0x00)) 
                break
            end

            #Draw sight line in map
            pix_x::UInt = floor((cx) * wall_w)
            pix_y::UInt = floor((cy) * wall_h)
            A[1 + pix_x + pix_y*width] = player_color 
            
        end 
    end    
    
    # Saving image to .ppm format
    drop_ppm_image("./out.ppm", A, width,  height)
    println("Done")
end

