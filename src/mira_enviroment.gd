extends Node2D

const MENU_OFFSET = Vector2(10, -138)

var menu_scene: PackedScene = preload("res://src/menu.tscn")
var menu: Window

@onready var mira: RigidBody2D = get_node("Mira")
@onready var camera: Camera2D = get_node("Camera2D")

func _ready():
	mira.connect("menu_opened", on_mira_menu_opened)
	mira.connect("menu_closed", on_mira_menu_closed)

func _physics_process(delta):
	# Window follow Mira 
	# +Fix glitches next to the borders of screen
	var window_size: Vector2 = get_window().size
	var new_window_pos = mira.position + Vector2(-window_size * 0.5)
	
	new_window_pos.x = clamp(new_window_pos.x, 0, Global.screen_size.x - window_size.x)
	new_window_pos.y = clamp(new_window_pos.y, 0, Global.screen_size.y - window_size.y)
	
	camera.position = new_window_pos
	get_window().position = new_window_pos
	# Sync camera, so window doesn't affect on view of
	# of world elemets, which are pinned to screen, not to the window
	# i.e. WindowKill

func on_mira_menu_opened():
	menu = menu_scene.instantiate()
	menu.position = mira.position + MENU_OFFSET
	add_child(menu)
	menu.connect("pin_pressed", on_pin_pressed)

func on_mira_menu_closed():
	remove_child(menu)

func on_pin_pressed():
	mira.change_pin()
