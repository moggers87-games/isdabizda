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

	public static final SPIN:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.UP, hxd.Key.W];
	public static final DROP:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.DOWN, hxd.Key.S];
	public static final MOVELEFT:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.LEFT, hxd.Key.A];
	public static final MOVERIGHT:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.RIGHT, hxd.Key.D];

	public static function isDown(keys:Iterable<Int>):Bool {
		for (key in keys) {
			if (inline hxd.Key.isDown(key)) {
				return true;
			}
		}
		return false;
	}
}

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
	var board:Board;
	var graphic:h2d.Graphics;

	public function new(shape:Polyomino, board:Board, parent:h2d.Object) {
		this.shape = shape;
		this.board = board;
		coordinates = [];
		graphic = new h2d.Graphics(parent);
		for (pos in shape.coordinates) {
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

	public function render(size:Float, xOffset, yOffset) {
		graphic.clear();
		for (idx => pos in coordinates) {
			graphic.beginFill(shape.colour);
			var x = (pos[0] * size) + xOffset;
			var y = (pos[1] * size) + yOffset;
			graphic.drawRect(x, y, size, size);
			/* shading */
			var margin = size / 5;
			if (margin < 1) continue;
			/* left */
			graphic.beginFill(0x777777, 0.5);
			graphic.lineTo(x, y);
			graphic.lineTo(x + margin, y + margin);
			graphic.lineTo(x + margin, y + size - margin);
			graphic.lineTo(x, y + size);
			graphic.lineTo(x, y);
			/* top */
			graphic.beginFill(0xFFFFFF, 0.5);
			graphic.lineTo(x, y);
			graphic.lineTo(x + margin, y + margin);
			graphic.lineTo(x + size - margin, y + margin);
			graphic.lineTo(x + size, y);
			graphic.lineTo(x, y);
			/* right */
			graphic.beginFill(0xAAAAAA, 0.5);
			graphic.lineTo(x + size, y);
			graphic.lineTo(x + size - margin, y + margin);
			graphic.lineTo(x + size - margin, y + size - margin);
			graphic.lineTo(x + size, y + size);
			graphic.lineTo(x + size, y);
			/* bottom */
			graphic.beginFill(0x000000, 0.5);
			graphic.lineTo(x, y + size);
			graphic.lineTo(x + margin, y + size - margin);
			graphic.lineTo(x + size - margin, y + size - margin);
			graphic.lineTo(x + size, y + size);
			graphic.lineTo(x, y + size);
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

	public function remove(?paint = true) {
		if (paint) {
			for (pos in coordinates) {
				board.set(pos[0], pos[1], BoardConstants.blockColour);
			}
		}
		graphic.remove();
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

	public function lineClear():Int {
		var count = 0;
		for (row in board) {
			if (!row.contains(null)) {
				count += 1;
			}
		}
		return count;
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
	var background:h2d.Bitmap;
	var boardBackground:h2d.Bitmap;
	var backgroundShader:BackgroundShader;

	var currentBlock:FallingBlock;
	var blockFallFrames:Float;
	var extraBlocks:Array<FallingBlock>;

	var ratio:Float;
	var xOffset:Float;
	var yOffset:Float;

	public function new() {
		super();
		board = new Board(BoardConstants.initialWidth, BoardConstants.initialHeight);
		extraBlocks = [];
	}

	override function init() {
		/* engine.backgroundColor = BoardConstants.backgroundColour; */
		background = new h2d.Bitmap(h2d.Tile.fromColor(BoardConstants.backgroundColour));
		backgroundShader = new BackgroundShader();
		background.filter = new h2d.filter.Shader(backgroundShader);
		s2d.add(background);
		boardBackground = new h2d.Bitmap(h2d.Tile.fromColor(BoardConstants.backgroundColour, 1, 1, 0.75));
		s2d.add(boardBackground);
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
		background.width = s2d.width;
		background.height = s2d.height;
		group.clear();
		cacheDrawValues();
		boardBackground.width = ratio * board.width;
		boardBackground.height = ratio * board.height;
		boardBackground.x = xOffset;
		boardBackground.y = yOffset;

		for (cell in board) {
			var tile:h2d.Tile;
			var xPos:Float = cell.x * ratio + xOffset;
			var yPos:Float = cell.y * ratio + yOffset;
			if (cell.value != null) {
				var cellTile = h2d.Tile.fromColor(cell.value);
				cellTile.setSize(ratio, ratio);
				group.add(xPos, yPos, cellTile);
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
		var block = new FallingBlock(tetromino, board, s2d);
		if (!block.relativeMove(Std.int(board.width / 2), tetromino.size())) {
			board.growBoard();
			block.relativeMove(Std.int(board.width / 2), tetromino.size());
		}
		return block;
	}

	function addExtraBlocks(count:Int) {
		var i = 0;
		while (i < count) {
			i++;
			var index:Int = RandomUtils.randomInt(0, Tetrominos.SHAPES.length);
			var tetromino:Polyomino = Tetrominos.SHAPES[index];
			var block = new FallingBlock(tetromino, board, s2d);
			var multiplier = i;
			if (i % 2 == 0) {
				multiplier = (multiplier - 1) * -1;
			}
			var x = Std.int(board.width / 2) + ((tetromino.size() + 1) * multiplier);
			if (!block.relativeMove(x, tetromino.size())) {
				block.remove(false);
			} else {
				extraBlocks.push(block);
			}
		}
	}

	override function update(dt:Float) {
		var naturalFall = hxd.Timer.frameCount % blockFallFrames == 0;
		var updateRequired = false;
		if (naturalFall && !currentBlock.relativeMove(0, 1)) {
			currentBlock.remove();
			var count:Int = board.lineClear();
			if (count > 0) {
				board.growBoard();
			}
			if (count > 1) {
				addExtraBlocks(count);
			}
			currentBlock = randomBlock();
			updateRequired = true;
		}
		currentBlock.render(ratio, xOffset, yOffset);

		if (extraBlocks.length > 0) {
			var i = 0;
			while (i < extraBlocks.length) {
				var block:FallingBlock = extraBlocks[i];
				if (!block.relativeMove(0, 1)) {
					extraBlocks.splice(i, 1);
					block.remove();
					updateRequired = true;
				} else {
					block.render(ratio, xOffset, yOffset);
				}
				i++;
			}
		}
		if (updateRequired) {
			board.lineClear();
			redrawGrid();
		}
	}
}
