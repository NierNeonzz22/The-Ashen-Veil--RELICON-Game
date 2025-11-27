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
	# Hide fader completely
	$Control/Control2/Fader.visible = false
	$Control/Control2/Fader/ScreenFade.visible = false
	$Control/Control2/Fader/ScreenFade.modulate.a = 0
	$Control/Control2/Fader/TheEndLabel.visible = false
	$Control/Control2/Fader/TheEndLabel.modulate.a = 0

	$Control/Control2/NameLabel.bbcode_enabled = true
	$Control/DialogueBox/DialogueLabel.bbcode_enabled = true

	await show_line()

# ----------------- Dialogue -----------------

func show_line() -> void:
	# NAME LABEL
	$Control/Control2/NameLabel.text = names[index]

	# DIALOGUE LABEL
	$Control/DialogueBox/DialogueLabel.text = ""

	typing = true
	var segs = get_segments(lines[index])
	await type_segments(segs)
	typing = false

func type_segments(segs: Array) -> void:
	var label = $Control/DialogueBox/DialogueLabel
	for segment in segs:
		label.text += segment["text"]
		if segment["pause"] > 0:
			await get_tree().create_timer(segment["pause"]).timeout

# ----------------- BBCode -----------------

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

# ----------------- Input -----------------

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and not typing:
		if index < lines.size() - 1:
			index += 1
			await show_line()
		else:
			await play_final_monologue()

# ----------------- Final Monologue -----------------

func play_final_monologue() -> void:
	var fader_layer = $Control/Control2/Fader
	var fader = $Control/Control2/Fader/ScreenFade
	var end_label = $Control/Control2/Fader/TheEndLabel

	fader_layer.visible = false
	fader.visible = false
	fader.modulate.a = 0
	end_label.visible = false
	end_label.modulate.a = 0

	# Clear text
	$Control/DialogueBox/DialogueLabel.text = ""
	$Control/Control2/NameLabel.text = ""

	typing = true
	var segs = get_segments(final_monologue)
	await type_segments(segs)
	typing = false

	await get_tree().create_timer(1.5).timeout

	# Fade to white
	fader_layer.visible = true
	fader.visible = true
	fader.modulate.a = 0

	for i in range(20):
		fader.modulate.a = (i + 1) * 0.05
		await get_tree().create_timer(0.05).timeout

	# THE END text
	end_label.visible = true
	end_label.modulate.a = 0
	for i in range(20):
		end_label.modulate.a = (i + 1) * 0.05
		await get_tree().create_timer(0.05).timeout

	await get_tree().create_timer(5.0).timeout

	for i in range(20):
		end_label.modulate.a = 1.0 - (i + 1) * 0.05
		await get_tree().create_timer(0.05).timeout
