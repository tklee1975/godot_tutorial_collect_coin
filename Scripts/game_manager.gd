extends Node

# --- 遊戲設定 (可從編輯器調整) ---
@export var initial_time: int = 30
@export var hud_path: NodePath # 在編輯器中選取 HUD 節點
@export var spawner_path: NodePath
@export var game_over_screen_path: NodePath

@onready var game_over_screen = get_node(game_over_screen_path)
@onready var spawner = get_node(spawner_path)

# --- 遊戲狀態變數 ---
var score: int = 0
var remain_time: int = 0
var is_playing: bool = false
var high_score: int = 0
var is_new_record_achieved: bool = false # 記錄本次遊戲是否曾破紀錄

# --- 節點引用 ---
@onready var game_timer: Timer = $GameTimer
var hud: CanvasLayer

func _ready() -> void:
	high_score = 0
	
	# 獲取 HUD 實體
	if hud_path:
		hud = get_node(hud_path)		
	
	# 連接介面的重新開始信號
	if game_over_screen:
		game_over_screen.restart_requested.connect(_on_restart_game)

	setup_game()

## 初始化遊戲數值
func setup_game() -> void:
	print("遊戲初始化...")
	score = 0
	remain_time = initial_time
	is_playing = true
	is_new_record_achieved = false
	
	# 初始化 HUD 顯示
	if hud:
		hud.update_score_display(score)
		hud.update_time_display(remain_time)
		hud.update_high_score_display(high_score)
	
	# 連接 Timer 信號並啟動
	game_timer.timeout.connect(_on_timer_timeout)
	game_timer.start()
	
	if spawner: 
		spawner.start_spawning()
		
	print("遊戲開始！isPlaying = ", is_playing)

# ==========================================
# 邏輯處理 (Logic)
# ==========================================

## 每秒觸發一次的倒數邏輯
func _on_timer_timeout() -> void:
	if not is_playing:
		return
		
	remain_time -= 1
	
	# 更新 HUD 顯示
	if hud:
		hud.update_time_display(remain_time)
	
	# 檢查時間是否結束
	if remain_time <= 0:
		end_game()

## 處理硬幣收集 (此函數將連接到 Coin 的信號)
func _on_coin_collected(amount: int) -> void:
	if not is_playing:
		return
		
	score += amount
	print("獲得分數: ", amount, " 當前總分: ", score)
	
	
	# 更新 HUD 分數
	if hud:
		hud.update_score_display(score)
		# 如果 HUD 有實作動畫也可以呼叫
		if hud.has_method("play_score_animation"):
			hud.play_score_animation()
			
	# 檢查是否突破最高分
	_check_high_score()


## 檢查最高分邏輯
func _check_high_score() -> void:
	if score > high_score:
		# 只有在「第一次」超過當前紀錄時播放音效
		if not is_new_record_achieved:
			is_new_record_achieved = true
			if hud:
				hud.play_new_record_sound()
				print("突破紀錄！")
		
		high_score = score
		if hud:
			hud.update_high_score_display(high_score)


## 遊戲結束處理
func end_game() -> void:
	is_playing = false
	game_timer.stop()
	
	# 停止生成硬幣並清理
	if spawner:
		spawner.stop_spawning()
		
	# 顯示結束畫面並傳入最終分數
	# 傳遞分數、最高分、以及是否破紀錄給結束介面
	if game_over_screen:
		game_over_screen.show_screen(score, high_score, is_new_record_achieved)
	
	
	print("時間到！遊戲結束。最終得分: ", score)
	# 之後可以在這裡實作顯示「重新開始」按鈕或結算畫面

# 重新開始遊戲的邏輯
func _on_restart_game() -> void:
	print("接收到重新開始請求，重啟場景...")
	# 方法 A：直接重新載入當前場景（最乾淨的方法）
	#get_tree().reload_current_scene()
	
	# 方法 B：如果你想手動重置變數而不重新載入場景：
	game_over_screen.hide_screen()
	setup_game()
