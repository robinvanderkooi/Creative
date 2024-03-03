extends CharacterBody2D

var acceleration = 20000
var lerp_strength = 0.1
var contact_world := true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if contact_world:
		contact_world = false
		World.set_world_position(64,64)
	World.set_local_position(self,position)
	
	var updown = Input.get_axis("move_up","move_down")
	var leftright = Input.get_axis("move_left","move_right")
	var direction := Vector2(leftright,updown)
	if direction.length() > 0: direction = direction.normalized()
	direction *= delta * acceleration
	velocity = velocity.lerp(direction,lerp_strength)
	move_and_slide()
	
	get_node("Label").text = str(position)
	
	World.set_local_position(null,position)

