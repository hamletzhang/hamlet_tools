# 滚动星空背景
# 负责: 程序化生成多速度星点持续向下滚动，营造飞行纵深感（零美术资源）
# 遵循规范: 纯程序生成视觉，用 _draw 一次性绘制所有星点，避免大量节点开销

extends Node2D

# ========== 导出变量 (Inspector可调) ==========
@export var star_count: int = 70
@export var min_speed: float = 30.0
@export var max_speed: float = 130.0

# ========== 状态变量 ==========
# 每颗星: {pos: Vector2, speed: float, size: float, alpha: float}
var _stars: Array[Dictionary] = []
var _bounds: Vector2 = Vector2(480, 854)
var _rng := RandomNumberGenerator.new()


# ========== 生命周期 ==========

func _ready() -> void:
	_rng.randomize()
	_bounds = get_viewport().get_visible_rect().size
	for i in star_count:
		_stars.append({
			"pos": Vector2(_rng.randf_range(0, _bounds.x), _rng.randf_range(0, _bounds.y)),
			"speed": _rng.randf_range(min_speed, max_speed),
			"size": _rng.randf_range(1.0, 2.5),
			"alpha": _rng.randf_range(0.3, 1.0),
		})


func _process(delta: float) -> void:
	# 越快的星点越大越亮，形成视差纵深；越界后从顶部回收
	for star in _stars:
		star["pos"].y += star["speed"] * delta
		if star["pos"].y > _bounds.y:
			star["pos"].y = 0.0
			star["pos"].x = _rng.randf_range(0, _bounds.x)
	queue_redraw()


func _draw() -> void:
	for star in _stars:
		draw_circle(star["pos"], star["size"], Color(0.7, 0.8, 1.0, star["alpha"]))
