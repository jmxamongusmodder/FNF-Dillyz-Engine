package rhythm;

typedef NoteData =
{
	var strumTime:Float;
	var noteData:Int;
	var sustainLength:Int;
	var noteType:String;
}

typedef SectionData =
{
	// replace this with the next var
	var sectionNotes:Array<Dynamic>;
	// aka this one
	var theNotes:Array<NoteData>;

	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
	// custom stuff
	var gfSings:Bool;
}

class Section
{
	public var curNotes:Array<NoteData> = [];

	public var lengthInSteps:Int = 16;
	// ?!?!?!?!??!?!?
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;
}
