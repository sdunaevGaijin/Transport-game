require daslib/media
require daslib/decs_boost
require main_menu
require gameplay
require tools
options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code

// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("Transport game")
    set_resolution(get_desktop_width(), get_desktop_height() - 200)
    create_game()
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    setup_2d_camera(cameraPos, CELL_SIZE)
    decs_stage("update")
    decs_stage("update_ui")
    update_controls(dt)
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
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

