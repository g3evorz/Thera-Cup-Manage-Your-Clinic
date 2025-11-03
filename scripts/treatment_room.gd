# TreatmentRoom.gd (Versi Final dengan State CLEANING)
extends Area2D

signal cleaning_finished(room_instance)

# DIUBAH: Tambahkan state CLEANING
enum State { AVAILABLE, OCCUPIED, NEEDS_CLEANING, CLEANING }
var current_state = State.AVAILABLE

var tex_available = preload("res://Texture/bed_1.png")
var tex_dirty = preload("res://Texture/bed_dirty.png")
var tex_occupied =  preload("res://Texture/bed_occupied.png")

@onready var sprite = $Sprite2D
@onready var cleaning_timer = $CleaningTimer
@onready var cleaning_bar = $CleaningBar
@onready var patient_position_marker = $PatientPosition

func _ready():
	if not cleaning_timer.timeout.is_connected(_on_cleaning_timer_timeout):
		cleaning_timer.timeout.connect(_on_cleaning_timer_timeout)
	
	cleaning_bar.hide()
	update_visuals()

func _process(_delta):
	if current_state == State.CLEANING:
		cleaning_bar.value = (cleaning_timer.time_left / cleaning_timer.wait_time) * 100

func _on_input_event(_viewport, event, _shape_idx):
	# Hanya bisa diklik jika statusnya NEEDS_CLEANING (belum mulai dibersihkan)
	if current_state == State.NEEDS_CLEANING:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Segera ubah status menjadi CLEANING agar tidak bisa diklik lagi
			set_state(State.CLEANING, "Dipanggil dari dalam TreatmentRoom: Mulai membersihkan.")
			cleaning_timer.start()

# Fungsi ini hanya berjalan saat timer selesai
func _on_cleaning_timer_timeout():
	# Pastikan hanya berubah jika memang sedang dalam proses cleaning
	if current_state == State.CLEANING:
		set_state(State.AVAILABLE, "Dipanggil dari dalam TreatmentRoom: Pembersihan selesai.")
		emit_signal("cleaning_finished", self)

func set_state(new_state, reason: String = "Status diubah"):
	# Hapus atau beri komentar pada blok print ini setelah bug diperbaiki
	print("--- Perubahan Status di '", self.name, "' ---")
	print("Status Lama: ", State.keys()[current_state])
	print("Status Baru: ", State.keys()[new_state])
	print(">> Alasan: ", reason)
	print("---------------------------------")
	
	current_state = new_state
	update_visuals()

func update_visuals():
	match current_state:
		State.AVAILABLE:
			sprite.texture = tex_available
			sprite.modulate = Color.WHITE
			cleaning_bar.hide()
		State.OCCUPIED:
			sprite.texture = tex_occupied
			sprite.modulate = Color(0.6, 0.6, 0.6) 
		State.NEEDS_CLEANING:
			sprite.texture = tex_dirty
			sprite.modulate = Color.WHITE
		# DIUBAH: Tambahkan visual untuk state CLEANING
		State.CLEANING:
			sprite.texture = tex_dirty
			sprite.modulate = Color(0.8, 0.8, 1.0) # Warna kebiruan
			cleaning_bar.show()
