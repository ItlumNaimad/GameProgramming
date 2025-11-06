extends CharacterBody2D
# Sygnał śmierci gracza
signal player_died
# --- Ustawienia Gracza ---
@export var speed = 300.0

# --- Ustawienia Ataku ---
# Ta zmienna kontroluje, czy możemy strzelić (cooldown)
@export var can_shoot: bool = true

# Sygnał emituje pozycję startową ORAZ kierunek strzału
# To jest kluczowa zmiana w porównaniu do Twojego kodu.
signal shoot(spawn_position, direction)

# Pobierz referencje do obu animatorów
@onready var legs_anim = $Legs
@onready var torso_anim = $Torso

# Referencja do Timera (przeciągnij w edytorze lub użyj @onready)
@onready var shoot_cooldown_timer = $Timer 
# Referencja do miejsca, skąd wylatuje pocisk
@onready var bullet_spawn_point = $BulletSpawn 
# Zmienna do przechowywania ostatniego kierunku patrzenia
var facing_direction = Vector2.DOWN

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
	
	# --- AKTUALIZACJA ANIMACJI ---
	# Wywołaj nową funkcję do zarządzania animacjami
	update_animations(move_direction, attack_direction)
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
	
	# --- NOWY BLOK: Sprawdzanie kolizji z wrogiem ---
	# To jest odpowiednik OnCollisionEnter2D [cite: 234]
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		# Sprawdzamy, czy to, z czym się zderzyliśmy, jest wrogiem
		if collision.get_collider().is_in_group("enemies"):
			# 1. Wyemituj sygnał, że gracz zginął
			player_died.emit()
			# 2. Usuń gracza ze sceny
			queue_free()
			# Przerwij pętlę, nie musimy szukać dalszych kolizji
			break

# Ta funkcja jest automatycznie wywoływana, gdy Timer dobiegnie końca
func _on_shoot_cooldown_timer_timeout():
	can_shoot = true # Gracz może znowu strzelać

# Nowa funkcja do zarządzania obiema animacjami
func update_animations(move_dir: Vector2, attack_dir: Vector2):
	
	# === 1. LOGIKA NÓG (zależna od RUCHU) ===
	if move_dir != Vector2.ZERO:
		legs_anim.play("walk")
	else:
		legs_anim.play("idle")

	# === 2. LOGIKA TUŁOWIA (zależna od CELOWANIA) ===
	
	# Priorytet ma kierunek ataku.
	if attack_dir != Vector2.ZERO:
		facing_direction = attack_dir.normalized()
	# Jeśli nie atakujemy, patrz w kierunku ruchu.
	elif move_dir != Vector2.ZERO:
		facing_direction = move_dir.normalized()

	# Zresetuj obrót sprite'a
	torso_anim.flip_h = false

	# Używamy abs(), aby znaleźć dominującą oś (pionową czy poziomą)
	if abs(facing_direction.y) > abs(facing_direction.x):
		# Patrzymy bardziej w GÓRĘ or DÓŁ
		if facing_direction.y < 0:
			torso_anim.play("face_up")
		else:
			torso_anim.play("face_down")
	else:
		# Patrzymy bardziej w LEWO or PRAWO
		if facing_direction.x < 0:
			torso_anim.play("face_left") 
		
		elif facing_direction.x > 0:
			torso_anim.play("face_right") # Obróć ją, by patrzeć w lewo
