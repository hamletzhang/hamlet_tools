# 摄像机震动
# 负责: 游戏内摄像机震动反馈，增强打击感

extends Camera2D

# ========== 导出变量 ==========
@export var decay: float = 0.8
@export var max_offset: Vector2 = Vector2(10, 10)

# ========== 状态变量 ==========
var _trauma: float = 0.0
var _rng := RandomNumberGenerator.new()


# ========== 生命周期 ==========

func _ready() -> void:
	_rng.randomize()


func _process(delta: float) -> void:
	if _trauma > 0:
		_decay_trauma(delta)
		_apply_shake()
	else:
		offset = Vector2.ZERO


# ========== 公共方法 ==========

## 触发震动
## trauma: float 参数范围 0-1，建议值: 小震动 0.2-0.4，大震动 0.6-1.0
func shake(duration: float = 0.3, intensity: float = 5.0) -> void:
	_trauma = minf(_trauma + intensity / max_offset.length(), 1.0)
	if duration > 0:
		decay = 1.0 / duration


# ========== 私有方法 ==========

func _decay_trauma(delta: float) -> void:
	_trauma = maxf(_trauma - decay * delta, 0.0)


func _apply_shake() -> void:
	var amount := _trauma * _trauma
	offset.x = max_offset.x * amount * _rng.randf_range(-1, 1)
	offset.y = max_offset.y * amount * _rng.randf_range(-1, 1)
