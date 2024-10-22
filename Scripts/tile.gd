extends PanelContainer

signal has_flipped
@export var facevalue:int = 0
@export var is_flipped:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func flip(is_suppressed:bool = false):
	$tileback/tileface.set_frame(facevalue)
	$AnimationPlayer.play('card_flip')
	is_flipped = true
	if not is_suppressed:
		has_flipped.emit(self)
	
func mark():
	if $tileback.get_frame() == 0:
		$tileback.set_frame(1)
	elif $tileback.get_frame() == 1:
		$tileback.set_frame(0)

func mark_reset():
	$tileback.set_frame(0)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.get_button_index() == 1:
			flip()
		elif event.get_button_index() == 2:
			mark()
