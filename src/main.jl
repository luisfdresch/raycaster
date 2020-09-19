# Importing packages
using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer


global player_x = 5
global player_y = 5  
global player_dir = deg2rad(45)
global player_fov = deg2rad(100) 
global canvas
global update_count = 0

function update_canvas(renderer)
    global player_x
    global player_y
    global player_dir
    global player_fov

    map_layout = get_map()
    map_w = map_h = 16  

    SDL2.SetRenderDrawColor(renderer, 0, 0, 0, 255)
    SDL2.RenderClear(renderer)
    
    win_w = 1024
    win_h = 512
     
    # Draw map
    wall_w::UInt8 = win_w/(map_w*2)
    wall_h::UInt8 = win_h/map_h 
    for j = 1:map_h
        for i = 1:map_w
            if map_layout[i + (j-1)*map_w] == '1'
                rect = SDL2.Rect(1+(i-1)*wall_w, 1+(j-1)*wall_h, wall_w, wall_h)
                SDL2.SetRenderDrawColor(renderer, 25, 125, 0, 255)
                SDL2.RenderFillRect(renderer, Ref(rect))
            end
        end
    end
    
    # Draw player position
    rect = SDL2.Rect(floor(1+ (player_x)*wall_w) ,floor(1 + (player_y)*wall_h) , 5, 5)
    SDL2.SetRenderDrawColor(renderer, 255, 25, 25, 255)
    SDL2.RenderFillRect(renderer, Ref(rect))

    # Draw FOV
    for a = 1:512
        angle = player_dir-(player_fov/2) + (a-1)*player_fov/(win_w/2)
        for c = 0:0.01:750
            cx = player_x + c*cos(angle)
            cy = player_y + c*sin(angle)
            if map_layout[1 + UInt(floor(cx)) + UInt(floor(cy))*map_w] != '0'; #If casted ray meets wall
                #Draw 3D FOV
                c_c = c*cos(player_dir - angle)
                rect =  SDL2.Rect( win_w/2 + a, UInt(floor(0.5*(win_h-(win_h*(1/(c_c+1)))))), 1 , UInt(floor(win_h*(1/(c_c+1)))) )
                SDL2.SetRenderDrawColor(renderer, Int64(floor(255/(1+c_c^2))) , Int64(floor(180/(1+c_c^2))) ,Int64(floor(120/(1+c_c^2))) , 255)
                SDL2.RenderFillRect(renderer, Ref(rect))
                break

                # Draw sight line in map
                if a % 16 == 0
                    pix_x::UInt = floor((cx) * wall_w)
                    pix_y::UInt = floor((cy) * wall_h)
                    SDL2.SetRenderDrawColor(renderer, 180, 180, 180, 255)
                    SDL2.RenderDrawLine(renderer, floor(player_x*wall_w), floor(player_y*wall_h), pix_x, pix_y)
            end
#=
            #Draw sight line in map
            if a == 1 || a === 512
                pix_x::UInt = floor((cx) * wall_w)
                pix_y::UInt = floor((cy) * wall_h)
                rectangle(ctx, pix_x, pix_y, 1, 1)
                set_source_rgb(ctx, 0.75, 0.75, 0.75)
                fill(ctx)
=#
            end
            
        end 
    end    
    SDL2.RenderPresent(renderer)
    global update_count += 1
   # println("Frame number: $update_count")
end

function newpos!(key)
    global player_dir
    global player_x
    global player_y
    if key == :W #W
        global player_x +=  0.1*cos(player_dir)
        global player_y +=  0.1*sin(player_dir)
    elseif key == :A #A
        global player_dir -= 0.10
    elseif key == :S #S
        global player_x -= 0.10*cos(player_dir)
        global player_y -= 0.10*sin(player_dir)
    elseif key == :D #D
        global player_dir += 0.10
    end
end

function main_loop(renderer, keys_dict)
    while true
        SDL2.PumpEvents()
        e = SDL2.event()
        if typeof(e) == SDL2.KeyboardEvent && e._type == SDL2.KEYDOWN
            if e.keysym.sym in keys_dict.keys
                newpos!(keys_dict[e.keysym.sym])
                update_canvas(renderer)
            end
        end
        if typeof(e) == SDL2.WindowEvent && e.event == 14
            SDL2.Quit()
        end
    end
end

function app()
    win_w = 1024
    win_h = 512
    mapsize = (16,16) #Unused
    
    SDL2.init()
    win = SDL2.CreateWindow("Raycaster Example", Int32(100), Int32(100), Int32(win_w), Int32(win_h), UInt32(SDL2.WINDOW_SHOWN))
    SDL2.SetWindowResizable(win, false)

    renderer = SDL2.CreateRenderer(win, Int32(-1), UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC))

    keys_dict = Dict([(119,:W), (97,:A), (100,:D), (115, :S)])
    
    main_loop(renderer, keys_dict)

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

app()

