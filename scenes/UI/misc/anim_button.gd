class_name AnimButton extends Button

#@onready var particles = $MovementParticles2D
#@onready var label: Label = $Label
@onready var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()

var tween: Tween

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)
	pivot_offset = size/2
	
	audio_stream_player.bus = "Sfx"
	#audio_stream_player.volume_db += 100 #TODO: remove this with better sound...
	get_tree().get_root().add_child.call_deferred(audio_stream_player)
	
	#Label stuff
	#_setup_text_animation()
#TODO
#func _setup_text_animation():
	#label.material = ShaderMaterial.new()
	#label.material.shader = preload("res://scenes/UI/misc/anim_text.gdshader")


func _on_mouse_entered() -> void:
	#particles.emitting = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.075, 1.075), 0.1).set_trans(Tween.TRANS_CUBIC)
	
	# smallish glow effect
	#var style = get_theme_stylebox("normal").duplicate()
	#style.shadow_size = 8
	#add_theme_stylebox_override("normal", style)
	
	## Label stuff
	#tween = create_tween()
	#tween.tween_method(_update_text_effect, 0.0, 1.0, 0.3)

func _on_mouse_exited() -> void:
	#particles.emitting = false
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_CUBIC)
	
	# Reset glow
	#add_theme_stylebox_override("normal", null)
	
	## label 
	#tween = create_tween()
	#tween.tween_method(_update_text_effect, 1.0, 0.0, 0.3)

func _on_button_down() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1).set_trans(Tween.TRANS_CUBIC)

func _on_button_up() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_CUBIC)

#func _update_text_effect(value: float):
	#label.material.set_shader_parameter("effect_value", value)


func _on_pressed() -> void:
	audio_stream_player.stream = load("res://assets/music/GUI_Sound_Effects_by_Lokif/click_2.wav")
	audio_stream_player.play()
	
#FIXME: Doesnt work due to the timers not being syncronised properly, hence looking bad.
	#await get_tree().create_timer(0.15).timeout
	#_on_mouse_entered()

func _exit_tree() -> void:
	audio_stream_player.queue_free()
