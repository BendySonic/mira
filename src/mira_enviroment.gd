extends Node2D

@onready var mira: RigidBody2D = get_node("Mira")
@onready var camera: Camera2D = get_node("Camera2D")

func _physics_process(delta):
	# Window follow Mira 
	# +Fix glitches next to the borders of screen
	var new_window_pos = mira.position - mira.get_size()
	var window_size = get_window().size
	
	new_window_pos.x = clamp(new_window_pos.x, 0, Global.screen_size.x - window_size.x - 4)
	new_window_pos.y = clamp(new_window_pos.y, 0, Global.screen_size.y - window_size.y - 4)
	
	DisplayServer.window_set_position(new_window_pos)
	
	# Sync camera, so window doesn't affect on view of
	# of world elemets, which are pinned to screen, not to the window
	# i.e. WindowKill
	camera.position = DisplayServer.window_get_position()
	
	# PIN: Maybe I can make this stuff much better.
	#      So, you can fix this, thank you ^_^


func _on_mira_body_entered(body):
	print("OK")
