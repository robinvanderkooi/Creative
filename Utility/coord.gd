extends Object

class_name Coord

var x:int=0
var y:int=0

func up()->Coord:return new_coord(x,(y+127)%128)
func down()->Coord:return new_coord(x,(y+1)%128)
func left()->Coord:return new_coord((x+127)%128,y)
func right()->Coord:return new_coord((x+1)%128,y)

func move_up():y=(y+127)%128
func move_down():y=(y+1)%128
func move_left():x=(x+127)%128
func move_right():x=(x+1)%128

func to_index()->int:
	return (x*128)+y
func copy() -> Coord:
	return new_coord(x,y)
static func new_coord(x:int,y:int)->Coord:
	var c:=Coord.new()
	c.x = x
	c.y = y
	return c

func subtract(c:Coord) -> Coord:
	return new_coord(x-c.x, y-c.y)
