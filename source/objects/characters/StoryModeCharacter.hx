package objects.characters;

typedef StoryModeCharacterData =
{
	var texture:String;
	var idleName:String;
	var heyName:String;
	var heyOffset:Array<Int>;
	var scale:Float;
	var flipX:Bool;
	var pos:Array<Int>;
}

class StoryModeCharacter extends FunkySprite {}
