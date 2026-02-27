extends CharacterBody3D

# Speed variables
var speed
const WALK_SPEED = 2.5
const SPRINT_SPEED = 5.5

const JUMP_VELOCITY = 4.5
const BASE_SENSITIVITY = 0.003
const ZOOM_SENS_MULTIPLIER = 0.7
var current_sensitivity = BASE_SENSITIVITY

# Head bob variables
const BOB_FREQ = 4.0
const BOB_AMP = 0.08
var t_bob = 0.0

# Idle breathing variables
const IDLE_BREATH_FREQ = 1.2
const IDLE_BREATH_AMP = 0.02

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Zoom variables
const ZOOM_FOV = 20.0
const ZOOM_SPEED = 7.0

# Gravity
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var flashlight = $Head/Camera3D/Spotlight/SpotLight3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * current_sensitivity)
		camera.rotate_x(-event.relative.y * current_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if Input.is_action_just_pressed("Flash Light"):
		flashlight.light_energy = 0.0 if flashlight.light_energy > 0.0 else 3.0


func _physics_process(delta):

	var is_zooming = Input.is_action_pressed("Zoom")
	current_sensitivity = BASE_SENSITIVITY * ZOOM_SENS_MULTIPLIER if is_zooming else BASE_SENSITIVITY

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	speed = SPRINT_SPEED if Input.is_action_pressed("Sprint") and input_dir.y < 0 else WALK_SPEED

	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# --- Smooth head bob + breathing ---

	var move_speed = velocity.length()
	var grounded = float(is_on_floor())

	if move_speed > 0.1 and grounded:
		if speed == SPRINT_SPEED:
			t_bob += delta * move_speed * 1.2   # Sprint bob speed/ lower if too fast
		else:
			t_bob += delta * move_speed * 1.9   # Walk bob speed/ increase if too slow
	else:
		t_bob += delta * IDLE_BREATH_FREQ

	var walk_strength = clamp(move_speed / SPRINT_SPEED, 0.0, 1.0)

	var walk_pos = Vector3.ZERO
	walk_pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP * walk_strength
	walk_pos.x = cos(t_bob * BOB_FREQ / 2.0) * BOB_AMP * walk_strength

	var idle_pos = Vector3.ZERO
	idle_pos.y = sin(t_bob) * IDLE_BREATH_AMP

	var blend = walk_strength * grounded

	camera.transform.origin = idle_pos.lerp(walk_pos, blend)

	# --- FOV ---

	var velocity_clamped = clamp(move_speed, 0.5, SPRINT_SPEED * 2)
	var sprint_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	var target_fov = ZOOM_FOV if is_zooming else sprint_fov

	camera.fov = lerp(camera.fov, target_fov, delta * ZOOM_SPEED)

	move_and_slide()
	
