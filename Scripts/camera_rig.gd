extends Node3D

@export var rotation_speed := 0.01
@export var zoom_speed := 2.0
@export var move_speed := 5.0
@export var min_distance := 5.0
@export var max_distance := 30.0

var dragging := false
var last_mouse_pos := Vector2()

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = $Pivot/Camera3D

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			last_mouse_pos = event.position

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_speed)

	elif event is InputEventMouseMotion and dragging:
		var delta = event.relative
		rotate_camera(delta)

func _process(delta: float):
	handle_keyboard_movement(delta)

func rotate_camera(delta: Vector2):
	pivot.rotate_y(-delta.x * rotation_speed)
	var pitch = pivot.rotation.x - delta.y * rotation_speed
	pitch = clamp(pitch, deg_to_rad(-75), deg_to_rad(75))
	pivot.rotation.x = pitch

func zoom_camera(amount: float):
	var offset = camera.transform.origin
	offset = offset.normalized() * clamp(offset.length() + amount, min_distance, max_distance)
	camera.transform.origin = offset

func handle_keyboard_movement(delta):
	var direction = Vector3.ZERO
	var right = transform.basis.x
	var forward = -transform.basis.z
	
	if Input.is_action_pressed("move_forwards"):
		direction += forward
	if Input.is_action_pressed("move_back"):
		direction -= forward
	if Input.is_action_pressed("move_left"):
		direction -= right
	if Input.is_action_pressed("move_right"):
		direction += right
	
	if direction != Vector3.ZERO:
		global_translate(direction.normalized() * move_speed * delta)
