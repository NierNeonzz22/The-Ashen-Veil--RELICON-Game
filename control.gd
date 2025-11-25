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
	"The air is cool, almost chilly, with small gusts of wind grazing Elia’s arms…",
	"She looks up at the welcoming skies; they're bright and clear today. She sighs. The sky is in their favor, yet as she stares at the big blue, all she can yearn for is a familiar voice to call her name. One does, but not the one she expects…",
	"Elia!!",
	"Gah! What?!",
	"You keep zoning out! It’s a beautiful day…",
	"I just— I wish he were here to see this.",
	"Oh… I— I think he is.",
    "You think?"
]

var final_monologue := "Two lives entered the lake that night. Only one returned. But in every tear that touched the surface, his name was whispered, and in every breath she drew, his memory endured. Because in the end, what defines us is not the years we hold but the choices we make, and the love we leave behind…"

var index := 0
var typing := false
var type_speed := 0.01

func _ready():
	$Control2/TextLabel1.bbcode_enabled = true
	$DialogueBox/TextLabel.bbcode_enabled = true

	$Control2/Fader/TheEndLabel.visible = false
	$Control2/Fader/ScreenFade.color = Color(0,0,0,0)

	show_line()

func show_line():
	var label = $DialogueBox/TextLabel
	label.text = ""
	label.visible_characters = 0
	typing = true

	$Control2/TextLabel1.text = names[index]

	var segs = get_segments(lines[index])
	await type_segments(segs)

	typing = false

	if index == lines.size() - 1:
		await get_tree().create_timer(1.0).timeout
		await play_final_monologue()
		return

func play_final_monologue():
	var label = $DialogueBox/TextLabel
	label.text = ""
	label.visible_characters = 0
	typing = true

	$Control2/TextLabel1.text = ""

	var segs = get_segments(final_monologue)
	await type_segments(segs)

	typing = false
	await get_tree().create_timer(1.5).timeout

	# Fade out the screen
	var fader = $Control2/Fader/ScreenFade
	for i in range(20):
		fader.color.a += 0.05
		await get_tree().create_timer(0.05).timeout

	# Show and fade in "THE END" label
	var end_label = $Control2/Fader/TheEndLabel
	end_label.visible = true
	end_label.modulate.a = 0

	# Fade in
	for i in range(20):
		end_label.modulate.a += 0.05
		await get_tree().create_timer(0.05).timeout

	await get_tree().create_timer(5.0).timeout

	# Fade out
	for i in range(20):
		end_label.modulate.a -= 0.05
		await get_tree().create_timer(0.05).timeout

# ----------------------------
#    SEGMENT SYSTEM (White Text)
# ----------------------------

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
			word_regex.compile(r"(\s+|[\w’']+|…|\.|,|;|!+|\?+)")
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

func type_segments(segs: Array) -> void:
	var label = $DialogueBox/TextLabel

	for segment in segs:
		if segment["is_tag"]:
			label.text += segment["text"]
			continue

		label.text += segment["text"]

		while label.visible_characters < label.text.length():
			label.visible_characters += 1
			await get_tree().create_timer(type_speed).timeout

		if segment["pause"] > 0:
			await get_tree().create_timer(segment["pause"]).timeout

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if not typing:  # Only allow next line if typing is done
			if index < lines.size() - 1:
				index += 1
				show_line()
