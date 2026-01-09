extends Node3D

@export var cell_size: float = 1.0
@export var highlight_scene: PackedScene = preload("res://HighlightTile.tscn")
var selected_piece: Area3D = null
var highlights: Array[Node3D] = []
var turn: int = 1

signal switch(turn)
signal check()
signal winner() 
signal promote(piece)

@onready var white_king: Area3D = get_node("../Pieces/White Pieces/WhiteKing")
@onready var black_king: Area3D = get_node("../Pieces/Black Pieces/Black King")



func _ready() -> void:
	pass



func select_piece(p: Area3D) -> void:
	if selected_piece and selected_piece != p:
		selected_piece.deselect()
		_clear_highlights()     
	if (p.color == "white" and turn == 1) or (p.color == "black" and turn == 0):
		selected_piece = p
		selected_piece.select()
		_show_valid_moves()



func _show_valid_moves() -> void:
	if not selected_piece:
		return
	var moves: Array[String] = selected_piece.get_valid_moves()
	for square_name in moves:
		var sq_node := get_node(square_name) as MeshInstance3D
		if not sq_node:
			continue
		var h := highlight_scene.instantiate() as Node3D
		var sq_global_pos: Vector3 = sq_node.position
		h.global_transform.origin = sq_global_pos + Vector3(0.0, 0.01, 0.0)
		add_child(h)
		highlights.append(h)



func _clear_highlights() -> void:
	for h in highlights:
		if is_instance_valid(h):
			h.queue_free()
	highlights.clear()



func move_piece_to_square(piece: Area3D, square_name: String) -> void:
	var sq_node := get_node(square_name) as Node3D
	if not sq_node:
		return
	if piece.piece_type == "king" or piece.piece_type == "rook":
		piece.has_moved = true
	if(piece.piece_type == "king" and abs(Helper.square_name_to_coords(piece.location_name).x - Helper.square_name_to_coords(square_name).x) >= 2):
		castling(piece, square_name)
		return
	var sq_global_pos: Vector3 = sq_node.global_position
	var origin = piece.transform.origin
	var mesh_box = piece.get_child(0).get_aabb()
	var mesh_box_global = piece.get_child(0).global_transform * mesh_box
	var square_aabb = sq_node.get_aabb()
	var square_global_aabb = sq_node.global_transform * square_aabb
	var x_offset = square_global_aabb.position.x - mesh_box_global.position.x
	var z_offset = square_global_aabb.position.z - mesh_box_global.position.z
	piece.global_position = Vector3(piece.global_position.x + x_offset, piece.position.y, piece.global_position.z + z_offset)
	if Helper._get_piece_at_square(square_name):
		Helper._get_piece_at_square(square_name).free()
	if piece.piece_type == "pawn" && (square_name.contains("8") or square_name.contains("1")):
		promote.emit(piece)
	piece.current_location = sq_node
	piece.location_name = square_name
	var color = verify_check()
	if color != "":
		check.emit(color)
		$"../Check".show()
		if is_checkmate(color):
			$"../Check".hide()
			winner.emit(color)
			$"../End Screen".show()
	else:
		$"../Check".hide()
	turn = 1 - turn
	switch.emit(turn)

func castling(piece: Area3D, square_name: String) -> void:
	var sq_node := get_node(square_name) as Node3D
	if not sq_node:
		return
	var square_aabb = sq_node.get_aabb()
	var mesh_box = piece.get_child(0).get_aabb()
	var mesh_box_global = piece.get_child(0).global_transform * mesh_box
	var square_global_aabb = sq_node.global_transform * square_aabb
	var x_offset = square_global_aabb.position.x - mesh_box_global.position.x
	var z_offset = square_global_aabb.position.z - mesh_box_global.position.z
	piece.global_position = Vector3(piece.global_position.x + x_offset, piece.position.y, piece.global_position.z + z_offset)
	piece.current_location = sq_node
	piece.location_name = square_name
	if square_name.contains("C"):
		if piece.color == "black":
			move_piece_to_square($"../Pieces/Black Pieces/Black Rook Right", "D8")
		else:
			move_piece_to_square($"../Pieces/White Pieces/White Rook Left", "D1")
	else:
		if piece.color == "black":
			move_piece_to_square($"../Pieces/Black Pieces/Black Rook Left", "F8")
		else:
			move_piece_to_square($"../Pieces/White Pieces/White Rook Right", "F1")

func verify_check() -> String:
	for piece in get_tree().get_nodes_in_group("chess_pieces"):
		if piece.color == "white":
			for move in piece.get_valid_moves():
				if Helper._get_piece_at_square(move) == black_king:
					return "black"
		elif piece.color == "black":
			for move in piece.get_valid_moves():
				if Helper._get_piece_at_square(move) == white_king:
					return "white"
	return ""



func is_checkmate(color: String) -> bool:
	for piece in get_tree().get_nodes_in_group("chess_pieces"):
		if(piece.color == color):
			var moves = piece.get_valid_moves()
			if simulate(piece, moves, color) == false:
				return false
	return true

func simulate(piece: Area3D, moves: Array[String], color: String) -> bool:
	var original_position = piece.current_location
	for move in moves:
		var new_square_node = get_node(move) as Node3D
		piece.current_location = new_square_node
		if(Helper._get_piece_at_square(move)):
			Helper._get_piece_at_square(move).set_process(false)
			if verify_check() != color:
				Helper._get_piece_at_square(move).set_process(true)
				piece.current_location = original_position
				return false
			Helper._get_piece_at_square(move).set_process(true)
		else:
			if verify_check() != color:
				piece.current_location = original_position
				return false
		piece.current_location = original_position
	return true



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if not selected_piece:
				return
			var camera := get_viewport().get_camera_3d()
			if not camera:
				return
			var ray_origin: Vector3 = camera.project_ray_origin(mb.position)
			var ray_dir: Vector3 = camera.project_ray_normal(mb.position)
			var board_y: float = global_transform.origin.y
			var chess_plane := Plane(Vector3.UP, board_y)
			var intersection: Vector3 = chess_plane.intersects_ray(ray_origin, ray_dir)
			if intersection == null:
				return
			var valid_moves: Array[String] = selected_piece.get_valid_moves()
			for sq_name in valid_moves:
				var sq_node := get_node(sq_name) as MeshInstance3D
				if not sq_node:
					continue
				var sq_pos: Vector3 = sq_node.global_transform.origin
				var dx: float = sq_pos.x - intersection.x
				var dz: float = sq_pos.z - intersection.z
				var distance_2d: float = Vector2(dx, dz).length()
				if distance_2d <= cell_size * 0.5:
					move_piece_to_square(selected_piece, sq_name)
					selected_piece.deselect()
					_clear_highlights()
					selected_piece = null
					return



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.as_text().to_lower() == "r":
		if selected_piece:
			selected_piece.deselect()
			selected_piece = null
		_clear_highlights()
