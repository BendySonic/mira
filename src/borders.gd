extends CharacterBody2D



@onready var left: CollisionShape2D = get_node("Left")
@onready var top: CollisionShape2D = get_node("Top")
@onready var right: CollisionShape2D = get_node("Right")
@onready var bottom: CollisionShape2D = get_node("Bottom")

func _ready():
	print("Border")
	left.position = Vector2(-100, Global.screen_size.y / 2)
	left.shape.size = Vector2(200, Global.screen_size.y)
	top.position = Vector2(Global.screen_size.x / 2, -100)
	top.shape.size = Vector2(Global.screen_size.x, 200)
	right.position = Vector2(Global.screen_size.x + 100, Global.screen_size.y / 2)
	right.shape.size = Vector2(200, Global.screen_size.y)
	bottom.position = Vector2(Global.screen_size.x / 2, Global.screen_size.y + 100)
	bottom.shape.size = Vector2(Global.screen_size.x, 200)
	
	
