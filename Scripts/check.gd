extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_chessboard_check(color: String) -> void:
	if color == "white":
		text = "White is in check"
	else:
		text = "Black is in check"
