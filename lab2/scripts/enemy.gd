extends CharacterBody2D

var player: Node2D

var speed = 200
func _ready():
	# Zakłada, że Twój gracz jest w grupie "player"
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta: float) -> void:
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
func die():
	# 1. Zatrzymaj ruch i wyłącz fizykę (odpowiednik "Static" )
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	
	# 2. Tutaj możesz uruchomić animację śmierci
	
	# 3. Zniszcz obiekt po 2 sekundach 
	# Użyj 'await' do prostej obsługi timera:
	await get_tree().create_timer(2.0).timeout
	queue_free()
