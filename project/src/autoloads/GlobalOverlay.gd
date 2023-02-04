extends CanvasLayer


signal fade_started
signal fade_all_completed

onready var fader: = $Fader
onready var overlay: = $Overlay
onready var content: = $Overlay/Content
var is_active: bool = false
var is_visible: bool setget, get_is_visible


func get_is_visible() -> bool:
	return overlay.modulate.a != 0.0


func _ready():
	fader.connect("fade_all_completed", self, "_on_fade_all_completed")


func remove_content():
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()


func fade_to_black(duration: float = -1.0):
	is_active = true
	fader.fade_to_opaque(overlay, duration)
	call_deferred("emit_signal", "fade_started")
	yield(fader, "fade_all_completed")


func fade_to_transparent(duration: float = -1.0):
	is_active = true
	fader.fade_to_transparent(overlay, duration)
	call_deferred("emit_signal", "fade_started")
	yield(fader, "fade_all_completed")


func _on_fade_all_completed():
	is_active = false
	emit_signal("fade_all_completed")
