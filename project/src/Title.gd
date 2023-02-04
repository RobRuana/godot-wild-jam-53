class_name Title
extends Sprite


export var dissolve_duration: float = 0.8
export (float, 0.0, 1.0) var dissolve_progress: float = 0.0 setget set_dissolve_progress


func set_dissolve_progress(value: float):
	dissolve_progress = value
	material.set_shader_param("progress", value)


func dissolve():
	$Tween.interpolate_property(self, "dissolve_progress", null, 1.0, dissolve_duration, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
