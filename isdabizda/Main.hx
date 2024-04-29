package isdabizda;

import gameUtils.RandomUtils;

enum abstract BoardConstants(Int) from Int to Int {
	var increaseFactor = 2;
	var blockColour = 0x1F001F;
	var backgroundColour = 0xFFFFFF;
	var initialHeight = 20;
	var initialWidth = 10;
}

class Controls {

	public static final SPIN:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.UP];
	public static final DROP:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.DOWN];
	public static final MOVELEFT:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.LEFT];
	public static final MOVERIGHT:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.RIGHT];

	public static function isDown(keys:Iterable<Int>):Bool {
		for (key in keys) {
			if (inline hxd.Key.isDown(key)) {
				return true;
			}
		}
		return false;
	}
}

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

class FallingBlock {

	var shape:Polyomino;
	var coordinates:Array<Array<Int>>;
	var colour:Int;
	var parent:h2d.Object;
	var objects:Array<h2d.Bitmap>;
	var board:Board;

	public function new(shape:Polyomino, x:Int, y:Int, board:Board, parent:h2d.Object) {
		this.shape = shape;
		this.parent = parent;
		this.board = board;
		objects = [];
		coordinates = [];
		/* TODO use batch rendering via SpriteBatch */
		for (pos in shape.coordinates) {
			var block = new h2d.Bitmap(h2d.Tile.fromColor(shape.colour, 1, 1));
			objects.push(block);
			parent.addChildAt(block, 1);
			coordinates.push(pos.copy());
		}
	}

	public function relativeMove(x:Int, y:Int):Bool {
		var newCoords:Array<Array<Int>> = [];
		for (pos in coordinates) {
			newCoords.push([pos[0] + x, pos[1] + y]);
		}
		if (!checkCollision(newCoords)) {
			coordinates = newCoords;
			return true;
		}
		return false;
	}

	public function rotate(?clockwise = true):Bool {
		var newCoords:Array<Array<Int>> = [];
		var zero:Array<Int> = coordinates[0].copy();
		var rotateVector:Array<Int> = [1, -1];
		if (!clockwise) {
			rotateVector = [-1, 1];
		}
		for (pos in coordinates) {
			/*
			 * remove centre coords from current coords to restore to "zero",
			 * rotate about the origin, move back to original position
			 */
			newCoords.push([
				((pos[1] - zero[1]) * rotateVector[1]) + zero[0],
				((pos[0] - zero[0]) * rotateVector[0]) + zero[1],
			]);
		}
		if (!checkCollision(newCoords)) {
			coordinates = newCoords;
			return true;
		}
		return false;
	}

	public function render(size, xOffset, yOffset) {
		for (idx => block in objects) {
			var pos:Array<Int>;

			block.height = size;
			block.width = size;
			pos = coordinates[idx];
			block.x = pos[0] * size + xOffset;
			block.y = pos[1] * size + yOffset;
		}
	}

	function checkCollision(checkCoords:Array<Array<Int>>):Bool {
		for (pos in checkCoords) {
			var cell:Cell = board.get(pos[0], pos[1]);
			if (cell.value != null || cell.index < 0) {
				return true;
			}
		}
		return false;
	}

	public function remove() {
		for (pos in coordinates) {
			board.set(pos[0], pos[1], BoardConstants.blockColour);
		}
		for (obj in objects) {
			obj.remove();
		}
	}
}

class Board {

	public var width(default, null):Int;
	public var height(default, null):Int;
	var board:Array<Array<Null<Int>>>;

	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
		board = [for (y in 0...height) [for (x in 0...width) null]];
	}

	public function get(x, y):Cell {
		if (x >= width || y >= height || x < 0 || y < 0) {
			return new Cell(-1, x, y, null);
		}
		var index:Int = y * height + x;
		return new Cell(index, x, y, board[y][x]);
	}

	public function set(x, y, value) {
		board[y][x] = value;
	}

	public function iterator():BoardIterator {
		return new BoardIterator(this);
	}

	public function growBoard() {
		var newWidth:Int = width * BoardConstants.increaseFactor;
		var newHeight:Int = height * BoardConstants.increaseFactor;
		var newBoard:Array<Array<Null<Int>>> = [for (y in 0...newHeight) [for (x in 0...newWidth) null]];
		var xOffset:Int = Std.int((newWidth - width) / 2);
		var yOffset:Int = newHeight - height;

		for (cell in this) {
			var newY:Int = cell.y + yOffset;
			var newX:Int = cell.x + xOffset;
			var value:Null<Int> = cell.value;
			newBoard[newY][newX] = value;
		}
		board = newBoard;
		width = newWidth;
		height = newHeight;
	}

	public function lineClear() {
		for (row in board) {
			if (!row.contains(null)) {
				growBoard();
				return;
			}
		}
	}
}

class BoardIterator {

	var board:Board;
	var index:Int;

	public inline function new(board:Board) {
		this.board = board;
		index = 0;
	}

	public inline function hasNext():Bool {
		return index < board.width * board.height;
	}

	public inline function next():Cell {
		var x:Int = index % board.width;
		var y:Int = Std.int(index / board.width);
		index++;
		return board.get(x, y);
	}
}

class Cell {

	public var index(default, null):Int;
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var value(default, null):Any;

	public inline function new(index:Int, x:Int, y:Int, value:Any) {
		this.index = index;
		this.x = x;
		this.y = y;
		this.value = value;
	}
}

class Main extends hxd.App {

	var board:Board;
	var group:h2d.TileGroup;

	var currentBlock:FallingBlock;
	var blockFallFrames:Float;

	var ratio:Float;
	var xOffset:Float;
	var yOffset:Float;

	public function new() {
		super();
		board = new Board(BoardConstants.initialWidth, BoardConstants.initialHeight);
	}

	override function init() {
		/*group = new h2d.TileGroup(h2d.Tile.fromColor(BoardConstants.backgroundColour, 1, 1), s2d);*/
		group = new h2d.TileGroup(null, s2d);
		currentBlock = randomBlock();
		s2d.addEventListener(keyboardControl);
		redrawGrid();
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}

	function cacheDrawValues() {
		var xRatio:Float = s2d.width / board.width;
		var yRatio:Float = s2d.height / board.height;
		if (xRatio * board.height < s2d.height) {
			ratio = xRatio;
			yOffset = (s2d.height - (ratio * board.height)) / 2;
			xOffset = 0;
		}
		else {
			ratio = yRatio;
			yOffset = 0;
			xOffset = (s2d.width - (ratio * board.width)) / 2;
		}
		var fallFactor:Float = (BoardConstants.initialHeight / board.height) * (BoardConstants.initialHeight / board.height);
		blockFallFrames = Math.max(1.0, fallFactor * hxd.Timer.wantedFPS);
	}

	function redrawGrid() {
		group.clear();
		cacheDrawValues();
		for (cell in board) {
			var tile:h2d.Tile;
			var xPos:Float = cell.x * ratio + xOffset;
			var yPos:Float = cell.y * ratio + yOffset;
			if (cell.value != null) {
				tile = h2d.Tile.fromColor(cell.value, 1, 1);
				tile.setSize(ratio, ratio);
				group.add(xPos, yPos, tile);
			}
			else {
				tile = h2d.Tile.fromColor(BoardConstants.backgroundColour, 1, 1);
				tile.setSize(ratio, ratio);
				group.add(xPos, yPos, tile);
			}
		}

		currentBlock.render(ratio, xOffset, yOffset);
	}

	function keyboardControl(event:hxd.Event) {
		if (event.kind != EKeyDown) {
			return;
		}
		var x = 0;
		var y = 0;
		if (Controls.SPIN.contains(event.keyCode)) {
			currentBlock.rotate();
		}
		if (Controls.DROP.contains(event.keyCode)) {
			y += 1;
		}
		if (Controls.MOVELEFT.contains(event.keyCode)) {
			x -= 1;
		}
		if (Controls.MOVERIGHT.contains(event.keyCode)) {
			x += 1;
		}
		currentBlock.relativeMove(x, y);
	}

	override function onResize() {
		redrawGrid();
	}

	function randomBlock():FallingBlock {
		var index:Int = RandomUtils.randomInt(0, Tetrominos.SHAPES.length);
		var tetromino:Polyomino = Tetrominos.SHAPES[index];
		var block = new FallingBlock(tetromino, Std.int(board.width / 2), tetromino.size(), board, s2d);
		if (!block.relativeMove(Std.int(board.width / 2), tetromino.size())) {
			board.growBoard();
			block.relativeMove(Std.int(board.width / 2), tetromino.size());
		}
		return block;
	}

	override function update(dt:Float) {
		if ((hxd.Timer.frameCount % blockFallFrames) == 0) {
			if (!currentBlock.relativeMove(0, 1)) {
				currentBlock.remove();
				board.lineClear();
				currentBlock = randomBlock();
				redrawGrid();
			}
		}
		currentBlock.render(ratio, xOffset, yOffset);
	}
}
