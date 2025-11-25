shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0) = 1.0;  // Alpha transparency

void fragment() {
    vec4 texColor = texture(TEXTURE, UV);
    texColor.a *= alpha;  // Modify the transparency based on the alpha parameter
    COLOR = texColor;
}

