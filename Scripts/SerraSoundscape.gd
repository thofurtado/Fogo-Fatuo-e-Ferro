extends Node

var scene: Node2D
var loops: Dictionary = {}
var cues: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var voice_index: int = 0
var cue_counts: Dictionary = {}

func _ready():
	scene = get_parent()
	for key in ["forest_ambience","wind_loop","rain_loop","rain_roof","river_loop","waterfall_loop","fire_loop"]:
		var player = AudioStreamPlayer.new()
		player.stream = load("res://Assets/SFX/"+key+".wav")
		player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		player.volume_db = -80
		add_child(player)
		loops[key] = player
		if DisplayServer.get_name() != "headless": player.play()
	for key in ["inventory_click","chest_cue","rest_cue","offering_cue","delivery_cue","hit_thud","rein_creak","snake_hiss"]:
		cues[key] = load("res://Assets/SFX/"+key+".wav")
	for index in range(6):
		var voice = AudioStreamPlayer.new()
		voice.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(voice)
		voices.append(voice)

func play_cue(key: String, volume: float = -16):
	if not cues.has(key): return
	cue_counts[key] = int(cue_counts.get(key,0))+1
	var voice = voices[voice_index]
	voice_index = (voice_index+1)%voices.size()
	voice.stream = cues[key]
	voice.volume_db = volume
	if DisplayServer.get_name() != "headless": voice.play()

func _process(_delta):
	var weather = scene.weather
	var wet = weather.rain
	var indoors = weather.sheltered
	_mix("forest_ambience",0.65-wet*0.3,-22)
	_mix("wind_loop",weather.wind,-23)
	_mix("rain_loop",wet*(0.22 if indoors else 1.0),-17)
	_mix("rain_roof",wet if indoors else 0.0,-17)
	var position = scene.player.global_position
	var river = scene.get_node("GroundLayer/RioCubatao").points
	var distance = 10000.0
	for i in range(river.size()-1):
		distance = minf(distance,position.distance_to(Geometry2D.get_closest_point_to_segment(position,river[i],river[i+1])))
	_mix("river_loop",clampf(1-distance/240.0,0,1),-23)
	_mix("waterfall_loop",clampf(1-position.distance_to(Vector2(730,960))/310.0,0,1),-19)
	_mix("fire_loop",clampf(1-position.distance_to(scene.get_node("YSortContainer/RanchoFogueira").global_position)/180.0,0,1),-20)

func _mix(key: String, amount: float, base: float):
	loops[key].volume_db = lerpf(loops[key].volume_db,base+linear_to_db(maxf(amount,0.0001)),0.12)

func _exit_tree():
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
