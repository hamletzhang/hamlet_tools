# 玩家飞机控制
# 负责: 移动输入、自动射击、碰撞检测、无敌帧
# 遵循规范: 使用 @export 暴露可配置参数，信号通知外部系统
# 架构: HurtBox (Area2D) 专门处理伤害碰撞，分离移动与碰撞逻辑

extends CharacterBody2D

# ========== 信号 ==========
signal died

# ========== 预加载 ==========
const BULLET_SCENE: PackedScene = preload("res://scenes/player_bullet.tscn")

# ========== 导出变量 (Inspector可调) ==========
@export var speed: float = 350.0
@export var shoot_interval: float = 0.15
@export var invincible_duration: float = 2.0

# ========== 状态变量 ==========
var _is_invincible: bool = false

# ========== 节点引用 (@onready懒加载) ==========
@onready var sprite: Polygon2D = $Polygon2D
@onready var hurtbox: Area2D = $HurtBox
@onready var muzzle: Marker2D = $Muzzle
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var blink_timer: Timer = $BlinkTimer


# ========== 生命周期 ==========

func _ready() -> void:
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

	invincible_timer.timeout.connect(_end_invincibility)
	blink_timer.timeout.connect(_toggle_blink)

	# 初始无敌
	_start_invincibility()


func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	move_and_slide()
	_clamp_to_screen()


# ========== 射击逻辑 ==========

func _on_shoot_timer_timeout() -> void:
	_shoot()


func _shoot() -> void:
	var bullet := BULLET_SCENE.instantiate() as Node2D
	bullet.global_position = muzzle.global_position
	var main := get_tree().current_scene
	var container := main.get_node("BulletContainer") as Node2D
	container.add_child(bullet)


# ========== 碰撞处理 (通过 HurtBox Area2D) ==========

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if _is_invincible:
		return
	if area.is_in_group("enemies") or area.is_in_group("enemy_bullets"):
		_die()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if _is_invincible:
		return
	if body.is_in_group("enemies"):
		_die()


# ========== 死亡与重生 ==========

func _die() -> void:
	_create_explosion()
	var main := get_tree().current_scene
	var cam := main.get_node("Camera2D") as Camera2D
	if cam.has_method("shake"):
		cam.shake(0.4, 8.0)
	died.emit()
	queue_free()


func _create_explosion() -> void:
	const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")
	var explosion := EXPLOSION_SCENE.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)


# ========== 无敌帧系统 ==========

func _start_invincibility() -> void:
	_is_invincible = true
	hurtbox.monitoring = false
	collision_shape.set_deferred("disabled", true)
	invincible_timer.start(invincible_duration)
	blink_timer.start(0.1)


func _end_invincibility() -> void:
	_is_invincible = false
	hurtbox.monitoring = true
	collision_shape.set_deferred("disabled", false)
	blink_timer.stop()
	sprite.visible = true


func _toggle_blink() -> void:
	sprite.visible = not sprite.visible


# ========== 屏幕边界限制 ==========

func _clamp_to_screen() -> void:
	var viewport_size := get_viewport_rect().size
	global_position.x = clampf(global_position.x, 20.0, viewport_size.x - 20.0)
	global_position.y = clampf(global_position.y, 20.0, viewport_size.y - 20.0)
