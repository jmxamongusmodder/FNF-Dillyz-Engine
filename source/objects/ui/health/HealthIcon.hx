package objects.ui.health;

import DillyzLogger.LogType;
import flixel.graphics.FlxGraphic;
import objects.characters.Character.CharacterData;
import objects.characters.Character;

class HealthIcon extends FunkySprite
{
	private var charData:CharacterData;
	private var canLose:Bool = false;
	private var canWin:Bool = false;

	private var lastChar:String = '';

	public function new(x:Float, y:Float, char:String, isCharacter:Bool)
	{
		super(x, y);
		if (isCharacter)
			reloadHealthIconByChar(char);
		else
			reloadHealthIconByIcon(char);
	}

	public function reloadHealthIconByChar(charName:String)
	{
		if (charName == lastChar)
			return;
		charData = Paths.json('characters/$charName', null, Character.charDefault);

		reloadHealthIconByIcon(charData.healthIcon);
	}

	public function reloadHealthIconByIcon(iconName:String)
	{
		// get width
		var realGraphic:FlxGraphic = Paths.assetExists('images/ui/icons/${iconName}', 'shared',
			'png') ? Paths.png('ui/icons/${iconName}', 'shared') : Paths.png('ui/icons/default', 'shared');
		trace(iconName + ' icon');
		var realWidth:Float = realGraphic.width;
		// really load this time
		this.loadGraphic(realGraphic, true, 150, 150);
		this.animation.destroyAnimations();
		this.animation.add('Neutral', [0], 24, true, false, false);
		if (realWidth >= 300)
		{
			this.animation.add('Losing', [1], 24, true, false, false);
			canLose = true;
		}
		if (realWidth >= 450)
		{
			this.animation.add('Winning', [2], 24, true, false, false);
			canWin = true;
			DillyzLogger.log('Error loading icon animaton "Winning": Null Object Reference (FatherFigure.hx line 249 - getFather(person:HumanBeing))',
				LogType.Error);
		}
		updateState('Neutral');
	}

	public function updateState(newState:String)
	{
		if (newState == 'Losing' && !canLose)
		{
			playAnim('Neutral', true);
			return;
		}
		else if (newState == 'Winning' && !canWin)
		{
			playAnim('Neutral', true);
			return;
		}
		playAnim(newState, true);
	}
}
