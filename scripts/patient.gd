# Patient.gd
extends CharacterBody2D


signal patient_clicked(patient_instance)
signal patience_ran_out(patient_instance) #
signal treatment_finished(patient_instance)

enum State { WAITING_IN_QUEUE, MOVING, IN_TREATMENT }
var current_state = State.WAITING_IN_QUEUE

# Ambil referensi ke node yang baru kita buat
@onready var patience_bar = $PatienceBar
@onready var patience_timer = $PatienceTimer
	

func _ready():
	# Saat pasien pertama kali muncul, mulai timer kesabarannya
	patience_timer.start()

func _process(_delta):
	# Fungsi ini berjalan setiap frame, bagus untuk update visual
	# Kita akan update nilai bar berdasarkan sisa waktu di timer
	if not patience_timer.is_stopped():
		# Hitung sisa waktu sebagai persentase
		patience_bar.value = (patience_timer.time_left / patience_timer.wait_time) * 100
	
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if current_state == State.WAITING_IN_QUEUE:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			patience_timer.stop()
			patience_bar.hide()
			emit_signal("patient_clicked", self)


# Kita perlu menghubungkan sinyal 'timeout' dari PatienceTimer ke fungsi ini
func _on_patience_timer_timeout():
	# Cek state pasien saat timer selesai
	if current_state == State.WAITING_IN_QUEUE:
		print("Waktu habis! Pasien marah dan pergi.")
		emit_signal("patience_ran_out", self)
		queue_free()
	elif current_state == State.IN_TREATMENT:
		print("Timer perawatan selesai.")
		patience_bar.hide()
		emit_signal("treatment_finished", self)
		
		
func start_treatment(duration: float):
	# Langsung ubah state, tidak perlu menunggu pergerakan
	current_state = State.IN_TREATMENT
	
	patience_timer.wait_time = duration
	patience_timer.start()
	patience_bar.show() # Tampilkan kembali bar untuk timer perawatan
