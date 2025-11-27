extends Control

var names = [
	"", 
	"", 
	"[color=#C7F9CC]Pablo:[/color]",
	"[color=#FFEAA7]Elia:[/color]",
	"[color=#C7F9CC]Pablo:[/color]",
	"[color=#FFEAA7]Elia:[/color]",
	"[color=#C7F9CC]Pablo:[/color]",
	"[color=#FFEAA7]Elia:[/color]"
]

var lines = [
	"The air is cool, almost chilly, with small gusts of wind grazing Elia's arms…",
	"She looks up at the welcoming skies; they're bright and clear today. She sighs. The sky is in their favor, yet as she stares at the big blue, all she can yearn for is a familiar voice to call her name. One does, but not the one she expects…",
	"Elia!!",
	"Gah! What?!",
	"You keep zoning out! It's a beautiful day…",
	"I just— I wish he were here to see this.",
	"Oh… I— I think he is.",
	"You think?"
]

var final_monologue := "Two lives entered the lake that night. Only one returned. But in every tear that touched the surface, his name was whispered, and in every breath she drew, his memory endured. Because in the end, what defines us is not the years we hold but the choices we make, and the love we leave behind…"

var index := 0
var typing := false
var type_speed := 0.015
var ending_started := false


func _ready():
	# Fader initial visibility
	$Control2/Fader.visible = true
	$Control2/Fader/ScreenFade.visible = true
	$Control2/Fader/ScreenFade.modulate.a = 1.0
	$Control2/Fader/TheEndLabel.visible = false
	$Control2/Fader/TheEndLabel.modulate.a = 0

	# Enable BBCode (correct nodes)
	$DialogueBox/Textlabel.bbcode_enabled = true
	$Control2/Textlabel1.bbcode_enabled = true

	# Play fade animation
	$Control2/Fader/anim.play("fade out")

	await show_line()


# ----------------- Dialogue -----------------

func show_line() -> void:
	var label = $DialogueBox/Textlabel
	var name_label = $Control2/Textlabel1

	# Correct display: name goes to NameLabel ONLY
	name_label.text = names[index]
	label.text = ""

	typing = true
	var segs = get_segments(lines[index])
	await type_segments(segs)
	typing = false


func type_segments(segs: Array) -> void:
	var label = $DialogueBox/Textlabel

	for segment in segs:
		if segment["is_tag"]:
			label.text += segment["text"]
			continue

		for ch in segment["text"]:
			label.text += ch
			await get_tree().create_timer(type_speed).timeout

		if segment["pause"] > 0:
			await get_tree().create_timer(segment["pause"]).timeout


# ----------------- BBCode Handling -----------------

func split_bbcode(text: String) -> Array:
	var bbcode_regex := RegEx.new()
	bbcode_regex.compile(r"(\[\/?color[^\]]*\])")
	var result: Array = []
	var last_idx := 0

	for match in bbcode_regex.search_all(text):
		var start = match.get_start(0)
		var end = match.get_end(0)
		if start > last_idx:
			result.append(text.substr(last_idx, start - last_idx))
		result.append(text.substr(start, end - start))
		last_idx = end

	if last_idx < text.length():
		result.append(text.substr(last_idx, text.length() - last_idx))

	return result


func get_segments(text: String) -> Array:
	var segments: Array = []
	var parts: Array = split_bbcode(text)

	for part in parts:
		if part.begins_with("[") and part.ends_with("]"):
			segments.append({"text": part, "pause": 0.0, "is_tag": true})
		else:
			var word_regex := RegEx.new()
			word_regex.compile(r"(\s+|[\w'’]+|…|\.|,|;|!+|\?+)")
			var words = word_regex.search_all(part)

			for i in range(words.size()):
				var s: String = words[i].get_string()
				var pause := 0.0

				match s:
					",": pause = 0.2
					".", ";": pause = 0.8
					"…": pause = 1.0
					_:
						if s.ends_with("!") or s.ends_with("?"):
							pause = 0.6

				if (s == "." or s == ";" or s.ends_with("!") or s.ends_with("?")):
					if i < words.size() - 1:
						var next = words[i + 1].get_string()
						if not next.begins_with(" "):
							s += " "

				segments.append({"text": s, "pause": pause, "is_tag": false})

	return segments


# ----------------- Input -----------------

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and not typing and not ending_started:
		if index < lines.size() - 1:
			index += 1
			await show_line()
		else:
			ending_started = true
			await play_final_monologue()


# ----------------- Final Monologue -----------------

func play_final_monologue() -> void:
	# Clear
	$DialogueBox/Textlabel.text = ""
	$Control2/Textlabel1.text = ""

	typing = true
	var segs = get_segments(final_monologue)
	await type_segments(segs)
	typing = false

	await get_tree().create_timer(1.0).timeout

	# Fade out animation
	if not $Control2/Fader/anim.is_playing():
		$Control2/Fader/anim.play("fade_out")
		await $Control2/Fader/anim.animation_finished

	# Fade THE END
	$Control2/Fader/TheEndLabel.visible = true
	for i in range(30):
		$Control2/Fader/TheEndLabel.modulate.a = float(i) / 29.0
		await get_tree().create_timer(0.03).timeout

	await get_tree().create_timer(5.0).timeout

	transition_to_main_menu()


func transition_to_main_menu() -> void:
	if has_node("/root/TransitionManager"):
		TransitionManager.transition_to_scene("res://scenes/MainMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
