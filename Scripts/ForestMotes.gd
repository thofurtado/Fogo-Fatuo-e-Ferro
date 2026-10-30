extends Node2D
var player: Node2D
var time: float = 0
func _process(delta):
	time += delta
	if is_instance_valid(player):
		position = player.global_position
	queue_redraw()
func _draw():
	for i in range(16):
		var x = fposmod(i*137.5 + time*(7+i%4), 720.0)-360
		var y = fposmod(i*91.7 + sin(time*0.2+i)*20 + time*2, 1100.0)-550
		var alpha = 0.16 + sin(time+i)*0.06
		draw_line(Vector2(x,y),Vector2(x+3,y-1),Color(0.8,0.85,0.47,alpha),1.2,true)
