package isdabizda;

class Polyomino {
	var shape:Array<Array<Int>>;

	public function new(shape:Array<Array<Int>>) {
		this.shape = shape;
	}
}

class Tetrominos {
	var shapes:Array<Polyomino> = [
		/* I */
		new Polyomino([[1, 1, 1, 1]]),
		/* O */
		new Polyomino([[1, 1], [1, 1]]),
		/* T */
		new Polyomino([[1, 1, 1], [0, 1, 0]]),
		/* J */
		new Polyomino([[0, 1], [0, 1], [1, 1]]),
		/* L */
		new Polyomino([[1, 0], [1, 0], [1, 1]]),
		/* S */
		new Polyomino([[0, 1, 1], [1 , 1, 0]]),
		/* Z */
		new Polyomino([[1, 1, 0], [0, 1, 1]]),
	];
}

class FallingBlock {
	var shape:Polyomino;
	var colour:Int;

	function new(shape:Polyomino, colour:Int) {
		this.shape = shape;
		this.colour = colour;
	}
}

class Main extends hxd.App {

	var gridHeight:Int;
	var gridWidth:Int;
	var group:h2d.TileGroup;
	var tile:h2d.Tile;
	var board:Array<Array<Null<Int>>>;

	var currentPolyomino:Polyomino;

	public function new() {
		super();
		gridWidth = 10;
		gridHeight = 20;
		board = [for (y in 0...gridHeight) [for (x in 0...gridWidth) null]];

		/* TODO test board code */
		board[0][3] = 0x1F001F;
		board[0][4] = 0x1F001F;
		board[0][5] = 0x1F001F;
		board[1][4] = 0x1F001F;

	}

	override function init() {
		group = new h2d.TileGroup(tile, s2d);
		redrawGrid();
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}

	inline function inverseYIndex(y:Int): Int {
		return gridHeight - (y % gridHeight) - 1;
	}

	function redrawGrid() {
		group.clear();
		var xRatio = s2d.width / gridWidth;
		var yRatio = s2d.height / gridHeight;
		var ratio:Float;
		var xOffset:Float;
		var yOffset:Float;
		if (xRatio * gridHeight < s2d.height) {
			ratio = xRatio;
			yOffset = (s2d.height - (ratio * gridHeight)) / 2;
			xOffset = 0;
		} else {
			ratio = yRatio;
			yOffset = 0;
			xOffset = (s2d.width - (ratio * gridWidth)) / 2;
		}

		for (y in 0...gridHeight) {
			for (x in 0...gridWidth) {
				var cell = board[inverseYIndex(y)][x];
				var xPos = x * ratio + xOffset;
				var yPos = y * ratio + yOffset;
				if (cell != null) {
					var tile = h2d.Tile.fromColor(cell, 1, 1);
					tile.setSize(ratio, ratio);
					group.add(xPos, yPos, tile);
				} else {
					var tile = h2d.Tile.fromColor(0xFFFFFF, 1, 1);
					tile.setSize(ratio, ratio);
					group.add(xPos, yPos, tile);
				}
			}
		}
	}

	override function onResize() {
		redrawGrid();
	}

	override function update(dt:Float) {
		/*keyboardMovement();*/
	}
}
