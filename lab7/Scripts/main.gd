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
	
	# Connect signals from the UI
	ui.watch_ad_pressed.connect(_on_watch_ad_requested)
	
	# Initialize and show banner ad
	if Engine.has_singleton("AdsManager"):
		var ads_manager = Engine.get_singleton("AdsManager")
		ads_manager.show_banner()

func add_point():
	score += 1
	ui.update_score(score) 

func _on_game_started():
	current_state = State.PLAYING
	score = 0
	ui.show_game_play()
	pipe_timer.start()
	
	# Hide banner during gameplay
	if Engine.has_singleton("AdsManager"):
		Engine.get_singleton("AdsManager").hide_banner()

func _on_game_over():
	current_state = State.GAME_OVER
	pipe_timer.stop()
	
	# Stop pipes (assuming they are in the "obstacles" group)
	get_tree().call_group("obstacles", "set_process", false)
	
	if score > best_score:
		best_score = score
	
	await get_tree().create_timer(0.5).timeout
	ui.show_game_over(score, best_score)
	
	if Engine.has_singleton("AdsManager"):
		var ads_manager = Engine.get_singleton("AdsManager")
		# Increment death count and potentially show interstitial
		ads_manager.on_player_died()
		# Show banner again on game over screen
		ads_manager.show_banner()

# Called when the "Watch Ad to Continue" button is pressed in the UI
func _on_watch_ad_requested():
	if Engine.has_singleton("AdsManager"):
		# Request to show rewarded ad, passing continue_game as the callback
		Engine.get_singleton("AdsManager").show_rewarded_ad(Callable(self, "continue_game"))

# This function implements the resurrection logic after a rewarded ad is watched
func continue_game():
	print("Main: Resuming game after rewarded ad!")
	
	# 1. Usuń stare przeszkody
	get_tree().call_group("obstacles", "queue_free")
	
	# 2. Reset bird position and velocity
	bird.reset_for_continue() # Assuming bird.gd has this function
	
	# 3. Przywrócenie stanu gry
	current_state = State.PLAYING 
	
	# 4. Update UI and restart pipe timer
	ui.show_game_play()
	pipe_timer.start()
	
	# Hide banner during resumed gameplay
	if Engine.has_singleton("AdsManager"):
		Engine.get_singleton("AdsManager").hide_banner()
