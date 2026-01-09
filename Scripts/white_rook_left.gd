extends Area3D

@export var piece_type: String = "rook"
@export var color: String = "white"
@onready var current_location =  get_node("../../../Chessboard/A1")
@onready var location_name: String = current_location.name

@onready var has_moved = false
@onready var board = get_tree().get_root().get_node("Main/Chessboard")

signal selected(piece)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))
	selected.connect(Callable(board, "select_piece"))

func position() -> String:
	return current_location.name

func get_valid_moves() -> Array[String]:
	var moves: Array[String] = []
	var dirs := [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
	var start_coords := Helper.square_name_to_coords(location_name)
	for dir in dirs:
		var c := start_coords
		while true:
			c += dir
			if not Helper._is_within_board(c):
				break
			var sq_name := Helper.coords_to_square_name(c)
			var piece := Helper._get_piece_at_square(sq_name)
			if piece:
				if piece.color != color:
					moves.append(sq_name)
				break
			moves.append(sq_name)
	return moves

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)
		print(get_valid_moves())

func select() -> void:
	var mesh_inst := $"White Rook Left Mesh" as MeshInstance3D
	if not mesh_inst:
		return
	var mat := mesh_inst.material_override as StandardMaterial3D
	if mat == null:
		var orig_mat = mesh_inst.get_active_material(0)
		if orig_mat:
			mat = orig_mat.duplicate() as StandardMaterial3D
		else:
			mat = StandardMaterial3D.new()
		mesh_inst.material_override = mat
	mat.albedo_color = Color(1, 1, 0)

func deselect() -> void:
	var mesh_inst := $"White Rook Left Mesh" as MeshInstance3D
	mesh_inst.material_override = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
