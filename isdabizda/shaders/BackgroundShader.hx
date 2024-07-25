package shaders;

import gameUtils.RandomUtils;

class BackgroundShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@:import h3d.shader.NoiseLib;

		@global var time:Float;
		@param var texture:Sampler2D;
		@param var seed:Int;

		function lines(point:Float):Vec4 {
			var staticFactor = 15;
			var timeFactor = time / 10;
			var sharedFactor = point * staticFactor + timeFactor;
			var offset = (point - timeFactor) / 3;
			return vec4(
				1.0 - smoothstep(1.0, 0.5, abs(sin(sharedFactor + offset))),
				1.0 - smoothstep(1.0, 0.5, abs(sin(sharedFactor))) * 3,
				1.0 - smoothstep(1.0, 0.5, abs(sin(sharedFactor - offset))),
				1.0
			);
		}

		function rotate2d(angle:Float):Mat2 {
			return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
		}

		function fragment() {
			noiseSeed = seed;
			var pos = input.position;
			var angle = snoise(pos);
			pos *= rotate2d(angle);
			pixelColor = lines(pos.x + pos.y);
		}
	}

	public function new() {
		super();
		this.seed = RandomUtils.randomInt(0, 2<<15);
	}
}
