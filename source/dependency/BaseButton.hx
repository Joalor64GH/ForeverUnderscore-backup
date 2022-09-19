package dependency;

import flixel.FlxSprite;

class BaseButton extends FlxSprite
{
	public var onClickAction:Void->Void;
	public var size:String = "";
	public var child(default, set):String;

	public function new(x:Float, y:Float, size:String = "", ?onClickAction:Void->Void)
	{
		super(x, y);

		this.onClickAction = onClickAction;
		this.size = size;

		loadGraphic(Paths.image('menus/chart editor/ui-buttons/charting_button-${size.toLowerCase()}'));
		antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		scrollFactor.set();
	}

	public function set_child(value:String):String
	{
		child = value;
		return child;
	}

	public function onClick(?value:Dynamic):Void
	{
		if (onClickAction != null)
			onClickAction();
	}
}

class ChartingButton extends BaseButton
{
	public function new(x:Float, y:Float, size:String = "", ?onClickAction:Void->Void)
	{
		super(x, y, size, onClickAction);
	}

	override public function onClick(?value:Dynamic)
	{
		if (value != null)
			child = value;

		super.onClick();
	}
}
