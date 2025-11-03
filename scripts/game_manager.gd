# GameManager.gd
extends Node

var money = 0
var game_started = false
@export var queue_positions: Array[Marker2D] = []
var waiting_patients: Array[Node] = []
var treatment_rooms: Array[Node] = []
var occupied_rooms: Dictionary = {}

@onready var start_day_button = $"../CanvasLayer/right_up/Start Day"
@onready var money_label = $"../CanvasLayer/MarginContainer3/MarginContainer/HBoxContainer/Money"
@onready var patient_spawn_timer = $PatientSpawnerTimer
@onready var day_timer = $DayTimer
@onready var day_timer_label = $"../CanvasLayer/MarginContainer3/MarginContainer/HBoxContainer/DayTimerLabel"

var patient_scene = preload("res://scene/patient.tscn")

func _ready():
	if not start_day_button.pressed.is_connected(_on_start_day_pressed):
		start_day_button.pressed.connect(_on_start_day_pressed)

	patient_spawn_timer.timeout.connect(_spawn_patient)
	day_timer.timeout.connect(_on_day_timer_timeout)
	
	var rooms_node = $"../World/Y-Sort/TreatmentRooms"
	for room in rooms_node.get_children():
		if room.is_in_group("ruang_rawat"):
			treatment_rooms.append(room)
			# Sambungkan sinyal dari setiap ruangan di sini jika diperlukan
			# room.cleaning_finished.connect(_on_room_cleaning_finished)
			
	treatment_rooms.sort_custom(func(a, b): return a.name < b.name)

func _process(delta: float) -> void:
	if game_started:
		update_timer_display()

func _on_start_day_pressed():
	game_started = true
	Engine.time_scale =  1.0
	reset_clinic_state()
	patient_spawn_timer.start()	
	day_timer.start()
	start_day_button.hide()
	_spawn_patient()
	
func _spawn_patient():
	if not game_started or waiting_patients.size() >= queue_positions.size():
		return
		
	var new_patient = patient_scene.instantiate()
	var queue_index = waiting_patients.size()
	$"../World/Y-Sort/Patients".add_child(new_patient)
	new_patient.global_position = queue_positions[queue_index].global_position
	
	# PENTING: Perintahkan pasien untuk memulai timer kesabarannya
	new_patient.start_patience_timer(30)
	
	waiting_patients.append(new_patient)
	new_patient.patient_clicked.connect(_on_patient_clicked)
	
func _on_day_timer_timeout():
	game_started = false
	Engine.time_scale = 0.0
	patient_spawn_timer.stop()
	start_day_button.show()
	day_timer_label.text = "Hari berakhir !"
	
func update_timer_display():
	var time_left = day_timer.time_left
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	
	# Format string agar selalu 2 digit (misal: 02:05)
	day_timer_label.text = "%02d:%02d" % [minutes, seconds]
	
func _on_patient_clicked(patient):
	if waiting_patients.is_empty() or patient != waiting_patients[0]:
		return
		
	var available_room = find_available_room()
	if available_room:
		patient.start_being_processed()
		available_room.set_state(available_room.State.OCCUPIED, "Dipanggil dari GameManager: Pasien mulai dirawat.")
		
		waiting_patients.pop_front()
		patient.queue_free()
		update_queue_positions()
		
		var patient_in_treatment = patient_scene.instantiate()
		patient_in_treatment.global_position = available_room.patient_position_marker.global_position
		$"../World/Y-Sort/Patients".add_child(patient_in_treatment)
		
		
		occupied_rooms[available_room] = patient_in_treatment
		
		patient_in_treatment.start_treatment(12)
		patient_in_treatment.hide_sprite()
		patient_in_treatment.treatment_finished.connect(_on_patient_treatment_finished)
	else:
		print("Tidak ada ruang rawat yang tersedia!")

func find_available_room():
	for room in treatment_rooms:
		if room.current_state == room.State.AVAILABLE:
			return room
	return null

func _on_patient_treatment_finished(patient):
	add_money(100)
	var room_to_free = null
	for room in occupied_rooms:
		if occupied_rooms[room] == patient:
			room_to_free = room
			break
	if room_to_free:
		occupied_rooms.erase(room_to_free)
		# DIUBAH: Tambahkan argumen alasan
		room_to_free.set_state(room_to_free.State.NEEDS_CLEANING, "Dipanggil dari GameManager: Perawatan pasien selesai.")
		
	patient.queue_free()

func reset_clinic_state():
	for patient in waiting_patients:
		patient.queue_free()
	waiting_patients.clear()
	
	for patient in occupied_rooms:
		patient.queue_free()
	occupied_rooms.clear()
	
	for room in treatment_rooms:
		if room.current_state != room.State.AVAILABLE:
			room.set_state(room.State.AVAILABLE, "Reset untuk hari baru")

func update_queue_positions():
	for i in waiting_patients.size():
		var patient_to_move = waiting_patients[i]
		patient_to_move.global_position = queue_positions[i].global_position

func add_money(amount):
	money += amount
	money_label.text = "$" + str(money)
