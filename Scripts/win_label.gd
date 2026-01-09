extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.get_parent().hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_chessboard_winner(winner: String) -> void:
	if winner == "white":
		text = "Blacks Wins"
	else:
		text = "White Wins"
