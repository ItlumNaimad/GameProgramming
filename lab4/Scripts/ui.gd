extends CanvasLayer

# Referencje do elementów UI
@onready var score_label: Label = $ScoreLabel
@onready var get_ready_screen = $"Info"

@onready var game_over_screen: Control = $GameOver
@onready var final_score_label = $GameOver/Panel/ScoreContainer/ScoreLabel
@onready var best_score_label = $GameOver/Panel/ScoreContainer/BestScoreLabel
@onready var medal_icon = $GameOver/Panel/Medal

# Tablica z teksturami medali 
# Kolejność: 0=Brak/Brąz, 1=Srebro, 2=Złoto, 3=Platyna (wg instrukcji PDF)
@export var medal_textures: Array[Texture2D]

func _ready():
	# Stan początkowy: Widoczne Get Ready, ukryte Game Over
	score_label.hide() # Ukrywamy licznik na czas intro
	get_ready_screen.show()
	game_over_screen.hide()

func update_score(points):
	score_label.text = str(points)

func show_game_play():
	get_ready_screen.hide()
	score_label.show()

func show_game_over(current_score, best_score):
	score_label.hide()
	game_over_screen.show()

	# Ustawiamy teksty
	final_score_label.text = str(current_score)
	best_score_label.text = str(best_score)

	# Logika Medali (tłumaczenie switch-case z PDF na GDScript) 
	var medal_index = -1

	if current_score >= 40: # Platyna (przykładowe progi)
		medal_index = 3
	elif current_score >= 30: # Złoto
		medal_index = 2
	elif current_score >= 20: # Srebro
		medal_index = 1
	elif current_score >= 10: # Brąz
		medal_index = 0

	if medal_index != -1 and medal_index < medal_textures.size():
		medal_icon.texture = medal_textures[medal_index]
		medal_icon.show()
	else:
		medal_icon.hide()

# Funkcje przycisków (podłącz sygnały pressed w edytorze!)
func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
