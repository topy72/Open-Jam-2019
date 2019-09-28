extends Control
onready var tween = $Tween
var cur_health = 100 setget update_health
onready var Health_label = $HealthCount 

func update_health(new_value):
	tween.interpolate_property(self, "cur_health", cur_health, new_value, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not tween.is_active():
    tween.start()

func _ready():
	pass#update_health(new_value)
	
func _process(delta):
	var round_value = round(cur_health)
	Health_label.text = str(round_value)


