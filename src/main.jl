# Importing packages
using Gtk


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

    map_layout = get_map()
    win_w= width(widget)
    win_h = height(widget)
    map_w = map_h = 16  

    ctx = Gtk.getgc(widget)

    rectangle(ctx, 0, 0, width(widget), height(widget)) #Paint background
    set_source_rgb(ctx, 0,0,0)
    fill(ctx)
    
    # Draw map
    wall_w::UInt8 = win_w/(map_w*2)
    wall_h::UInt8 = win_h/map_h 
    for j = 1:map_h
        for i = 1:map_w
            if map_layout[i + (j-1)*map_w] == '1'
                rectangle(ctx, 1+(i-1)*wall_w, 1+(j-1)*wall_h, wall_w, wall_h)
                set_source_rgb(ctx, 0.1, 0.5, 0)
                fill(ctx)
            end
        end
    end
    
    # Draw player position
    rectangle(ctx, floor(1+ (player_x)*wall_w) ,floor(1 + (player_y)*wall_h) , 5, 5)
    set_source_rgb(ctx, 1, 0.1, 0.1)
    fill(ctx)

    # Draw FOV
    for a = 1:512
        angle = player_dir-(player_fov/2) + (a-1)*player_fov/(win_w/2)
        for c = 0:0.05:750
            cx = player_x + c*cos(angle)
            cy = player_y + c*sin(angle)
            if map_layout[1 + UInt(floor(cx)) + UInt(floor(cy))*map_w] != '0'; #If casted ray meets wall
                #Draw 3D FOV
                c_c = c*cos(player_dir - angle)
                rectangle(ctx,   win_w/2 + a, UInt(floor(0.5*(win_h-(win_h*(1/(c_c+1)))))), 1 , UInt(floor(win_h*(1/(c_c+1)))) )
                set_source_rgb(ctx, 5.5/c_c^3, 3.5/c_c^3, 2.5/c_c^3)
                fill(ctx)
                break
            end

            #Draw sight line in map
            if a == 1 || a === 512
                pix_x::UInt = floor((cx) * wall_w)
                pix_y::UInt = floor((cy) * wall_h)
                rectangle(ctx, pix_x, pix_y, 1, 1)
                set_source_rgb(ctx, 0.75, 0.75, 0.75)
                fill(ctx)
            end
            
        end 
    end    

    global update_count += 1
   # println("Frame number: $update_count")
end

function on_key_clicked(w, event)
    global c
    newpos!(event.keyval) #Get new position
    update_canvas(c) #Update canvas
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
        global player_y -= 0.10*sin(player_dir)
    elseif key == 100 #D
        global player_dir += 0.10
    end
end

function app()
    win_w = 1024
    win_h = 512
    mapsize = (16,16) #Unused
    global c = @GtkCanvas()
    global win = GtkWindow(c, "Raycaster example", win_w, win_h)
    c.draw = update_canvas
    signal_connect(on_key_clicked, win, "key-press-event")
    showall(win)
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

