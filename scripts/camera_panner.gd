extends Node2D

@onready var camera = $Camera2D

var panning = false
var pan_start_position = Vector2.ZERO
var pan_speed = 1.0
var zoom_speed = 0.1 # Kecepatan zoom
var min_zoom = 0.5   # Batas zoom in
var max_zoom = 2.0   # Batas zoom out

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

	# === LOGIKA ZOOM (RODA MOUSE) ===
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom in: Kurangi nilai zoom
			camera.zoom -= Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom out: Tambah nilai zoom
			camera.zoom += Vector2(zoom_speed, zoom_speed)
	
	# === BATASAN ZOOM (CLAMPING) ===
	camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
	camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
