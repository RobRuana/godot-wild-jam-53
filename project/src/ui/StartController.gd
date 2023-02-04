extends UIController

signal continue_game
signal quit_game

func _on_continue_game():
	emit_signal("continue_game")

func _on_quit_game():
	emit_signal("quit_game")
