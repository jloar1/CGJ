extends Control


export var mainGameScene : PackedScene


func _on_Start_button_up():
	get_tree().change_scene(mainGameScene.resource_path)
