extends Node

var scene: Node2D
var critters: Array[CharacterBody2D] = []
var enabled: bool = true
var reactions_enabled: bool = true
var sky_layer: Node2D

func _ready():
	scene = get_parent()
	call_deferred("_populate")

func _populate():
	sky_layer = Node2D.new()
	sky_layer.name = "FaunaSky"
	sky_layer.z_index = 50
	scene.add_child(sky_layer)
	for route in scene.get_node("WildlifeRoutes").get_children():
		var animal = preload("res://Scripts/WildlifeCritter.gd").new()
		animal.kind = route.species
		animal.patrol_curve = route.world_curve()
		animal.patrol_points = route.world_points()
		animal.position = animal.patrol_points[0]
		animal.cover = animal.patrol_points[maxi(0,animal.patrol_points.size()-2)]
		animal.pause_times = route.pause_seconds
		animal.sheltered_stops = route.sheltered_stops
		animal.perch_height = route.elevation
		animal.patrol_speed = route.patrol_speed
		animal.manager = self
		animal.name = "Fauna_"+str(critters.size()+1)+"_"+animal.kind
		if animal.kind == "bird": sky_layer.add_child(animal)
		else: scene.get_node("YSortContainer").add_child(animal)
		critters.append(animal)
		if animal.kind == "snake":
			for index in animal.sheltered_stops:
				var bush = preload("res://Scenes/SerraFern.tscn").instantiate()
				bush.position = animal.patrol_points[index]+Vector2(13,5)
				bush.scale = Vector2(0.7,0.7)
				bush.name = "Abrigo_"+route.name+str(index)
				bush.set_meta("fauna_cover",true)
				bush.get_node("Sprite2D").modulate = Color(0.87,0.96,0.82)
				scene.get_node("YSortContainer").add_child(bush)

func can_react() -> bool:
	return enabled and reactions_enabled and not scene.mission.finished and not scene.player.input_blocked and not scene.dialogue_box.visible and not scene.player.is_falling_ledge

func snake_near(snake: Node2D):
	if not can_react() or snake.is_concealed() or snake.global_position.distance_to(scene.mula.global_position) > 90:
		return
	if scene.mula.startle(snake.global_position):
		scene.mission.notify("Uma cobra! Bonita se assustou e puxou a rédea.",Color(1,0.82,0.43))

func is_position_visible(point: Vector2, height: float = 0) -> bool:
	var viewport = scene.get_viewport()
	var screen = viewport.get_canvas_transform()*(point-Vector2(0,height))
	return viewport.get_visible_rect().grow(70).has_point(screen)
