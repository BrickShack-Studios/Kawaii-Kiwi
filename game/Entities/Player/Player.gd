extends KinematicBody

export (float) var moveSpeed    : float
export (float) var speedPercent : float
export (float) var jumpForce    : float
export (float) var gravity      : float
export (float) var maxFallSpeed : float
export (float) var drag         : float

export (float) var vLookSensitivity : float
export (float) var hLookSensitivity : float

# Points up
const Y_AXIS := Vector3(0, 1, 0)

onready var camBase      := $CameraBase as Spatial
onready var anim         := $AnimationPlayer/AnimationTree as AnimationTree
onready var animPlayback := anim.get("parameters/playback") as AnimationNodeStateMachinePlayback

var yVelocity  := 0.0
var doubleJump := false
var velocity   := Vector3()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	anim.active = true
	animPlayback.start("idle")
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
	
	var runMod := 1.0
	
	if (Input.is_action_pressed("run")):
		runMod += speedPercent
	
	moveVec *= moveSpeed * runMod
	moveVec.y = yVelocity
	
	velocity = lerp(velocity, moveVec, drag)
	move_and_slide(velocity, Y_AXIS)
	
	var onFloor    : bool = is_on_floor()
	
	if (not onFloor): playAnimation("falling")
	elif (velocity.length() > 0.11 and runMod > 1): playAnimation("run")
	elif (velocity.length() > 0.11): playAnimation("walk")
	elif (velocity.length() < 0.11): playAnimation("idle")
	
	yVelocity -= gravity
	
	if (onFloor and Input.is_action_just_pressed("jump")):
		yVelocity  = jumpForce
		playAnimation("jump")
	elif (Input.is_action_just_pressed("jump") and not onFloor and not doubleJump):
		yVelocity  = jumpForce
		doubleJump = true
		playAnimation("jump")
	elif (onFloor and yVelocity <= 0):
		yVelocity  = -0.1
		doubleJump = false
	
	if (yVelocity < -maxFallSpeed):
		yVelocity = -maxFallSpeed
		
	return

func _input(event : InputEvent) -> void:
	if (event is InputEventMouseMotion):
		camBase.rotation_degrees.x -= event.relative.y * vLookSensitivity
		camBase.rotation_degrees.x = clamp(camBase.rotation_degrees.x, -90, 90)
		
		rotation_degrees.y -= event.relative.x * hLookSensitivity

# Handles playing animations so you don't have to
# worry about checking if it's already playing
func playAnimation(a : String) -> void:
	if (not animPlayback.is_playing()):
		animPlayback.travel(a)
	else:
		if (animPlayback.get_current_node() != a):
			if (animPlayback.get_current_node() == "falling" and a != "jump"):
					$Sounds/Landing.play()
			animPlayback.travel(a)
	
	return