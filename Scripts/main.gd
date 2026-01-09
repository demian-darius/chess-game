extends Node3D

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var from_camera = get_viewport().get_camera_3d()
		var mouse_pos = event.position
		var space_state = get_world_3d().direct_space_state
		var origin    = from_camera.project_ray_origin(mouse_pos)
		var direction = from_camera.project_ray_normal(mouse_pos)
		var target    = origin + direction * 100
		var params = PhysicsRayQueryParameters3D.create(origin, target)
		var result = space_state.intersect_ray(params)
		if result:
			var clicked_object = result.collider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
