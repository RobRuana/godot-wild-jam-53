class_name SwitchRootSceneButton
extends Button


export var scene: String


func _ready():
	connect("pressed", self, "_on_button_pressed")


func _on_button_pressed():
	SceneManager.change_root_scene(scene)
