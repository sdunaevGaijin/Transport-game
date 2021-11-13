require daslib/decs_boost
require daslib/media
require tools

let imgFarm <- create_image("images/farm.png")
let imgCity <- create_image("images/city.png")
let imgWoodStorage <- create_image("images/wood_storage.png")
let imgSawmill <- create_image("images/sawmill.png")
let imgFurnFactory <- create_image("images/furniture_factory.png")
let imgDairy <- create_image("images/cheese_dairy.png")
let imgPumpStation <- create_image("images/pumping_station.png")
let imgDerrick <- create_image("images/oil_derrick.png")
let imgRefinery <- create_image("images/refinery.png")

let cellGround <- create_image("images/ground_cell.png")
let cellWater <- create_image("images/water_cell.png")
let cellSand <- create_image("images/sand_cell.png")
let cellSnow <- create_image("images/snow_cell.png")
let cellMountain <- create_image("images/mount_cell.png")

let levels_src: array<string> <- [{auto
    "WWWWWWWWGCCGWWWWGCCCCCCGGGGGGGGGGGG";
    "WWWWWWWWGWGGWWWWGGCCGGCGGGGGGGGGGGG";
    "WWWGWWWWWWGGWWWGGGGGGGGGGGGGGGGGGGG";
    "WWWGWWWWWWWGWWWGGGGGGGGGGGGGGGGGGGG";
    "WWWGGWWWWGWGWWWGGGGGGGGGGGGGGGGGGGG";
    "WGWGGWWWWGWWWWGGGGGGGGGGGGGGGGGGGGG";
    "WGWGGWWGGGGGGGGGGGGGGGGGGGGGGGGGGGG";
    "WWWGGGWGGGGGGGGGGGGGGGGGGGGGGGGGGGG";
    "WWGGGWWGGGGGGGGGGGGGGGGGGGGGGGGGGGG";
    "WWWWWWGGGGGGGGGGGGGGGGGGGGGGGGGGGGG";
    "WWWGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG";
    "WWWWGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG";
    "WWWWWGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG";
    "WWWWWGGGGGMGGGGGGGGGGGGGGGGGGGGGGGG";
    "WWWWWGGGGMMMGGGGGGGGGGGGGGGSSSSSSSS";
    "WWWWWGGGGGWMGGGGGGGGWWGWGGGSWWWSSSS";
    "WGGGGGGWWGGWWGGGGGGGWWGWGGGGWWSSSSS";
    "WGGGGGGWWWGGWWGGGGGWWWWWWGGMWWSSSSS";
    "WGGGGGWWGWWGGWWGGGGWWWWWWWGGGWWSSSS";
    "WGGGGGWWGWWWGGWWGGGGGGGGGGGGGWWSSSS";
    "WGGGGSWWWWWGGWWWGWGGGGGGGGGGGWWSSSM";
    "WWWWWWWWWWGWWWWWGWGGGGGGGGGGGWWSSSM";
    "WWGWWWWWWWWWWWWWWWWWWWWGSSSSSSSSSSS";
    "WWGGGSSSSGWWWWWWWWWWWWWGSSSSSSSSSSS";
    "WGGGSSSSSGGWWWWWWWWWWWWSSSSSSSSSSSS";
    "WSSSSSSSSSSSSSSSSSSSSWGSSSSSSSSSSSS";
    "WSSSSSSSSSSSSSSSSSSSSWSSSSSSSWSSSSS"
}]

var levelSize = int2(0, 0)
var level : array<int>

[decs_template(prefix)]
struct City
    pos:int2
    name:string
    needGood:array<int2>
    haveGood:array<int2>

[decs_template(prefix)]
struct Factory
    ftype:int
    pos:int2
    needGood:int
    productGood:int


[decs_template(prefix)]
struct Terminal
    pos:int2
    t_type:int
    capacity:int
    busy:int

[decs_template]
struct Road
    pos:int2
    dir:int2
    r_type:int

def make_factory(pos:int2; f_type:int; need_good, product_good: int2)
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Factory ftype = f_type, pos = pos, needGood = need_good.x, productGood = product_good.x]])

def make_city(pos:int2; name:string)
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[City name = name, pos = pos]])

def create_objects
    //make_city(int2(4, 7), "London")
    make_factory(int2(20, 2), F_WOOD_STORAGE, int2(-1, 0), int2(G_WOOD, 20))
    make_factory(int2(25, 12), F_WOOD_STORAGE, int2(-1, 0), int2(G_WOOD, 20))
    make_factory(int2(34, 8), F_WOOD_STORAGE, int2(-1, 0), int2(G_WOOD, 20))
    make_factory(int2(6, 16), F_WOOD_STORAGE, int2(-1, 0), int2(G_WOOD, 20))
    make_factory(int2(7, 7), F_SAWMILL, int2(G_WOOD, 20), int2(G_BOARDS, 15))
    make_factory(int2(34, 0), F_SAWMILL, int2(G_WOOD, 20), int2(G_BOARDS, 15))
    make_factory(int2(15, 17), F_SAWMILL, int2(G_WOOD, 20), int2(G_BOARDS, 15))
    make_factory(int2(10, 10), F_FURNITURE, int2(G_BOARDS, 15), int2(G_FURNITURE, 15))
    make_factory(int2(4, 20), F_FURNITURE, int2(G_BOARDS, 15), int2(G_FURNITURE, 15))
    make_factory(int2(29, 13), F_FURNITURE, int2(G_BOARDS, 15), int2(G_FURNITURE, 15))
    make_factory(int2(15, 4), F_FARM, int2(-1, 0), int2(G_MILK, 35))
    make_factory(int2(17, 10), F_FARM, int2(-1, 0), int2(G_MILK, 35))
    make_factory(int2(13, 14), F_FARM, int2(-1, 0), int2(G_MILK, 35))
    make_factory(int2(22, 25), F_FARM, int2(-1, 0), int2(G_MILK, 35))
    make_factory(int2(5, 10), F_CHEESE_DAIRY, int2(G_MILK, 22), int2(G_CHEESE, 17))
    make_factory(int2(12, 20), F_CHEESE_DAIRY, int2(G_MILK, 22), int2(G_CHEESE, 17))
    make_factory(int2(2, 18), F_CHEESE_DAIRY, int2(G_MILK, 22), int2(G_CHEESE, 17))
    make_factory(int2(25, 7), F_CHEESE_DAIRY, int2(G_MILK, 22), int2(G_CHEESE, 17))
    make_factory(int2(33, 15), F_CHEESE_DAIRY, int2(G_MILK, 22), int2(G_CHEESE, 17))
    make_factory(int2(32, 20), F_OIL_DERRICK, int2(-1, 0), int2(G_OIL, 18))
    make_factory(int2(29, 25), F_OIL_DERRICK, int2(-1, 0), int2(G_OIL, 18))
    make_factory(int2(7, 23), F_OIL_DERRICK, int2(-1, 0), int2(G_OIL, 18))
    make_factory(int2(8, 1), F_OIL_DERRICK, int2(-1, 0), int2(G_OIL, 18))
    make_factory(int2(30, 3), F_OIL_DERRICK, int2(-1, 0), int2(G_OIL, 18))
    make_factory(int2(24, 15), F_OIL_DERRICK, int2(-1, 0), int2(G_OIL, 18))
    make_factory(int2(20, 20), F_REFINERY, int2(G_OIL, 18), int2(G_FUEL, 30))
    make_factory(int2(2, 8), F_REFINERY, int2(G_OIL, 18), int2(G_FUEL, 30))
    make_factory(int2(20, 5), F_REFINERY, int2(G_OIL, 18), int2(G_FUEL, 30))
    make_factory(int2(15, 2), F_REFINERY, int2(G_OIL, 18), int2(G_FUEL, 30))
    make_factory(int2(1, 6), F_PUMPING_STATION, int2(-1, 0), int2(G_WATER, 70))
    make_factory(int2(25, 16), F_PUMPING_STATION, int2(-1, 0), int2(G_WATER, 70))

def create_terminal(pos:int2; t_type, capacity:int)
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Terminal t_type = t_type, pos = pos, capacity = capacity, busy = 0]])

def create_road(pos:int2; r_type:int; dir:int2)
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Road r_type = r_type, pos = pos, dir = dir]])

[decs(stage=draw)]
def draw_factory(var factory: Factory)
    let imgSize = float2(1.0, 1.0)
    if factory.ftype == F_WOOD_STORAGE
        imgWoodStorage |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)
    elif factory.ftype == F_SAWMILL
        imgSawmill |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)
    elif factory.ftype == F_FURNITURE
        imgFurnFactory |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)
    elif factory.ftype == F_FARM
        imgFarm |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)
    elif factory.ftype == F_CHEESE_DAIRY
        imgDairy |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)
    elif factory.ftype == F_PUMPING_STATION
        imgPumpStation |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)
    elif factory.ftype == F_OIL_DERRICK
        imgDerrick |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)
    elif factory.ftype == F_REFINERY
        imgRefinery |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)
    draw_good_indicator(factory.productGood, float2(factory.pos.x, factory.pos.y), 0.4, true)
    draw_good_indicator(factory.needGood, float2(factory.pos.x, factory.pos.y) + float2(0.0, 0.5), 0.4, true)

[decs(stage=draw)]
def draw_city(city: City)
    imgCity |> draw_image(float(city.pos.x), float(city.pos.y), 0xFFFFFFFF, float2(1.0, 1.0))

[decs(stage=draw)]
def draw_roads(var road: Road)
    let imgSize = float2(1.0, 1.0)
    let angle = acos(clamp(dot(float2(road.dir.x, road.dir.y), float2(-1.0, 0.0)), -1.0, 1.0))
    if road.r_type == B_ROAD
        imgRoadLine |> draw_image_transformed(float(road.pos.x) + 0.5, float(road.pos.y) + 0.5, float4(0.0, 0.0, 128.0, 128.0), 0xFFFFFFFF, imgSize, angle)
    elif road.r_type == B_RAIL
        imgRailLine |> draw_image_transformed(float(road.pos.x) + 0.5, float(road.pos.y) + 0.5, float4(0.0, 0.0, 128.0, 128.0), 0xFFFFFFFF, imgSize, angle)

[decs(stage=draw)]
def draw_terminal(var term: Terminal; eid:EntityId)
    let imgSize = float2(1.0, 1.0)
    var color = 0xFFFFFFFF
    let found = find_query <| $ (builder: UnitBuilder)
        if eid == builder.source
            color = 0x7700FF00
            return true
        elif eid == builder.destination
            color = 0x77FFFF00
            return true
    if term.t_type == B_AIRPORT
        imgAirportObj |> draw_image(float(term.pos.x), float(term.pos.y), 0xFFFFFFFF, imgSize)
    if term.t_type == B_PORT
        imgPortObj |> draw_image(float(term.pos.x), float(term.pos.y), 0xFFFFFFFF, imgSize)
    if term.t_type == B_TRAIN_TERM
        imgRailStationObj |> draw_image(float(term.pos.x), float(term.pos.y), 0xFFFFFFFF, imgSize)
    if term.t_type == B_CAR_TERM
        imgTerminalObj |> draw_image(float(term.pos.x), float(term.pos.y), 0xFFFFFFFF, imgSize)
    if found
        fill_circle(float(term.pos.x) + 0.5, float(term.pos.y) + 0.5, 1.0, color)

def try_get_terminal_id(position:float2; term_type:int)
    let worldPos = int2(screen_to_world(position))
    var eId = INVALID_ENTITY_ID
    find_query <| $ (pos:int2; t_type:int; eid:EntityId)
        if term_type == t_type && worldPos.x == pos.x && worldPos.y == pos.y
            eId = eid
            return true
    return eId

def get_available_good(var goods: array<int>; terminal:EntityId)
    var termPos = int2(-1, -1)
    goods |> clear()
    query(terminal) <| $ (pos:int2)
        termPos = pos
    query <| $ (pos:int2; productGood:int)
        if abs(pos.x - termPos.x) + abs(pos.y - termPos.y) <= 1
            if goods |> find_index(productGood) < 0
                goods |> push(productGood)


