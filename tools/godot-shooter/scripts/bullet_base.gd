# 子弹基类
# 负责: 子弹基础行为（移动、出界销毁）
# 遵循规范: 抽象基类定义通用接口，子类实现具体差异

extends Area2D
class_name BulletBase


# ========== 导出变量 ==========
@export var speed: float = 600.0
@export var damage: int = 1
@export var direction: Vector2 = Vector2.UP


# ========== 生命周期 ==========

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_check_out_of_bounds()


# ========== 碰撞处理 (子类可覆盖) ==========

func _on_body_entered(_body: Node2D) -> void:
	_on_hit(_body)


func _on_area_entered(_area: Area2D) -> void:
	_on_hit(_area)


func _on_hit(_target: Node) -> void:
	pass


# ========== 出界检测 ==========

func _check_out_of_bounds() -> void:
	var viewport_size := get_viewport_rect().size
	if global_position.y < -50 or global_position.y > viewport_size.y + 50:
		queue_free()
