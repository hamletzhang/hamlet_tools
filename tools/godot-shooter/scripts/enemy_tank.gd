# 坦克敌人
# AI行为: 慢速直线移动，高血量，连续射击（3连发）
# 外观: 绿色大方块

extends EnemyBase


# ========== 配置覆盖 ==========

func _ready() -> void:
	max_health = 5
	speed = 60.0
	score_value = 500
	can_shoot = true
	shoot_interval = 2.5
	super._ready()


# ========== AI行为 ==========

func _update_ai(_delta: float) -> void:
	_move_direction = Vector2.DOWN


# ========== 射击覆盖: 3连发 ==========

func _try_shoot() -> void:
	if not can_shoot:
		return
	var angles := [-0.2, 0.0, 0.2]
	for angle in angles:
		var bullet := ENEMY_BULLET_SCENE.instantiate() as Node2D
		bullet.global_position = global_position
		if bullet.has_method("set_direction"):
			bullet.set_direction(Vector2(angle, 1.0).normalized())
		var main := get_tree().current_scene
		var container := main.get_node("BulletContainer") as Node2D
		container.add_child(bullet)
