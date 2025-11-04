extends CharacterBody2D

# --- Ustawienia Gracza ---
@export var speed = 300.0

# --- Ustawienia Ataku ---
# Ta zmienna kontroluje, czy możemy strzelić (cooldown)
@export var can_shoot: bool = true

# Sygnał emituje pozycję startową ORAZ kierunek strzału
# To jest kluczowa zmiana w porównaniu do Twojego kodu.
signal shoot(spawn_position, direction)

# Referencja do Timera (przeciągnij w edytorze lub użyj @onready)
@onready var shoot_cooldown_timer = $Timer 
# Referencja do miejsca, skąd wylatuje pocisk
@onready var bullet_spawn_point = $BulletSpawn 

func _ready():
	# Łączymy sygnał 'timeout' Timera z funkcją, która resetuje cooldown
	# To jest standardowy sposób na używanie Timera jako licznika "rate of fire"
	shoot_cooldown_timer.connect("timeout", _on_shoot_cooldown_timer_timeout)


func _physics_process(delta: float) -> void:
	# --- RUCH (WASD) ---
	# Upewnij się, że w Ustawienia -> Mapa Wejść masz akcje:
	# "move_up" (W), "move_down" (S), "move_left" (A), "move_right" (D)
	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_direction * speed
	move_and_slide()

	# --- ATAK (STRZAŁKI) ---
	# Upewnij się, że w Ustawienia -> Mapa Wejść masz akcje:
	# "attack_up" (Strzałka w górę), "attack_down" (w dół), "attack_left" (w lewo), "attack_right" (w prawo)
	var attack_direction = Input.get_vector("attack_left", "attack_right", "attack_up", "attack_down")

	# Sprawdź, czy gracz trzyma przycisk ataku I czy minął cooldown
	if attack_direction != Vector2.ZERO and can_shoot:
		
		# 1. Zablokuj możliwość strzelania (rozpoczynamy cooldown)
		can_shoot = false
		
		# 2. Uruchom timer cooldownu
		shoot_cooldown_timer.start()
		
		# 3. Pobierz pozycję, skąd strzelamy
		var spawn_pos = bullet_spawn_point.global_position
		
		# 4. Wyemituj sygnał z pozycją ORAZ kierunkiem
		# Twój główny skrypt (np. stage.gd) będzie musiał to odebrać
		shoot.emit(spawn_pos, attack_direction)


# Ta funkcja jest automatycznie wywoływana, gdy Timer dobiegnie końca
func _on_shoot_cooldown_timer_timeout():
	can_shoot = true # Gracz może znowu strzelać
