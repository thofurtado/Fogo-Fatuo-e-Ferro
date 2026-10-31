@tool
extends Path2D

@export_enum("snake", "bird", "frog", "marmoset") var species: String = "frog"
@export var pause_seconds: PackedFloat32Array = PackedFloat32Array([3,2,4])
@export var sheltered_stops: PackedInt32Array = PackedInt32Array()
@export_range(0,220,1) var elevation: float = 0
@export_range(5,160,1) var patrol_speed: float = 25

func world_points() -> PackedVector2Array:
	var points = PackedVector2Array()
	if curve:
		for index in range(curve.point_count):
			points.append(to_global(curve.get_point_position(index)))
	return points

func world_curve() -> Curve2D:
	var result = Curve2D.new()
	if curve:
		for index in range(curve.point_count):
			result.add_point(to_global(curve.get_point_position(index)),global_transform.basis_xform(curve.get_point_in(index)),global_transform.basis_xform(curve.get_point_out(index)))
	return result
