# 主菜单
# 负责: 游戏启动入口、标题展示、开始按钮

extends Control

# ========== 节点引用 ==========
@onready var start_button: Button = $VBoxContainer/StartButton


# ========== 生命周期 ==========

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	_start_button_pulse()


# ========== 动画 ==========

func _start_button_pulse() -> void:
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(start_button, "scale", Vector2(1.05, 1.05), 0.8)
	tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 0.8)


# ========== 信号回调 ==========

func _on_start_pressed() -> void:
	GameManager.start_game()
