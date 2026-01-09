extends GridContainer

var Promote: Area3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_queen_button_pressed() -> void:
	pass # Replace with function body.


func _on_knight_button_pressed() -> void:
	pass # Replace with function body.


func _on_bishop_button_pressed() -> void:
	pass # Replace with function body.


func _on_rook_button_pressed() -> void:
	pass # Replace with function body.


func _on_chessboard_promote(piece: Variant) -> void:
	self.show()
	Promote = piece
