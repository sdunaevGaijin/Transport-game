require daslib/decs_boost
require daslib/media
require levels
require tools
require unit


let mouseSpeed = 1.0
let airportPrice = 100000
let portPrice = 300000
let terminalPrice = 20000
let railStationPrice = 50000
let roadPrice = 1000
let railPrice = 1500

let cellTypes:table<int; int> <- {{'G' => GROUND; 'W' => WATER; 'S' => SAND; 'C' => SNOW; 'M' => MOUNTAIN}}
var cameraPos = float2(0.0, 0.0)
var builderButtons: array<EntityId>
     
def create_level
    var width = 0
    var height = length(levels_src)
    for row in levels_src
        width = row |> length
        for cell in row
            level |> push(find(cellTypes, cell) ?? 0)
    levelSize = int2(width, height)
    cameraPos = float2(float(levelSize.x) * 0.5, float(levelSize.y) * 0.5)

def create_game
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[PlayerInfo balance = 10000000]])
    create_level()
    create_objects()
    create_button(float2(10.0, screenHei - elemSz), @@create_builder)
    create_button(float2(10.0, screenHei - 2.1 * elemSz), @@create_unit_builder)
    create_button(float2(10.0, screenHei - 3.2 * elemSz), @@create_shop)
    decs_stage("initialize")

def update_controls(dt:float)
    if get_key_down(VK_ESCAPE)
        var found = find_query <| $ [REQUIRE(Builder_building_type)] ( eid:EntityId )
            delete_entity(eid)
            return true
        if !found
            found = find_query <| $ [REQUIRE(UnitBuilder_u_type)] ( eid:EntityId )
                delete_entity(eid)
                return true
            if !found
                found = find_query <| $ [REQUIRE(Shop_selectedItem)] ( eid:EntityId )
                    delete_entity(eid)
                    return true    
            if !found
                schedule_quit_game()
                return true
    if get_key(VK_RIGHT)
        cameraPos.x = min(cameraPos.x + dt * mouseSpeed, float(levelSize.x))
    if get_key(VK_LEFT)
        cameraPos.x = max(cameraPos.x - dt * mouseSpeed, 0.0)
    if get_key(VK_UP)
        cameraPos.y = max(cameraPos.y - dt * mouseSpeed, 0.0)
    if get_key(VK_DOWN)
        cameraPos.y = min(cameraPos.y + dt * mouseSpeed, float(levelSize.y))
    if get_key_down(VK_SPACE)
        find_query <| $ (var Builder_dir:int2)
            Builder_dir = int2(Builder_dir.y, -Builder_dir.x)
            return true
    if get_mouse_button_down(MB_LEFT)
        let mouse = get_mouse_position()
        var found = find_query <| $ (var button : Button)
            if mouse.x > button.pos.x && mouse.x < button.pos.x + elemSz && mouse.y > button.pos.y && mouse.y < button.pos.y + elemSz
                button.is_clicked = true
                invoke(button.on_click)
                return true;
        if !found
            query <| $ (builder : Builder; var eid:EntityId)
                found = true
                if builder.building_type != B_NONE
                    if builder.building_type < B_ROAD
                        if try_create_terminal(mouse, builder.building_type)
                            for i in range(builderButtons |> length)
                                delete_entity(builderButtons[i])
                            builderButtons |> clear()
                            delete_entity(eid)
                    else
                        try_create_road(mouse, builder.dir, builder.building_type)
        if !found
            query <| $ (var builder : UnitBuilder; var eid:EntityId)
                found = true
                if builder.u_type != -1
                    if !unit_builder_on_click(mouse)
                        let term_type = get_term_type_by_unit_type(builder.u_type)
                        if term_type != B_NONE
                            let terminalId = try_get_terminal_id(mouse, term_type)
                            if terminalId != INVALID_ENTITY_ID
                                found = true
                                if builder.source == INVALID_ENTITY_ID
                                    builder.source = terminalId
                                    get_available_good(builder.availableGoods, terminalId)
                                else
                                    builder.destination = terminalId
                                    if confirm_create_unit()
                                        for i in range(builderButtons |> length)
                                            delete_entity(builderButtons[i])
                                        builderButtons |> clear()
                                        delete_entity(eid)
                    elif builder.source != INVALID_ENTITY_ID && builder.destination != INVALID_ENTITY_ID
                        if confirm_create_unit()
                            for i in range(builderButtons |> length)
                                delete_entity(builderButtons[i])
                            builderButtons |> clear()
                            delete_entity(eid)
        if !found
            found = shop_on_click(mouse)
    return false

def draw_level
    for i in range(levelSize.y)
        for j in range(levelSize.x)
            let cell = level[i * levelSize.x + j]
            if cell == GROUND
                cellGround |> draw_image(float(j), float(i), 0xFFFFFFFF, float2(1.0, 1.0))
            elif cell == WATER
                cellWater |> draw_image(float(j), float(i), 0xFFFFFFFF, float2(1.0, 1.0))
            elif cell == SAND
                cellSand |> draw_image(float(j), float(i), 0xFFFFFFFF, float2(1.0, 1.0))
            elif cell == SNOW
                cellSnow |> draw_image(float(j), float(i), 0xFFFFFFFF, float2(1.0, 1.0))
            elif cell == MOUNTAIN
                cellMountain |> draw_image(float(j), float(i), 0xFFFFFFFF, float2(1.0, 1.0))
   
[decs(stage=draw_ui)]
def draw_balance(var player: PlayerInfo)
    text_out(10, 10, "Balance: {player.balance}$ Units:{length(player.units)}", 0xFFFFFFFF)

def draw_UI
    imgBuild |> draw_image(10.0, screenHei - elemSz, 0xFFFFFFFF, elemSz)
    imgUBuild |> draw_image(10.0, screenHei - 2.1 * elemSz, 0xFFFFFFFF, elemSz)
    imgShop |> draw_image(10.0, screenHei - 3.2 * elemSz, 0xFFFFFFFF, elemSz)

def request_road
    find_query <| $ (var Builder_building_type:int& )
        Builder_building_type = B_ROAD
        return true

def request_rail
    find_query <| $ (var Builder_building_type:int& )
        Builder_building_type = B_RAIL
        return true

def request_car_terminal
    find_query <| $ (var Builder_building_type:int& )
        Builder_building_type = B_CAR_TERM
        return true

def request_rail_terminal
    find_query <| $ (var Builder_building_type:int& )
        Builder_building_type = B_TRAIN_TERM
        return true

def request_port
    find_query <| $ (var Builder_building_type:int& )
        Builder_building_type = B_PORT
        return true

def request_airport
    find_query <| $ (var Builder_building_type:int& )
        Builder_building_type = B_AIRPORT
        return true

def request_plane
    let found = find_query <| $ (var UnitBuilder_u_type:int& )
        UnitBuilder_u_type = UT_PLANE
        return true

def request_car
    find_query <| $ (var UnitBuilder_u_type:int& )
        UnitBuilder_u_type = UT_CAR
        return true

def request_train
    find_query <| $ (var UnitBuilder_u_type:int& )
        UnitBuilder_u_type = UT_TRAIN
        return true

def request_ship
    find_query <| $ (var UnitBuilder_u_type:int& )
        UnitBuilder_u_type = UT_SHIP
        return true

def create_builder
    find_query <| $ [REQUIRE(UnitBuilder_u_type)] ( eid:EntityId )
        delete_entity(eid)
        return true
    find_query <| $ [REQUIRE(Shop_selectedItem)] ( eid:EntityId )
        delete_entity(eid)
        return true
    for i in range(builderButtons |> length)
        delete_entity(builderButtons[i])
    builderButtons |> clear()
    builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - elemSz), @@request_airport))
    builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - 2.1 * elemSz), @@request_port))
    //builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - 3.2 * elemSz), @@request_rail_terminal))
    builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - 3.2 * elemSz), @@request_car_terminal))
    //builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - 5.4 * elemSz), @@request_rail))
    builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - 4.3 * elemSz), @@request_road))
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Builder building_type = B_NONE, dir = int2(1, 0)]])

def create_shop
    find_query <| $ [REQUIRE(UnitBuilder_u_type)] ( eid:EntityId )
        delete_entity(eid)
        return true
    find_query <| $ [REQUIRE(Builder_building_type)] ( eid:EntityId )
        delete_entity(eid)
        return true
    for i in range(builderButtons |> length)
        delete_entity(builderButtons[i])
    builderButtons |> clear()
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Shop selectedItem = -1]])
    create_shop_items()
    builderButtons |> push(create_button(float2(windowWidth, screenHei * 0.5 + windowHeight * 0.5 - elemSz - 10.0), @@apply_shop_purchase))

def create_unit_builder
    find_query <| $ [REQUIRE(Builder_building_type)] ( eid:EntityId )
        delete_entity(eid)
        return true
    find_query <| $ [REQUIRE(Shop_selectedItem)] ( eid:EntityId )
        delete_entity(eid)
        return true
    for i in range(builderButtons |> length)
        delete_entity(builderButtons[i])
    builderButtons |> clear()
    builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - elemSz), @@request_plane))
    builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - 2.1 * elemSz), @@request_ship))
    //builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - 3.2 * elemSz), @@request_train))
    builderButtons |> push(create_button(float2(10.0 + elemSz, screenHei - 3.2 * elemSz), @@request_car))
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[UnitBuilder u_type = -1, selectedUnit = -1, selectedGood = -1]])

def try_create_terminal(position:float2; t_type:int)
    let worldPos = int2(screen_to_world(position))
    var found = find_query <| $ (Factory_pos:int2)
        if worldPos.x == Factory_pos.x && worldPos.y == Factory_pos.y
            return true
    if !found
        found = find_query <| $ (Terminal_pos:int2)
            if worldPos.x == Terminal_pos.x && worldPos.y == Terminal_pos.y
                return true
    if !found
        found = find_query <| $ (Road_pos:int2)
            if worldPos.x == Road_pos.x && worldPos.y == Road_pos.y
                return true
    if found
        return false
    let cell = level[worldPos.y * levelSize.x + worldPos.x]
    if cell == MOUNTAIN || cell == WATER
        return false
    if t_type == B_PORT
        var haveNearWater = false
        if worldPos.x < levelSize.x - 1 && level[worldPos.y * levelSize.x + worldPos.x + 1] == WATER
            haveNearWater = true
        elif worldPos.x > 0 && worldPos.x < levelSize.x - 1 && level[worldPos.y * levelSize.x + worldPos.x - 1] == WATER
            haveNearWater = true
        elif worldPos.y < levelSize.y - 1 && level[(worldPos.y + 1)* levelSize.x + worldPos.x] == WATER
            haveNearWater = true
        elif worldPos.y > 0 && level[(worldPos.y - 1)* levelSize.x + worldPos.x] == WATER
            haveNearWater = true
        if !haveNearWater
            return false
    var price = 0
    if  t_type == B_PORT
        price = -portPrice
    elif t_type == B_AIRPORT
        price = -airportPrice
    elif t_type == B_TRAIN_TERM
        price = -railStationPrice
    elif t_type == B_CAR_TERM
        price = -terminalPrice
    if change_balance(price)
        create_terminal(worldPos, t_type, 2)
        create_cash_diff(screen_to_world(position), price)
    return true

def try_create_road(position:float2; dir:int2; r_type:int)
    let worldPos = int2(screen_to_world(position))
    var found = find_query <| $ (Factory_pos:int2)
        if worldPos.x == Factory_pos.x && worldPos.y == Factory_pos.y
            return true
    if !found
        found = find_query <| $ (Terminal_pos:int2)
            if worldPos.x == Terminal_pos.x && worldPos.y == Terminal_pos.y
                return true
    if found
        return false
    let cell = level[worldPos.y * levelSize.x + worldPos.x]
    if cell == MOUNTAIN && r_type != B_ROAD_TUNNEL
        return false
    if cell == WATER && r_type != B_ROAD_TUNNEL && r_type != B_ROAD_BRIDGE
        return false
    found = find_query <| $ (road: Road)
        if worldPos.x == road.pos.x && worldPos.y == road.pos.y && (road.dir == dir || road.dir == -dir)
            return true
    if found
        return false
    var price = 0
    if  r_type == B_ROAD
        price = roadPrice
    if  r_type == B_RAIL
        price = roadPrice
    if change_balance(price)
        create_road(worldPos, r_type, dir)
        create_cash_diff(screen_to_world(position), price)
    return true
    
