extends Area3D

@export var piece_type: String = "king"
@export var color: String = "white"
@onready var current_location =  get_node("../../../Chessboard/E1")
@onready var location_name: String = current_location.name

var has_moved: bool = false
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
	var start = Helper.square_name_to_coords(location_name)
	
	var offsets = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
	for off in offsets:
		var cand = start + off
		if not Helper._is_within_board(cand):
			continue
		var cand_name = Helper.coords_to_square_name(cand)
		var p = Helper._get_piece_at_square(cand_name)
		if not p or p.color != color:
			moves.append(cand_name)
	if not has_moved:
		var enemy_color := "black"
		if not is_attacked_by_enemy(location_name, enemy_color):
			var rook_ks = Helper._get_piece_at_square("H1")
			if rook_ks and rook_ks.piece_type == "rook" and rook_ks.color == color and not rook_ks.has_moved:
				if not Helper._get_piece_at_square("F1") and not Helper._get_piece_at_square("G1"):
					if not is_attacked_by_enemy("F1", enemy_color) and not is_attacked_by_enemy("G1", enemy_color):
						moves.append("G1")
			var rook_qs = Helper._get_piece_at_square("A1")
			if rook_qs and rook_qs.piece_type == "rook" and rook_qs.color == color and not rook_qs.has_moved:
				if not Helper._get_piece_at_square("B1") and not Helper._get_piece_at_square("C1") and not Helper._get_piece_at_square("D1"):
					if not is_attacked_by_enemy("D1", enemy_color) and not is_attacked_by_enemy("C1", enemy_color):
						moves.append("C1")
	return moves

func is_attacked_by_enemy(square_name: String, by_color: String) -> bool:
	for piece in get_tree().get_nodes_in_group("chess_pieces"):
		if piece.color == by_color and piece.piece_type != "king":
			if square_name in piece.get_valid_moves():
				return true
	return false

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)
		print(get_valid_moves())

func select() -> void:
	var mesh_inst := $"White King Mesh" as MeshInstance3D
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
	var mesh_inst := $"White King Mesh" as MeshInstance3D
	mesh_inst.material_override = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
