extends Node2D
@onready var left: Sprite2D = $left
@onready var right: Sprite2D = $right
@onready var sum: Sprite2D = $sum
@onready var sub: Sprite2D = $sub
@onready var proyect_left_right: Sprite2D = $proyect_left_right
@onready var proyect_right_left: Sprite2D = $proyect_right_left


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			left.position = viewport_pos_to_world(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right.position = viewport_pos_to_world(event.position)
			
		sum.position = right.position + left.position
		sub.position = right.position - left.position
		
		#proyect_left_right.position = (right.position/right.position.length()) * cos(left.position.angle_to(right.position)) * left.position.length()
		#proyect_right_left.position = (left.position/left.position.length()) * cos(right.position.angle_to(left.position)) * right.position.length()
		proyect_left_right.position = right.position.project(left.position)
		proyect_right_left.position = left.position.project(right.position)
		

func viewport_pos_to_world(event_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * event_pos
