extends CharacterBody2D

var player: Node2D

@onready var body_anim: AnimatedSprite2D = $body

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
	velocity = Vector2.ZERO
	$CollisionShape2D.disabled = true
	
	# 2. Tutaj możesz uruchomić animację śmierci
	body_anim.play("death")
	await body_anim.animation_finished
	# 3. Zniszcz obiekt po zakończeniu animacji
	queue_free()
