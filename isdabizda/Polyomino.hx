package isdabizda;

class Polyomino {

	public var coordinates(default, null):Array<Array<Int>>;
	public var colour(default, null):Int;

	public function new(colour:Int, coordinates:Array<Array<Int>>) {
		this.coordinates = coordinates;
		this.colour = colour;
	}

	public function size():Int {
		var maxX = 0;
		var maxY = 0;
		var minX = 0;
		var minY = 0;
		for (pos in coordinates) {
			if (pos[0] > maxX) {
				maxX = pos[0];
			}
			else if (pos[0] < minX) {
				minX = pos[0];
			}
			if (pos[1] > maxY) {
				maxY = pos[1];
			}
			else if (pos[1] < minY) {
				minY = pos[1];
			}
		}
		var differenceX:Int = maxX - minX;
		var differenceY:Int = maxY - minY;
		if (differenceX > differenceY) {
			return differenceX;
		}
		else {
			return differenceY;
		}
	}
}

class Tetrominos {

	public static final SHAPES:Array<Polyomino> = [
		/* I */
		new Polyomino(0xE81416, [[0, 0], [0, 1], [0, 2], [0, -1]]),
		/* O */
		new Polyomino(0xFFA500, [[0, 0], [0, 1], [1, 0], [1, 1]]),
		/* T */
		new Polyomino(0xFAEB36, [[0, 0], [0, 1], [0, -1], [1, 0]]),
		/* J */
		new Polyomino(0x79C314, [[0, 0], [-1, 0], [1, 0], [1, -1]]),
		/* L */
		new Polyomino(0x487DE7, [[0, 0], [-1, 0], [1, 0], [1, 1]]),
		/* S */
		new Polyomino(0x4B369D, [[0, 0], [0, 1], [1, 0], [1, -1]]),
		/* Z */
		new Polyomino(0x70369D, [[0, 0], [0, -1], [1, 0], [1, 1]]),
	];
}
