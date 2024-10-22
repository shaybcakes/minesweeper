extends PanelContainer

@onready var tilelist:Dictionary
@export var num_bombs:int = 10
@onready var notify = get_tree().root.find_child('Notify')
var heinouscount:int = 0
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	$grid.set_mouse_filter(0)
	tilelist = {}
	tilelist.all = []
	for i in range(0,10):
		tilelist[i] = []
		print(i)
		
	var grid = $grid
	for xaxis in grid.get_children():
		for yaxis in xaxis.get_children():
			var cell = int(str(xaxis.get_name()))
			tilelist[cell].append(yaxis)
			tilelist.all.append(yaxis)
	for x in range(0,10):
		for y in range(0,10):
			tile(x,y).has_flipped.connect(_on_tile_flip)
	reset(true)


func reset(first:bool = false):	
	$grid.set_mouse_filter(0)
	
	if not first:
		for cell in tilelist.all:
			if not cell.is_flipped:
				cell.flip(true)
				
			cell.mark_reset()
	await get_tree().create_timer(3).timeout
	$Label.show()
	for cell in tilelist.all:
		if cell.is_flipped:
			var anim = cell.find_child('AnimationPlayer')
			anim.play('unflip')
			cell.is_flipped = false
		cell.facevalue = 0
	var all_copy = tilelist.all.duplicate()
	print(len(tilelist.all))
	for i in range(0,num_bombs):
		var length = len(tilelist.all)- 1 - i
		var cell = all_copy[randi_range(0,length)]
		print(cell)
		cell.facevalue = 9
		all_copy.erase(cell)
	print(len(tilelist.all))
	for cell in tilelist.all: cprint([cell,": ",cell.facevalue])
	for x in range(0,10):
		
		for y in range(0,10):
			var cell = tile(x,y)
			if cell.facevalue != 9:
				var neighbours = [tile(x,y-1),tile(x+1,y-1),tile(x+1,y),tile(x+1,y+1),tile(x,y+1),tile(x-1,y+1),tile(x-1,y),tile(x-1,y-1)]
				var bomb_count:int = 0
				for n in neighbours:
					if str(n).begins_with('dum'): continue
					cprint(['COUNTCHECK ',x,',',y,' ',n,':',n.facevalue])
					if n.facevalue == 9: 
						cprint([n,' is a bomb'])
						bomb_count = bomb_count + 1
				cell.facevalue = bomb_count
				cprint(['Cell (',x,",",y,'): ',bomb_count,' Meta:',cell.facevalue])
	$grid.set_mouse_filter(1)
	$Label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tile_flip(object:Node):
	$grid.set_mouse_filter(0)
	var x:int
	var y:int
	cprint(["OBJECT CHECK",object])
	if object.facevalue == 0:
		for childx in $grid.get_children():
			x = int(str(childx.get_name()))
			for childy in childx.get_children():
				y = int(str(childy.get_name()))
				if tile(x,y) == object:
					var neighbours = [tile(x,y-1),tile(x+1,y-1),tile(x+1,y),tile(x+1,y+1),tile(x,y+1),tile(x-1,y+1),tile(x-1,y),tile(x-1,y-1)]
					for n in neighbours:
						print(n.facevalue)
						if not n.is_flipped:
							await get_tree().create_timer(0.1).timeout
							n.flip()
	if object.facevalue == 9:
		await get_tree().create_timer(3).timeout
		for cell in tilelist.all:
			if cell.facevalue == 9 and cell != object:
				cell.flip(true)
				await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(2).timeout
		reset()
	else: $grid.set_mouse_filter(1)
	
	

func pprint(dict:Dictionary,delim:String="  "):
	print(JSON.stringify(dict,delim))
	return
	
func cprint(terms:Array):
	var output = ""
	for t in terms:
		if typeof(t) == TYPE_STRING: output = output + t + " "
		else: output = output + str(t) + " "
	print(output)

func tile(x:int,y:int):
	if x < 0 or x > 9 or y < 0 or y > 9:
		#print('FUCKYWUCKY ALERT! Tried to call:'+str(x)+","+str(y))
		return($dummy)
		
	else: return(tilelist[x][y])


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.is_valid_int:
		var num = int(new_text)
		if num <= 100:
			num_bombs = num
		reset()
	elif heinouscount > 5:
		num_bombs = 100
	else: heinouscount += 1
