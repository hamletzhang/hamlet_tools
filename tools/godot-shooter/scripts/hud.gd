# HUD ( Heads-Up Display )
# 负责: 游戏内UI显示（分数、生命、波次）、暂停遮罩

extends Control

# ========== 常量 ==========
const HEART_ICON := "❤"

# ========== 节点引用 ==========
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var health_container: HBoxContainer = $MarginContainer/VBoxContainer/HealthContainer
@onready var wave_label: Label = $MarginContainer/VBoxContainer/WaveLabel
@onready var enemy_count_label: Label = $MarginContainer/VBoxContainer/EnemyCountLabel
@onready var pause_overlay: ColorRect = $PauseOverlay


# ========== 生命周期 ==========

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.enemy_count_changed.connect(_on_enemy_count_changed)
	_update_score(GameManager.score)
	_update_health(GameManager.health)
	_update_wave(GameManager.current_wave)
	pause_overlay.visible = false


# ========== 公共方法 ==========

func show_pause_overlay() -> void:
	pause_overlay.visible = true


func hide_pause_overlay() -> void:
	pause_overlay.visible = false


# ========== 更新方法 ==========

func _update_score(new_score: int) -> void:
	score_label.text = "分数: %d" % new_score


func _update_health(new_health: int) -> void:
	for child in health_container.get_children():
		child.queue_free()
	for i in range(new_health):
		var heart := Label.new()
		heart.text = HEART_ICON
		heart.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		heart.add_theme_font_size_override("font_size", 24)
		health_container.add_child(heart)


func _update_wave(new_wave: int) -> void:
	wave_label.text = "波次: %d" % new_wave


func _update_enemy_count(remaining: int) -> void:
	enemy_count_label.text = "敌人: %d" % remaining


# ========== 信号回调 ==========

func _on_score_changed(new_score: int) -> void:
	_update_score(new_score)


func _on_health_changed(new_health: int) -> void:
	_update_health(new_health)


func _on_wave_changed(new_wave: int) -> void:
	_update_wave(new_wave)


func _on_enemy_count_changed(remaining: int) -> void:
	_update_enemy_count(remaining)
