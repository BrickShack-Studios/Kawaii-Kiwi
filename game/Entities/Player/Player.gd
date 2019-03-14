extends KinematicBody

export (float) var moveSpeed
export (float) var jumpForce
export (float) var gravity
export (float) var maxFallSpeed

export (float) var vLookSensitivity
export (float) var hLookSensitivity

# Points up
const Y_AXIS := Vector3(0, 1, 0)

onready var camBase := $CameraBase as Spatial

var yVelocity := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	return

func _process(delta : float) -> void:
	if (Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()
		
func _physics_process(delta : float) -> void:
	var moveVec := Vector3()
	
	if (Input.is_action_pressed("moveForwards")):
		moveVec.z -= 1
	if (Input.is_action_pressed("moveBackwards")):
		moveVec.z += 1
	if (Input.is_action_pressed("moveRight")):
		moveVec.x += 1
	if (Input.is_action_pressed("moveLeft")):
		moveVec.x -= 1
	
	# We don't want moving diagonally to be faster
	moveVec = moveVec.normalized()
	# Align movement to player rotation
	moveVec = moveVec.rotated(Y_AXIS, rotation.y)
	
	moveVec *= moveSpeed
	moveVec.y = yVelocity
	
	move_and_slide(moveVec, Y_AXIS)
	
	
	var onFloor    : bool = is_on_floor()
	var justJumped : bool = false
	
	yVelocity -= gravity
	
	if (onFloor and Input.is_action_just_pressed("jump")):
		justJumped = true
		yVelocity = jumpForce
	elif (onFloor and yVelocity <= 0):
		yVelocity = -0.1
		
	if (yVelocity < -maxFallSpeed):
		yVelocity = -maxFallSpeed
	
	return

func _input(event : InputEvent) -> void:
	if (event is InputEventMouseMotion):
		camBase.rotation_degrees.x -= event.relative.y * vLookSensitivity
		camBase.rotation_degrees.x = clamp(camBase.rotation_degrees.x, -90, 90)
		
		rotation_degrees.y -= event.relative.x * hLookSensitivity
