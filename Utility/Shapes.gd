class_name Shapes

static func Box(size:float) -> PackedVector2Array:
	var poly : PackedVector2Array = []
	poly.append(Vector2(size/-2,size/-2))
	poly.append(Vector2(size/-2,size/2))
	poly.append(Vector2(size/2,size/2))
	poly.append(Vector2(size/2,size/-2))
	return poly

static func Circle(slices:int, radius:float) -> PackedVector2Array:
	var poly : PackedVector2Array = []
	var fullRadians := 2.0 * PI
	var subRadian := fullRadians / slices
	for i in range(slices):
		var thisRadian = subRadian * i
		var newPoint = (Vector2.UP * radius).rotated(thisRadian)
		poly.append(newPoint)
	return poly
