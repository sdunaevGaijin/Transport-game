require daslib/decs_boost
require daslib/media
require tools
require levels

let indA380 <- create_image("images/a380indicator.png")
let indBoeing <- create_image("images/boeing_indicator.png")

let indTitanic <- create_image("images/titanic_indicator.png")
let indCargo <- create_image("images/cargo_indicator.png")

let indTruck <- create_image("images/truck_indicator.png")

[decs_template]
struct Unit
    pos:float2
    volume:int
    speed:float
    maxSpeed:float
    accel:float
    dir:float2
    product:int
    model:int
    destination:EntityId
    source:EntityId
    revert:bool
    unloadingTime:float
    curUnloadTime:float
    serviceCost:int

[decs_template]
struct Plane : Unit
    plane_tag:bool

[decs_template]
struct Ship : Unit
    ship_tag:bool
    path:array<int2>
    cur_point:int

[decs_template]
struct Truck : Unit
    truck_tag:bool
    path:array<int4>
    cur_point:int

def create_unit(position: float2; u_type, volume, in_product, model, service: int; var dest, sour: EntityId; accel, maxSpeed, time: float)
    if u_type == UT_PLANE
        create_entity <| @ ( eid, cmp )
            cmp |> set("eid", eid)
            apply_decs_template(cmp, [[Plane  pos = position, volume = volume, speed = 0.0, product = in_product, dir = float2(1.0, 0.0),
            model = model, revert = false, destination = dest, maxSpeed = maxSpeed, accel = accel, source = sour, unloadingTime = time,
            curUnloadTime = -1.0, serviceCost = service]])
    if u_type == UT_SHIP
        create_entity <| @ ( eid, cmp )
            cmp |> set("eid", eid)
            apply_decs_template(cmp, [[Ship  pos = position, volume = volume, speed = 0.0, product = in_product, dir = float2(1.0, 0.0),
            model = model, revert = false, destination = dest, maxSpeed = maxSpeed, accel = accel, source = sour, unloadingTime = time,
            curUnloadTime = -1.0, serviceCost = service]])
    if u_type == UT_CAR
        create_entity <| @ ( eid, cmp )
            cmp |> set("eid", eid)
            apply_decs_template(cmp, [[Truck  pos = position, volume = volume, speed = 0.0, product = in_product, dir = float2(1.0, 0.0),
            model = model, revert = false, destination = dest, maxSpeed = maxSpeed, accel = accel, source = sour, unloadingTime = time,
            curUnloadTime = -1.0, serviceCost = service]])
        
def initialize_ship(var ship_path:array<int2>; ship_source, ship_destination:EntityId)
    var start = int2(-1, -1)
    var end = int2(-1, -1)
    query(ship_source) <| $ (pos: int2)
        if pos.x < levelSize.x - 1 && level[pos.y * levelSize.x + pos.x + 1] == WATER
            start = int2(pos.x + 1, pos.y)
        elif pos.x > 0 && pos.x < levelSize.x - 1 && level[pos.y * levelSize.x + pos.x - 1] == WATER
            start = int2(pos.x - 1, pos.y)
        elif pos.y < levelSize.y - 1 && level[(pos.y + 1)* levelSize.x + pos.x] == WATER
            start = int2(pos.x, pos.y + 1)
        elif pos.y > 0 && level[(pos.y - 1)* levelSize.x + pos.x] == WATER
            start = int2(pos.x, pos.y - 1)
    query(ship_destination) <| $ (pos: int2)
        if pos.x < levelSize.x - 1 && level[pos.y * levelSize.x + pos.x + 1] == WATER
            end = int2(pos.x + 1, pos.y)
        elif pos.x > 0 && pos.x < levelSize.x - 1 && level[pos.y * levelSize.x + pos.x - 1] == WATER
            end = int2(pos.x - 1, pos.y)
        elif pos.y < levelSize.y - 1 && level[(pos.y + 1)* levelSize.x + pos.x] == WATER
            end = int2(pos.x, pos.y + 1)
        elif pos.y > 0 && level[(pos.y - 1)* levelSize.x + pos.x] == WATER
            end = int2(pos.x, pos.y - 1)
    ship_pathfinder(ship_path, start, end)

def initialize_truck(var truck_path:array<int4>; truck_source, truck_destination:EntityId)
    var start:array<int4>
    var end:array<int4>
    query(truck_source) <| $ (pos: int2)
        query() <| $ (road: Road)
            if road.r_type == B_ROAD && sqr(road.pos.x - pos.x) + sqr(road.pos.y - pos.y) == 1
                if (road.pos + road.dir) == pos || (road.pos - road.dir) == pos
                    let node = int4(road.pos.x, road.pos.y, road.dir.x, road.dir.y)
                    start |> push(node)
    query(truck_destination) <| $ (pos: int2)
        query() <| $ (road: Road)
            if road.r_type == B_ROAD && sqr(road.pos.x - pos.x) + sqr(road.pos.y - pos.y) == 1  
                if (road.pos + road.dir) == pos || (road.pos - road.dir) == pos
                    let node = int4(road.pos.x, road.pos.y, road.dir.x, road.dir.y)
                    end |> push(node)
    truck_pathfinder(truck_path, start, end)

[decs(stage=draw)]
def draw_planes(unit:Plane)
    var angle = acos(clamp(dot(unit.dir, float2(-1.0, 0.0)), -1.0, 1.0))
    if unit.dir.y > 0.0
        angle = -angle
    if unit.model == PM_A380
        indA380 |> draw_image_transformed(unit.pos.x, unit.pos.y, float4(0.0, 0.0, 128.0, 128.0), 0xFFFFFFFF, float2(0.75, 0.75), angle)
    elif unit.model == PM_BOEING
        indBoeing |> draw_image_transformed(unit.pos.x, unit.pos.y, float4(0.0, 0.0, 128.0, 128.0),0xFFFFFFFF, float2(0.75, 0.75), angle)
    if !unit.revert
        draw_good_indicator(unit.product, unit.pos - float2(0.3, 1.0), 0.5, false)

[decs(stage=draw)]
def draw_ships(unit:Ship)
    if unit.model == SM_TITANIC
        indTitanic |> draw_image_transformed(unit.pos.x, unit.pos.y, float4(0.0, 0.0, 128.0, 128.0), 0xFFFFFFFF, float2(1.0, 1.0), 0.0)
    elif unit.model == SM_CARGO
        indCargo |> draw_image_transformed(unit.pos.x, unit.pos.y, float4(0.0, 0.0, 128.0, 128.0),0xFFFFFFFF, float2(1.0, 1.0), 0.0)
    if !unit.revert
        draw_good_indicator(unit.product, unit.pos - float2(0.3, 1.0), 0.5, false)

[decs(stage=draw)]
def draw_trucks(unit:Truck)
    var angle = acos(clamp(dot(unit.dir, float2(-1.0, 0.0)), -1.0, 1.0))
    if unit.dir.y > 0.0
        angle = -angle
    indTruck |> draw_image_transformed(unit.pos.x, unit.pos.y, float4(0.0, 0.0, 128.0, 128.0), 0xFFFFFFFF, float2(1.0, 1.0), angle)
    if !unit.revert
        draw_good_indicator(unit.product, unit.pos - float2(0.3, 1.0), 0.5, false)

def confirm_create_unit
    var confirm = false
    query <| $ (var builder : UnitBuilder; eid:EntityId)
        if builder.destination != INVALID_ENTITY_ID && builder.source != INVALID_ENTITY_ID && builder.selectedUnit >= 0 && builder.selectedGood >= 0
            query(builder.source) <| $ (pos: int2)
                find_query <| $ (var player:PlayerInfo)
                    if length(player.units) > builder.selectedUnit
                        var cnt = -1
                        for unit in player.units
                            if !unit.used && unit.u_type == builder.u_type
                                ++cnt
                                if cnt == builder.selectedUnit
                                    create_unit(float2(pos.x, pos.y) + float2(0.5, 0.5), unit.u_type, unit.volume, builder.selectedGood, unit.model, unit.serviceCost,
                                    builder.destination, builder.source, unit.accel, unit.maxSpeed, unit.unloadingTime)
                                    delete_entity(eid)
                                    confirm = true
                                    unit.used = true
    return confirm

def can_unload(term_pos:int2; good:int)
    let found = find_query <| $ [REQUIRE(ftype)] (pos:int2; needGood:int)
        if needGood == good && abs(pos.x - term_pos.x) + abs(pos.y - term_pos.y) <= 1
            return true
    return found

[decs(stage=update)]
def update_planes(var plane:Plane)
    let dt = get_delta_time()
    let destId = plane.revert ? plane.source : plane.destination
    if destId != INVALID_ENTITY_ID
        query(destId) <| $ (pos: int2)
            let destPos = float2(pos.x, pos.y) + float2(0.5, 0.5)
            if length_sq(destPos - plane.pos) < 0.0025
                plane.pos = destPos
                plane.speed = 0.0
                plane.dir = float2(1.0, 0.0)
                let canUn = plane.revert || can_unload(pos, plane.product)
                if canUn
                    if plane.curUnloadTime <= -1.0
                        plane.curUnloadTime = plane.unloadingTime
                    plane.curUnloadTime -= dt
                    if plane.curUnloadTime <= 0.0
                        plane.curUnloadTime = -1.0
                        let reward = !plane.revert ? ((length(good_reward) > plane.product ? good_reward[plane.product] : 0) * plane.volume - plane.serviceCost) : -plane.serviceCost
                        change_balance(reward)
                        create_cash_diff(destPos, reward)
                        plane.revert = !plane.revert
            else
                plane.dir = normalize(destPos - plane.pos)
                if plane.speed < plane.maxSpeed
                    plane.speed = min(plane.maxSpeed, plane.speed + dt * plane.accel)
                if length_sq(destPos - plane.pos) > sqr(plane.speed * dt)
                    plane.pos += plane.dir * plane.speed * dt
                else
                    plane.pos = destPos
                    

def ship_pathfinder(var path: array<int2>; start, finish: int2)
    var reachable:array<int2>
    var explored:array<int2>
    reachable |> clear()
    explored |> clear()
    reachable |> push(start)
    var prevs: table<int2; int2>

    while length(reachable) > 0
        var node = reachable[0]

        if node == finish
            while find(prevs, node) != null
                path |> push(node, 0)
                node = prevs[node]
            path |> push(start, 0)
            return
        
        reachable |> erase(0)
        explored |> push(node)

        let cur = int2(node.x, node.y)
        var newReachable:array<int2>
        newReachable |> clear()
        if cur.x < levelSize.x - 1 && level[cur.y * levelSize.x + cur.x + 1] == WATER && find_index(explored, int2(cur.x + 1, cur.y)) < 0
            newReachable |> push(int2(cur.x + 1, cur.y))
        if cur.x > 0 && cur.x < levelSize.x - 1 && level[cur.y * levelSize.x + cur.x - 1] == WATER && find_index(explored, int2(cur.x - 1, cur.y)) < 0
            newReachable |> push(int2(cur.x - 1, cur.y))
        if cur.y < levelSize.y - 1 && level[(cur.y + 1)* levelSize.x + cur.x] == WATER && find_index(explored, int2(cur.x, cur.y + 1)) < 0
            newReachable |> push(int2(cur.x, cur.y + 1))
        if cur.y > 0 && level[(cur.y - 1)* levelSize.x + cur.x] == WATER && find_index(explored, int2(cur.x, cur.y - 1)) < 0
            newReachable |> push(int2(cur.x, cur.y - 1))
        
        for adjacent in newReachable
            if find_index(reachable, adjacent) < 0
                prevs[adjacent] = node
                reachable |> push(adjacent)



[decs(stage=update)]
def update_ships(var ship:Ship)
    let dt = get_delta_time()
    let destId = ship.revert ? ship.source : ship.destination
    query(destId) <| $ (pos: int2)
        let destPos = float2(pos.x, pos.y) + float2(0.5, 0.5)
        if length(ship.path) == 0
            initialize_ship(ship.path, ship.source, ship.destination)
        if length_sq(destPos - ship.pos) < 0.0025
            ship.pos = destPos
            ship.speed = 0.0
            let canUn = ship.revert || can_unload(pos, ship.product)
            if canUn
                if ship.curUnloadTime <= -1.0
                    ship.curUnloadTime = ship.unloadingTime
                ship.curUnloadTime -= dt
                if ship.curUnloadTime <= 0.0
                    ship.curUnloadTime = -1.0
                    let reward = !ship.revert ? ((length(good_reward) > ship.product ? good_reward[ship.product] : 0) * ship.volume - ship.serviceCost) : -ship.serviceCost
                    change_balance(reward)
                    create_cash_diff(destPos, reward)
                    ship.revert = !ship.revert
                    ship.cur_point = ship.revert ? length(ship.path) - 1 : 0
        elif length_sq(destPos - ship.pos) <= 1.0025
            ship.dir = normalize(destPos - ship.pos)
            if length_sq(destPos - ship.pos) > sqr(ship.speed * dt)
                ship.pos += ship.dir * ship.speed * dt
            else
                ship.pos = destPos
        else
            if length(ship.path) > ship.cur_point
                var destP = float2(ship.path[ship.cur_point].x, ship.path[ship.cur_point].y) + float2(0.5, 0.5)
                if length_sq(destP - ship.pos) < 0.0025
                    ship.pos = destP
                    ship.cur_point += ship.revert ? -1 : 1
                destP = length(ship.path) > ship.cur_point && ship.cur_point >= 0 ? (float2(ship.path[ship.cur_point].x, ship.path[ship.cur_point].y) + float2(0.5, 0.5)) : destPos
                ship.dir = normalize(destP - ship.pos)
                if ship.speed < ship.maxSpeed
                    ship.speed = min(ship.maxSpeed, ship.speed + dt * ship.accel)
                if length_sq(destP - ship.pos) > sqr(ship.speed * dt)
                    ship.pos += ship.dir * ship.speed * dt
                else
                    ship.pos = destP

                    
def truck_pathfinder(var path, start, finish: array<int4>)
    var reachable:array<int4>
    var explored:array<int4>
    reachable |> clear()
    explored |> clear()
    for stNode in start
        reachable |> push(stNode)
    var prevs: table<int4; int4>
    

    while length(reachable) > 0
        var node = reachable[0]
        
        if find_index(finish, node) >= 0
            while find(prevs, node) != null
                path |> push(node, 0)
                node = prevs[node]
            path |> push(node, 0)
            return
        
        reachable |> erase(0)
        explored |> push(node)

        var newReachable:array<int4>
        newReachable |> clear()
        let cur = int2(node.x, node.y)
        let dir = int2(node.z, node.w)
        query() <| $ (road: Road)
            let newNode = int4(road.pos.x, road.pos.y, road.dir.x, road.dir.y)
            if road.r_type == B_ROAD && sqr(road.pos.x - node.x) + sqr(road.pos.y - node.y) <= 1 && find_index(explored, newNode) < 0
                if road.pos != cur || road.dir != dir
                    if (((road.pos + road.dir) == cur || (road.pos - road.dir) == cur) && abs(road.dir.x) == abs(dir.x) && abs(road.dir.y) == abs(dir.y) ||
                     road.pos == cur)
                        newReachable |> push(newNode)
        
        for adjacent in newReachable
            if find_index(reachable, adjacent) < 0
                prevs[adjacent] = node
                reachable |> push(adjacent)

[decs(stage=update)]
def update_trucks(var truck:Truck)
    let dt = get_delta_time()
    let destId = truck.revert ? truck.source : truck.destination
    query(destId) <| $ (pos: int2)
        let destPos = float2(pos.x, pos.y) + float2(0.5, 0.5)
        if length(truck.path) == 0
            initialize_truck(truck.path, truck.source, truck.destination)
        if length_sq(destPos - truck.pos) < 0.0025
            truck.pos = destPos
            truck.speed = 0.0 
            let canUn = truck.revert || can_unload(pos, truck.product)
            if canUn
                if truck.curUnloadTime <= -1.0
                    truck.curUnloadTime = truck.unloadingTime
                truck.curUnloadTime -= dt
                if truck.curUnloadTime <= 0.0
                    truck.curUnloadTime = -1.0
                    let reward = !truck.revert ? ((length(good_reward) > truck.product ? good_reward[truck.product] : 0) * truck.volume - truck.serviceCost) : -truck.serviceCost
                    change_balance(reward)
                    create_cash_diff(destPos, reward)
                    truck.revert = !truck.revert
                    truck.cur_point = truck.revert ? length(truck.path) - 1 : 0
        elif length_sq(destPos - truck.pos) <= 1.0025
            truck.dir = normalize(destPos - truck.pos)
            if length_sq(destPos - truck.pos) > sqr(truck.speed * dt)
                truck.pos += truck.dir * truck.speed * dt
            else
                truck.pos = destPos
        else
            if length(truck.path) > truck.cur_point
                var destP = float2(truck.path[truck.cur_point].x, truck.path[truck.cur_point].y) + float2(0.5, 0.5)
                if length_sq(destP - truck.pos) < sqr(0.001)
                    truck.pos = destP
                    truck.cur_point += truck.revert ? -1 : 1
                destP = length(truck.path) > truck.cur_point && truck.cur_point >= 0 ? (float2(truck.path[truck.cur_point].x, truck.path[truck.cur_point].y) + float2(0.5, 0.5)) : destPos
                truck.dir = normalize(destP - truck.pos)
                if truck.speed < truck.maxSpeed
                    truck.speed = min(truck.maxSpeed, truck.speed + dt * truck.accel)
                if length_sq(destP - truck.pos) > sqr(truck.speed * dt)
                    truck.pos += truck.dir * truck.speed * dt
                else
                    truck.pos = destP
