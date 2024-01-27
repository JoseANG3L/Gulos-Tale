extends RigidBody2D

var picked : bool = false

func _ready():
	if picked:
		position = get_node("../PickupPosition").position
		gravity_scale = 0
	lock_rotation = true
	
func _physics_process(delta):
	if picked:
		position = get_node("../PickupPosition").position
		get_node("CollisionShape2D").transform = position
	
func bubble_on_floor():
	await get_tree().create_timer(2.0).timeout
	queue_free()

func throw(forward):
	picked = false
	apply_impulse(Vector2(150 * forward, -160), Vector2(0, 0))
	gravity_scale = 0.5
