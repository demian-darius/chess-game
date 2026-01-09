extends Area3D

@export var piece_type: String = "pawn"
@export var color: String = "white"
@onready var current_location =  get_node("../../../Chessboard/A2")
@onready var location_name: String = current_location.name

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
	var dir: Vector2
	if color == "white":
		dir = Vector2(0, 1)
	else:
		dir = Vector2(0, -1)
	
	var start = Helper.square_name_to_coords(location_name)
	
	var forward = start + dir
	if Helper._is_within_board(forward):
		var forward_name = Helper.coords_to_square_name(forward)
		if not Helper._get_piece_at_square(forward_name):
			moves.append(forward_name)
			
			var initial_rank: int
			if color == "white":
				initial_rank = 1
			else:
				initial_rank = 6
			if int(start.y) == initial_rank:
				var two_forward = start + dir * 2
				if Helper._is_within_board(two_forward):
					var two_name = Helper.coords_to_square_name(two_forward)
					if not Helper._get_piece_at_square(two_name):
						moves.append(two_name)
	var diag_offsets = [Vector2(1, dir.y), Vector2(-1, dir.y)]
	for d in diag_offsets:
		var diag = start + d
		if Helper._is_within_board(diag):
			var diag_name = Helper.coords_to_square_name(diag)
			var p = Helper._get_piece_at_square(diag_name)
			if p and p.color != color:
				moves.append(diag_name)
	return moves

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)
		print(get_valid_moves())

func select() -> void:
	var mesh_inst := $"White Pawn A" as MeshInstance3D
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
	var mesh_inst := $"White Pawn A" as MeshInstance3D
	mesh_inst.material_override = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
