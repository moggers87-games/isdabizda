package isdabizda;

import isdabizda.Constants.BoardConstants;
import isdabizda.Board.Cell;

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
