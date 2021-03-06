extends "res://Scripts/Fish.gd"

signal xp_gained # when fish eat little fish

#export (float) var speed = 3

onready var sprite = $Sprite
onready var animation = $Sprite/AnimationPlayer
onready var die_effect = $die_effect

var current_speed

func _ready():
	current_speed = speed
	Global.die_effect(die_effect, self)

func _process(delta):
	pc_control(self, animation)
	move(delta, self, speed)

func _input(event):
	mobile_control(event, self, animation)

func _on_Fish_area_entered(area):
	if area.is_in_group("enemy") and area.is_in_group("badfish"): # if enemy is a fish
		if area.scale >= (scale + Vector2(0.7, 0.7)): #if badfish is bigger than our fish
			_die(die_effect) #our fish died
		elif (area.scale + Vector2(0.5, 0.5)) <= scale: #badfish is smaller than our fish
			emit_signal("xp_gained")
			Settings.nom_sound.play()
			eaten_fish_count += 1
			Global.eaten_fish_count = eaten_fish_count
#			print(Global.eaten_fish_count)
	elif area.is_in_group("enemy") and area.is_in_group("not_fish"): #if enemy is not fish, we can't eat it but they can eat us
		if area.scale >= (scale + Vector2(0.7, 0.7)): #if enemy is bigger than our fish
			_die(die_effect) #our fish died

func _on_HUD_fisholution_up(): # when fisholution level increase
	sprite.region_rect.position.y += 128 # fish evolution (changing text region's position)
	if scale <= Vector2(2.6, 2.6):
		var rand_gain_scale = rand_range(0.05, 0.15)
		scale += Vector2(rand_gain_scale, rand_gain_scale) # our fish grows up

