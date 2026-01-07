extends CanvasLayer

var gui_components = [
	"res://Scenes/settings_menu.tscn"
]

var resolutions = {
	"3840x2160": Vector2i(3840, 2160),
	"2560x1440": Vector2i(2560, 1440),
	"1920x1080": Vector2i(1920, 1080),
	"1366x768": Vector2i(1366, 768),
	"1280x720": Vector2i(1280, 720),
	"1440x900": Vector2i(1440, 900),
	"1600x900": Vector2i(1600, 900),
	"1152x648": Vector2i(1152, 648),
	"1024x600": Vector2i(1024, 600),
	"800x600": Vector2i(800, 600)
}

var settings_menu: Control

func _ready() -> void:
	for i in gui_components:
		var new_scene = load(i).instantiate()
		add_child(new_scene)
		new_scene.hide()

		# Cache settings menu reference
		if new_scene.name == "Settings Menu":
			settings_menu = new_scene

	# Optional but recommended
	add_to_group("settings_layer")

func _input(_event):
	if Input.is_action_just_pressed("toggle_settings"):
		toggle_settings()

func toggle_settings():
	if not settings_menu:
		return

	settings_menu.visible = !settings_menu.visible
	settings_menu.update_button_value()

func open_settings():
	if settings_menu and not settings_menu.visible:
		settings_menu.visible = true
		settings_menu.update_button_value()

func close_settings():
	if settings_menu and settings_menu.visible:
		settings_menu.visible = false

func center_window():
	var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size / 2)
