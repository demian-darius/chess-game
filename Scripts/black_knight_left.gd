extends Area3D

@export var piece_type: String = "knight"
@export var color: String = "black"
@onready var current_location =  get_node("../../../Chessboard/G8")
@onready var location_name: String = current_location.name

signal selected(piece)

@onready var board = get_tree().get_root().get_node("Main/Chessboard")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.BLACK
	$"Black Knight Left Mesh".material_override = mat
	connect("input_event", Callable(self, "_on_input_event"))
	selected.connect(Callable(board, "select_piece"))

func position() -> String:
	return current_location.name

func get_valid_moves() -> Array[String]:
	var moves: Array[String] = []
	var start = Helper.square_name_to_coords(location_name)
	
	var offsets = [Vector2(1, 2), Vector2(2, 1), Vector2(-1, 2), Vector2(-2, 1), Vector2(1, -2), Vector2(2, -1), Vector2(-1, -2), Vector2(-2, -1)]
	for off in offsets:
		var cand = start + off
		if Helper._is_within_board(cand):
			var cand_name = Helper.coords_to_square_name(cand)
			var p = Helper._get_piece_at_square(cand_name)
			if not p:
				moves.append(cand_name)
			elif p.color != color:
				moves.append(cand_name)
	return moves

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)
		print(get_valid_moves())

func select() -> void:
	print("am venit aici sa colorez piesa")
	var mesh_inst := $"Black Knight Left Mesh" as MeshInstance3D
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
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.BLACK
	$"Black Knight Left Mesh".material_override = mat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
