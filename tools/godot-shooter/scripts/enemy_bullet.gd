# 敌人子弹
# 负责: 向下飞行，击中玩家造成伤害

extends Area2D

# ========== 导出变量 ==========
@export var speed: float = 250.0
@export var damage: int = 1

# ========== 状态变量 ==========
var _direction: Vector2 = Vector2.DOWN


# ========== 生命周期 ==========

func _ready() -> void:
	add_to_group("enemy_bullets")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += _direction * speed * delta
	_check_out_of_bounds()


# ========== 方向设置 ==========

func set_direction(dir: Vector2) -> void:
	_direction = dir


# ========== 碰撞处理 ==========

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.player_take_damage(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		GameManager.player_take_damage(damage)
		queue_free()


# ========== 出界检测 ==========

func _check_out_of_bounds() -> void:
	var viewport_size := get_viewport_rect().size
	if global_position.y > viewport_size.y + 50:
		queue_free()
