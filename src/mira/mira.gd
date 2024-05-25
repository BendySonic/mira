class_name Mira
extends RigidBody2D



signal menu_opened
signal menu_closed

const DRAG_SPEED = 15
const DRAG_LIMIT = 30

const MAX_SQUEEZE = 1
const MIN_SQUEEZE = 0.65

const MIN_SPEED = 5
const MAX_SPEED = 5000

const START_POSITION = Vector2(500, 500)

# Menu
var is_menu_opened := false
var is_pinned := false

# Hold
var is_hold := false
var relative_mouse_pos

# State
var is_on_floor := false
var is_playing := false

# Collisions
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var bottom_raycast: RayCast2D = get_node("Bottom")
@onready var right_raycast: RayCast2D = get_node("Right")
@onready var top_raycast: RayCast2D = get_node("Top")
@onready var left_raycast: RayCast2D = get_node("Left")

# Visuals
@onready var sprite: Node2D = get_node("Sprite")
@onready var eyes: Node2D = get_node("Sprite/Eyes")
@onready var eyes_animation: AnimationPlayer = get_node("EyesAnimationPlayer")
@onready var body_animation: AnimationPlayer = get_node("BodyAnimationPlayer")
@onready var idle_animation_timer: Timer = get_node("IdleAnimationTimer")

#Emotions
@onready var emotion_manager: EmotionManager = get_node("EmotionManager")



func _ready():
	emotion_manager.connect("feared", on_mira_feared)
	position = START_POSITION

func _integrate_forces(_state):
	gravity_scale = 0.0 if is_pinned or is_hold else 1.0

func _physics_process(delta):
	sensor(delta)
	behavior(delta)
	move(delta)
	squeeze()
	idle_animation()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					close_menu()
					hold()
			MouseButton.MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					if is_menu_opened:
						close_menu()
					else:
						open_menu()

func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				if not event.is_pressed():
					unhold()



#region Process cycle
# Get additional information about environment
func sensor(delta):
	is_on_floor = bottom_raycast.is_colliding()
	relative_mouse_pos = DisplayServer.mouse_get_position() - Vector2i(position)

# Reaction depending on environment
func behavior(delta):
	# Movement and position
	if is_hold:
		if linear_velocity.length() > 0:
			move_eyes(delta, Vector2(relative_mouse_pos).normalized() * 6.5)
	elif linear_velocity.length() > MIN_SPEED:
		move_eyes(delta, linear_velocity.normalized() * 6.5)
	
	if is_on_floor:
		move_eyes(delta, Vector2(0, 0))
	
	# Shaking
	if linear_velocity.length() > 4000:
		emotion_manager.feel(emotion_manager.Event.SCARY, 0.001)

func move(delta):
	if is_hold:
		if relative_mouse_pos.length() > DRAG_LIMIT:
			linear_velocity = (Vector2(relative_mouse_pos) * DRAG_SPEED).limit_length(MAX_SPEED)
		else:
			linear_velocity = Vector2(0, 0)

func squeeze():
	if is_hold:
		# TODO: Kinda bad code, fix this
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

func unsqueeze():
	sprite.scale = Vector2(1, 1)
#endregion



#region Hold
func hold():
	stop_idle_animation()
	is_hold = true

func unhold():
	unsqueeze()
	is_hold = false
#endregion



#region Animation
func move_eyes(delta, position):
	eyes.position = eyes.position.move_toward(position, delta * 40)

func on_mira_feared():
	eyes_animation.play("eyes/feared_1")
	is_playing = true

func idle_animation():
	if is_on_floor and not is_playing and not is_hold:
		idle_animation_timer.wait_time = randi_range(3, 12)
		idle_animation_timer.start()
		is_playing = true
		body_animation.play("body/idle")
		eyes_animation.play("eyes/idle")

func _on_animation_timer_timeout():
	var animation_index = str(randi_range(1, 2))
	is_playing = true
	eyes_animation.stop()
	eyes_animation.play("eyes/eyes_" + animation_index)

func _on_eyes_animation_player_animation_finished(anim_name):
	is_playing = false

func stop_idle_animation():
	is_playing = false
	idle_animation_timer.stop()
	eyes_animation.stop()
	body_animation.stop()
#endregion



#region Menu
func open_menu():
	if not is_menu_opened:
		menu_opened.emit()
		is_menu_opened = true

func close_menu():
	if is_menu_opened:
		menu_closed.emit()
		is_menu_opened = false
#endregion



#region Public
func change_pin():
	is_pinned = not is_pinned
	close_menu()

func get_size():
	return collision_shape.shape.size
#endregion


