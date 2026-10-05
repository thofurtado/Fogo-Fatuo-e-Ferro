extends CharacterBody2D
class_name PushableCargo

@export var friction: float = 8.0

func _ready():
	add_to_group("pushable")

func _physics_process(delta):
	if velocity.length() > 2.0:
		velocity = velocity.move_toward(Vector2.ZERO, friction * 60.0 * delta)
		move_and_slide()
	else:
		velocity = Vector2.ZERO
