extends CanvasLayer

# --- 信號 ---
# 當玩家點擊重新開始按鈕時，通知外部 (例如 GameManager)
signal restart_requested

# --- 節點引用 ---
@onready var score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var background: ColorRect = $Background
@onready var high_score_label: Label = $CenterContainer/VBoxContainer/HighScoreLabel
@onready var new_record_tag: Label = $CenterContainer/VBoxContainer/NewRecordTag

func _ready() -> void:
	# 初始狀態為隱藏
	hide_screen()
	# 連接按鈕點擊信號
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)

# ==========================================
# 提供給 GameManager 調用的介面 (Public Interfaces)
# ==========================================

## 顯示結算介面
func show_screen(final_score: int, high_score: int, is_new_record: bool) -> void:
	score_label.text = "Score: %d" % final_score
	
	high_score_label.text = "High Score: %d" % high_score
	
	# 如果是新紀錄，顯示標籤
	new_record_tag.visible = is_new_record
	
	self.visible = true
	# 如果有暫停邏輯，可以在這裡執行
	# get_tree().paused = true

## 隱藏結算介面
func hide_screen() -> void:
	self.visible = false

# ==========================================
# 內部邏輯
# ==========================================

func _on_restart_pressed() -> void:
	# 這裡不直接寫重開邏輯，而是發出信號讓 GameManager 處理
	restart_requested.emit()
