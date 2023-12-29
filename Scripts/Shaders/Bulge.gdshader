shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float distortion_amm = 0.0f;

vec2 distort(vec2 r, float alpha)
{
    return r * -alpha * (dot(r, r));
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float scale = 1.0f;
	uv.x -= 0.5f;
	uv.y -= 0.5f;
	uv *= scale;
	uv.x += 0.5f;
	uv.y += 0.5f;
    vec2 v = (uv - vec2(.5, .5));
    
    //float amount = m.x;
    float amount = (sin(-distortion_amm) * .5 ) ;
        
    uv = uv + distort(v, amount);
	COLOR = textureLod(screen_texture, uv, 0.0);
}