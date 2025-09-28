# GameManager.gd
extends Node

# Uang dan status game
var money = 0
var game_started = false
@export var queue_positions: Array[Marker2D] = []
var waiting_patients: Array[Node] = []
var treatment_rooms: Array[Marker2D] = []
var occupied_rooms: Dictionary = {}

# Referensi ke Node lain
@onready var start_day_button = $"../CanvasLayer/right_up/Start Day"
@onready var money_label = $"../CanvasLayer/MarginContainer2/Money"
@onready var patient_spawn_timer = $PatientSpawnerTimer


# Preload scene pasien
var patient_scene = preload("res://scene/patient.tscn")


func _ready():
	start_day_button.pressed.connect(_on_start_day_pressed)
	patient_spawn_timer.timeout.connect(_spawn_patient)
	

	var rooms_node = $"../World/TreatmentRooms"
	for room_marker in rooms_node.get_children():
		if room_marker is Marker2D:
			treatment_rooms.append(room_marker)
	treatment_rooms.sort_custom(func(a, b): return a.name < b.name)

	
func _on_start_day_pressed() -> void:
	game_started = true
	patient_spawn_timer.start()
	start_day_button.hide()
	print("Hari dimulai!")
	_spawn_patient()
	
func _spawn_patient():
	print("--- Kondisi Array saat _spawn_patient() ---")
	for marker in queue_positions:
		print("- ", marker.name)
	print("-----------------------------------------")
	
	if not game_started:
		return
		
	# Cek apakah antrean masih ada tempat
	if waiting_patients.size() >= queue_positions.size():
		print("Antrean penuh, pasien tidak jadi datang!")
		return
		
	var new_patient = patient_scene.instantiate()
	
	# Tentukan posisi antrean berikutnya yang kosong
	var queue_index = waiting_patients.size()
	var target_position = queue_positions[queue_index].global_position
	
	
	# Langsung tempatkan pasien di posisi antrean yang benar
	new_patient.global_position = target_position
	
	# Tambahkan pasien ini ke dalam daftar antrean kita
	waiting_patients.append(new_patient)
	
	new_patient.patient_clicked.connect(_on_patient_clicked)
	$"../World".add_child(new_patient)
	print("Pasien baru datang di antrean ke-", queue_index + 1)
	print(target_position)
	
func _on_patient_clicked(patient):
	# Pastikan yang diklik adalah pasien di paling depan
	if waiting_patients.is_empty() or patient != waiting_patients[0]:
		print("Harap layani pasien di antrean paling depan!")
		return
		
	var available_room = find_available_room()
	
	if available_room:
		print("Ruang rawat tersedia! Memproses pasien...")
		
		# 1. Hapus pasien dari daftar antrean
		waiting_patients.pop_front()
		# Hapus objek pasien yang di antrean dari game
		patient.queue_free()
		# 2. Update posisi antrean di belakangnya
		update_queue_positions()
		# 3. BUAT PASIEN BARU di ruang rawat
		var patient_in_treatment = patient_scene.instantiate()
		patient_in_treatment.global_position = available_room.global_position
		$"../World".add_child(patient_in_treatment)
		# 4. Tandai ruangan sebagai terisi oleh pasien baru
		occupied_rooms[available_room] = patient_in_treatment
		# 5. Mulai proses perawatan pada pasien baru
		patient_in_treatment.start_treatment(12)
		# 6. Hubungkan sinyal selesai perawatan dari pasien baru
		patient_in_treatment.treatment_finished.connect(_on_patient_treatment_finished)
	else:
		print("Tidak ada ruang rawat yang tersedia!")


func find_available_room():
	for room in treatment_rooms:
		if not occupied_rooms.has(room):
			return room
	return null # Kembalikan null jika tidak ada ruangan kosong

func _on_patient_treatment_finished(patient):
	print("Perawatan untuk pasien selesai. Dapat uang!")
	add_money(100) # Contoh menambah uang
	
	# Cari tahu pasien ini ada di ruangan mana
	var room_to_free = null
	for room in occupied_rooms:
		if occupied_rooms[room] == patient:
			room_to_free = room
			break
			
	# Kosongkan ruangan tersebut
	if room_to_free:
		occupied_rooms.erase(room_to_free)
		print(room_to_free.name, " sekarang tersedia.")
		
	# Hapus pasien dari game
	patient.queue_free()

# FUNGSI BARU UNTUK MENGGERAKKAN SEMUA PASIEN DI ANTRIAN
func update_queue_positions():
	# Loop melalui setiap pasien yang masih menunggu
	for i in waiting_patients.size():
		var patient_to_move = waiting_patients[i]
		var new_target_position = queue_positions[i].global_position
		patient_to_move.global_position = new_target_position

func add_money(amount):
	money += amount
	money_label.text = "Uang : $" + str(money)
