extends Node

var scene: Node2D
var critters: Array[CharacterBody2D] = []
var enabled: bool = true

func _ready():
	scene = get_parent()
	call_deferred("_populate")

func _populate():
	# Deliberate habitats keep encounters readable and avoid an arbitrary swarm.
	var habitats = [
		["snake",Vector2(960,1650),Vector2(1040,1630)],
		["snake",Vector2(940,1540),Vector2(1010,1550)],
		["snake",Vector2(1170,480),Vector2(1240,470)],
		["bird",Vector2(865,1550),Vector2(1020,1370)],
		["bird",Vector2(1140,1200),Vector2(1310,1080)],
		["bird",Vector2(960,580),Vector2(1180,440)],
		["frog",Vector2(772,1490),Vector2(735,1535)],
		["frog",Vector2(744,1280),Vector2(710,1320)],
		["frog",Vector2(705,1060),Vector2(690,1110)],
		["marmoset",Vector2(640,1400),Vector2(555,1335)],
		["marmoset",Vector2(1300,1030),Vector2(1410,960)],
		["marmoset",Vector2(1175,650),Vector2(1260,575)]
	]
	for definition in habitats:
		var animal = preload("res://Scripts/WildlifeCritter.gd").new()
		animal.kind = definition[0]
		animal.position = definition[1]
		animal.cover = definition[2]
		animal.manager = self
		animal.name = "Fauna_"+str(critters.size()+1)+"_"+animal.kind
		scene.get_node("YSortContainer").add_child(animal)
		critters.append(animal)

func can_react() -> bool:
	return enabled and not scene.mission.finished and not scene.player.input_blocked and not scene.dialogue_box.visible and not scene.player.is_falling_ledge

func snake_near(snake: Node2D):
	if not can_react() or snake.global_position.distance_to(scene.mula.global_position) > 90:
		return
	if scene.mula.startle(snake.global_position):
		scene.mission.notify("Uma cobra! Bonita se assustou e puxou a rédea.",Color(1,0.82,0.43))
