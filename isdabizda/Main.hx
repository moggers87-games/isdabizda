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

	var currentPolyomino:Polyomino;

	public function new() {
		super();
		gridWidth = 10;
		gridHeight = 20;
	}

	override function init() {
		tile = h2d.Tile.fromColor(0xFF0000, 1, 1);
		group = new h2d.TileGroup(tile, s2d);
		redrawGrid();
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}

	function redrawGrid() {
		group.clear();
		var xRatio = s2d.width / gridWidth;
		var yRatio = s2d.height / gridHeight;
		var ratio:Float;
		if (xRatio * gridHeight < s2d.height) {
			ratio = xRatio;
		} else {
			ratio = yRatio;
		}
		tile.setSize(ratio, ratio);

		var x = 0;
		while (x < gridWidth) {
			var y = x % 2;
			while (y < gridHeight) {
				group.add(x*ratio, y*ratio, tile);
				y += 2;
			}
			x += 1;
		}
	}

	override function onResize() {
		redrawGrid();
	}

	override function update(dt:Float) {
		/*keyboardMovement();*/
	}
}
