shader_type spatial;
render_mode unshaded;

uniform float low_range : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float high_range : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform vec4 outer_color : hint_color = vec4(vec3(0.4), 1.0);
uniform vec4 inner_color : hint_color = vec4(vec3(0.2), 1.0);
uniform bool toggle_outer = false;
uniform vec3 highlight_tri_pos;
uniform bool enable_highlight_tri_pos = true;
uniform sampler2D tex_colors : hint_black;
uniform sampler2D tex_data : hint_black;
uniform vec2 tex_data_size;
uniform vec2 tex_data_offset;

varying flat vec3 tri_pos;
varying flat vec2 global_data;

vec3 pick_tri(vec2 pos) {
    return vec3(ceil(1.0 * pos.x - sqrt(3.0) / 3.0 * pos.y),
                floor(sqrt(3.0) * 2.0 / 3.0 * pos.y) + 1.0,
                ceil(-1.0 * pos.x - sqrt(3.0) / 3.0 * pos.y));
}

vec3 tex_color(int i) {
    if (i < 0) {
        return vec3(0.0);
    } else if (i >= 8) {
        return vec3(0.5);
    }

    float x = (float(i) * 2.0 + 1.0) / (2.0 * 8.0);
    vec4 col = texture(tex_colors, vec2(x, 0.8));

    return col.rgb;
}

vec2 read_data() {
    ivec3 i_tri_pos = ivec3(round(tri_pos));
    bool pointy = i_tri_pos.x + i_tri_pos.y + i_tri_pos.z == 2;
    vec2 raw_pos = tri_pos.xy + tex_data_offset;
    vec2 pos = (raw_pos * 2.0 + 1.0) / (2.0 * tex_data_size);  // scaled to 0 - 1
    vec4 col = texture(tex_data, pos);
    vec2 data = pointy ? col.rg : col.ba;
    return round(data * 255.0);
}

void vertex() {
    mat4 mat = WORLD_MATRIX;
    vec2 world_pos = vec2(mat[3][0], mat[3][2]);  // model world position
    tri_pos = pick_tri(world_pos * vec2(1, -1) - 0.25);
    global_data = read_data();
}

void fragment() {
    vec3 bary = COLOR.xyz;  // triangle barycentric coordinates
    ivec2 data = ivec2(global_data);

    vec3 k = fwidth(bary) / 2.0;  // 2 is optimal because p-k,p+k

    vec3 low_split = smoothstep((low_range / 3.0) - k, (low_range / 3.0) + k, bary);
    float low = low_split.x * low_split.y * low_split.z;

    vec3 high_split = smoothstep((high_range / 3.0) - k, (high_range / 3.0) + k, bary);
    float high = high_split.x * high_split.y * high_split.z;

    float edge = low * (1.0 - high);

    if (toggle_outer) {
        edge = 1.0 - edge;
    }

    vec3 new_inner_color = inner_color.rgb;

    if (data.r > 0) {
        new_inner_color = tex_color(data.r - 1);
    }

    vec3 color = mix(outer_color.rgb, new_inner_color, edge).rgb;

    if (enable_highlight_tri_pos && distance(tri_pos, highlight_tri_pos) < 0.1) {
        color = vec3(1, 0, 0);
    }

    ALBEDO = color;
}
