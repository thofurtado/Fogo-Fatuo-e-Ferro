extends Line2D

var mule: CharacterBody2D
var shadow_line: Line2D
var highlight: Line2D
var clock: float = 0
var tension: float = 0
var creak_cooldown: float = 0
var previous_tension: float = 0

func _ready():
	mule = get_parent()
	antialiased = true
	width = 1.8
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	shadow_line = Line2D.new()
	shadow_line.antialiased = true
	shadow_line.width = 2.7
	shadow_line.default_color = Color(0.04,0.025,0.01,0.20)
	shadow_line.position = Vector2(0.7,1.0)
	shadow_line.z_index = -1
	add_child(shadow_line)
	highlight = Line2D.new()
	highlight.antialiased = true
	highlight.width = 0.55
	highlight.position = Vector2(0,-0.3)
	highlight.default_color = Color(0.80,0.65,0.40,0.75)
	add_child(highlight)

func _process(delta):
	clock += delta
	creak_cooldown = maxf(0,creak_cooldown-delta)
	update_rope()

func update_rope():
	if not is_instance_valid(mule.follow_target): return
	var player = mule.follow_target
	var start = to_local(mule.get_rein_anchor())
	var end = to_local(player.get_rein_anchor())
	var distance = mule.global_position.distance_to(player.global_position)
	tension = clampf((distance-(mule.follow_distance-12))/27.0,0,1)
	if mule.panic_time > 0 and distance > 66: tension = maxf(tension,0.92)
	if tension>0.85 and previous_tension<=0.85 and creak_cooldown<=0:
		var scene = get_tree().current_scene
		if scene and scene.get("soundscape"): scene.soundscape.play_cue("rein_creak",-23)
		creak_cooldown = 1.6
	previous_tension = tension
	var sag = lerpf(17,1.2,tension)
	var sway = lerpf(1.2,0.08,tension)
	var curve_points = PackedVector2Array()
	for index in range(25):
		var t = float(index)/24
		var envelope = 4*t*(1-t)
		var point = start.lerp(end,t)
		point.y += envelope*sag
		point.x += sin(clock*2.4+t*PI)*envelope*sway
		curve_points.append(point)
	points = curve_points
	shadow_line.points = curve_points
	highlight.points = curve_points
	default_color = Color(0.42,0.30,0.15).lerp(Color(0.61,0.40,0.21),tension)
