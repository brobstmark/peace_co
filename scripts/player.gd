extends CharacterBody3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var target_speed: float = 0.0
var current_speed: float = 0.0
@export var speed_increments: float = 5.0
@export var acceleration: float = 1.0
@export var reverse_speed: float = 5.0

@export var max_speed: float = 10.0
@export var turn_speed: float = 2.0
@export var mouse_sensitivity: float = 0.002
@export var min_turn_speed: float = 0.5

# Make the mech bob up and down during motion
var t_bob: float = 0.0
@export var bob_freq: float = 2.0
@export var bob_amp: float = 0.2
var head_default_y: float = 0.0

@onready var head:Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready():
	# LOCKS THE MOUSE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	head_default_y = head.position.y

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	# check keyboard input for forward, backward motion and set throttle accordingly
	if Input.is_action_just_pressed("move_forward"):
		target_speed += speed_increments
	elif Input.is_action_just_pressed("move_backward"):
		target_speed -= speed_increments
	
	target_speed = clamp(target_speed, -reverse_speed, max_speed)
	current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	
	# turning logic
	var speed_percent = abs(current_speed) / max_speed
	var dynamic_turn_speed = lerp(turn_speed, min_turn_speed, speed_percent)
	var turn_input = Input.get_axis("move_left", "move_right")
	rotate_y(-turn_input * dynamic_turn_speed * delta)
	
	var direction = -transform.basis.z
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	# bob up and down based on speed
	t_bob += abs(current_speed) * delta
	var bob_offset = sin(t_bob * bob_freq) * bob_amp
	head.position.y = head_default_y + bob_offset
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Directly modify the raw rotation properties instead of using rotate_y() / rotate_x()
		head.rotation.y -= event.relative.x * mouse_sensitivity
		head.rotation.x -= event.relative.y * mouse_sensitivity
		
		# Your clamps stay exactly the same
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-30), deg_to_rad(30))
		head.rotation.y = clamp(head.rotation.y, deg_to_rad(-50), deg_to_rad(50))
