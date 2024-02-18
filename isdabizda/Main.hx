package isdabizda;

class Main extends hxd.App {

    var gridHeight:Int;
    var gridWidth:Int;
    var group:h2d.TileGroup;
    var tile:h2d.Tile;

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

	static function main() {
        hxd.Res.initEmbed();
		new Main();
	}
}
