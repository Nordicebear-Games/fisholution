extends Node

export (Array, PackedScene) var BadFishes
var score

func _ready():
	randomize()

func new_game():
	score = 0
	$Fish.start($StartPosition.position)
	$Fish.scale = Vector2(2, 2)
	$StartTimer.start()
	$HUD.show_message("Get Ready")
	$HUD.update_score(score)
	$HUD/FisholutionBar.show()
	$Music.play()
	$HUD/FisholutionBar.reset_fisholution()

func game_over():
	$ScoreTimer.stop()
	$BadFishTimer.stop()
	$HUD.game_over()
	$GameOverSound.play()
	$Music.stop()

func _on_StartTimer_timeout():
	$BadFishTimer.start()
	$ScoreTimer.start()
	$HUD.update_score(score)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD/ScoreLabel.text = str(score) #score problem fixed with this line

func _on_BadFishTimer_timeout():
	# Choose a random location on Path2D.
    $Fish/BadFishPath/BFSpawnLocation.set_offset(randi())
    # Create a BadFish instance and add it to the scene.
    var badfish = BadFishes[randi() % BadFishes.size()].instance()
    add_child(badfish)
    # Set the badfish's direction perpendicular to the path direction.
    var direction = $Fish/BadFishPath/BFSpawnLocation.rotation + PI / 2
    # Set the badfish's position to a random location.
    badfish.position = $Fish/BadFishPath/BFSpawnLocation.global_position
#    # Add some randomness to the direction.
    direction += rand_range(-PI / 4, PI / 4) # PI/4 means 45 angle
    badfish.rotation = direction
    # Set the velocity (speed & direction).
    badfish.linear_velocity = Vector2(rand_range(badfish.min_speed, badfish.max_speed), 0)
    badfish.linear_velocity = badfish.linear_velocity.rotated(direction)
    # [DemoFish]Set the velocity (speed & direction).
#    var badfishRB = badfish.find_node("RigidBody2D")
#    badfishRB.linear_velocity = Vector2(rand_range(badfish.min_speed, badfish.max_speed), 0)
#    badfishRB.linear_velocity = badfishRB.linear_velocity.rotated(direction)