# 主场景逻辑
# 负责: 场景初始化、状态机响应、子系统协调
# 遵循规范: 主场景作为"导演"，协调各子系统，不直接处理游戏逻辑

extends Node2D

# ========== 预加载 ==========
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

# ========== 运行时变量 ==========
var _player: Node2D = null

# ========== 节点引用 ==========
@onready var wave_manager: Node = $WaveManager
@onready var camera: Camera2D = $Camera2D
@onready var hud: Control = $CanvasLayer/HUD
@onready var main_menu: Control = $CanvasLayer/MainMenu
@onready var game_over_screen: Control = $CanvasLayer/GameOver
@onready var player_spawn_point: Marker2D = $PlayerSpawnPoint
@onready var enemy_container: Node2D = $EnemyContainer
@onready var bullet_container: Node2D = $BulletContainer


# ========== 生命周期 ==========

func _ready() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_waves_cleared.connect(_on_all_waves_cleared)
	_show_main_menu()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING \
			or GameManager.current_state == GameManager.GameState.PAUSED:
			GameManager.toggle_pause()


# ========== 场景状态切换 ==========

func _show_main_menu() -> void:
	main_menu.visible = true
	hud.visible = false
	game_over_screen.visible = false
	enemy_container.visible = false
	bullet_container.visible = false
	get_tree().paused = false


func _start_gameplay() -> void:
	main_menu.visible = false
	hud.visible = true
	game_over_screen.visible = false
	enemy_container.visible = true
	bullet_container.visible = true
	_clear_container(enemy_container)
	_clear_container(bullet_container)
	_spawn_player()
	wave_manager.start_waves()


func _show_game_over() -> void:
	hud.visible = false
	game_over_screen.visible = true
	game_over_screen.update_score(GameManager.score)


# ========== 私有方法 ==========

func _spawn_player() -> void:
	if _player != null:
		_player.queue_free()
	_player = PLAYER_SCENE.instantiate()
	_player.global_position = player_spawn_point.global_position
	_player.died.connect(_on_player_died)
	add_child(_player)


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()


# ========== 信号回调 ==========

func _on_game_started() -> void:
	_start_gameplay()


func _on_game_over(_final_score: int) -> void:
	_show_game_over()


func _on_game_paused() -> void:
	hud.show_pause_overlay()


func _on_game_resumed() -> void:
	hud.hide_pause_overlay()


func _on_player_died() -> void:
	GameManager.player_take_damage(1)
	if GameManager.health > 0:
		await get_tree().create_timer(1.0).timeout
		if GameManager.current_state == GameManager.GameState.PLAYING:
			_spawn_player()


func _on_wave_completed(_wave_number: int) -> void:
	GameManager.next_wave()
	await get_tree().create_timer(2.0).timeout
	if GameManager.current_state == GameManager.GameState.PLAYING:
		wave_manager.start_next_wave()


func _on_all_waves_cleared() -> void:
	GameManager.add_score(1000)
	await get_tree().create_timer(3.0).timeout
	if GameManager.current_state == GameManager.GameState.PLAYING:
		wave_manager.reset_and_intensify()
