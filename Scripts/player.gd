extends CharacterBody3D

# OUTSIDE VARIABLES
@onready var head: Node3D = $head

# MOVEMENT VARIABLES
var speed = 0
var base_speed = 5
var sprint_multiplier = 2
var crouch_multiplier = 0.25
var Jump_force = 4.5
var crouch_depth = -0.5

# MOUSE VARIABLES
var mouse_sens = 0.2

# WRLD LOGIC VARIABLES
var lerp_speed = 10
var direction = Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event): 
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * -mouse_sens))
		head.rotate_x(deg_to_rad(event.relative.y * -mouse_sens - 0.2))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _physics_process(delta: float) -> void:
	
	# COUCH & SPRINT
	if Input.is_action_pressed("crouch"):
		speed = base_speed * crouch_multiplier
		head.position.y = crouch_depth
	else:
		head.position.y = 0.0
		if Input.is_action_pressed("sprint"):
			speed = base_speed * sprint_multiplier
		else:
			speed = base_speed
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = Jump_force

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
