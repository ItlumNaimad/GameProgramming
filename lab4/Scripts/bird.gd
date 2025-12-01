extends RigidBody2D

signal player_died
signal game_started

@export var jump_force = -500.0

# ZMIEŃ WARTOŚĆ: Tutaj dajemy np. 5.0 do 10.0. 
# To oznacza "przesuwaj się o 10% dystansu w każdej klatce".
# Nie dawaj tu dużych liczb typu 100 czy 400!
@export var rotation_speed = 0.08

var is_game_started = false
var is_dead = false # Flaga oznaczająca stan śmierci ptaka

func _ready():
	freeze = true
	if ready:
		rotation_degrees = 0
	# Upewnij się, że w Inspektorze "Lock Rotation" jest zaznaczone!

func _input(event):
	# Pozwól na skok tylko, jeśli ptak nie jest martwy
	if event.is_action_pressed("jump") and not is_dead:
		if not is_game_started:
			start_game()
		jump()

func start_game():
	is_game_started = true
	freeze = false
	game_started.emit()

func jump():
	linear_velocity.y = 0
	apply_impulse(Vector2(0, jump_force))
	
	# Skok = natychmiast w górę (-30 stopni)
	rotation_degrees = -30.0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not is_game_started:
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
		rotation_degrees = lerp(rotation_degrees, 50.0, rotation_speed/2)
	else:
		# WZNOSZENIE:
		# Trzymamy -30.
		if rotation_degrees > -30.0:
			rotation_degrees = lerp(rotation_degrees,-40.0, rotation_speed*1.6)
			
func _on_body_entered(body):
	# Sprawdzamy, czy ptak już nie jest martwy, aby uniknąć wielokrotnego wywołania
	if body.is_in_group("obstacles") and not is_dead:
		is_dead = true # Ustawiamy flagę śmierci
		player_died.emit()
		$CollisionShape2D.set_deferred("disabled", true)
