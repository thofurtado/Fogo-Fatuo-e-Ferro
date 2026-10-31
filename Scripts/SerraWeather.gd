extends Node2D

var scene: Node2D
var elapsed: float = 0
var rain: float = 0
var wind: float = 0.3
var rain_target: float = 0
var auto_cycle: bool = true
var phase: int = 0
var phase_time: float = 0
var sheltered: bool = false
var shelter: Rect2
var foliage_materials: Dictionary = {}
const DURATIONS = [45.0,30.0,55.0,35.0]
const INTENSITIES = [0.0,0.35,0.9,0.12]

func _ready():
	scene = get_parent()
	z_index = 60
	shelter = Rect2(scene.get_node("YSortContainer/RanchoCabana").global_position+Vector2(-65,-44),Vector2(130,60))
	for actor in scene.get_node("YSortContainer").get_children():
		if str(actor.name).begins_with("Tree_") or str(actor.name).begins_with("Samambaia"):
			decorate_foliage(actor.get_node("Sprite2D"))

func decorate_foliage(sprite: Sprite2D):
	var height = sprite.texture.get_height()
	if not foliage_materials.has(height):
		var material = ShaderMaterial.new()
		material.shader = preload("res://Assets/Shaders/foliage_wind.gdshader")
		material.set_shader_parameter("sprite_height",float(height))
		material.set_shader_parameter("sway_pixels",7.0 if height<700 else 60.0)
		foliage_materials[height] = material
	sprite.material = foliage_materials[height]

func set_weather(intensity: float, immediate: bool = false):
	auto_cycle = false
	rain_target = clampf(intensity,0,1)
	if immediate:
		rain = rain_target
		RenderingServer.global_shader_parameter_set("serra_rain",rain)

func is_sheltered(point: Vector2) -> bool:
	return shelter.has_point(point)

func status_text() -> String:
	if sheltered and rain>0.1: return "Abrigo do rancho · chuva no telhado"
	if rain>0.65: return "Chuva forte · vento na mata"
	if rain>0.12: return "Garoa · chão molhado"
	return "Tempo aberto · brisa na serra"

func _process(delta):
	elapsed += delta
	if auto_cycle:
		phase_time += delta
		if phase_time >= DURATIONS[phase]:
			phase_time = 0
			phase = (phase+1)%DURATIONS.size()
			rain_target = INTENSITIES[phase]
	rain = move_toward(rain,rain_target,delta*0.055)
	wind = 0.25+rain*0.65+(sin(elapsed*0.31)+1)*0.11
	RenderingServer.global_shader_parameter_set("serra_rain",rain)
	RenderingServer.global_shader_parameter_set("serra_wind",wind)
	sheltered = is_sheltered(scene.player.global_position)
	scene.player.weather_speed_factor = 1.0 if sheltered else 1.0-rain*0.06
	for actor in [scene.player,scene.mula]:
		actor.set_meta("under_roof",is_sheltered(actor.global_position))
	var roof = scene.get_node("YSortContainer/RanchoCabana/Sprite2D")
	roof.modulate.a = move_toward(roof.modulate.a,0.58 if sheltered else 1.0,delta*2)
	if scene.mission and scene.mission.weather_label:
		scene.mission.weather_label.text = status_text()
	queue_redraw()

func _draw():
	if not scene or rain<0.02: return
	var viewport = get_viewport()
	var inverse = viewport.get_canvas_transform().affine_inverse()
	var rect = Rect2(inverse*Vector2.ZERO,inverse*viewport.get_visible_rect().size-inverse*Vector2.ZERO)
	draw_rect(rect,Color(0.08,0.12,0.17,rain*0.10))
	var count = mini(240,int(rect.size.x*rect.size.y/3000.0*rain))
	for index in range(count):
		var point = rect.position+Vector2(fposmod(index*89.13+elapsed*wind*42,rect.size.x),fposmod(index*157.6+elapsed*(360+index%7*15),rect.size.y))
		if is_sheltered(point): continue
		draw_line(point,point+Vector2(wind*9,13+rain*10),Color(0.70,0.79,0.88,0.16+rain*0.15),1,true)
	# Restrained ripples read as rain hitting the ground rather than a screen filter.
	for index in range(mini(38,count/4)):
		var point = rect.position+Vector2(fposmod(index*127.7,rect.size.x),fposmod(index*91.3,rect.size.y))
		if is_sheltered(point): continue
		var age = fposmod(elapsed*2.3+index*0.17,1)
		draw_arc(point,1+age*3,0,PI,8,Color(0.70,0.82,0.89,(1-age)*rain*0.22),1,true)

func _exit_tree():
	RenderingServer.global_shader_parameter_set("serra_rain",0.0)
	RenderingServer.global_shader_parameter_set("serra_wind",0.3)
