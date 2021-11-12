require daslib/media
require gameplay

def draw_menu
    setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)
    fill_circle(100, 100, 50, 0xFFFFFF)

def control_menu
    if get_key_down(VK_ESCAPE)
        schedule_quit_game()
    if get_key_down(VK_RETURN)
        create_game()
        return true
    return false
