extends CharacterBody2D
class_name BaseCharacter

const FALL_SCENE : String = "res://visual_effects/dust_particles/fall/fall_effect.tscn"
const JUMP_SCENE : String = "res://visual_effects/dust_particles/jump/jump_effect.tscn"

var _has_sword: bool = false
var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _jump_count: int = 0
var _on_floor: bool = true
var _attack_index: int = 1
var _air_attack_count: int = 0

@export_category("Variables")
@export var _speed: float = 200.0
@export var _jump_velocity: float = -300.0

@export_category("Objects")
@export var _character_texture: CharacterTexture
@export var _attack_combo: Timer

func _physics_process(_delta: float) -> void:
	_vertical_movement(_delta)
	_horizontal_movement()
	_attack_handler()
	move_and_slide()

	_character_texture.animate(velocity)
	
	
func _vertical_movement(_delta: float) -> void:
	if is_on_floor():
		if  _on_floor == false:
			_air_attack_count = 0
			global.spawn_effect(FALL_SCENE, Vector2(0,2),
				global_position, false)
			_character_texture.action_animation("land")
			set_physics_process(false)
			_on_floor = true
		_jump_count = 0
		
	if not is_on_floor():
		_on_floor = false
		velocity.y += _gravity * _delta

	if Input.is_action_just_pressed("jump") and _jump_count < 2:
		_jump_count += 1
		velocity.y = _jump_velocity
		global.spawn_effect(JUMP_SCENE, Vector2(0,2),
			global_position, _character_texture.flip_h)
			
func _horizontal_movement() -> void:
	var _direction = Input.get_axis("move_left", "move_right")
	if _direction:
		velocity.x = _direction * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)

func _attack_handler() -> void:
	if not _has_sword:
		return
	if Input.is_action_just_pressed("attack") and is_on_floor():
		_attack_animation_handler("attack_", 4)
	if (
		Input.is_action_just_pressed("attack") and not is_on_floor() and 
		_air_attack_count < 2
	):
		print(_air_attack_count)
		_attack_animation_handler("air_attack_", 3, true)

func _attack_animation_handler(_prefix: String, _index_limit: int, _on_air: bool = false) -> void:
	_character_texture.action_animation(_prefix + str(_attack_index))
	_attack_index += 1
	if _attack_index == _index_limit:
		_attack_index = 1
	
	set_physics_process(false)
	if _on_air:
		_air_attack_count += 1
	
	_attack_combo.start()

func update_sword_state(_state: bool) -> void:
	_has_sword = _state
	_character_texture.update_suffix(_has_sword)

func _on_attack_combo_timeout() -> void:
	_attack_index = 1
