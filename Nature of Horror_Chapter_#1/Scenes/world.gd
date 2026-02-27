extends Node3D

@export var watcher_scene: PackedScene
@export var min_spawn_distance: float = 55.0
@export var respawn_delay: float = 5.0
@export var spawn_band_width: float = 65.0

var current_enemy = null
var respawn_timer: Timer
var player: CharacterBody3D

func _ready():
	randomize()

	# Get player
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("Player not found in group 'player'")
		return

	# Create timer
	respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.wait_time = respawn_delay
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	add_child(respawn_timer)

	# Wait one frame so everything is inside tree
	await get_tree().process_frame

	spawn_enemy()


func spawn_enemy():
	if current_enemy != null:
		return

	if not player.is_inside_tree():
		return

	var points = get_tree().get_nodes_in_group("spawn_points")
	if points.is_empty():
		print("No spawn points found!")
		return

	var valid_points = []
	var max_spawn_distance = min_spawn_distance + spawn_band_width

	for point in points:
		if not point.is_inside_tree():
			continue

		var distance = point.global_position.distance_to(player.global_position)

		if distance >= min_spawn_distance and distance <= max_spawn_distance:
			valid_points.append(point)

	if valid_points.is_empty():
		print("No spawn points inside spawn band!")
		return

	var chosen_point = valid_points.pick_random()

	var enemy = watcher_scene.instantiate()
	enemy.global_position = chosen_point.global_position
	add_child(enemy)

	current_enemy = enemy
	enemy.tree_exited.connect(_on_enemy_removed)


func _on_enemy_removed():
	current_enemy = null
	respawn_timer.start()


func _on_respawn_timer_timeout():
	spawn_enemy()
