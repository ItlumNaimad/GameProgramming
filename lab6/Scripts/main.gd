extends Node

enum State {
	MENU,
	PLAYING,
	GAME_OVER
}

var current_state = State.MENU
var score = 0
var best_score = 0 # Zmienna na najlepszy wynik

# Zamiast referencji do Labela, bierzemy referencję do całego skryptu UI
@onready var ui = $UI 
@onready var bird = $Bird
@onready var pipe_timer = $PipeSpawner/Timer

func _ready():
	# Łączymy sygnały z ptaka
	bird.player_died.connect(_on_game_over)
	bird.game_started.connect(_on_game_started)
	
	# Connect signals for ads
	ui.watch_ad_pressed.connect(_on_watch_ad_requested)
	if Engine.has_singleton("AdsManager"):
		var ads_manager = Engine.get_singleton("AdsManager")
		ads_manager.reward_earned.connect(continue_game_after_ad)
		ads_manager.show_banner()

func add_point():
	score += 1
	ui.update_score(score) 

func _on_game_started():
	current_state = State.PLAYING
	score = 0
	ui.show_game_play()
	pipe_timer.start()
	if Engine.has_singleton("AdsManager"):
		Engine.get_singleton("AdsManager").hide_banner()

func _on_game_over():
	current_state = State.GAME_OVER
	pipe_timer.stop()
	
	get_tree().call_group("obstacles", "set_process", false)
	
	if score > best_score:
		best_score = score
	
	await get_tree().create_timer(0.5).timeout
	ui.show_game_over(score, best_score)
	
	if Engine.has_singleton("AdsManager"):
		var ads_manager = Engine.get_singleton("AdsManager")
		ads_manager.game_count += 1
		if ads_manager.game_count % 3 == 0:
			ads_manager.show_interstitial()
		ads_manager.show_banner()

func _on_watch_ad_requested():
	if Engine.has_singleton("AdsManager"):
		Engine.get_singleton("AdsManager").show_rewarded()

func continue_game_after_ad():
	print("Kontynuujemy grę!")
	
	# 1. Usuń stare przeszkody
	get_tree().call_group("obstacles", "queue_free")
	
	# 2. Reset ptaka
	bird.reset_for_continue()
	
	# 3. Przywrócenie stanu gry
	current_state = State.PLAYING 
	
	# 4. UI i Timer
	ui.show_game_play()
	pipe_timer.start()
