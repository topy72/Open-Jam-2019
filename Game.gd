extends Node2D

export var event_number = 20
var event_index = 1

onready var audio = get_node("/root/Audio")
onready var c = get_node("/root/Constants")

onready var cam_anim = $Background/Camera2D/CamAnim
onready var overlay_anim = $Warning/Anim
onready var bg = $Background/Camera2D/BG

onready var gui = $HUD/GUI
onready var choices = $Choice/Choices
onready var player = $Player

const nodes = {
	"asteroids": preload("res://events/asteroids/Asteroids.tscn"),
	"contraband": preload("res://events/contraband/Contraband.tscn"),
	"cantina": preload("res://events/cantina/Cantina.tscn"),
	"repair": preload("res://events/repair/Repair.tscn")
	}

func _ready():
	# Init stuff
	audio.play("GameMusic")
	init_gui()
	
	# Start game
	yield(get_tree().create_timer(2), "timeout")
	choices.propose_choices(10, c.cantina, c.repair)
	overlay_anim.play("warning")

# Init HUD
func init_gui():
	gui._on_Player_goods_changed(player.goods)
	gui._on_Player_crew_changed(player.crew)
	gui._on_Player_health_changed(player.health)

# When choice has been made
func _on_Choices_event_selected(event):
	execute_event(event)

# Function that manages which function to call
func execute_event(e):
	match e:
		c.unknown:
			execute_event(randi()%6+1)
		c.asteroids:
			asteroids()
		c.cantina:
			cantina()
		c.pirate:
			pass
		c.contraband:
			contraband()
		c.repair:
			repair()
		c.nothing:
			pass
	yield(get_tree().create_timer(2), "timeout")
	if event_index == event_number:
		return
	event_index += 1
	
	choices.propose_choices(player.crew)

##
# Event functions
##

func asteroids():
	# Add asteroids
	var instance = nodes.asteroids.instance()
	instance.global_position = Vector2(0,0)
	add_child(instance)
	
	# Wait a bit and animate
	yield(get_tree().create_timer(0.5), "timeout")
	player.health -= int(rand_range(5,50))
	cam_anim.play("screenshake")
	
	yield(get_tree().create_timer(3), "timeout")
	instance.queue_free()

func contraband():
	# Add instance
	var instance = nodes.contraband.instance()
	instance.global_position = Vector2(0,0)
	instance.z_index = -1
	add_child(instance)
	
	# Slow down
	bg.slow_down(0.6)
	yield(get_tree().create_timer(0.6), "timeout")
	
	# Land
	player.anim.play("land")
	yield(get_tree().create_timer(0.4), "timeout")
	
	# Player gets repaired
	audio.play("Repair")
	player.health -= int(rand_range(5,30))
	
	# Player gets money
	yield(get_tree().create_timer(0.5), "timeout")
	player.goods += int(rand_range(50,200))
	audio.play("Cash")
	
	# Player takeoff
	yield(get_tree().create_timer(0.5), "timeout")
	player.anim.play_backwards("land")
	yield(get_tree().create_timer(0.3), "timeout")
	
	# Speed up
	bg.speed_up(0.5)
	instance.get_node("Sprite/Anim").play("speed_up")

func cantina():
	# Add instance
	var instance = nodes.cantina.instance()
	instance.global_position = Vector2(0,0)
	instance.z_index = -1
	add_child(instance)
	
	# Slow down
	bg.slow_down(0.6)
	yield(get_tree().create_timer(0.6), "timeout")
	
	# Land
	player.anim.play("land")
	yield(get_tree().create_timer(0.4), "timeout")
	
	audio.play_pitch("Cash", 0.5)
	player.goods -= int(rand_range(50,500))
	player.crew += int(rand_range(0,4))
	
	# Player takeoff
	yield(get_tree().create_timer(0.5), "timeout")
	player.anim.play_backwards("land")
	yield(get_tree().create_timer(0.3), "timeout")
	
	# Speed up
	bg.speed_up(0.5)
	instance.get_node("Sprite/Anim").play("speed_up")

func repair():
	# Add instance
	var instance = nodes.repair.instance()
	instance.global_position = Vector2(0,0)
	instance.z_index = -1
	add_child(instance)
	
	# Slow down
	bg.slow_down(0.6)
	yield(get_tree().create_timer(0.6), "timeout")
	
	# Land
	player.anim.play("land")
	yield(get_tree().create_timer(0.4), "timeout")
	
	if player.goods > 0 && player.health < 100:
		# Repair
		player.health += int(rand_range(5,20))
		audio.play("Repair")
		audio.play("Select")
		
		# Pay
		yield(get_tree().create_timer(0.5), "timeout")
		audio.play("Cash")
		player.goods -= int(rand_range(50,700))
		yield(get_tree().create_timer(0.5), "timeout")
	
	# Player takeoff
	player.anim.play_backwards("land")
	yield(get_tree().create_timer(0.3), "timeout")
	
	# Speed up
	bg.speed_up(0.5)
	instance.get_node("Sprite/Anim").play("speed_up")