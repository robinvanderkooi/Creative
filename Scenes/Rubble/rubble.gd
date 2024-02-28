extends StaticBody2D

func _ready() -> void:
	var poly : Polygon2D = get_node("Poly")
	var coll : CollisionPolygon2D = get_node("CollisionPolygon2D")
	#var thePoly : PackedVector2Array = poly.polygon
	coll.polygon = poly.polygon
