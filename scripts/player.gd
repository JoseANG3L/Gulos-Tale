extends CharacterBody2D

@export var max_speed : int = 1000
@export var gravity : float = 100
@export var jump_force : int = 1600
@export var jump_buffer_time : int  = 15
@export var cayote_time : int = 15
@export var platform_offset : float = 18
@export var platform_position_offset : float = 6
@export var object_offset : float = 35

@onready var tilemap = $"../Map/TileMap2"
@onready var object_raycast = $"ObjectDetector"

var bubble = preload("res://objects/bubble.tscn")

var jump_buffer_counter : int = 0
var cayote_counter : int = 0
var forward : int = 1
var drop_bubble : bool = true
var pickup : bool = false
	
func _physics_process(delta):
	
	# var is_on_platform = platform_raycast.is_colliding() or platform_raycast2.is_colliding()
	
	var is_on_platform = is_on_floor()
	
	if is_on_platform:
		cayote_counter = cayote_time

	if not is_on_platform:
		if cayote_counter > 0:
			cayote_counter -= 1
		
		velocity.y += gravity * delta
		#if velocity.y > 2000:
			#velocity.y = 2000

	if Input.is_action_pressed("right"):
		velocity.x = max_speed
		$Sprite.flip_h = false
		forward = 1

	elif Input.is_action_pressed("left"):
		velocity.x = -max_speed
		$Sprite.flip_h = true
		forward = -1

	else:
		velocity.x = 0
	
	#velocity.x = clamp(velocity.x, -max_speed, max_speed)
	#
	if Input.is_action_just_pressed("jump"):
		jump_buffer_counter = jump_buffer_time
	
	if jump_buffer_counter > 0:
		jump_buffer_counter -= 1
	
	if jump_buffer_counter > 0 and cayote_counter > 0:
		velocity.y = -jump_force
		jump_buffer_counter = 0
		cayote_counter = 0
	#
	if Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y = -60
			
	move_and_slide()

	var char_pos = tilemap.local_to_map(global_position)
	var pos = tilemap.map_to_local(Vector2i(char_pos.x + forward, char_pos.y))
	var posup = tilemap.map_to_local(Vector2i(char_pos.x, char_pos.y - 1))
	object_raycast.target_position = Vector2(object_offset * forward, 0)
	
	if Input.is_action_pressed("bubble"):
		if drop_bubble and not object_raycast.is_colliding():
			spawn_bubble(pos)
			drop_bubble = false
	if Input.is_action_just_released("bubble"):
		drop_bubble = true
		
	if Input.is_action_pressed("bubblehit"):
		if drop_bubble and not object_raycast.is_colliding():
			spawn_bubble2(posup, forward)
			drop_bubble = false
		
	if Input.is_action_just_released("bubblehit"):
		drop_bubble = true
		
		
func spawn_bubble(pos):
	var b = bubble.instantiate()
	b.global_position = pos
	b.freeze = true
	b.gravity_scale = 0.5
	owner.add_child(b)

func spawn_bubble2(pos, forward):
	if pickup:
		var b = get_child(-1)
		b.throw(forward)
		pickup = false
	else:
		var b = bubble.instantiate()
		b.picked = true
		#b.apply_impulse(Vector2(150 * forward, -160), Vector2(0, 0))
		add_child(b)
		pickup = true
	
