class_name GravityDecider extends Area3D

var gravAreas: Array[Area3D] = []
# the area we use if we're in no areas.
var fallback: Area3D

const GRAV_MAG = 13.2

func _ready():
	area_entered.connect(_onAreaEntered)
	area_exited.connect(_onAreaExited)

func getGravity():
	var a: Area3D = fallback
	if !gravAreas.is_empty():
		a = gravAreas[gravAreas.size() - 1]
	
	if !a:
		L.info('GravityDecider: no gravity area. using UP')
		return Vector3.UP
	
	var dir: Vector3
	if a.gravity_point:
		dir = global_position.direction_to(a.global_position + a.gravity_point_center)
	else:
		dir = a.global_basis * a.gravity_direction
	
	return dir * GRAV_MAG

func _onAreaEntered(a: Area3D):
	if a.gravity_space_override != a.SPACE_OVERRIDE_REPLACE:
		return
	gravAreas.push_back(a)

func _onAreaExited(a: Area3D):
	gravAreas.erase(a)
	if gravAreas.is_empty():
		fallback = a

