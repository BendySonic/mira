extends RigidBody2D


signal menu_opened
signal menu_closed

const DRAG_SPEED = 15
const DRAG_LIMIT = 30
const MAX_SQUEEZE = 1
const MIN_SQUEEZE = 0.65
const MAX_SPEED = 5000

var is_hold := false
var is_menu_opened := false
var relative_mouse_pos

var is_pinned := false

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var bottom_raycast: RayCast2D = get_node("Bottom")
@onready var right_raycast: RayCast2D = get_node("Right")
@onready var top_raycast: RayCast2D = get_node("Top")
@onready var left_raycast: RayCast2D = get_node("Left")


func _integrate_forces(state):
	gravity_scale = 0.0 if is_pinned else 1.0

func _physics_process(delta):
	move()
	squeeze()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					close_menu()
					hold()
			MouseButton.MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					is_menu_opened = not is_menu_opened
					if is_menu_opened:
						open_menu()
					else:
						close_menu()

func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
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
		# PIN: Kinda bad code
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

func open_menu():
	menu_opened.emit()

func close_menu():
	menu_closed.emit()


func change_pin():
	is_pinned = not is_pinned
	close_menu()

func get_size():
	return collision_shape.shape.size
