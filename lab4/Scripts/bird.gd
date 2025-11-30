extends RigidBody2D

@export var jump_force = -500.0

# ZMIEŃ WARTOŚĆ: Tutaj dajemy np. 5.0 do 10.0. 
# To oznacza "przesuwaj się o 10% dystansu w każdej klatce".
# Nie dawaj tu dużych liczb typu 100 czy 400!
@export var rotation_speed = 0.1

var game_started = false

func _ready():
	freeze = true 
	# Upewnij się, że w Inspektorze "Lock Rotation" jest zaznaczone!

func _input(event):
	if event.is_action_pressed("jump"):
		if not game_started:
			start_game()
		jump()

func start_game():
	game_started = true
	freeze = false 

func jump():
	linear_velocity.y = 0
	apply_impulse(Vector2(0, jump_force))
	
	# Skok = natychmiast w górę (-30 stopni)
	rotation_degrees = -30.0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not game_started:
		return

	# Logika spadania
	if linear_velocity.y > 0:
		# SPADANIE:
		# Chcemy przejść z -30 (góra) do +90 (dół).
		# Minus zamieni się w plus płynnie, przechodząc przez zero.
		# Waga (trzeci parametr) musi być mała (np. 10 * 0.016 = 0.16), żeby było płynnie.
		#print(rotation_speed * delta)
		#print(rotation_degrees)
		#if randi_range(0, 15) < 3:
		#	angular_velocity += 0.1
		#state.apply_torque_impulse(rotation_speed)
		rotation_degrees = lerp(rotation_degrees, 90.0, rotation_speed)
	else:
		# WZNOSZENIE:
		# Trzymamy -30.
		if rotation_degrees > -30.0:
			rotation_degrees = -30.0
			
func _on_body_entered(body):
	if body.is_in_group("obstacles"):
		get_tree().reload_current_scene()
