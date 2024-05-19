extends RigidBody2D


const DRAG_SPEED = 20
const DRAG_LIMIT = 20
const MAX_SQUEEZE = 1
const MIN_SQUEEZE = 0.65
const MAX_SPEED = 5000

var is_hold := false
var relative_mouse_pos

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var bottom_raycast: RayCast2D = get_node("Bottom")
@onready var right_raycast: RayCast2D = get_node("Right")
@onready var top_raycast: RayCast2D = get_node("Top")
@onready var left_raycast: RayCast2D = get_node("Left")


func _physics_process(delta):
	move()
	squeeze()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			hold()

func _input(event):
	if event is InputEventMouseButton:
		if not event.is_pressed():
			unhold()

func hold():
	gravity_scale = 0
	is_hold = true

func unhold():
	gravity_scale = 1
	is_hold = false

func move():
	relative_mouse_pos = DisplayServer.mouse_get_position() - Vector2i(position)
	
	if is_hold:
		if relative_mouse_pos.length() > DRAG_LIMIT:
			linear_velocity = (Vector2(relative_mouse_pos) * DRAG_SPEED).limit_length(MAX_SPEED)
		else:
			linear_velocity = Vector2(0, 0)

func squeeze():
	if is_hold:
		if bottom_raycast.is_colliding():
			var scale0 = 1 - float(relative_mouse_pos.y) / 32
			sprite.scale.y = clamp(scale0, MIN_SQUEEZE, MAX_SQUEEZE)
			sprite.position.y = (1 - sprite.scale.y) * 64 / 2
		if right_raycast.is_colliding():
			var scale0 = 1 - float(relative_mouse_pos.x) / 32
			sprite.scale.x = clamp(scale0, MIN_SQUEEZE, MAX_SQUEEZE)
			sprite.position.x = (1 - sprite.scale.x) * 64 / 2
		if top_raycast.is_colliding():
			var scale0 = 1 + float(relative_mouse_pos.y) / 32
			sprite.scale.y = clamp(scale0, MIN_SQUEEZE, MAX_SQUEEZE)
			sprite.position.y = -(1 - sprite.scale.y) * 64 / 2
		if left_raycast.is_colliding():
			var scale0 = 1 + float(relative_mouse_pos.x) / 32
			sprite.scale.x = clamp(scale0, MIN_SQUEEZE, MAX_SQUEEZE)
			sprite.position.x = -(1 - sprite.scale.x) * 64 / 2

func get_squeeze_direction():
	pass

func show_menu():
	pass

func hide_menu():
	pass



func get_size():
	return collision_shape.shape.size
