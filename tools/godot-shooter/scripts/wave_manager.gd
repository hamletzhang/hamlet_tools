# 波次管理器
# 负责: 程序化生成敌人波次，难度递增，关卡设计
# 遵循规范: 数据驱动波次配置，便于AI辅助生成和修改

extends Node

# ========== 信号 ==========
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemy_spawned(enemy: Node2D)
signal all_waves_cleared

# ========== 预加载 ==========
const ENEMY_SCENES: Dictionary = {
	"basic": preload("res://scenes/enemy_basic.tscn"),
	"fast": preload("res://scenes/enemy_fast.tscn"),
	"tank": preload("res://scenes/enemy_tank.tscn")
}

# ========== 波次配置结构 ==========
# 每个波次定义: { enemy_type, count, spawn_interval, spawn_pattern }
const WAVE_CONFIGS: Array[Dictionary] = [
	{"enemies": [{"type": "basic", "count": 5}], "spawn_interval": 1.5, "pattern": "line"},
	{"enemies": [{"type": "basic", "count": 4}, {"type": "fast", "count": 2}], "spawn_interval": 1.2, "pattern": "mixed"},
	{"enemies": [{"type": "basic", "count": 10}], "spawn_interval": 0.8, "pattern": "rush"},
	{"enemies": [{"type": "fast", "count": 6}, {"type": "basic", "count": 3}], "spawn_interval": 1.0, "pattern": "mixed"},
	{"enemies": [{"type": "tank", "count": 1}, {"type": "basic", "count": 5}], "spawn_interval": 1.5, "pattern": "boss_support"},
	{"enemies": [{"type": "fast", "count": 12}], "spawn_interval": 0.5, "pattern": "rush"},
	{"enemies": [{"type": "basic", "count": 6}, {"type": "fast", "count": 4}, {"type": "tank", "count": 1}], "spawn_interval": 0.8, "pattern": "mixed"},
	{"enemies": [{"type": "tank", "count": 2}, {"type": "fast", "count": 6}], "spawn_interval": 1.0, "pattern": "boss_support"},
	{"enemies": [{"type": "basic", "count": 10}, {"type": "fast", "count": 8}, {"type": "tank", "count": 2}], "spawn_interval": 0.4, "pattern": "rush"},
	{"enemies": [{"type": "tank", "count": 3}, {"type": "fast", "count": 10}, {"type": "basic", "count": 10}], "spawn_interval": 0.6, "pattern": "boss_support"}
]

# ========== 状态变量 ==========
var _current_wave_index: int = 0
var _enemies_remaining: int = 0
var _spawn_queue: Array[Dictionary] = []
var _spawn_timer: float = 0.0
var _is_spawning: bool = false
var _intensity_multiplier: float = 1.0


# ========== 公共方法 ==========

func start_waves() -> void:
	_current_wave_index = 0
	_intensity_multiplier = 1.0
	_start_wave(_current_wave_index)


func start_next_wave() -> void:
	_current_wave_index += 1
	if _current_wave_index >= WAVE_CONFIGS.size():
		all_waves_cleared.emit()
		return
	_start_wave(_current_wave_index)


func reset_and_intensify() -> void:
	_intensity_multiplier += 0.3
	_current_wave_index = 0
	_start_wave(0)


# ========== 私有方法 ==========

func _start_wave(index: int) -> void:
	var config: Dictionary = WAVE_CONFIGS[index]
	_spawn_queue.clear()
	for entry in config["enemies"]:
		for i in range(entry["count"]):
			_spawn_queue.append({"type": entry["type"]})
	_spawn_queue.shuffle()
	_enemies_remaining = _spawn_queue.size()
	_spawn_timer = 1.0
	_is_spawning = true
	wave_started.emit(GameManager.current_wave)


func _physics_process(delta: float) -> void:
	if not _is_spawning:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0 and _spawn_queue.size() > 0:
		_spawn_next_enemy()
		var base_interval: float = WAVE_CONFIGS[_current_wave_index]["spawn_interval"]
		_spawn_timer = base_interval / _intensity_multiplier
	if _enemies_remaining <= 0 and _spawn_queue.size() == 0:
		_is_spawning = false
		wave_completed.emit(GameManager.current_wave)


func _spawn_next_enemy() -> void:
	if _spawn_queue.size() == 0:
		return
	var entry: Dictionary = _spawn_queue.pop_front()
	var enemy_type: String = entry["type"]
	if not ENEMY_SCENES.has(enemy_type):
		push_error("未知敌人类型: " + enemy_type)
		return
	var enemy := ENEMY_SCENES[enemy_type].instantiate() as Node2D
	enemy.global_position = _get_spawn_position()
	if enemy is EnemyBase:
		enemy.speed *= _intensity_multiplier
		enemy.score_value = int(enemy.score_value * _intensity_multiplier)
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
	var main := get_tree().current_scene
	var container := main.get_node("EnemyContainer") as Node2D
	container.add_child(enemy)
	enemy_spawned.emit(enemy)


func _get_spawn_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var margin := 40.0
	var x := randf_range(margin, viewport_size.x - margin)
	return Vector2(x, -30.0)


func _on_enemy_died(_pos: Vector2, _score: int) -> void:
	_enemies_remaining -= 1
