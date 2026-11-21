extends CanvasLayer

# --- 節點引用 ---
# 使用 @onready 確保在場景載入完成後取得 UI 節點
@onready var score_label: Label = $UIContainer/VBoxContainer/HBoxContainer/ScorePanel/ScoreLabel
@onready var time_label: Label = $UIContainer/VBoxContainer/HBoxContainer/TimePanel/TimeLabel
@onready var high_score_label: Label = $UIContainer/VBoxContainer/HBoxContainer2/HighScoreLabel

# 新增音效組件引用
@onready var record_audio_player: AudioStreamPlayer2D = $NewRecordAudioPlayer

# --- 內部變數 ---
var _current_score: int = 0
var _current_time: int = 0

func _ready() -> void:
	# 初始化顯示
	update_score_display(0)
	update_time_display(0)

# ==========================================
# 提供給外部調用的介面 (Public Interfaces)
# ==========================================

## 更新分數的接口
func update_score_display(new_score: int) -> void:
	_current_score = new_score
	score_label.text = "SCORE: %d" % _current_score

## 增加分數的接口 (方便 Coin 等物品調用)
func add_score(amount: int) -> void:
	_current_score += amount
	update_score_display(_current_score)

## 更新剩餘時間的接口
func update_time_display(seconds: int) -> void:
	_current_time = seconds
	# 將秒數格式化為 00:00 格式 (可選)
	time_label.text = "TIME: %03d" % [seconds]
	
	# 如果你只需要顯示純數字，可以使用這行：
	# time_label.text = "Time: " + str(_current_time)

## 播放 UI 特效 (例如分數變動時跳動一下)
func play_score_animation() -> void:
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)



## 更新最高分顯示
func update_high_score_display(value: int) -> void:
	high_score_label.text = "HI SCORE: %d" % value
	
	play_new_record_sound()
	play_new_record_fx()

## 播放突破紀錄音效
func play_new_record_sound() -> void:
	if record_audio_player: 
		if record_audio_player.stream:
			record_audio_player.play()

## 播放突破紀錄的特效 (文字閃爍或變色)
func play_new_record_fx() -> void:
	var tween = create_tween()
	tween.tween_property(high_score_label, "modulate", Color.YELLOW, 0.2)
	tween.tween_property(high_score_label, "modulate", Color.WHITE, 0.2)
	# 可以在這裡加入一個音效節點播放播放
