extends CanvasLayer

@onready var score_label = $HUD/ScoreLabel
@onready var speed_label = $HUD/SpeedLabel
@onready var start_screen = $StartScreen
@onready var game_over_screen = $GameOverScreen
@onready var final_score_label = $GameOverScreen/FinalScore
@onready var hud = $HUD

func _ready():
	get_parent()
	$StartScreen/StartButton.pressed.connect(_on_start_pressed)
	$GameOverScreen/RestartButton.pressed.connect(_on_restart_pressed)

func show_start_screen():
	start_screen.visible = true
	game_over_screen.visible = false
	hud.visible = false

func hide_all_screens():
	start_screen.visible = false
	game_over_screen.visible = false
	hud.visible = true

func show_game_over(score: int):
	game_over_screen.visible = true
	hud.visible = false
	final_score_label.text = "SCORE: " + str(score)

func update_score(score: int):
	score_label.text = str(score)

func update_speed(spd: int):
	speed_label.text = "SPD " + str(spd)

func _on_start_pressed():
	get_parent().start_game()

func _on_restart_pressed():
	get_parent().start_game()
	game_over_screen.visible = false
	hud.visible = true
