extends Area2D

# 定義信號：當硬幣被收集時發出，並傳遞分數值
signal coin_collected(amount: int)

# 設定這枚硬幣價值多少分
@export var score_value: int = 1

# 標記是否已經被收集，防止多次觸發（例如兩個碰撞體同時進入）
var is_collected: bool = false

func _ready() -> void:
	# 連接自帶的信號：當有物體進入此區域時觸發
	# 你也可以在編輯器介面的「節點(Node)」面板手動連接 body_entered
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# 檢查是否已經被收集，避免重複執行
	if is_collected:
		return
	
	# 這裡可以根據需要檢查碰撞的是不是玩家 (假設玩家在 "Player" 群組)
	# if body.is_in_group("Player"):
	
	collect_coin()

func collect_coin() -> void:
	is_collected = true
	
	# 1. 發出信號通知其他節點（例如 UI 或 Game Manager）
	coin_collected.emit(score_value)
	
	# 2. 播放收集音效
	if $PickupSound.stream:
		$PickupSound.play()
	
	# 3. 視覺效果：隱藏硬幣圖案並關閉碰撞（防止再次觸發）
	# 我們不直接 queue_free() 是因為要等音效播完
	hide() 
	set_deferred("monitoring", false)
	
	# 4. 等待音效播放結束後再刪除節點
	# 如果沒有音效，可以直接 queue_free()
	if $PickupSound.playing:
		$PickupSound.finished.connect(queue_free)
	else:
		queue_free()
