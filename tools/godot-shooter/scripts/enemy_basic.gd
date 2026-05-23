# 基础敌人
# AI行为: 直线向下移动，偶尔左右摆动，基础射击
# 外观: 红色三角形

extends EnemyBase


# ========== 配置覆盖 ==========

func _ready() -> void:
	max_health = 1
	speed = 120.0
	score_value = 100
	can_shoot = true
	shoot_interval = 3.0
	super._ready()


# ========== AI行为 ==========

func _update_ai(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	var sway := sin(time * 2.0) * 0.3
	_move_direction = Vector2(sway, 1.0).normalized()
