extends Node2D

@onready var camera = $Camera2D

# === VARIABEL BARU UNTUK BATASAN PANNING ===
@export var pan_limit_left = -500.0   # BARIS BARU: Batas paling kiri
@export var pan_limit_right = 500.0  # BARIS BARU: Batas paling kanan
@export var pan_limit_top = -300.0    # BARIS BARU: Batas paling atas
@export var pan_limit_bottom = 300.0 # BARIS BARU: Batas paling bawah

var panning = false
var pan_start_position = Vector2.ZERO
var pan_speed = 1.0
var zoom_speed = 0.1
var min_zoom = 0.5
var max_zoom = 2.0

func _input(event):
	# === LOGIKA PANNING (PERGERAKAN MOUSE) ===
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				panning = true
				pan_start_position = event.position
			else:
				panning = false
	
	if panning and event is InputEventMouseMotion:
		var delta = pan_start_position - event.position
		self.position += delta * pan_speed
		pan_start_position = event.position
		
		# === LOGIKA BATASAN PANNING (CLAMPING) ===
		# BARIS BARU: Pastikan posisi X dan Y tidak melewati batas
		self.position.x = clamp(self.position.x, pan_limit_left, pan_limit_right)
		self.position.y = clamp(self.position.y, pan_limit_top, pan_limit_bottom)

	# === LOGIKA ZOOM (RODA MOUSE) ===
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom -= Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom += Vector2(zoom_speed, zoom_speed)
	
	# === BATASAN ZOOM (CLAMPING) ===
	camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
	camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
