# 敌人基类
# 负责: 敌人通用行为（移动、受伤、死亡、分数奖励）
# 遵循规范: 抽象基类定义通用接口，子类覆盖 AI 行为

extends Area2D
class_name EnemyBase


# ========== 信号 ==========
signal died(position: Vector2, score_value: int)

# ========== 预加载 ==========
const ENEMY_BULLET_SCENE: PackedScene = preload("res://scenes/enemy_bullet.tscn")
const EXPLOSION_SCENE: PackedScene = preload("res://scenes/explosion.tscn")

# ========== 导出变量 ==========
@export var max_health: int = 1
@export var speed: float = 100.0
@export var score_value: int = 100
@export var shoot_interval: float = 2.0
@export var can_shoot: bool = false

# ========== 状态变量 ==========
var _current_health: int = 1
var _shoot_timer: float = 0.0
var _move_direction: Vector2 = Vector2.DOWN


# ========== 生命周期 ==========

func _ready() -> void:
	_current_health = max_health
	add_to_group("enemies")
	# 敌人不需要主动监听碰撞：被玩家子弹击中由 player_bullet 调用 take_damage()，
	# 撞到玩家由玩家 HurtBox 裁决。敌人自身无碰撞回调，保持职责单一。


func _physics_process(delta: float) -> void:
	_update_ai(delta)
	position += _move_direction * speed * delta
	if can_shoot:
		_shoot_timer += delta
		if _shoot_timer >= shoot_interval:
			_shoot_timer = 0.0
			_try_shoot()
	_check_out_of_bounds()


# ========== AI 行为 (子类覆盖) ==========

func _update_ai(_delta: float) -> void:
	_move_direction = Vector2.DOWN


# ========== 受伤与死亡 ==========

func take_damage(amount: int = 1) -> void:
	_current_health -= amount
	_flash_white()
	if _current_health <= 0:
		_die()


func _die() -> void:
	GameManager.add_score(score_value)
	_create_explosion()
	var main := get_tree().current_scene
	var cam := main.get_node("Camera2D") as Camera2D
	if cam.has_method("shake"):
		cam.shake(0.2, 5.0)
	died.emit(global_position, score_value)
	queue_free()


func _create_explosion() -> void:
	var explosion := EXPLOSION_SCENE.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)


func _flash_white() -> void:
	var sprite := get_node_or_null("Polygon2D") as Polygon2D
	if sprite:
		var original_color := sprite.color
		sprite.color = Color.WHITE
		await get_tree().create_timer(0.05).timeout
		if is_instance_valid(sprite):
			sprite.color = original_color


# ========== 射击 ==========

func _try_shoot() -> void:
	if not can_shoot:
		return
	var bullet := ENEMY_BULLET_SCENE.instantiate() as Node2D
	bullet.global_position = global_position
	var main := get_tree().current_scene
	var container := main.get_node("BulletContainer") as Node2D
	container.add_child(bullet)


# ========== 出界检测 ==========

func _check_out_of_bounds() -> void:
	var viewport_size := get_viewport_rect().size
	if global_position.y > viewport_size.y + 100:
		queue_free()
