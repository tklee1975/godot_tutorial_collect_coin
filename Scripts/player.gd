extends CharacterBody2D

# AI Prompt:
# 請提供 Player.tscn 中 CharacterBody2D 的基礎移動腳本範例。

# =============================
#  匯出變數（可在 Inspector 調整）
# =============================
@export var speed: float = 200.0        # 移動速度

# =============================
#  節點引用
# =============================
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

# =============================
#  內部狀態
# =============================
var is_alive: bool = true

# =============================
#  _physics_process：每個物理幀執行
# =============================
func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	_handle_movement()
	_handle_animation()

# =============================
#  移動處理
# =============================
func _handle_movement() -> void:
	# 取得輸入方向（內建 Input Map）
	var direction: Vector2 = Vector2.ZERO

	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	# 斜向移動正規化（防止斜向速度過快）
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# 設定速度並移動
	velocity = direction * speed
	move_and_collide(velocity * get_physics_process_delta_time())
	# 或使用（推薦）：
	# move_and_slide()



# =============================
#  動畫處理
# =============================
func _handle_animation() -> void:
	if velocity.length() > 0:
		anim_sprite.play("walk")

		# 左右翻轉 Sprite
		if velocity.x < 0:
			anim_sprite.flip_h = true
		elif velocity.x > 0:
			anim_sprite.flip_h = false
	else:
		anim_sprite.play("idle")
