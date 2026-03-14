extends Node3D

var score: float = 0.0
var speed: float = 8.0
var max_speed: float = 25.0
var speed_increase: float = 0.003
var is_running: bool = false
var is_game_over: bool = false

const LANES = [-2.5, 0.0, 2.5]

var spawn_timer: float = 0.0
var tiles: Array = []
const TILE_LENGTH: float = 20.0
const TILES_AHEAD: int = 7

var touch_start: Vector2 = Vector2.ZERO
var is_touching: bool = false
const SWIPE_THRESHOLD: float = 50.0

@onready var player = $Player
@onready var ui = $UI

func _ready():
	_spawn_initial_tiles()
	ui.show_start_screen()

func _spawn_initial_tiles():
	for i in range(TILES_AHEAD):
		_spawn_tile(i * TILE_LENGTH)

func _spawn_tile(z_pos: float):
	var tile = preload("res://Tile.tscn").instantiate()
	add_child(tile)
	tile.position.z = -z_pos
	tiles.append(tile)

func _process(delta: float):
	if not is_running:
		return

	speed = min(speed + speed_increase, max_speed)
	score += speed * delta

	_move_world(delta)
	_recycle_tiles()

	spawn_timer -= delta
	if spawn_timer <= 0:
		_spawn_obstacle_or_coin()
		spawn_timer = 1.8 * (8.0 / speed)

	ui.update_score(int(score))
	ui.update_speed(int(speed * 10))

func _move_world(delta: float):
	for child in get_children():
		if child == player or child.name == "DirectionalLight3D" or child.name == "NeonLight" or child.name == "Camera3D" or child.name == "UI":
			continue
		if child is Node3D:
			child.position.z += speed * delta
			if child.position.z > 15:
				child.queue_free()
				if child in tiles:
					tiles.erase(child)

func _recycle_tiles():
	var furthest_z: float = 0.0
	for tile in tiles:
		if is_instance_valid(tile):
			if tile.position.z < furthest_z:
				furthest_z = tile.position.z
	while furthest_z > -(TILES_AHEAD * TILE_LENGTH):
		furthest_z -= TILE_LENGTH
		_spawn_tile(-furthest_z)

func _spawn_obstacle_or_coin():
	var lane = randi() % 3
	if randf() < 0.6:
		var obs = preload("res://Obstacle.tscn").instantiate()
		add_child(obs)
		obs.position = Vector3(LANES[lane], 0, -30)
	else:
		var coin = preload("res://Coin.tscn").instantiate()
		add_child(coin)
		coin.position = Vector3(LANES[lane], 1.0, -30)

func start_game():
	is_running = true
	is_game_over = false
	score = 0.0
	speed = 8.0
	player.reset()
	ui.hide_all_screens()

func game_over():
	if is_game_over:
		return
	is_game_over = true
	is_running = false
	ui.show_game_over(int(score))

func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			is_touching = true
		else:
			is_touching = false
	elif event is InputEventScreenDrag:
		if is_touching:
			var diff = event.position - touch_start
			if diff.length() > SWIPE_THRESHOLD:
				if abs(diff.x) > abs(diff.y):
					if diff.x > 0:
						player.move_right()
					else:
						player.move_left()
				else:
					if diff.y < 0:
						player.jump()
					else:
						player.slide()
				touch_start = event.position
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT: player.move_left()
			KEY_RIGHT: player.move_right()
			KEY_UP, KEY_SPACE: player.jump()
			KEY_DOWN: player.slide()
			KEY_ENTER:
				if not is_running:
					start_game()
