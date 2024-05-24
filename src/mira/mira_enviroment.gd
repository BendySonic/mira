extends Node2D


const MENU_OFFSET = Vector2(0, -32)

var menu_scene: PackedScene = preload("res://src/mira/menu.tscn")
var menu: Window
var launcher_scene: PackedScene = preload("res://src/launcher/launcher.tscn")
var launcher: Window

@onready var mira: RigidBody2D = get_node("Mira")
@onready var camera: Camera2D = get_node("Camera2D")


func _ready():
	mira.connect("menu_opened", on_mira_menu_opened)
	mira.connect("menu_closed", on_mira_menu_closed)

func _physics_process(_delta):
	update_view()

func update_view():
	# Window follow Mira 
	# +Fix glitches next to the borders of screen
	var window_size: Vector2 = get_window().size
	# Offset to set Mira to center of window
	var new_window_pos = mira.position + Vector2(-window_size * 0.5)
	
	new_window_pos.x = clamp(new_window_pos.x, 0, Global.screen_size.x - window_size.x)
	new_window_pos.y = clamp(new_window_pos.y, 0, Global.screen_size.y - window_size.y)
	
	# Sync camera, so window doesn't affect on view of
	# of world elemets, which are pinned to screen, not to the window
	# i.e. WindowKill
	camera.position = new_window_pos
	get_window().position = new_window_pos



#region Menu
func on_mira_menu_opened():
	menu = menu_scene.instantiate()
	menu.position = mira.position - Vector2(menu.size) + Vector2(menu.size.x, 0) + MENU_OFFSET
	menu.connect("activities_pressed", on_activities_pressed)
	menu.connect("pin_pressed", on_menu_pin_pressed)
	menu.connect("launcher_pressed", on_menu_launcher_pressed)
	add_child(menu)

func on_mira_menu_closed():
	menu.queue_free()

func on_activities_pressed():
	pass

func on_menu_pin_pressed():
	mira.change_pin()

func on_menu_launcher_pressed():
	launcher = launcher_scene.instantiate()
	add_child(launcher)
#endregion
