extends Node3D

const LANES = [-2.5, 0.0, 2.5]
var current_lane: int = 1
var target_x: float = 0.0
var lane_switch_speed: float = 12.0

var is_jumping: bool = false
var is_sliding: bool = false
var jump_velocity: float = 0.0
var gravity: float = -20.0
const JUMP_FORCE: float = 10.0
var base_y: float = 0.5

var slide_timer: float = 0.0
const SLIDE_DURATION: float = 0.8

var invincible: bool = false
var invincible_timer: float = 0.0

@onready var body = $Body
@onready var glow = $NeonGlow

func _ready():
	target_x = LANES[current_lane]
	# Build player mesh
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.4
	mesh.height = 1.6
	body.mesh = mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 0.9, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.0, 1.0, 0.8)
	mat.emission_energy_multiplier = 1.5
	mat.metallic = 0.8
	body.material_override = mat
	# Collision
	var area = $CollisionArea
	var shape_node = $CollisionArea/CollisionShape3D
	var shape = CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.6
	shape_node.shape = shape
	area.area_entered.connect(_on_area_entered)

func _process(delta: float):
	position.x = lerp(position.x, target_x, lane_switch_speed * delta)

	if is_jumping:
		jump_velocity += gravity * delta
		position.y += jump_velocity * delta
		if position.y <= base_y:
			position.y = base_y
			is_jumping = false
			jump_velocity = 0.0

	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			is_sliding = false
			body.scale.y = 1.0
			body.position.y = 0.0

	if invincible:
		invincible_timer -= delta
		body.visible = fmod(invincible_timer * 10, 1.0) > 0.5
		if invincible_timer <= 0:
			invincible = false
			body.visible = true

	body.rotation.y += delta * 2.0

func move_left():
	if current_lane > 0:
		current_lane -= 1
		target_x = LANES[current_lane]

func move_right():
	if current_lane < 2:
		current_lane += 1
		target_x = LANES[current_lane]

func jump():
	if not is_jumping and not is_sliding:
		is_jumping = true
		jump_velocity = JUMP_FORCE

func slide():
	if not is_jumping and not is_sliding:
		is_sliding = true
		slide_timer = SLIDE_DURATION
		body.scale.y = 0.5
		body.position.y = -0.4

func reset():
	invincible = false
	is_jumping = false
	is_sliding = false
	current_lane = 1
	target_x = LANES[1]
	position = Vector3(0, base_y, 0)
	body.visible = true
	body.scale = Vector3.ONE
	body.position.y = 0.0

func _on_area_entered(area: Area3D):
	if area.is_in_group("obstacle"):
		if not invincible:
			invincible = true
			invincible_timer = 1.5
			get_parent().game_over()
	elif area.is_in_group("coin"):
		get_parent().score += 50
		area.get_parent().collect()
