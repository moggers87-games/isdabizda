package isdabizda;

import gameUtils.RandomUtils;
import isdabizda.Constants.BoardConstants;
import isdabizda.Constants.Controls;
import isdabizda.Board.Cell;
import isdabizda.Polyomino.Tetrominos;

class Main extends hxd.App {

	var board:Board;
	var group:h2d.TileGroup;
	var background:h2d.Bitmap;
	var boardBackground:h2d.Bitmap;
	var backgroundShader:shaders.BackgroundShader;

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
		backgroundShader = new shaders.BackgroundShader();
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
