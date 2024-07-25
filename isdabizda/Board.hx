package isdabizda;

import isdabizda.Constants.BoardConstants;

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

