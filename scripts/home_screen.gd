extends Control
@onready var animation_player = $AnimationPlayer
@onready var popup = $ColorRect/popup

func _ready() -> void:
	animation_player.play("fade_in")
	popup.visible = false
	

func _on_start_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scene/clinic.tscn")
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	popup.visible = true


func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	popup.visible = false
