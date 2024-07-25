package isdabizda;

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
