shader_type canvas_item;

uniform vec2 multiplier = vec2(2.);
uniform float threshold = 0.5;
uniform float smoothing = 0.2;
uniform sampler2D noise;

uniform vec4 transition_color:source_color = vec4(1.0);

//// A linear function that passes through (0.5, 0.5), with a slope that makes
//// it start at (0.5 - smoothing) and end at (0.5 + smoothing), and then clamps
//// where it leaves 0.0 - 1.0 to those values.
//float ease(float a)
//{
	//if (a < 0.5 - smoothing){return 0.0;}
	//if (a > 0.5 + smoothing){return 1.0;}
	//return (a - 0.5) / (2.0 * smoothing) + 0.5;
//}
//
//// Stretches the given value vertically, keeping (0.5,0.5) the same.
//// Used to transform a threshold range from (0.0 - 1.0) to 
//// (0.0 - smoothing, 1.0 + smoothing).
//float stretch(float a)
//{
	//return (2.0*smoothing + 1.0) * a - smoothing;
//}

// Combined the old calculation functions into one.
// Same as ease(a - 0.5 + stretch(threshold))
float get_value(float a)
{
	return (a + threshold * (2.0 * smoothing + 1.) - smoothing - 1.) / (2.0 * smoothing) + 0.5;
}

void fragment() {
	
	vec2 new_uv = floor(UV * multiplier) / multiplier;
	float index = get_value(new_uv.y);
	
	if (index >= texture(noise, new_uv).r)
	{
		COLOR.rgb = transition_color.rgb;
		COLOR.a *= transition_color.a;
	}
}
