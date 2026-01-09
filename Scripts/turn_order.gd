extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_chessboard_switch(turn: int) -> void:
	if turn == 1:
		text = "White Turn"
		self.add_theme_color_override("font_color", Color.WHITE)
	else:
		text = "Black Turn"
		self.add_theme_color_override("font_color", Color.BLACK)
