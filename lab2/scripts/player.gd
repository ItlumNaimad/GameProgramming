extends CharacterBody2D

const SPEED = 300.0
var can_laser: bool = true
signal laser(pos)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	
	move_and_slide()
	
	# shoting input
	if Input.is_action_pressed("primary_action") and can_laser:
		#randomly selected a markerd 2D for shoting lasers
d		var laser_markers = $LaserStartPosition.get_children()
		var selected_laser = laser_markers[randi() % laser_markers.size()]
		can_laser=false
		$Timer.start()
		laser.emit(selected_laser.global_position)
