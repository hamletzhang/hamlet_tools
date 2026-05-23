# 游戏结束画面
# 负责: 显示最终分数、重新开始、返回菜单

extends Control

# ========== 节点引用 ==========
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var menu_button: Button = $VBoxContainer/MenuButton


# ========== 生命周期 ==========

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	visible = false


# ========== 公共方法 ==========

func update_score(final_score: int) -> void:
	score_label.text = "最终分数: %d" % final_score
	var rating := ""
	if final_score >= 10000:
		rating = "传奇飞行员! ✈✈✈"
	elif final_score >= 5000:
		rating = "王牌飞行员! ✈✈"
	elif final_score >= 2000:
		rating = "优秀飞行员! ✈"
	else:
		rating = "继续加油!"
	score_label.text += "\n" + rating


# ========== 信号回调 ==========

func _on_restart_pressed() -> void:
	GameManager.start_game()


func _on_menu_pressed() -> void:
	GameManager.return_to_menu()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
