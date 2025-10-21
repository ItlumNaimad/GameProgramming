extends CharacterBody2D

# Te zmienne pojawią się w inspektorze
@export var speed = 400
@export var up_action = "ui_up"
@export var down_action = "ui_down"

# WAŻNE: Ustaw wysokość paletki w edytorze,
# aby clamp działał poprawnie.
@export var paddle_height = 32

var screen_size_y = 0

func _ready():
	add_to_group("paddles")
	# Pobieramy wysokość ekranu raz, na starcie (wydajniejsze)
	screen_size_y = get_viewport_rect().size.y

func _physics_process(delta):
	# 1. Pobierz input (Twoja wersja z if/elif też jest OK!)
	var direction = Input.get_axis(up_action, down_action)
	
	# 2. Oblicz nową, docelową pozycję Y
	var new_y = global_position.y + (direction * speed * delta)
	
	# 3. OGRANICZ docelową pozycję ZANIM się ruszymy
	var clamped_y = clamp(new_y, paddle_height / 2, screen_size_y - (paddle_height / 2))
	
	# 4. Oblicz wektor ruchu (motion) do tej ograniczonej pozycji
	#    (Różnica między tym, gdzie chcemy być, a tym, gdzie jesteśmy)
	var motion = Vector2(0, clamped_y - global_position.y)
	
	# 5. Użyj move_and_collide, aby fizycznie wykonać ruch
	move_and_collide(motion)
	
	# 6. Zaktualizuj 'velocity' na użytek piłki (dla podkręcenia)
	#    To jest kluczowe, aby piłka wiedziała, jak szybko się ruszaliśmy
	if delta > 0:
		velocity = motion / delta
	else:
		velocity = Vector2.ZERO
