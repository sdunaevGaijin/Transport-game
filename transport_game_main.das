require daslib/media
require daslib/decs_boost
require main_menu
require gameplay
require tools
options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code

//var is_in_menu : bool
// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("Transport game")
    set_resolution(get_desktop_width(), get_desktop_height() - 200)
    //is_in_menu = true
    create_game()
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    //if !is_in_menu
    setup_2d_camera(cameraPos, CELL_SIZE)
    decs_stage("update")
    decs_stage("update_ui")
    update_controls(dt)
    //    is_in_menu = true
    //elif control_menu()
    //    is_in_menu = false
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    /*if is_in_menu
        draw_menu()
    else*/
    enable_alpha_blend()
    draw_level()
    decs_stage("draw")
    decs_stage("draw_units")
    setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)
    draw_UI()
    decs_stage("draw_ui")
    text_out(get_desktop_width() - 200, 10, "Press F1 for help", 0xFFFFFFFF)
    decs_stage("draw_help")
    return

