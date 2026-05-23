# 爆炸特效
# 负责: 粒子爆炸动画，自动销毁

extends Node2D

# ========== 节点引用 ==========
@onready var particles: CPUParticles2D = $CPUParticles2D


# ========== 生命周期 ==========

func _ready() -> void:
	particles.emitting = true
	particles.one_shot = true
	var colors := [Color.ORANGE, Color.YELLOW, Color.RED]
	particles.color = colors[randi() % colors.size()]
	await get_tree().create_timer(0.6).timeout
	queue_free()
