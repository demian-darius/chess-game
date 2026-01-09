extends Node

func square_name_to_coords(name: String) -> Vector2:
	var file := name[0]                                
	var rank := int(name.substr(1))                    
	var x := "ABCDEFGH".find(file)                     
	var y := rank - 1                                  
	return Vector2(x, y)                               


func coords_to_square_name(coords: Vector2) -> String:
	var file := "ABCDEFGH"[int(coords.x)]              
	var rank := str(int(coords.y) + 1)                 
	return file + rank                                 

func _is_within_board(coords: Vector2) -> bool:
	return coords.x >= 0 and coords.x < 8 and coords.y >= 0 and coords.y < 8


func _get_piece_at_square(square_name: String) -> Area3D:
	for piece in get_tree().get_nodes_in_group("chess_pieces"): 
		if piece.position() == square_name:            
			return piece                                    
	return null                                            
