class_name Mira
extends RigidBody2D



signal menu_opened
signal menu_closed

signal music_on

enum State {FLY, IDLE, HOLD, PET, DJ}

const DRAG_SPEED = 15
const DRAG_LIMIT = 30

const MAX_SQUEEZE = 1
const MIN_SQUEEZE = 0.65

const MIN_SPEED = 5
const MAX_SPEED = 5000

const START_POSITION = Vector2(500, 500)

const PET_ZONE = Rect2(Vector2(-32, -32), Vector2(64, 32))
const PET_SPEED = 0.02
const PET_MIN = 0.8

# State machine
var state: State = State.FLY

# Menu
var is_menu_opened := false
var is_pinned := false

# Sensor
var relative_mouse_pos_0 := Vector2(0, 0)
var relative_mouse_pos := Vector2(0, 0)
var is_on_floor := false
var pet_indicator: float # 0.0-1.0

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
@onready var pet_timer: Timer = get_node("PetTimer")
@onready var eyes_move_timer: Timer = get_node("EyesMoveTimer")

#Emotions
@onready var emotion_manager: EmotionManager = get_node("EmotionManager")



func _ready():
	emotion_manager.connect("feared", on_mira_feared)
	position = START_POSITION

func _integrate_forces(_state):
	gravity_scale = 0.0 if is_pinned or is_state(State.HOLD) else 1.0

func _physics_process(delta):
	sensor(delta)
	behavior(delta)
	move(delta)
	squeeze()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					close_menu()
					hold()
			MouseButton.MOUSE_BUTTON_RIGHT:
				if event.is_pressed() and is_state(State.IDLE):
					if is_menu_opened:
						close_menu()
					else:
						open_menu()

func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				if not event.is_pressed() and is_state(State.HOLD):
					unhold()



#region State
func set_state(state: State):
	if self.state == state:
		return
	
	self.state = state
	if is_state(State.IDLE):
		move_eyes_queue(0.05, Vector2(0, 0))
		idle_animation_timer.start()
		eyes_move_timer.start()
		body_animation.play("body/idle_1")
		eyes_animation.play("eyes/idle_1")
	else:
		idle_animation_timer.stop()
		if is_state(State.HOLD):
			eyes_animation.play("eyes/reset")
			body_animation.play("body/reset")
		elif is_state(State.PET):
			body_animation.play("body/pet")
			eyes_animation.play("eyes/pet")
		elif is_state(State.DJ):
			body_animation.play("body/DJ")
			eyes_animation.play("eyes/DJ")
			music_on.emit()
			await eyes_animation.animation_finished
			body_animation.play("body/DJ_dance_1")

func is_state(state: State):
	return self.state == state
#endregion



#region Process cycle
# Get additional information about environment
func sensor(delta):
	is_on_floor = bottom_raycast.is_colliding()
	relative_mouse_pos_0 = relative_mouse_pos
	relative_mouse_pos = DisplayServer.mouse_get_position() - Vector2i(position)
	
	if is_on_floor and is_state(State.FLY):
		set_state(State.IDLE)
	
	if (
			PET_ZONE.has_point(relative_mouse_pos)
			and not (relative_mouse_pos - relative_mouse_pos_0).length() == 0
	):
		pet()

# Reaction depending on environment
func behavior(delta):
	# Movement and position
	if is_state(State.HOLD):
		if linear_velocity.length() > 0:
			move_eyes(delta, Vector2(relative_mouse_pos).normalized() * 6.5)
	elif linear_velocity.length() > MIN_SPEED:
		move_eyes(delta, linear_velocity.normalized() * 6.5)
	
	# Shaking
	if linear_velocity.length() > 4000:
		emotion_manager.feel(emotion_manager.Event.SCARY, 0.001)

# Move Mira durning hold
func move(delta):
	if is_state(State.HOLD):
		if relative_mouse_pos.length() > DRAG_LIMIT:
			linear_velocity = (Vector2(relative_mouse_pos) * DRAG_SPEED).limit_length(MAX_SPEED)
		else:
			linear_velocity = Vector2(0, 0)

# Squeeze Mira next to the screen borders
func squeeze():
	if is_state(State.HOLD):
		# TODO: Kinda bad code, fix this pls
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



#region Animation
# Move eyes by process
func move_eyes(delta, position):
	eyes.position = eyes.position.move_toward(position, delta * 40)

# Move eyes by "one signal"
func move_eyes_queue(delta, position):
	for i in range(0, 120):
		move_eyes(delta, position)
		if eyes.position == position:
			break
		await get_tree().physics_frame

func _on_eyes_move_timer_timeout():
	move_eyes_queue(0.05, Vector2(randi_range(-5, 5), randi_range(-5, 5)))
	eyes_move_timer.start()

# Special
func on_mira_feared():
	eyes_animation.play("eyes/feared_1")

func _on_eyes_animation_player_animation_finished(anim_name):
	if is_state(State.IDLE):
		eyes_animation.play("eyes/idle_1")
		idle_animation_timer.wait_time = randi_range(4, 7)
		idle_animation_timer.start()

func _on_idle_animation_timer_timeout():
	var animation_index = str(randi_range(2, 6))
	eyes_animation.play("eyes/idle_" + animation_index)
#endregion



#region Hold
func hold():
	if not is_state(State.DJ):
		set_state(State.HOLD)

func unhold():
	unsqueeze()
	set_state(State.FLY)
#endregion



#region Pet
func pet():
	if is_state(State.IDLE):
		pet_indicator += PET_SPEED
		pet_indicator = clamp(pet_indicator, 0.0, 1.0)
		pet_timer.start()
		if pet_indicator > PET_MIN:
			set_state(State.PET)

func _on_pet_timer_timeout():
	if is_state(State.PET) or is_state(State.IDLE):
		pet_indicator = 0.0
		set_state(State.IDLE)
		
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
func turn_on_dj():
	set_state(State.DJ)

func change_pin():
	is_pinned = not is_pinned
	close_menu()

func get_size():
	return collision_shape.shape.size
#endregion



