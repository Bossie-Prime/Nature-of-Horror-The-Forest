extends Control

@onready var stamina = $TextureProgressBar

var can_regen = false
var regen_delay = 1.5
var delay_timer = 0.0

var drain_speed = 30.0   # stamina per second
var regen_speed = 20.0   # stamina per second

func _ready():
	stamina.value = stamina.max_value

func _process(delta):
	var is_sprinting = Input.is_action_pressed("Sprint") and stamina.value > 0

	# === SPRINTING ===
	if is_sprinting:
		stamina.value -= drain_speed * delta
		delay_timer = 0.0
		can_regen = false

	# === NOT SPRINTING ===
	else:
		if stamina.value < stamina.max_value:
			delay_timer += delta

			if delay_timer >= regen_delay:
				can_regen = true

	# === REGEN ===
	if can_regen:
		stamina.value += regen_speed * delta

	# === CLAMP & STOP REGEN AT FULL ===
	stamina.value = clamp(stamina.value, 0, stamina.max_value)

	if stamina.value == stamina.max_value:
		can_regen = false
		delay_timer = 0.0
