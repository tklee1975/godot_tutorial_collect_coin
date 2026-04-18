extends Node2D

# --- 配置參數 ---
@export var coin_scene: PackedScene           # 拖入 Coin.tscn
@export var max_coin: int = 10                # 場景最大硬幣數
@export var spawn_interval: float = 2.0       # 生成間隔 (秒)
@export var min_distance: float = 200.0       # 與玩家的最短距離
@export var player_path: NodePath             # 拖入 Player 節點

# --- 節點引用 ---
@onready var spawn_timer: Timer = $SpawnTimer
@onready var coin_container: Node2D = $CoinContainer
var player: Node2D
var game_manager: Node # 用於獲取遊戲狀態

func _ready() -> void:
	if player_path:
		player = get_node(player_path)
	
	# 獲取場景中的 GameManager (假設名稱為 GameManager)
	game_manager = get_tree().current_scene.find_child("GameManager", true, false)
	
	# 設定 Timer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

# ==========================================
# 邏輯處理
# ==========================================

func _on_spawn_timer_timeout() -> void:
	# 1. 檢查遊戲是否正在進行
	if game_manager and not game_manager.is_playing:
		return
		
	# 2. 檢查目前硬幣數量是否已達上限
	if coin_container.get_child_count() >= max_coin:
		return
		
	spawn_coin()

func spawn_coin() -> void:
	var spawn_pos = _get_valid_spawn_position()
	
	# 如果找不到合適位置（例如嘗試次數過多），則放棄本次生成
	if spawn_pos == Vector2.ZERO:
		return
		
	var coin = coin_scene.instantiate()
	coin.position = spawn_pos
	
	# 連接信號給 GameManager (依照之前的設定)
	if game_manager:
		coin.coin_collected.connect(game_manager._on_coin_collected)
		
	coin_container.add_child(coin)

## 獲取一個合法的生成位置
func _get_valid_spawn_position() -> Vector2:
	var view_size = get_viewport_rect().size
	var attempts = 0
	var max_attempts = 10 # 防止無限迴圈
	
	while attempts < max_attempts:
		# 在畫面範圍內隨機取點 (保留 50px 邊距防止貼邊)
		var random_pos = Vector2(
			randf_range(50, view_size.x - 50),
			randf_range(50, view_size.y - 50)
		)
		
		# 檢查與玩家的距離
		if player:
			var dist = random_pos.distance_to(player.global_position)
			if dist >= min_distance:
				return random_pos
		else:
			return random_pos # 如果沒有玩家，直接返回
			
		attempts += 1
	
	return Vector2.ZERO

## 清理所有未收集的硬幣
func clear_all_coins() -> void:
	print("清理場景中的硬幣...")
	for coin in coin_container.get_children():
		coin.queue_free()

# ==========================================
# 外部接口
# ==========================================

## 停止生產 (當 GameManager 遊戲結束時可調用)
func stop_spawning() -> void:
	spawn_timer.stop()
	clear_all_coins()

func start_spawning() -> void:
	spawn_timer.start()
