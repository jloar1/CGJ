extends Control

export var mainGameSceneReplay : PackedScene
export var mainMenu : PackedScene


func _on_Replay_button_up():
	get_tree().change_scene(mainGameSceneReplay.resource_path)


func _on_ReturnMainMenu_button_up():
	get_tree().change_scene(mainMenu.resource_path)
