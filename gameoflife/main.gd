extends Node2D

var cells = [{}, {}]

var to_check = {}

@export var alive_color: Color = Color.AQUA
@export var grid_pix_size: int = 32

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			place_cell(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			remove_cell(event.position)
	if event.is_action_pressed("ui_cancel"):
		print("CANCEL")
		get_tree().quit()
	if event.is_action_pressed("ui_accept"):
		print("START/STOP")
		start_stop()
	if event.is_action_pressed("ui_reset"):
		print("RESET")
		reset()
	
func place_cell(pos: Vector2):
	var grid_pos = get_grid_pos(pos)
	print("Grid cell pos: " + str(grid_pos))
	if not cells[0].has(grid_pos):
		add_new_cell(grid_pos)
	
func add_new_cell(grid_pos: Vector2, is_in_current_grid: bool = true):
	var pos = grid_pos * float(grid_pix_size)
	#Create the Cell node
	var cell = $Cell.duplicate() #create
	cell.position = pos
	add_child(cell)
	#--------------------
	cell.show() #Make it visible
	if is_in_current_grid:
		cells[0][grid_pos] = cell
	else:
		cells[1][grid_pos] = cell
	
func get_grid_pos(pos: Vector2) -> Vector2:
	var pixels = float(grid_pix_size)
	return pos.snapped(Vector2(pixels, pixels)) / pixels

func remove_cell(pos: Vector2):
	var key = get_grid_pos(pos)
	if cells[0].has(key):
		cells[0][key].queue_free() #Delete from godot memory (the instance)
		cells[0].erase(key)
		cells[1].erase(key)

func start_stop():
	if $Timer.is_stopped() and cells[0].size() > 0:
		$Timer.start()
		print("RUNNING")
	else:
		$Timer.stop()
		print("STOPPED")
	
func reset():
	$Timer.stop()
	for key in cells[0].keys():
		cells[0][key].queue_free()
	cells[0].clear()
	cells[1].clear()


func _on_timer_timeout() -> void:
	set_killed_cells() 
	set_add_new_cells()
	destroy_cells()
	cells.reverse()
	cells[1].clear()
	
func destroy_cells():
	for key in cells[0]:
		if not cells[1].has(key):
			cells[0][key].queue_free()

func set_killed_cells():
	for key in cells[0].keys():
		var n = get_num_live_cells(key)
		if n == 2 or n == 3: # Alive
			cells[1][key] = cells[0][key]
		else: # Dead
			pass

func get_num_live_cells(grid_pos: Vector2, first_pass = true):
	var num_live_cells = 0
	for y in [-1, 0, 1]:
		for x in [-1, 0, 1]:
			if not (x == 0 and y == 0):
				var new_pos = grid_pos + Vector2(x, y)
				if cells[0].has(new_pos):
					num_live_cells += 1 #if alive
				else:
					if first_pass:
						to_check[new_pos] = true
	return num_live_cells

func set_add_new_cells():
	for grid_pos in to_check:
		if not cells[1].has(grid_pos):
			var n = get_num_live_cells(grid_pos, false)
			if n == 3 :
				add_new_cell(grid_pos,false)
	to_check.clear()
