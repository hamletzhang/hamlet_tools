# 快速敌人
# AI行为: 高速斜向移动，追踪玩家水平位置，不射击
# 外观: 黄色菱形

extends EnemyBase

# ========== 节点引用 ==========
var _player: Node2D = null


# ========== 配置覆盖 ==========

func _ready() -> void:
	max_health = 1
	speed = 220.0
	score_value = 200
	can_shoot = false
	super._ready()
	_player = _find_player()


# ========== AI行为 ==========

func _update_ai(_delta: float) -> void:
	var target_x := global_position.x
	if _player != null and is_instance_valid(_player):
		target_x = _player.global_position.x
	var diff_x := target_x - global_position.x
	var move_x := clampf(diff_x * 0.02, -0.8, 0.8)
	_move_direction = Vector2(move_x, 1.0).normalized()


# ========== 查找玩家 ==========

func _find_player() -> Node2D:
	var main := get_tree().current_scene
	for child in main.get_children():
		if child.is_in_group("player"):
			return child
	return null
