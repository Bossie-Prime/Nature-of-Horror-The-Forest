extends Node3D

@export var player: CharacterBody3D
@export var stare_speed := 5.0
@export var vanish_time := 30.0   # Seconds before auto vanish

var player_inside := false
var time_alive := 0.0


func _process(delta):

	# Always stare at player
	if player and not player_inside:
		var target_pos = player.global_transform.origin
		look_at(target_pos, Vector3.UP)
		rotate_y(deg_to_rad(-90))

	# Count time if player has NOT entered
	if not player_inside:
		time_alive += delta

		if time_alive >= vanish_time:
			print("Player ignored Watcher...")
			disappear()


func _on_detection_area_3d_body_entered(body):
	if body == player:
		print("Player got too close...")
		player_inside = true
		disappear()


func disappear():
	print("Watcher vanished")
	queue_free()
