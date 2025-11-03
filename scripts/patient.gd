# Patient.gd
extends CharacterBody2D

signal patient_clicked(patient_instance)
signal treatment_finished(patient_instance)

@onready var timer = $PatienceTimer
@onready var progress_bar = $ProgressBar
@onready var patient_sprite = $Sprite2D

var is_in_treatment = false

func _ready():
	# Sambungkan sinyal dengan aman HANYA melalui kode.
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if not is_in_treatment and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("patient_clicked", self)
		
func start_being_processed():
	timer.stop()
	progress_bar.hide()

func _on_timer_timeout():
	if is_in_treatment:
		progress_bar.hide()
		emit_signal("treatment_finished", self)
	else:
		print("Pasien pergi karena tidak sabar!")
		queue_free()

func _process(_delta):
	if not timer.is_stopped():
		progress_bar.value = (timer.time_left / timer.wait_time) * 100
	else:
		progress_bar.value = 0

func start_patience_timer(duration: float):
	is_in_treatment = false
	progress_bar.show()
	timer.wait_time = duration
	timer.start()

func start_treatment(duration: float):
	is_in_treatment = true
	progress_bar.show()
	timer.wait_time = duration
	timer.start() 
	
func hide_sprite():
	patient_sprite.hide()
