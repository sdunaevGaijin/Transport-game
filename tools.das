require daslib/decs_boost
require daslib/media

let elemSz = 50.0
let screenHei = float(get_desktop_height() - 200)
let CELL_SIZE = 75.0

let windowHeight = 560.0
let windowWidth = 1024.0
let imageSz = float2(200.0, 100.0)

let
    B_NONE = 0
    B_CAR_TERM = 1
    B_TRAIN_TERM = 2
    B_PORT = 3
    B_AIRPORT = 4
    B_ROAD = 5
    B_ROAD_BRIDGE = 6
    B_ROAD_TUNNEL = 7
    B_RAIL = 8
    B_RAIL_BRIDGE = 9
    B_RAIL_TUNNEL = 10


let
    GROUND = 0
    WATER = 1
    SAND = 2
    SNOW = 3
    MOUNTAIN = 4

let 
    G_PASSANGER = 0
    G_MAIL = 1
    G_REFUSE = 2
    G_WOOD = 3
    G_BOARDS = 4
    G_FURNITURE = 5
    G_MILK = 6
    G_CHEESE = 7
    G_WATER = 8
    G_OIL = 9
    G_FUEL = 10

let good_reward: array<int> <- [{auto
    500;
    350;
    600;
    1000;
    2000;
    4000;
    900;
    2100;
    290;
    1200;
    1700
}]

let
    F_WOOD_STORAGE = 0
    F_SAWMILL = 1
    F_FURNITURE = 2
    F_FARM = 3
    F_CHEESE_DAIRY = 4
    F_PUMPING_STATION = 5
    F_OIL_DERRICK = 6
    F_REFINERY = 7

let
    UT_CAR = 0
    UT_TRAIN = 1
    UT_SHIP = 2
    UT_PLANE = 3

let
    PM_A380 = 0
    PM_BOEING = 1
let
    SM_TITANIC = 3
    SM_CARGO = 4

let
    TM_BENZ = 0

let imgTerm <- create_image("images/car_terminal.png")
let imgRailTerm <- create_image("images/rail_station.png")
let imgPort <- create_image("images/port.png")
let imgAirport <- create_image("images/airport.png")

let imgCar <- create_image("images/car_build.png")
let imgTrain <- create_image("images/train_build.png")
let imgShip <- create_image("images/ship_build.png")
let imgPlane <- create_image("images/plane_build.png")
let imgRoad <- create_image("images/road_build.png")
let imgRail <- create_image("images/rail_build.png")

let imgBuild <- create_image("images/builder.png")
let imgUBuild <- create_image("images/unit_builder.png")
let imgShop <- create_image("images/shop.png")
let imgAirportObj <- create_image("images/airport_obj.png")
let imgPortObj <- create_image("images/port_obj.png")
let imgRailStationObj <- create_image("images/rail_station_obj.png")
let imgTerminalObj <- create_image("images/car_terminal_obj.png")
let imgRoadLine <- create_image("images/road_line.png")
let imgRoadCross <- create_image("images/road_cross.png")
let imgRoadTCross <- create_image("images/road_t_cross.png")
let imgRailLine <- create_image("images/rail_line.png")

let shopA380 <- create_image("images/a380_shop.png")
let shopBoeing <- create_image("images/boeing_shop.png")
let shopTitanic <- create_image("images/titanic_shop.png")
let shopCargo <- create_image("images/cargo_shop.png")
let shopTruck <- create_image("images/truck_shop.png")

let imgApply <- create_image("images/apply.png")

let wood <- create_image("images/wood.png")
let boards <- create_image("images/boards.png")
let furniture <- create_image("images/furniture.png")
let milk <- create_image("images/milk.png")
let cheese <- create_image("images/cheese.png")
let water <- create_image("images/water.png")
let oil <- create_image("images/oil.png")
let fuel <- create_image("images/fuel.png")
let passanger <- create_image("images/passanger.png")
let mail <- create_image("images/mail.png")
let refuse <- create_image("images/refuse.png")

[decs_template]
struct Builder
    building_type:int
    dir:int2

[decs_template]
struct UnitBuilder
    u_type:int
    model:int
    destination:EntityId
    source:EntityId
    selectedUnit:int
    availableGoods:array<int>
    selectedGood:int

[decs_template]
struct Button
    pos:float2
    is_clicked:bool
    on_click:function

[decs_template]
struct CashDiff
    pos:float2
    screenPos:int2
    value:int
    timer:float

[decs_template]
struct Shop
    selectedItem:int

struct ShopUnit
    price:int
    maxSpeed:float
    volume:int
    accel:float
    model:int
    u_type:int
    name:string
    unloadingTime:float
    used:bool
    serviceCost:int

[decs_template]
struct PlayerInfo
    balance: int
    units:array<ShopUnit>

[decs_template]
struct Help
    help_tag:bool

var shopItems: array<ShopUnit>

def create_button(pos: float2; on_click:function)
    var eId = create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Button pos = pos, is_clicked = false, on_click = on_click]])
    return eId

def get_term_type_by_unit_type(u_type: int)
    if u_type == UT_CAR
        return B_CAR_TERM
    if u_type == UT_TRAIN
        return B_TRAIN_TERM
    if u_type == UT_SHIP
        return B_PORT
    if u_type == UT_PLANE
        return B_AIRPORT
    return B_NONE

[decs(stage=draw_ui)]
def draw_ui_builder(var builder: Builder)
    imgAirport |> draw_image(10.0 + elemSz, screenHei - elemSz, builder.building_type == B_AIRPORT ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    imgPort |> draw_image(10.0 + elemSz, screenHei - 2.1 * elemSz, builder.building_type == B_PORT ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    //imgRailTerm |> draw_image(10.0 + elemSz, screenHei - 3.2 * elemSz, builder.building_type == B_TRAIN_TERM ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    imgTerm |> draw_image(10.0 + elemSz, screenHei - 3.2 * elemSz, builder.building_type == B_CAR_TERM ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    //imgRail |> draw_image(10.0 + elemSz, screenHei - 5.4 * elemSz, builder.building_type == B_RAIL ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    imgRoad |> draw_image(10.0 + elemSz, screenHei - 4.3 * elemSz, builder.building_type == B_ROAD ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    if builder.building_type != B_NONE
        let mouse = get_mouse_position()
        if builder.building_type < B_ROAD
            fill_circle(mouse.x, mouse.y, CELL_SIZE, 0x7700FF00)
        if builder.building_type == B_AIRPORT
            imgAirportObj |> draw_image(mouse.x - CELL_SIZE * 0.5, mouse.y - CELL_SIZE * 0.5, 0xFFFFFFFF, CELL_SIZE)
        elif builder.building_type == B_PORT
            imgPortObj |> draw_image(mouse.x - CELL_SIZE * 0.5, mouse.y - CELL_SIZE * 0.5, 0xFFFFFFFF, CELL_SIZE)
        elif builder.building_type == B_TRAIN_TERM
            imgRailStationObj |> draw_image(mouse.x - CELL_SIZE * 0.5, mouse.y - CELL_SIZE * 0.5, 0xFFFFFFFF, CELL_SIZE)
        elif builder.building_type == B_CAR_TERM
            imgTerminalObj |> draw_image(mouse.x - CELL_SIZE * 0.5, mouse.y - CELL_SIZE * 0.5, 0xFFFFFFFF, CELL_SIZE)
        elif builder.building_type == B_ROAD
            let imgSize = float2(1.0, 1.0) * CELL_SIZE
            let angle = acos(clamp(dot(float2(builder.dir.x, builder.dir.y), float2(-1.0, 0.0)), -1.0, 1.0))
            imgRoadLine |> draw_image_transformed(mouse.x, mouse.y, float4(0.0, 0.0, 128.0, 128.0), 0xAAFFFFFF, imgSize, angle)
        elif builder.building_type == B_RAIL
            let imgSize = float2(1.0, 1.0) * CELL_SIZE
            let angle = acos(clamp(dot(float2(builder.dir.x, builder.dir.y), float2(-1.0, 0.0)), -1.0, 1.0))
            imgRailLine |> draw_image_transformed(mouse.x, mouse.y, float4(0.0, 0.0, 128.0, 128.0), 0xAAFFFFFF, imgSize, angle)

def draw_available_good(goods:array<int>)
    for good, i in goods, range(length(goods))
        fill_rect(float(get_desktop_width()) - elemSz - 29.0, 50.0 + float(i) * (elemSz + 5.0), elemSz + 2.0, elemSz + 2.0, 0xFFFFFFFF)
        if good == G_WOOD
            wood |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_BOARDS
            boards |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_FURNITURE
            furniture |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_MILK
            milk |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_CHEESE
            cheese |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_OIL
            oil |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_FUEL
            fuel |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_WATER
            water |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_PASSANGER
            passanger |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_MAIL
            mail |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)
        elif good == G_REFUSE
            refuse |> draw_image(float(get_desktop_width()) - elemSz - 30.0, 50.0 + float(i) * (elemSz + 5.0),0xFFFFFFFF, elemSz)


[decs(stage=draw_ui)]
def draw_ui_unit_builder(var builder: UnitBuilder)
    imgPlane |> draw_image(10.0 + elemSz, screenHei - elemSz, builder.u_type == UT_PLANE ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    imgShip |> draw_image(10.0 + elemSz, screenHei - 2.1 * elemSz, builder.u_type == UT_SHIP ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    //imgTrain |> draw_image(10.0 + elemSz, screenHei - 3.2 * elemSz, builder.u_type == UT_TRAIN ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)
    imgCar |> draw_image(10.0 + elemSz, screenHei - 3.2 * elemSz, builder.u_type == UT_CAR ? 0xFFFFFF00 : 0xFFFFFFFF, elemSz)

    if builder.u_type >= 0
        find_query <| $ (var player : PlayerInfo)
            var i = 0
            for item in player.units
                if !item.used && item.u_type == builder.u_type
                    let color = builder.selectedUnit == i ? 0xFFCCFFCC : 0xFFFFFFFF
                    fill_rect(10.0 + elemSz, 50.0 + float(i) * imageSz.y, imageSz.x, imageSz.y, 0xFFFFFFFF)
                    if item.u_type == UT_CAR
                        shopTruck |> draw_image(10.0 + elemSz, 50.0 + float(i) * imageSz.y,0xFFFFFFFF, imageSz)
                    if item.u_type == UT_PLANE
                        if item.model == PM_A380
                            shopA380 |> draw_image(10.0 + elemSz, 50.0 + float(i) * imageSz.y,0xFFFFFFFF, imageSz)
                        if item.model == PM_BOEING
                            shopBoeing |> draw_image(10.0 + elemSz, 50.0 + float(i) * imageSz.y,0xFFFFFFFF, imageSz)
                    if item.u_type == UT_SHIP
                        if item.model == SM_CARGO
                            shopCargo |> draw_image(10.0 + elemSz, 50.0 + float(i) * imageSz.y,0xFFFFFFFF, imageSz)
                        if item.model == SM_TITANIC
                            shopTitanic |> draw_image(10.0 + elemSz, 50.0 + float(i) * imageSz.y,0xFFFFFFFF, imageSz)
                    ++i
            if builder.selectedUnit >= i
                builder.selectedUnit = -1
            return true
    draw_available_good(builder.availableGoods)

[decs(stage=draw_ui)]
def draw_ui_shop(var shop: Shop)
    fill_rect(10.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5, windowWidth, windowHeight, 0xFFFFFFFF)
    line(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 5.0, 15.0 + elemSz + imageSz.x, screenHei * 0.5 - windowHeight * 0.5 + 5.0, 0xFF000000)
    shopTruck |> draw_image(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 10.0, shop.selectedItem == 0 ? 0xFFCCFFCC :0xFFFFFFFF, imageSz)
    line(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 15.0 + imageSz.y, 15.0 + elemSz + imageSz.x, screenHei * 0.5 - windowHeight * 0.5 + 15.0 + imageSz.y, 0xFF000000)
    shopTitanic |> draw_image(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 20.0 + imageSz.y, shop.selectedItem == 1 ? 0xFFCCFFCC :0xFFFFFFFF, imageSz)
    line(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 25.0 + 2.0 * imageSz.y, 15.0 + elemSz + imageSz.x, screenHei * 0.5 - windowHeight * 0.5 + 25.0 + 2.0 * imageSz.y, 0xFF000000)
    shopCargo |> draw_image(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 30.0 + 2.0 * imageSz.y, shop.selectedItem == 2 ? 0xFFCCFFCC :0xFFFFFFFF, imageSz)
    line(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 35.0 + 3.0 * imageSz.y, 15.0 + elemSz + imageSz.x, screenHei * 0.5 - windowHeight * 0.5 + 35.0 + 3.0 * imageSz.y, 0xFF000000)
    shopA380 |> draw_image(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 40.0 + 3.0 * imageSz.y, shop.selectedItem == 3 ? 0xFFCCFFCC :0xFFFFFFFF, imageSz)
    line(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 45.0 + 4.0 * imageSz.y, 15.0 + elemSz + imageSz.x, screenHei * 0.5 - windowHeight * 0.5 + 45.0 + 4.0 * imageSz.y, 0xFF000000)
    shopBoeing |> draw_image(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 50.0 + 4.0 * imageSz.y, shop.selectedItem == 4 ? 0xFFCCFFCC :0xFFFFFFFF, imageSz)
    line(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 55.0 + 5.0 * imageSz.y, 15.0 + elemSz + imageSz.x, screenHei * 0.5 - windowHeight * 0.5 + 55.0 + 5.0 * imageSz.y, 0xFF000000)
    line(15.0 + elemSz + imageSz.x, screenHei * 0.5 - windowHeight * 0.5 + 5.0, 15.0 + elemSz + imageSz.x, screenHei * 0.5 + windowHeight * 0.5 - 5.0, 0xFF000000)
    line(15.0 + elemSz, screenHei * 0.5 - windowHeight * 0.5 + 5.0, 15.0 + elemSz, screenHei * 0.5 + windowHeight * 0.5 - 5.0, 0xFF000000)
    imgApply |> draw_image(windowWidth, screenHei * 0.5 + windowHeight * 0.5 - elemSz - 10.0, shop.selectedItem < 0 ? 0xFF333333 :0xFFFFFFFF, elemSz)

    if (shop.selectedItem >= 0 && shop.selectedItem < length(shopItems))
        let item = shopItems[shop.selectedItem]
        text_out(30.0 + elemSz + imageSz.x, screenHei * 0.5 - windowHeight * 0.5 + 10.0,
         "Model: {item.name}\nСapacity: {item.volume}\nMax speed: {int(item.maxSpeed * 100.0)} km/h\nAcceleration: {item.accel}\nUnloading time: {int(item.unloadingTime)} sec\nPrice: {item.price}$\nService cost:{item.serviceCost}$",
         0xFF000000)

def create_cash_diff(pos: float2; diff: int)
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[CashDiff pos = pos, value = diff, timer = 3.0]])

[decs(stage=update_ui)]
def update_cash_diff(var cash: CashDiff; eid:EntityId)
    let dt = get_delta_time()
    cash.timer -= dt
    cash.pos.y -= 0.5 * dt
    let pos = world_to_screen(cash.pos)
    cash.screenPos = int2(pos.x, pos.y)
    if (cash.timer <= 0.0)
        delete_entity(eid)

[decs(stage=draw_ui)]
def draw_cash_diff(var cash: CashDiff)
    let color = cash.value < 0 ? 0xFFFF0000 : 0xFF00FF00
    text_out(cash.screenPos.x, cash.screenPos.y, "{cash.value}$", color)

def change_balance(change:int)
    var cashEnough = false
    find_query <| $ (var player: PlayerInfo)
        if change >= 0 
            player.balance += change
            cashEnough = true
            return true
        elif player.balance > -change
            player.balance += change
            cashEnough = true
            return true
    return cashEnough

def apply_shop_purchase
    if length(shopItems) > 0
        var idx = -1
        find_query <| $ (var shop: Shop)
            idx = shop.selectedItem
            return true
        if idx >= 0 && idx < length(shopItems)
            find_query <| $ (var player: PlayerInfo)
                let item = shopItems[idx]
                if item.price <= player.balance
                    player.units |> push(item)
                    player.balance -= item.price

def create_shop_items
    if shopItems |> length() > 0
        return
    shopItems |> clear()
    shopItems |> emplace(
        [[ShopUnit name = "daBenz V100",
            price = 100000,
            volume = 3,
            accel = 0.5,
            model = TM_BENZ,
            u_type = UT_CAR,
            unloadingTime = 2.0,
            maxSpeed = 1.0,
            used = false,
            serviceCost = 450
        ]])
    shopItems |> emplace(
        [[ShopUnit name = "Titanic",
            price = 800000,
            volume = 20,
            accel = 0.1,
            model = SM_TITANIC,
            u_type = UT_SHIP,
            unloadingTime = 15.0,
            maxSpeed = 0.5,
            used = false,
            serviceCost = 2300
        ]])
    shopItems |> emplace(
        [[ShopUnit name = "Cargo D",
            price = 700000,
            volume = 64,
            accel = 0.1,
            model = SM_CARGO,
            u_type = UT_SHIP,
            unloadingTime = 15.0,
            maxSpeed = 0.3,
            used = false,
            serviceCost = 5000
        ]])
    shopItems |> emplace(
        [[ShopUnit name = "AirShip Z380",
            price = 500000,
            volume = 10,
            accel = 1.0,
            model = PM_A380,
            u_type = UT_PLANE,
            unloadingTime = 5.0,
            maxSpeed = 10.0,
            used = false,
            serviceCost = 1020
        ]])
    shopItems |> emplace(
        [[ShopUnit name = "Borsing 878",
            price = 400000,
            volume = 8,
            accel = 1.1,
            model = PM_BOEING,
            u_type = UT_PLANE,
            unloadingTime = 5.0,
            maxSpeed = 9.0,
            used = false,
            serviceCost = 900
        ]])

def shop_on_click(mouse:float2)
    let found = find_query() <| $ (var shop: Shop)
        if mouse.x >= 15.0 + elemSz && mouse.x <= 15.0 + elemSz + imageSz.x
            if mouse.y < screenHei * 0.5 + windowHeight * 0.5 && mouse.y > screenHei * 0.5 - windowHeight * 0.5
                let idx = int((mouse.y - (screenHei * 0.5 - windowHeight * 0.5)) / imageSz.y);
                if idx >= 0 && idx < length(shopItems)
                    shop.selectedItem = idx
        return true
    return found

def unit_builder_on_click(mouse:float2)
    var found = false
    find_query() <| $ (var builder: UnitBuilder)
        var cnt = 0
        query() <| $ (var player: PlayerInfo)
            for item in player.units
                if !item.used && item.u_type == builder.u_type
                    ++cnt
        if mouse.x >= 10.0 + elemSz && mouse.x <= 10.0 + elemSz + imageSz.x
            if mouse.y > 50.0 && mouse.y < 50.0 + imageSz.y * float(cnt)
                let idx = int((mouse.y - 50.0) / imageSz.y);
                if idx >= 0 && idx < cnt
                    builder.selectedUnit = idx
                    found = true
        if !found
            cnt = length(builder.availableGoods)
            if mouse.x >= (float(get_desktop_width()) - elemSz - 29.0) && mouse.x <= (float(get_desktop_width()) - 25.0)
                if mouse.y >= 50.0 && mouse.y <= 50.0 + float(cnt) * (elemSz + 5.0)
                    let idx = int((mouse.y - 50.0) / (elemSz + 5.0));
                    if idx >= 0 && idx < cnt
                        builder.selectedGood = builder.availableGoods[idx]
                        found = true
        return true
    return found

def draw_good_indicator(good:int; pos:float2; size:float; need_back:bool)
    if good >= 0
        if need_back
            fill_circle(pos.x + size * 0.5, pos.y + size * 0.5, size * 0.6, 0x77FFFFFF) 
        if good == G_PASSANGER
            passanger |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_MAIL
            mail |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_REFUSE
            refuse |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_WOOD
            wood |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_BOARDS
            boards |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_FURNITURE
            furniture |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_MILK
            milk |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_CHEESE
            cheese |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_WATER
            water |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_OIL
            oil |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
        elif good == G_FUEL
            fuel |> draw_image(pos.x, pos.y, 0xFFFFFFFF, size)
    

[decs(stage=draw_help)]
def draw_help(help: Help)
    fill_rect(0.0, 0.0, float(get_desktop_width()), float(get_desktop_height()) - 200.0, 0xFFFFFFFF)
    text_out(10, 10, "For move camera use arrows", 0xFF000000)
    text_out(10, 50, "For start transport you must create terminal, buy transport and create task:", 0xFF000000)
    text_out(10, 90, "1. For create terminal click on button ", 0xFF000000)
    imgBuild |> draw_image(400.0, 80.0, 0xFFFFFFFF, 40.0)
    text_out(450, 90, "and click on type of terminal: for trucks, for ships and for planes.", 0xFF000000)
    text_out(10, 110, "Next click on empty cell of game-map", 0xFF000000)
    text_out(10, 130, "To start the truck, you must build a road. A port can only be built on a land cell adjacent to water", 0xFF000000)
    text_out(10, 150, "The road must be directed to the terminal and be on the adjacent cell from it", 0xFF000000)
    text_out(10, 170, "To make a turn in the road, build two roads in different directions on the same square", 0xFF000000)
    text_out(10, 190, "To change the direction of the road press the button 'SPACE'", 0xFF000000)
    text_out(10, 230, "2. For buy transport click on button", 0xFF000000)
    imgUBuild |> draw_image(380.0, 220.0, 0xFFFFFFFF, 40.0)
    text_out(430, 230, "and click on image of needed transport. Click on ", 0xFF000000)
    text_out(10, 270, "3. For start transport click on button ", 0xFF000000)
    imgShop |> draw_image(400.0, 260.0, 0xFFFFFFFF, 40.0)
    text_out(450, 270, "Next click on start terminal, click on destination terminal, click on accessible transport from left list", 0xFF000000)
    text_out(10, 300, "and click on accessible goods from right list. Trasnport will start.", 0xFF000000)
    text_out(10, 330, "To receive money, you must deliver the desired product to the plant.", 0xFF000000)
    text_out(10, 350, "The product that the factory produces is indicated in the lower left corner of the factory icon, the product that the factory needs is indicated in the upper left corner.", 0xFF000000)
    text_out(10, 370, "The terminal must be placed on the adjacent cell from the plant", 0xFF000000)
    text_out(10, 390, "You will receive money only if you have delivered the required product to the plant", 0xFF000000)
    text_out(10, 410, "To start the truck, you must build a road", 0xFF000000)
    text_out(10, 430, "To close any window press the button 'ESC'", 0xFF000000)
