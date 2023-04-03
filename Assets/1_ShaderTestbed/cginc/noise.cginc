// from h3r github: https://gist.github.com/h3r/3a92295517b2bee8a82c1de1456431dc
// modified to work in Unity

#ifndef NOISE
#define NOISE

/*
  Most of this code hasn't been made by me (maybe partially tweaked to fit) and just collected those snippets from many sources 
  across the internet. I haven't saved some of the original author names and all the credits 
  should go to them. I'm pretty some of you may find optimizations to them, feel free to leave a comment.
  HPlass (hermann.plass@gmail.com) - 2020
  Source:
    https://thebookofshaders.com/11/
    https://thebookofshaders.com/edit.php#11/lava-lamp.frag
    http://webstaff.itn.liu.se/~stegu/jgt2012/article.pdf
*/

/*  glsl style mod because of missmatch issues: https://forum.unity.com/threads/translating-a-glsl-shader-noise-algorithm-to-hlsl-cg.485750/
     mod(1.5, 1) == 0.5    //  glsl mod +, + = +
    fmod(1.5, 1) == 0.5    // hlsl fmod +, + = +
     mod(-1.5, -1) == -0.5 //  glsl mod -, - = -
    fmod(-1.5, -1) == -0.5 // hlsl fmod -, - = -
     mod(-1.5, 1) == 0.5   //  glsl mod -, + = +
    fmod(-1.5, 1) == -0.5  // hlsl fmod -, + = -
     mod(1.5, -1) == -0.5  //  glsl mod +, - = -
    fmod(1.5, -1) == 0.5   // hlsl fmod +, - = +
    // and the real kicker
     mod(-1.25, 1) == 0.75
    fmod(-1.25, 1) == -0.25
*/

#define mod(x, y) (x - y * floor(x / y))
#include <UnityShaderVariables.cginc>
float  lt(float  a, float b){ return a<b?1.0:0.0;}
float  lessThan(float  a, float b){ return lt(a,b); }
float2 lessThan(float2 a, float2 b){ return float2(lt(a.x,b.x),lt(a.y,b.y) );}
float3 lessThan(float3 a, float3 b){ return float3(lt(a.x,b.x),lt(a.y,b.y),lt(a.z,b.z) );}
float4 lessThan(float4 a, float4 b){ return float4(lt(a.x,b.x),lt(a.y,b.y),lt(a.z,b.z),lt(a.w,b.w) );}


//--------------------------------------------------------------------------------------
// Generic 1,2,3 Noise
//--------------------------------------------------------------------------------------
float rand1(float n)  { return frac(sin(n) * 43758.5453123); }
float rand2(float2 n) { return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453); }

//--------------------------------------------------------------------------------------
// NDimensionalRandom
//--------------------------------------------------------------------------------------
float rand4dTo1d(float4 value, float4 dotDir = float4(12.9898, 78.233, 37.719, 17.4265)){
	float4 smallValue = sin(value);
	float random = dot(smallValue, dotDir);
	random = frac(sin(random) * 143758.5453);
	return random;
}

//get a scalar random value from a 3d value
float rand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719)){
	//make value smaller to avoid artefacts
	float3 smallValue = sin(value);
	//get scalar value from 3d vector
	float random = dot(smallValue, dotDir);
	//make value more random by making it bigger and then taking the factional part
	random = frac(sin(random) * 143758.5453);
	return random;
}

float rand2dTo1d(float2 value, float2 dotDir = float2(12.9898, 78.233)){
	float2 smallValue = sin(value);
	float random = dot(smallValue, dotDir);
	random = frac(sin(random) * 143758.5453);
	return random;
}

float rand1dTo1d(float3 value, float mutator = 0.546){
	float random = frac(sin(value + mutator) * 143758.5453);
	return random;
}

//to 2d functions

float2 rand3dTo2d(float3 value){
	return float2(
		rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
		rand3dTo1d(value, float3(39.346, 11.135, 83.155))
	);
}

float2 rand2dTo2d(float2 value){
	return float2(
		rand2dTo1d(value, float2(12.989, 78.233)),
		rand2dTo1d(value, float2(39.346, 11.135))
	);
}

float2 rand1dTo2d(float value){
	return float2(
		rand2dTo1d(value, 3.9812),
		rand2dTo1d(value, 7.1536)
	);
}

//to 3d functions

float3 rand3dTo3d(float3 value){
	return float3(
		rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
		rand3dTo1d(value, float3(39.346, 11.135, 83.155)),
		rand3dTo1d(value, float3(73.156, 52.235, 09.151))
	);
}

float3 rand2dTo3d(float2 value){
	return float3(
		rand2dTo1d(value, float2(12.989, 78.233)),
		rand2dTo1d(value, float2(39.346, 11.135)),
		rand2dTo1d(value, float2(73.156, 52.235))
	);
}

float3 rand1dTo3d(float value){
	return float3(
		rand1dTo1d(value, 3.9812),
		rand1dTo1d(value, 7.1536),
		rand1dTo1d(value, 5.7241)
	);
}

// to 4d // TEMP
float4 rand4dTo4d(float4 value){
	return float4(
		rand4dTo1d(value, float4(12.989, 78.233, 37.719, -12.15)),
		rand4dTo1d(value, float4(39.346, 11.135, 83.155, -11.44)),
		rand4dTo1d(value, float4(73.156, 52.235, 09.151, 62.463)),
		rand4dTo1d(value, float4(-12.15, 12.235, 41.151, -1.135))
	);
}


float gnoise(float p){
	float fl = floor(p);
        float fc = frac(p);
	return lerp(rand1(fl), rand1(fl + 1.0), fc);
}
	
float gnoise(float2 n) {
	const float2 d = float2(0.0, 1.0);
    	float2  b = floor(n), 
        f = smoothstep(d.xx, d.yy, frac(n));

    //float2 f = frac(n);
	//f = f*f*(3.0-2.0*f);

    float x = lerp(rand2(b), rand2(b + d.yx), f.x),
          y = lerp(rand2(b + d.xy), rand2(b + d.yy), f.x);

	return lerp( x, y, f.y );
}



float  mod289(float x) { return x - floor(x * (1.0 / 289.0)) * 289.0;}
float4 mod289(float4 x){ return x - floor(x * (1.0 / 289.0)) * 289.0;}
float4 perm(float4 x)  { return mod289(((x * 34.0) + 1.0) * x);}

float gnoise(float3 p){
    	float3 a = floor(p);
	float3 d = p - a;
    	d = d * d * (3.0 - 2.0 * d);

    	float4 b = a.xxyy + float4(0.0, 1.0, 0.0, 1.0);
    	float4 k1 = perm(b.xyxy);
    	float4 k2 = perm(k1.xyxy + b.zzww);

    	float4 c = k2 + a.zzzz;
    	float4 k3 = perm(c);
    	float4 k4 = perm(c + 1.0);

    	float4 o1 = frac(k3 * (1.0 / 41.0));
    	float4 o2 = frac(k4 * (1.0 / 41.0));

    	float4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    	float2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    	return o4.y * d.y + o4.x * (1.0 - d.y);
}
//	<https://www.shadertoy.com/view/4dS3Wd>
//	By Morgan McGuire @morgan3d, http://graphicscodex.com
//
float hash(float n) { return frac(sin(n) * 1e4); }
float hash(float2 p) { return frac(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float noise(float x) {
	float i = floor(x);
	float f = frac(x);
	float u = f * f * (3.0 - 2.0 * f);
	return lerp(hash(i), hash(i + 1.0), u);
}

float noise(float2 x) {
	float2 i = floor(x);
	float2 f = frac(x);

	// Four corners in 2D of a tile
	float a = hash(i);
	float b = hash(i + float2(1.0, 0.0));
	float c = hash(i + float2(0.0, 1.0));
	float d = hash(i + float2(1.0, 1.0));

	// Simple 2D lerp using smoothstep envelope between the values.
	// return float3(lerp(lerp(a, b, smoothstep(0.0, 1.0, f.x)),
	//			lerp(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	float2 u = f * f * (3.0 - 2.0 * f);
	return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// This one has non-ideal tiling properties that I'm still tuning
float noise(float3 x) {
	const float3 step = float3(110, 241, 171);

	float3 i = floor(x);
	float3 f = frac(x);
 
	// For performance, compute the base input to a 1D hash from the integer part of the argument and the 
	// incremental change to the 1D based on the 3D -> 1D wrapping
  	float n = dot(i, step);

	float3 u = f * f * (3.0 - 2.0 * f);
	return lerp(lerp(lerp( hash(n + dot(step, float3(0, 0, 0))), hash(n + dot(step, float3(1, 0, 0))), u.x),
               lerp( hash(n + dot(step, float3(0, 1, 0))), hash(n + dot(step, float3(1, 1, 0))), u.x), u.y),
               lerp(lerp( hash(n + dot(step, float3(0, 0, 1))), hash(n + dot(step, float3(1, 0, 1))), u.x),
               lerp( hash(n + dot(step, float3(0, 1, 1))), hash(n + dot(step, float3(1, 1, 1))), u.x), u.y), u.z);
}


//--------------------------------------------------------------------------------------
// Simplex Noise https://en.wikipedia.org/wiki/Simplex_noise
//--------------------------------------------------------------------------------------
// Simplex 2D noise
//
float  permute(float x)  { return floor(mod(((x*34.0)+1.0)*x, 289.0)); }
float3 permute(float3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }
float4 permute(float4 x){  return mod(((x*34.0)+1.0)*x, 289.0); }
float taylorInvSqrt(float r){return 1.79284291400159 - 0.85373472095314 * r;}
float4 taylorInvSqrt(float4 r){  return float4( taylorInvSqrt(r.x), taylorInvSqrt(r.y), taylorInvSqrt(r.z), taylorInvSqrt(r.w) ); }


float snoise(float2 v){
	const float4 C = float4(0.211324865405187, 0.366025403784439,-0.577350269189626, 0.024390243902439);
	float2 i  = floor(v + dot(v, C.yy) );
  	float2 x0 = v -   i + dot(i, C.xx);
  	float2 i1;
  	i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  	float4 x12 = x0.xyxy + C.xxzz;
  	x12.xy -= i1;
  	i = mod(i, 289.0);
  	float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 )) + i.x + float3(0.0, i1.x, 1.0 ));
  	float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  	m = m*m ;
  	m = m*m ;
  	float3 x = 2.0 * frac(p * C.www) - 1.0;
  	float3 h = abs(x) - 0.5;
  	float3 ox = floor(x + 0.5);
  	float3 a0 = x - ox;
  	m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  	float3 g;
  	g.x  = a0.x  * x0.x  + h.x  * x0.y;
  	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  	return 130.0 * dot(m, g);
}
//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
//


float snoise(float3 v){ 
  	const float2  C = float2(1.0/6.0, 1.0/3.0) ;
  	const float4  D = float4(0.0, 0.5, 1.0, 2.0);

	// First corner
  	float3 i  = floor(v + dot(v, C.yyy) );
  	float3 x0 =   v - i + dot(i, C.xxx) ;

	// Other corners
  	float3 g = step(x0.yzx, x0.xyz);
  	float3 l = 1.0 - g;
  	float3 i1 = min( g.xyz, l.zxy );
  	float3 i2 = max( g.xyz, l.zxy );

  	//  x0 = x0 - 0. + 0.0 * C 
  	float3 x1 = x0 - i1 + 1.0 * C.xxx;
  	float3 x2 = x0 - i2 + 2.0 * C.xxx;
  	float3 x3 = x0 - 1. + 3.0 * C.xxx;

	// Permutations
  	i = mod(i, 289.0 ); 
  	float4 p = permute( permute( permute( 
             i.z + float4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + float4(0.0, i1.x, i2.x, 1.0 ));

	// Gradients
	// ( N*N points uniformly over a square, mapped onto an octahedron.)
  	float n_ = 1.0/7.0; // N=7
  	float3  ns = n_ * D.wyz - D.xzx;
	
  	float4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)
	
  	float4 x_ = floor(j * ns.z);
  	float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
	
  	float4 x = x_ *ns.x + ns.yyyy;
  	float4 y = y_ *ns.x + ns.yyyy;
  	float4 h = 1.0 - abs(x) - abs(y);
	
  	float4 b0 = float4( x.xy, y.xy );
  	float4 b1 = float4( x.zw, y.zw );
	
  	float4 s0 = floor(b0)*2.0 + 1.0;
  	float4 s1 = floor(b1)*2.0 + 1.0;
  	float4 sh = -step(h, float4(0,0,0,0));
	
  	float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  	float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
	
  	float3 p0 = float3(a0.xy,h.x);
  	float3 p1 = float3(a0.zw,h.y);
  	float3 p2 = float3(a1.xy,h.z);
  	float3 p3 = float3(a1.zw,h.w);

	//Normalise gradients
  	float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  	p0 *= norm.x;
  	p1 *= norm.y;
  	p2 *= norm.z;
  	p3 *= norm.w;

	// lerp final noise value
  	float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  	m = m * m;
  	return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}
//	Simplex 4D Noise 
//	by Ian McEwan, Ashima Arts
//

float4 grad4(float j, float4 ip){
  	const float4 ones = float4(1.0, 1.0, 1.0, -1.0);
  	float4 p,s;

  	p.xyz = floor( frac(float3(j,j,j) * ip.xyz) * 7.0) * ip.z - 1.0;
  	p.w = 1.5 - dot(abs(p.xyz), ones.xyz);

  	s = float4(lessThan(p, float4(0,0,0,0)));
  	p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www; 
	
  	return p;
}

float snoise(float4 v){
  	const float2  C = float2( 0.138196601125010504,  // (5 - sqrt(5))/20  G4
                        0.309016994374947451); // (sqrt(5) - 1)/4   F4
	// First corner
  	float4 i  = floor(v + dot(v, C.yyyy) );
  	float4 x0 = v -   i + dot(i, C.xxxx);

	// Other corners

	// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  	float4 i0;

  	float3 isX = step( x0.yzw, x0.xxx );
  	float3 isYZ = step( x0.zww, x0.yyz );
	//  i0.x = dot( isX, float3( 1.0 ) );
  	i0.x = isX.x + isX.y + isX.z;
  	i0.yzw = 1.0 - isX;

	//  i0.y += dot( isYZ.xy, float2( 1.0 ) );
  	i0.y += isYZ.x + isYZ.y;
  	i0.zw += 1.0 - isYZ.xy;

  	i0.z += isYZ.z;
  	i0.w += 1.0 - isYZ.z;

  	// i0 now contains the unique values 0,1,2,3 in each channel
  	float4 i3 = clamp( i0, 0.0, 1.0 );
  	float4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  	float4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  	//  x0 = x0 - 0.0 + 0.0 * C 
  	float4 x1 = x0 - i1 + 1.0 * C.xxxx;
  	float4 x2 = x0 - i2 + 2.0 * C.xxxx;
  	float4 x3 = x0 - i3 + 3.0 * C.xxxx;
  	float4 x4 = x0 - 1.0 + 4.0 * C.xxxx;

	// Permutations
  	i = mod(i, 289.0); 
  	float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  	float4 j1 = permute( permute( permute( permute (
             i.w + float4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + float4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + float4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + float4(i1.x, i2.x, i3.x, 1.0 ));
	// Gradients
	// ( 7*7*6 points uniformly over a cube, mapped onto a 4-octahedron.)
	// 7*7*6 = 294, which is close to the ring size 17*17 = 289.

  	float4 ip = float4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;
	
  	float4 p0 = grad4(j0,   ip);
  	float4 p1 = grad4(j1.x, ip);
  	float4 p2 = grad4(j1.y, ip);
  	float4 p3 = grad4(j1.z, ip);
  	float4 p4 = grad4(j1.w, ip);

	// Normalise gradients
  	float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  	p0 *= norm.x;
  	p1 *= norm.y;
  	p2 *= norm.z;
  	p3 *= norm.w;
  	p4 *= taylorInvSqrt(dot(p4,p4));

	// lerp contributions from the five corners
  	float3 m0 = max(0.6 - float3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  	float2 m1 = max(0.6 - float2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  	m0 = m0 * m0;
  	m1 = m1 * m1;
  	return 49.0 * ( dot(m0*m0, float3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
  	             + dot(m1*m1, float2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

}
// 	<www.shadertoy.com/view/XsX3zB>
//	by Nikita Miropolskiy

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
float3 rand3(float3 c) {
	float j = 4096.0*sin(dot(c,float3(17.0, 59.4, 15.0)));
	float3 r;
	r.z = frac(512.0*j);
	j *= .125;
	r.x = frac(512.0*j);
	j *= .125;
	r.y = frac(512.0*j);
	return r-0.5;
}


float _snoise(float3 p) {
  	const float F3 =  0.3333333;
  	const float G3 =  0.1666667;
	float3 s = floor(p + dot(p, float3(F3,F3,F3)));
	float3 x =   p - s + dot(s, float3(G3,G3,G3));
	 
	float3 e = step(float3(0.0, 0.0, 0.0), x - x.yzx);
	float3 i1 = e*(1.0 - e.zxy);
	float3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	float3 x1 = x - i1 + G3;
	float3 x2 = x - i2 + 2.0*G3;
	float3 x3 = x - 1.0 + 3.0*G3;
	 
	float4 w, d;
	 
	w.x = dot(x, x);
	w.y = dot(x1, x1);
	w.z = dot(x2, x2);
	w.w = dot(x3, x3);
	 
	w = max(0.6 - w, 0.0);
	 
	d.x = dot(rand3(s), x);
	d.y = dot(rand3(s + i1), x1);
	d.z = dot(rand3(s + i2), x2);
	d.w = dot(rand3(s + 1.0), x3);
	 
	w *= w;
	w *= w;
	d *= w;
	 
	return dot(d, float4(52.0,52.0,52.0,52.0));
}

float snoisefracal(float3 m) {
	return   0.5333333* _snoise(m)
		+0.2666667* _snoise(2.0*m)
		+0.1333333* _snoise(4.0*m)
		+0.0666667* _snoise(8.0*m);
}

//--------------------------------------------------------------------------------------
// NormalMap Noise
//--------------------------------------------------------------------------------------
float3 normalNoise(float2 _st, float _zoom, float _speed){
  	float time = _Time.y;
	float2 v1 = _st;
	float2 v2 = _st;
	float2 v3 = _st;
	float expon = pow(10.0, _zoom*2.0);
	v1 /= 1.0*expon;
	v2 /= 0.62*expon;
	v3 /= 0.83*expon;
	float n = time*_speed;
	float nr = (snoise(float3(v1, n)) + snoise(float3(v2, n)) + snoise(float3(v3, n))) / 6.0 + 0.5;
	n = time * _speed + 1000.0;
	float ng = (snoise(float3(v1, n)) + snoise(float3(v2, n)) + snoise(float3(v3, n))) / 6.0 + 0.5;
	return float3(nr,ng,0.5);
}

//--------------------------------------------------------------------------------------
// fracional Brownian motion https://en.wikipedia.org/wiki/fracional_Brownian_motion
//--------------------------------------------------------------------------------------
//	<https://www.shadertoy.com/view/Xd23Dh>
//	by inigo quilez <http://iquilezles.org/www/articles/voronoise/voronoise.htm>
//

float3 hash3( float2 p ){
    	float3 q = float3( dot(p,float2(127.1,311.7)), 
			   dot(p,float2(269.5,183.3)), 
			   dot(p,float2(419.2,371.9)) );
	return frac(sin(q)*43758.5453);
}

float iqnoise( in float2 x, float u, float v ){
    	float2 p = floor(x);
    	float2 f = frac(x);
		
	float k = 1.0+63.0*pow(1.0-v,4.0);
	
	float va = 0.0;
	float wt = 0.0;
    	for( int j=-2; j<=2; j++ )
    	for( int i=-2; i<=2; i++ )
    	{
        	float2 g = float2( float(i),float(j) );
		float3 o = hash3( p + g )*float3(u,u,1.0);
		float2 r = g - f + o.xy;
		float d = dot(r,r);
		float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
		va += o.z*ww;
		wt += ww;
    	}
	
    	return va/wt;
}

//	https://www.shadertoy.com/view/lsjGWD
//	by Pietro De Nicola
//
#define OCTAVES   		1		// 7
#define SWITCH_TIME 	60.0		// seconds

/*
const float t = time/SWITCH_TIME;
const float function 			= mod(t,4.0);
const bool  multiply_by_F1	= mod(t,8.0)  >= 4.0;
const bool  inverse				= mod(t,16.0) >= 8.0;
const float distance_type	= mod(t/16.0,4.0);
*/

float2 hash2( float2 p ){
	p = float2( dot(p,float2(127.1,311.7)),dot(p,float2(269.5,183.3)));
	return frac(sin(p)*43758.5453);
}

float voronoi( in float2 x ){
  	const float t = _Time.y/SWITCH_TIME;
  	const float function 			= mod(t,4.0);
  	const bool  multiply_by_F1	= mod(t,8.0)  >= 4.0;
  	const bool  inverse				= mod(t,16.0) >= 8.0;
  	const float distance_type	= mod(t/16.0,4.0);

	float2 n = floor( x );
	float2 f = frac( x );
	
	float F1 = 8.0;
	float F2 = 8.0;
	
	for( int j=-1; j<=1; j++ )
	for( int i=-1; i<=1; i++ ){
		float2 g = float2(i,j);
		float2 o = hash2( n + g );

		o = 0.5 + 0.41*sin( _Time.y + 6.2831*o );	
		float2 r = g - f + o;

		float d = distance_type < 1.0 ? dot(r,r)  :				// euclidean^2
			  distance_type < 2.0 ? sqrt(dot(r,r)) :			// euclidean
		          distance_type < 3.0 ? abs(r.x) + abs(r.y) :		// manhattan
			  distance_type < 4.0 ? max(abs(r.x), abs(r.y)) :	// chebyshev
			  0.0;

		if( d<F1 ) { 
			F2 = F1; 
			F1 = d; 
		} else if( d<F2 ) {
			F2 = d;
		}
    	}
	
	float c = function < 1.0 ? F1 : 
	          function < 2.0 ? F2 : 
		  function < 3.0 ? F2-F1 :
		  function < 4.0 ? (F1+F2)/2.0 : 
		  0.0;
		
	if( multiply_by_F1 ) c *= F1;
	if( inverse )	     c = 1.0 - c;
	
	return c;
}

float vfbm( in float2 p ){
	float s = 0.0;
	float m = 0.0;
	float a = 0.5;
	
	for( int i=0; i<OCTAVES; i++ ){
		s += a * voronoi(p);
		m += a;
		a *= 0.5;
		p *= 2.0;
	}
	return s/m;
}

// Use:
//	  float2 p = gl_FragCoord.xy/iResolution.xx;
//    float c = POWER*vfbm( SCALE*p ) + BIAS;

//--------------------------------------------------------------------------------------
// NormalMap Noise
//--------------------------------------------------------------------------------------
#define NUM_OCTAVES 5

float fbm(float x) {
	float v = 0.0;
	float a = 0.5;
	float shift = float(100);
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}


float fbm(float2 x) {
	float v = 0.0;
	float a = 0.5;
	float2 shift = float2(100,100);
	// Rotate to reduce axial bias
  //float2x2 rot = float2x2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
  float2x2 rot = { cos(0.5), sin(0.5), -sin(0.5), cos(0.50) };
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x);
		x = mul(rot, x) * 2.0 + shift;
    		//0 no translation, 1 translation
		a *= 0.5;
	}
	return v;
}


float fbm(float3 x) {
	float v = 0.0;
	float a = 0.5;
	float3 shift = float3(100, 100, 100);
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

float fbm(float4 v){float w=0.,d=.5;float4 y=float4(100,100,100,100);for(int x=0;x<NUM_OCTAVES;++x)w+=d*snoise(v),v=v*2.+y,d*=.5;return w;}


// 	<https://www.shadertoy.com/view/MdX3Rr>
//	by inigo quilez
//

float fbm2( in float2 p ){
	const float2x2 m2 = {0.8,-0.6,0.6,0.8};
    	float f = 0.0;
    	f += 0.5000*noise( p ); p = mul(m2,p) * 2.02;
    	f += 0.2500*noise( p ); p = mul(m2,p) * 2.03;
    	f += 0.1250*noise( p ); p = mul(m2,p) * 2.01;
    	f += 0.0625*noise( p );

    	return f/0.9375;
}


#endif
