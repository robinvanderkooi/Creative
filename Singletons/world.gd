extends Node

var current_data_map:=PackedInt32Array()
var current_render_map:=PackedInt32Array()
var data_distance:=2
var render_distance:=1
var terrains:=Dictionary()
var world_seed:int:
	get: return _world_seed
	set(value): _world_seed = value
var world_position:Coord:
	get: return _world_position
	set(value): _world_position = value

var _world_position:=Coord.new()
var _world_seed:=randi()
var _world_seeds:=Dictionary()

func _init() -> void:
	var c = Coord.new_coord(2,5)
	var ctoi = c.to_index()
	var itoc = _index_to_coord(ctoi)
	var hmmm = 123
	pass
func _ready() -> void:
	pass
func _process(delta: float) -> void:
	pass


#func _get_terrain_by_index(index:int) -> Terrain:
	#if !terrains.has(index):_initialize_terrain(index)
	#return terrains[index]
#func _get_terrain_by_coords(x:int,y:int)->Terrain:
	#return _get_terrain_by_index(_coords_to_index(x,y))
#func _get_terrain_by_coord(c:Coord)->Terrain:
	#return _get_terrain_by_index(_coords_to_index(c.x,c.y))

func check_terrain():
	#Testing first. We're making a single terrain spawn in.
	
	pass

func _initialize_terrain():
	var terrain_scene:=load("res://Scenes/Terrain/terrain.tscn")
	#A default Terrain is a 1000 by 1000 square.
	#Each Terrain will be 1000 px apart.
	
	var data_map := _generate_data_map()
	var render_map := _generate_render_map()
	data_map.sort()
	render_map.sort()
	
	var to_ininialize:=PackedInt32Array()
	var to_destroy:=PackedInt32Array()
	var to_render:=PackedInt32Array()
	var to_conceal:=PackedInt32Array()
	
	for ind in data_map: if !current_data_map.has(ind): to_ininialize.append(ind)
	for ind in current_data_map: if !data_map.has(ind): to_destroy.append(ind)
	for ind in render_map: if !current_render_map.has(ind): to_render.append(ind)
	for ind in current_render_map: if !render_map.has(ind): to_conceal.append(ind)
	
	print("total terrains: " + str(to_ininialize.size()))
	for index in to_ininialize:
		print("initialize: " + str(index))
		if !terrains.has(index):
			var current_scene = get_tree().current_scene
			var new_terrain:Terrain= terrain_scene.instantiate()
			var new_coords = _index_to_coord(index)
			current_scene.add_child(new_terrain)
			new_terrain.seed = world_seed + index
			new_terrain.world_position = new_coords
			new_terrain.initialize()
			var diff = new_coords.subtract(world_position)
			new_terrain.position = Vector2(1000 * diff.x, 1000 * diff.y)
			terrains[index] = new_terrain
			#terrains[index].create_debug_points()
	for index in to_render:
		print("render: " + str(index))
		#terrains[index].create_debug_scenes()
		terrains[index].create_scenes()
	current_data_map = data_map
	current_render_map = render_map

func move_scenes(v:Vector2):
	for ter in terrains.values():
		ter.position += v

func _generate_data_map() -> PackedInt32Array:
	return _generate_map_by_range(data_distance)
func _generate_render_map() -> PackedInt32Array:
	return _generate_map_by_range(render_distance)
func _generate_map_by_range(distance:int) -> PackedInt32Array:
	var results:=PackedInt32Array()
	var neg_corner := Coord.new_coord(world_position.x,world_position.y)
	for i in distance + 1:
		neg_corner.move_left()
		neg_corner.move_up()
	var x_pointer := neg_corner.copy()
	for t0 in (distance*2)+1:
		x_pointer.move_right()
		var y_pointer := x_pointer.copy()
		for t1 in (distance*2)+1:
			y_pointer.move_down()
			results.append(y_pointer.to_index())
	return results


"""Player Scipts"""
##Hard reset the world position.
func set_world_position(x:int, y:int):
	set_world_position_coord(Coord.new_coord(x,y))
func set_world_position_coord(c:Coord)->Vector2:
	if world_position.to_index() != c.to_index():
		var diff = world_position.subtract(c)
		var moveby := Vector2(diff.x * 1000, diff.y * 1000)
		move_scenes(moveby)
		world_position = c
		_initialize_terrain()
		return -moveby
	return Vector2.ZERO
##Report on your position. Sets world position if 
func set_local_position(player:Node2D,pos:Vector2):
	var new_world_position:Coord=Coord.new_coord(64,64)
	var x = floori((abs(pos.x)+500)/1000)
	var y = floori((abs(pos.y)+500)/1000)
	if x>0 || y>0:
		for n in x:
			if pos.x < 0 : new_world_position.move_left()
			else: new_world_position.move_right()
		for n in y:
			if pos.y < 0 : new_world_position.move_up()
			else: new_world_position.move_down()
	var moveby = set_world_position_coord(new_world_position)
	if player != null:
		player.position += moveby


"""Helpers"""
func _coords_to_index(x:int, y:int) -> int:
	return x + (128 * y)
func _coord_to_index(c:Coord) -> int:
	return _coords_to_index(c.x,c.y)
func _index_to_coord(i:int) -> Coord:
	var x:int = i % 128
	var y:int = (i-x)/128
	return Coord.new_coord(x,y)
