require daslib/decs_boost
require daslib/media
require tools

let imgFarm <- create_image("images/farm.png")

let levels_src: array<string> <- [{auto
    "GGGGGGGG";
    "GGWWGGGC";
    "GSWWWSGC";
    "GSWWMMGG";
    "GGWMCCMG"
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

def create_objects
    make_factory(int2(1, 2), F_WOOD_STORAGE, int2(-1, 0), int2(G_WOOD, 20))
    make_factory(int2(5, 0), F_SAWMILL, int2(G_WOOD, 20), int2(G_BOARDS, 15))

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
    imgFarm |> draw_image(float(factory.pos.x), float(factory.pos.y), 0xFFFFFFFF, imgSize)

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
        print("{pos}, G:{productGood}")
        if abs(pos.x - termPos.x) + abs(pos.y - termPos.y) <= 1
            if goods |> find_index(productGood) < 0
                goods |> push(productGood)
    print("goods: {length(goods)}")


