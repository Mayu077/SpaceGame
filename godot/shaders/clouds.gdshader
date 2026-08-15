shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_alpha_prepass, diffuse_burley;

uniform float seed = 5.4;
uniform float coverage : hint_range(0.0, 1.0) = 0.54;
uniform vec3 cloud_color : source_color = vec3(0.76, 0.86, 0.9);
uniform float time_scale = 0.004;

float hash31(vec3 p) { p=fract(p*.1031); p+=dot(p,p.yzx+33.33); return fract((p.x+p.y)*p.z); }
float noise3(vec3 p){ vec3 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash31(i),hash31(i+vec3(1,0,0)),f.x),mix(hash31(i+vec3(0,1,0)),hash31(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash31(i+vec3(0,0,1)),hash31(i+vec3(1,0,1)),f.x),mix(hash31(i+vec3(0,1,1)),hash31(i+vec3(1)),f.x),f.y),f.z);}
float fbm(vec3 p){float v=0.0,a=.5;for(int i=0;i<6;i++){v+=noise3(p)*a;p=p*2.04+vec3(9.1);a*=.5;}return v;}

void fragment(){
    vec3 p=normalize(VERTEX);
    p.xz=mat2(cos(TIME*time_scale),-sin(TIME*time_scale),sin(TIME*time_scale),cos(TIME*time_scale))*p.xz;
    float synoptic=fbm(p*3.7+vec3(seed));
    float detail=fbm(p*14.0+vec3(seed*2.1));
    float bands=exp(-pow(abs(p.y)-0.18,2.0)/0.08)+0.65*exp(-pow(abs(p.y)-0.62,2.0)/0.06);
    float cloud=smoothstep(coverage,coverage+.17,synoptic*.69+detail*.28+bands*.07);
    ALBEDO=cloud_color;
    ROUGHNESS=.92;
    ALPHA=cloud*.72;
}
