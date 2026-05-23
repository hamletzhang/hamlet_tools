# 玩家子弹
# 负责: 向上飞行，击中敌人造成伤害
# 遵循规范: 继承 BulletBase 或直接实现，复用基础行为

extends Area2D

# ========== 配置 ==========
@export var speed: float = 800.0
@export var damage: int = 1
var direction: Vector2 = Vector2.UP


# ========== 生命周期 ==========

func _ready() -> void:
	add_to_group("player_bullets")
	area_entered.connect(_on_hit)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_check_out_of_bounds()


# ========== 击中处理 ==========

func _on_hit(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()


# ========== 出界检测 ==========

func _check_out_of_bounds() -> void:
	if global_position.y < -50:
		queue_free()
