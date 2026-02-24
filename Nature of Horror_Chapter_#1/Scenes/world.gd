extends Node3D

@export var watcher_scene: PackedScene
@export var player: CharacterBody3D

## Safe radius around player (enemy cannot spawn inside this)
@export var min_spawn_distance: float = 20.0

## Time before enemy respawns after despawning
@export var respawn_delay: float = 5.0

## Width of the spawn band outside the safe zone.
## Enemy will spawn between:
## min_spawn_distance AND (min_spawn_distance + spawn_band_width)
@export var spawn_band_width: float = 10.0


# Ensures only ONE enemy exists at a time.
var current_enemy = null

# Internal timer used to delay respawning.
var respawn_timer: Timer


func _ready():
	randomize()

	respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.wait_time = respawn_delay
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	add_child(respawn_timer)

	spawn_enemy()


func spawn_enemy():

	if current_enemy != null:
		return

	var points = get_tree().get_nodes_in_group("spawn_points")

	if points.is_empty():
		print("No spawn points found!")
		return

	var valid_points = []

	var max_spawn_distance = min_spawn_distance + spawn_band_width

	for point in points:
		var distance = point.global_position.distance_to(player.global_position)

		# Spawn ONLY inside the ring band
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
	respawn_timer.wait_time = respawn_delay
	respawn_timer.start()


func _on_respawn_timer_timeout():
	spawn_enemy()
