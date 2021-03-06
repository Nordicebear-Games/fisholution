extends CanvasLayer

signal fisholution_up

onready var blur = $Blur
#fisholution completed panel
onready var fisholution_completed_panel = $FisholutionCompletedPanel
onready var keep_playing_button = $FisholutionCompletedPanel/Panel/KeepPlayingButton
#ns completed panel
onready var ns_completed_panel = $NSCompletedPanel
onready var winner_fish_label = $NSCompletedPanel/Panel/WinnerFishLabel
onready var winner_fish_sprite1 = $NSCompletedPanel/Panel/WonLabel/WinnerFish1
onready var winner_fish_sprite2 = $NSCompletedPanel/Panel/WonLabel/WinnerFish2
#fisholution bar
onready var fisholution_bar = $FisholutionBar
#Labels
onready var score_label = $Labels/ScoreLabel
onready var title_label = $Labels/TitleLabel
onready var highscore_label = $Labels/HighscoreLabel
#Buttons
onready var restart_button = $Buttons/RestartButton
onready var choosescene_button = $Buttons/ChooseSceneButton
onready var home_button = $Buttons/HomeButton
onready var pause_button = $Buttons/PauseButton
onready var resume_button = $Buttons/ResumeButton
#Timer
onready var message_timer = $MessageTimer
#Score Calculate Panel
onready var score_calculate_panel = $ScoreCalculatePanel
onready var score_label2 = $ScoreCalculatePanel/Score/ScoreLabel
onready var eatenfish_label = $ScoreCalculatePanel/EatenFish/EatenFishLabel
onready var winner_node = $ScoreCalculatePanel/Winner
onready var winner_label = $ScoreCalculatePanel/Winner/NSWinnerLabel
onready var total_label = $ScoreCalculatePanel/Total/TotalLabel

var score_value = 0
var total_value = 0
var highscore_value
var xp = 5

func _ready():
	_prepare_hud_scene("ready")

func show_message(text, hide_or_not):
	title_label.text = text
	title_label.show()
	if hide_or_not == true:
		message_timer.start()

func game_over():
	_prepare_hud_scene("game_over")

func assign_highscore(total_value):
	Global.save_highscore(total_value)
	highscore_value = str(Global.load_highscore()) # update high score
	highscore_label.text = "Highscore: " + highscore_value # assign high score to text

func update_score(score):
	score_value = score
#	print(score_value)
	score_label.text = str(score)

func _on_MessageTimer_timeout():
	title_label.hide()

func _on_RestartButton_pressed():
	Settings.water_click_sound.play()
	_prepare_hud_scene("restart")

func _on_ChooseSceneButton_pressed():
	Settings.water_click_sound.play()
	Global.change_scene("ChooseScene")

func _on_HomeButton_pressed():
	Settings.water_click_sound.play()
	Global.change_scene("MainScene")

func _on_PauseButton_pressed():
	Settings.water_click_sound.play()
	_prepare_hud_scene("pause")

func _on_ResumeButton_pressed():
	Settings.water_click_sound.play()
	_prepare_hud_scene("resume")

func _on_Fish_xp_gained():
	var increase_xp = fisholution_bar.max_value / (fisholution_bar.level * xp) #reduce xp amount after every fisholution
	fisholution_bar.fisholution_process(increase_xp)

func _on_FisholutionBar_fisholution_up():
	emit_signal("fisholution_up")

func _show_fisholution_completed_panel():
	_prepare_hud_scene("fisholution_completed")

func _show_ns_completed_panel(winner_fish_no):
#	print(winner_fish_no)
	winner_fish_label.text ="'" + "Fish" + str(winner_fish_no + 1) + "'s" 
	winner_fish_sprite1.region_rect.position.y = 32 * winner_fish_no
	winner_fish_sprite2.region_rect.position.y = 32 * winner_fish_no
	_prepare_hud_scene("ns_completed")

func _keep_playing():
	Settings.water_click_sound.play()
	_prepare_hud_scene("keep_playing")

func score_calculate(eaten_fish):
	var winner_bonus = 0
	score_label2.text = str(score_value)
	eatenfish_label.text = str(eaten_fish) + " " + "x" + " " + str(20)
	if Global.which_mode == "fisholution":
		total_value = score_value + (eaten_fish * 20)
	elif Global.which_mode == "natural_selection":
		if Global.ns_winner:
			winner_bonus = 100
		else:
			winner_bonus = 0
		winner_label.text = str(winner_bonus)
		total_value = score_value + (eaten_fish * 20) + winner_bonus
#	print(winner_bonus)
	total_label.text = str(total_value)
	assign_highscore(total_value)

func _prepare_hud_scene(condition):
	match condition:
		"ready":
			assign_highscore(total_value)
			if Global.which_mode == "fisholution":
				fisholution_bar.connect("show_congrats_panel", self, "_show_fisholution_completed_panel")
				keep_playing_button.connect("pressed", self, "_keep_playing")
			elif Global.which_mode == "natural_selection":
				score_label.rect_position = Vector2(160, 0)
		"restart":
			blur.hide()
			fisholution_completed_panel.hide()
			if Global.which_mode == "fisholution":
				fisholution_bar.show()
			highscore_label.hide()
			restart_button.hide()
			home_button.hide()
			choosescene_button.hide()
			Global.change_scene("GameScene") # reload game scene
		"game_over":
			if Global.which_mode == "fisholution":
				fisholution_bar.show()
				home_button.rect_position = Vector2(260, 460)
				show_message("Fisholution Over", false)
			elif Global.which_mode == "natural_selection":
				choosescene_button.show()
				home_button.rect_position = Vector2(200, 540)
				show_message("Ns Over", false)
				winner_node.show()
			blur.show()
			score_label.show()
			home_button.show()
#			assign_highscore()
			highscore_label.rect_position = Vector2(120, 240)
			highscore_label.show()
			restart_button.show()
			pause_button.hide()
			score_calculate(Global.eaten_fish_count)
			score_calculate_panel.show()
		"fisholution_completed":
			get_tree().paused = true
			blur.show()
			fisholution_completed_panel.show()
#			assign_highscore()
			highscore_label.rect_position = Vector2(120, 408)
			highscore_label.show()
			home_button.show()
			home_button.rect_position = Vector2(200, 460)
			pause_button.hide()
			score_calculate(Global.eaten_fish_count)
			score_calculate_panel.show()
		"keep_playing":
			blur.hide()
			fisholution_completed_panel.hide()
			highscore_label.hide()
			restart_button.hide()
			home_button.hide()
			pause_button.show()
			show_message("Game Continues", false)
			yield(get_tree().create_timer(3), "timeout")
			title_label.hide()
			get_tree().paused = false
		"ns_completed":
			get_tree().paused = true
			blur.show()
			ns_completed_panel.show()
#			assign_highscore()
			highscore_label.rect_position = Vector2(120, 408)
			highscore_label.show()
			title_label.hide() # if ns completed screen opened after ns over screen
			restart_button.show()
			choosescene_button.show()
			home_button.rect_position = Vector2(200, 540)
			home_button.show()
			pause_button.hide()
			$Tables.get_node("FishTable").table_transparency(false)
			$Tables.get_node("ScoreTable").table_transparency(false)
			score_calculate(Global.eaten_fish_count)
			winner_node.show()
			score_calculate_panel.show()
		"pause":
			pause_button.hide()
			resume_button.show()
			get_tree().paused = true
			blur.show()
			show_message("Paused", false)
			highscore_label.rect_position = Vector2(120, 320)
			highscore_label.show()
			if Global.which_mode == "fisholution":
				home_button.rect_position = Vector2(200, 460)
				home_button.show()
			elif Global.which_mode == "natural_selection":
				choosescene_button.show()
				home_button.rect_position = Vector2(140, 460)
				home_button.show()
				$Tables.get_node("FishTable").table_transparency(false)
				$Tables.get_node("ScoreTable").table_transparency(false)
		"resume":
			resume_button.hide()
			pause_button.show()
			get_tree().paused = false
			blur.hide()
			title_label.hide()
			highscore_label.hide()
			if Global.which_mode == "fisholution":
				home_button.hide()
			elif Global.which_mode == "natural_selection":
				choosescene_button.hide()
				home_button.hide()
				$Tables.get_node("FishTable").table_transparency(true)
				$Tables.get_node("ScoreTable").table_transparency(true)

