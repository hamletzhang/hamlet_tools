# 全局游戏管理器 (AutoLoad 单例)
# 负责: 游戏状态管理、分数统计、生命值、信号总线
# 遵循规范: 单例模式管理全局状态，避免节点间直接硬引用

extends Node

# ========== 信号 ==========
signal score_changed(new_score: int)
signal health_changed(new_health: int)
signal wave_changed(new_wave: int)
signal game_started
signal game_over(final_score: int)
signal game_paused
signal game_resumed

# ========== 游戏状态枚举 ==========
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

# ========== 常量 ==========
const MAX_HEALTH: int = 3
const INITIAL_SCORE: int = 0
const INITIAL_WAVE: int = 1

# ========== 状态变量 ==========
var current_state: GameState = GameState.MENU
var score: int = INITIAL_SCORE:
	set(value):
		score = value
		score_changed.emit(score)

var health: int = MAX_HEALTH:
	set(value):
		health = clampi(value, 0, MAX_HEALTH)
		health_changed.emit(health)
		if health <= 0 and current_state == GameState.PLAYING:
			_trigger_game_over()

var current_wave: int = INITIAL_WAVE:
	set(value):
		current_wave = value
		wave_changed.emit(current_wave)


# ========== 公共方法 ==========

## 开始新游戏
func start_game() -> void:
	score = INITIAL_SCORE
	health = MAX_HEALTH
	current_wave = INITIAL_WAVE
	current_state = GameState.PLAYING
	game_started.emit()


## 暂停/恢复游戏
func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		game_paused.emit()
	elif current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		game_resumed.emit()


## 增加分数
func add_score(points: int) -> void:
	score += points


## 玩家受伤
func player_take_damage(damage: int = 1) -> void:
	health -= damage


## 进入下一波
func next_wave() -> void:
	current_wave += 1


## 返回主菜单
func return_to_menu() -> void:
	current_state = GameState.MENU
	get_tree().paused = false


# ========== 私有方法 ==========

func _trigger_game_over() -> void:
	current_state = GameState.GAME_OVER
	game_over.emit(score)
