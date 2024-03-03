extends Node2D

class_name Terrain

#TODO REWORK THIS CLASS TO WORK WITH WORLD

@export var count : int = 400
@export var width : int = 1000
@export var height : int = 1000
@export var seed : int = -1
@export var edge_range:float = 200

var world_position:Coord

#var points : PackedVector2Array = []
var bigpoints : PackedVector2Array = []
var delaunay : PackedInt32Array = []
var neighbor_triangles := Dictionary()
var neighbor_points := Dictionary()

var other_neighbor_counts := PackedInt32Array() 
var other_neighbor_indexes := PackedInt32Array()

var halfway_points := []
var perpendicular_vectors := []
var perpendicular_intersections := []

var point_polyIds:=Dictionary()
var point_values:=Dictionary()

var _randy:RandomNumberGenerator = null
var _hasInitialized := false

var _bigpoint_debuginfo:PackedStringArray=[]

#func _ready() -> void:
	#GeneratePoints()
	#var special_list = [] #[10]
	#for n in count:
		#neighbor_triangles[n] = []
		#neighbor_points[n] = []
		##var visual_point := Polygon2D.new()
		##visual_point.polygon = [Vector2(-3,-3),Vector2(-3,3),Vector2(3,3),Vector2(3,-3)]
		##visual_point.color = Color.DARK_RED
		##visual_point.position = points[n]
		##visual_point.z_index = 1
		##add_child(visual_point)
		#if special_list.has(n):#special point for debugging
			#var Special_point := Polygon2D.new()
			#Special_point.polygon = Shapes.Circle(12,6)
			#Special_point.color = Color.DEEP_SKY_BLUE
			#Special_point.position = points[n]
			#Special_point.z_index = 2
			#print(points[n])
			#add_child(Special_point)
	#delaunay = Geometry2D.triangulate_delaunay(points)
	##for iD in range(0,delaunay.size(),3):
		##var line := Line2D.new()
		##line.add_point(points[delaunay[iD+0]])
		##line.add_point(points[delaunay[iD+1]])
		##line.add_point(points[delaunay[iD+2]])
		##line.closed = true
		##line.width = 1
		##add_child(line)
	#for iP in count:
		#for iD in range(0,delaunay.size(),3):
			#if delaunay[iD] == iP || delaunay[iD+1] == iP || delaunay[iD+2] == iP :
				#neighbor_triangles[iP].append([delaunay[iD],delaunay[iD+1],delaunay[iD+2]])
				#if delaunay[iD] != iP && !neighbor_points[iP].has(delaunay[iD]) :
					#neighbor_points[iP].append(delaunay[iD])
				#if delaunay[iD+1] != iP && !neighbor_points[iP].has(delaunay[iD+1]) :
					#neighbor_points[iP].append(delaunay[iD+1])
				#if delaunay[iD+2] != iP && !neighbor_points[iP].has(delaunay[iD+2]) :
					#neighbor_points[iP].append(delaunay[iD+2])
	#for p in points.size():
		#halfway_points.append([])
		#perpendicular_vectors.append([])
		#perpendicular_intersections.append([])
		#neighbor_points[p].sort_custom(func(a, b): return (points[p] - points[a]).angle() > (points[p] - points[b]).angle())
		#for n in neighbor_points[p].size():
			#var index = neighbor_points[p][n]
			#halfway_points[p].append((points[index] + points[p]) / 2.0)
			#if special_list.has(p):
				#var poly := Polygon2D.new()
				#poly.polygon = Shapes.Circle(12,(n*2)+2)
				#poly.position = points[index]
				#poly.color = Color.BLUE_VIOLET
				#poly.z_index = 4
				#add_child(poly)
		#var i = 0
		#for n in neighbor_points[p]:
			#perpendicular_vectors[p].append((points[n] - points[p]).orthogonal().normalized())
			##var visual_perpendicular := Polygon2D.new()
			##visual_perpendicular.color = Color.DODGER_BLUE
			##visual_perpendicular.polygon = Shapes.Box(3)
			##visual_perpendicular.position = halfway_points[p][i] + (perpendicular_vectors[p][i] * 3.0)
			##add_child(visual_perpendicular)
			##var visual_perpendicular2 := Polygon2D.new()
			##visual_perpendicular2.color = Color.DODGER_BLUE
			##visual_perpendicular2.polygon = Shapes.Box(3)
			##visual_perpendicular2.position = halfway_points[p][i] - (perpendicular_vectors[p][i] * 3.0)
			##add_child(visual_perpendicular2)
				#
			#i+=1
		#for n in neighbor_points[p].size():
			#var this_point = points[neighbor_points[p][n]]
			#var np = (n+1) % neighbor_points[p].size()
			#var next_point = points[neighbor_points[p][np]]
			#var this_halfway = (points[p] + this_point) / 2.0
			#var next_halfway = (points[p] + next_point) / 2.0
			#var intersection = Geometry2D.line_intersects_line(
				#halfway_points[p][n],
				#perpendicular_vectors[p][n],
				#halfway_points[p][np],
				#perpendicular_vectors[p][np]
			#)
			#perpendicular_intersections[p].append(intersection)
			#if special_list.has(p):
				#var halfline := Line2D.new()
				#halfline.add_point(this_halfway)
				#halfline.add_point(next_halfway)
				#halfline.width = 2
				#halfline.default_color = Color.LIME_GREEN
				#add_child(halfline)
		#
		#var poly := Polygon2D.new()
		#if (true || special_list.has(p)) && Geometry2D.is_point_in_polygon(points[p],perpendicular_intersections[p]):
			#var clipped:PackedVector2Array= perpendicular_intersections[p]
			#poly.polygon = clipped
			#poly.color = Color(randf(),randf(),randf())
			#poly.z_index = -1
			#poly.name = "point" + str(p)
			##poly.position = points[p]
			#point_polyIds[p] = poly.get_instance_id()
			#add_child(poly)
	#RandomizeTerrain()
	#while StablizeTerrain():pass
	#var hmmm = 123

func create_debug_points():
	var norm_label_settings:LabelSettings = LabelSettings.new()
	norm_label_settings.font_color = (Color.LIGHT_SALMON + Color.WHITE)/2
	var other_label_settings:LabelSettings = LabelSettings.new()
	other_label_settings.font_color = (Color.LIGHT_BLUE + Color.WHITE)/2
	for p in bigpoints.size():
		var pnt = bigpoints[p]
		var visual_point := Polygon2D.new()
		visual_point.polygon = [Vector2(-5,0),Vector2(0,5),Vector2(5,0),Vector2(0,-5)]
		visual_point.color = Color.BLACK
		visual_point.position = pnt
		visual_point.z_index = 3
		add_child(visual_point)
		var visual_point_ui : Label=Label.new()
		visual_point_ui.text = _bigpoint_debuginfo[p]
		visual_point_ui.scale = Vector2.ONE * 0.3
		if p < count:
			visual_point_ui.label_settings = norm_label_settings
		else:
			visual_point_ui.label_settings = other_label_settings
			visual_point_ui.position += Vector2(0,-6)
		visual_point.add_child(visual_point_ui)
		add_child(visual_point_ui)
	var new_box:Line2D=Line2D.new()
	new_box.add_point(Vector2(-500,-500))
	new_box.add_point(Vector2(-500,500))
	new_box.add_point(Vector2(500,500))
	new_box.add_point(Vector2(500,-500))
	new_box.closed = true
	new_box.width = 2
	new_box.default_color = Color.ANTIQUE_WHITE
	new_box.z_index = -10
	add_child(new_box)
	var position_ui : Label=Label.new()
	position_ui.text = str(world_position.x) + ", " + str(world_position.y)
	add_child(position_ui)


func create_debug_scenes():
	var norm_label_settings:LabelSettings = LabelSettings.new()
	norm_label_settings.font_color = (Color.LIGHT_SALMON + Color.WHITE)/2
	var other_label_settings:LabelSettings = LabelSettings.new()
	other_label_settings.font_color = (Color.LIGHT_BLUE + Color.WHITE)/2

	var new_box:Line2D=Line2D.new()
	new_box.add_point(Vector2(-500,-500))
	new_box.add_point(Vector2(-500,500))
	new_box.add_point(Vector2(500,500))
	new_box.add_point(Vector2(500,-500))
	new_box.closed = true
	new_box.width = 2
	new_box.default_color = Color.ANTIQUE_WHITE
	new_box.z_index = -10
	add_child(new_box)
	DoDelaunayBetter()
	print("bigpoint size "+str(bigpoints.size()))
	var original_points := bigpoints.slice(0,count)
	var other_points := bigpoints.slice(count)
	for p in bigpoints.size():
		var visual_point_ui : Label=Label.new()
		visual_point_ui.text = _bigpoint_debuginfo[p]
		visual_point_ui.scale = Vector2.ONE * 0.3
		if p < count:
			visual_point_ui.label_settings = norm_label_settings
		else:
			visual_point_ui.label_settings = other_label_settings
			visual_point_ui.position += Vector2(0,-6)
		if p < count:
			var visual_point := Polygon2D.new()
			visual_point.polygon = [Vector2(-3.5,0),Vector2(0,3.5),Vector2(3.5,0),Vector2(0,-3.5)]
			visual_point.color = Color.DARK_RED
			visual_point.position = bigpoints[p]
			visual_point.z_index = 1
			visual_point.add_child(visual_point_ui)
			add_child(visual_point)
		else:
			var visual_point := Polygon2D.new()
			visual_point.polygon = [Vector2(-8,-8),Vector2(-8,8),Vector2(8,8),Vector2(8,-8)]
			visual_point.color = Color.DARK_BLUE
			visual_point.position = bigpoints[p]
			visual_point.z_index = 2
			visual_point.add_child(visual_point_ui)
			add_child(visual_point)
	for p in count:
		var my_neighbors = neighbor_points[p]
		for n in my_neighbors.size():
			var my_neighbor = my_neighbors[n]
			var new_line:Line2D=Line2D.new()
			new_line.add_point(bigpoints[p])
			new_line.add_point(bigpoints[my_neighbor])
			new_line.default_color = Color.BROWN
			new_line.width = 1
			add_child(new_line)
		if true: #p == 10:
			for n in perpendicular_intersections[p].size():
				var next_n = (n+1)%perpendicular_intersections[p].size()
				var new_line:Line2D=Line2D.new()
				new_line.add_point(perpendicular_intersections[p][n])
				new_line.add_point(perpendicular_intersections[p][next_n])
				new_line.default_color = Color.LIGHT_CORAL
				new_line.width = 1
				add_child(new_line)
		

func create_scenes():
	if neighbor_points.is_empty():
		DoDelaunayBetter()
	if !point_polyIds.is_empty(): return
	
	for p in count:
		var poly := Polygon2D.new()
		var clipped:PackedVector2Array= perpendicular_intersections[p]
		poly.polygon = clipped
		poly.color = Color(randf(),randf(),randf())
		poly.z_index = -1
		poly.name = "point" + str(p)
		#poly.position = points[p]
		point_polyIds[p] = poly.get_instance_id()
		add_child(poly)
	
	StablizeTerrain()
	ColorTerrain()
	
	var hmmm = 123

func remove_scenes():
	if !point_polyIds.is_empty():
		for instance_id in point_polyIds:
			instance_from_id(instance_id).free()
		point_polyIds.clear()


func initialize():
	GeneratePoints()
	AssignValues()
	
	_hasInitialized = true
	var hmmm = 123

#func DoDelaunay():
	#for n in count:
		#neighbor_triangles[n] = []
		#neighbor_points[n] = []
	#delaunay = Geometry2D.triangulate_delaunay(points)
	#for iP in count:
		#for iD in range(0,delaunay.size(),3):
			#if delaunay[iD] == iP || delaunay[iD+1] == iP || delaunay[iD+2] == iP :
				#neighbor_triangles[iP].append([delaunay[iD],delaunay[iD+1],delaunay[iD+2]])
				#if delaunay[iD] != iP && !neighbor_points[iP].has(delaunay[iD]) :
					#neighbor_points[iP].append(delaunay[iD])
				#if delaunay[iD+1] != iP && !neighbor_points[iP].has(delaunay[iD+1]) :
					#neighbor_points[iP].append(delaunay[iD+1])
				#if delaunay[iD+2] != iP && !neighbor_points[iP].has(delaunay[iD+2]) :
					#neighbor_points[iP].append(delaunay[iD+2])
	#for p in points.size():
		#halfway_points.append([])
		#perpendicular_vectors.append([])
		#perpendicular_intersections.append([])
		#neighbor_points[p].sort_custom(func(a, b): return (points[p] - points[a]).angle() > (points[p] - points[b]).angle())
		#for n in neighbor_points[p].size():
			#var index = neighbor_points[p][n]
			#halfway_points[p].append((points[index] + points[p]) / 2.0)
		#var i = 0
		#for n in neighbor_points[p]:
			#perpendicular_vectors[p].append((points[n] - points[p]).orthogonal().normalized())
			#i+=1
		#for n in neighbor_points[p].size():
			#var this_point = points[neighbor_points[p][n]]
			#var np = (n+1) % neighbor_points[p].size()
			#var next_point = points[neighbor_points[p][np]]
			#var this_halfway = (points[p] + this_point) / 2.0
			#var next_halfway = (points[p] + next_point) / 2.0
			#var intersection = Geometry2D.line_intersects_line(
				#halfway_points[p][n],
				#perpendicular_vectors[p][n],
				#halfway_points[p][np],
				#perpendicular_vectors[p][np]
			#)
			#perpendicular_intersections[p].append(intersection)
func DoDelaunayBetter():
	#other points
	for x in range(-1,2):
		for y in range(-1,2):
			if x==0 && y==0:continue
			var new_world_position:Coord = world_position.copy()
			if x == -1 : new_world_position.move_left()
			if x == 1 : new_world_position.move_right()
			if y == -1 : new_world_position.move_up()
			if y == 1 : new_world_position.move_down()
			var other_terrain:Terrain = World.terrains[new_world_position.to_index()]
			var other_points = other_terrain.bigpoints.slice(0,count)
			var count_added = 0
			for p in other_points.size():
				var pnt = other_points[p]
				var max_range = edge_range
				if x == -1 && pnt.x < max_range: continue
				if x == 1 && pnt.x > -max_range: continue
				if y == -1 && pnt.y < max_range: continue
				if y == 1 && pnt.y > -max_range: continue
				count_added+=1
				var new_point:Vector2 = pnt + Vector2(x * 1000,y * 1000)
				bigpoints.append(new_point)
				_bigpoint_debuginfo.append("Pnt " + str(p) + " in " + new_world_position.to_string())
			other_neighbor_counts.append(count_added)
			other_neighbor_indexes.append(new_world_position.to_index())
			print(["left","middle","right"][x+1]+" "+["top","middle","bottom"][y+1]+" "+str(count_added))
	
	for n in count:
		neighbor_triangles[n] = []
		neighbor_points[n] = []
	delaunay = Geometry2D.triangulate_delaunay(bigpoints)
	for iP in count:
		for iD in range(0,delaunay.size(),3):
			if delaunay[iD] == iP || delaunay[iD+1] == iP || delaunay[iD+2] == iP :
				neighbor_triangles[iP].append([delaunay[iD],delaunay[iD+1],delaunay[iD+2]])
				if delaunay[iD] != iP && !neighbor_points[iP].has(delaunay[iD]) :
					neighbor_points[iP].append(delaunay[iD])
				if delaunay[iD+1] != iP && !neighbor_points[iP].has(delaunay[iD+1]) :
					neighbor_points[iP].append(delaunay[iD+1])
				if delaunay[iD+2] != iP && !neighbor_points[iP].has(delaunay[iD+2]) :
					neighbor_points[iP].append(delaunay[iD+2])
	for p in count:
		halfway_points.append([])
		perpendicular_vectors.append([])
		perpendicular_intersections.append([])
		neighbor_points[p].sort_custom(func(a, b): return (bigpoints[p] - bigpoints[a]).angle() > (bigpoints[p] - bigpoints[b]).angle())
		for n in neighbor_points[p].size():
			var index = neighbor_points[p][n]
			halfway_points[p].append((bigpoints[index] + bigpoints[p]) / 2.0)
		var i = 0
		for n in neighbor_points[p]:
			perpendicular_vectors[p].append((bigpoints[n] - bigpoints[p]).orthogonal().normalized())
			i+=1
		for n in neighbor_points[p].size():
			var this_point = bigpoints[neighbor_points[p][n]]
			var np = (n+1) % neighbor_points[p].size()
			var next_point = bigpoints[neighbor_points[p][np]]
			var this_halfway = (bigpoints[p] + this_point) / 2.0
			var next_halfway = (bigpoints[p] + next_point) / 2.0
			var intersection = Geometry2D.line_intersects_line(
				halfway_points[p][n],
				perpendicular_vectors[p][n],
				halfway_points[p][np],
				perpendicular_vectors[p][np]
			)
			perpendicular_intersections[p].append(intersection)

func GeneratePoints():
	_randy = RandomNumberGenerator.new()
	_randy.seed = seed
	for i in count:
		bigpoints.append(Vector2(_randy.randf_range(width/-2,width/2),_randy.randf_range(width/-2,width/2)))
		_bigpoint_debuginfo.append("Pnt " + str(i) + " in " + world_position.to_string())
		


func AssignValues():
	for p in count:
		point_values[p]=roundi(_randy.randf())

func ColorTerrain():
	for p in count:
		if !point_polyIds.has(p):continue
		var poly:Polygon2D = instance_from_id(point_polyIds[p])
		var val:int = point_values[p]
		
		if val % 2 == 0:
			poly.color = Color.BLACK
		else:
			poly.color = Color.WHITE

func StablizeTerrain():
	var changed = true
	while changed:
		changed = false
		for p in count:
			var myval:int=point_values[p]
			var neighbor_total:= 0.0
			var neighbor_count:int= neighbor_points[p].size()
			for n in neighbor_points[p].size():
				var neighbor_index = neighbor_points[p][n]
				var neighbor_value = 1.0
				if point_values.has(neighbor_index):
					neighbor_value = point_values[neighbor_index]
				else:
					var foreign_lookup = get_foreign_index(neighbor_index-count)
					var foreign_terrain:Terrain=World.terrains[foreign_lookup[1]]
					neighbor_value = foreign_terrain.point_values[foreign_lookup[0]]
				neighbor_total += neighbor_value
			var ratio = neighbor_total / neighbor_count
			if ratio > 0.50 && myval == 0:
				point_values[p] = 1.0
				changed = true
			if ratio < 0.50 && myval == 1:
				point_values[p] = 0.0
				changed = true


func draw_polys():
	pass


func get_foreign_index(p:int)->Array:
	for n in other_neighbor_counts.size():
		if p < other_neighbor_counts[n]:
			return [p, other_neighbor_indexes[n]]
		else:
			p -= other_neighbor_counts[n]
	return []
