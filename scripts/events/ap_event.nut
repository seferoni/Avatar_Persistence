this.ap_event <- ::inherit("scripts/events/event",
{
	m = {},
	function create()
	{
		this.assignGenericProperties();
		this.assignSpecialProperties();
	}

	function assignGenericProperties()
	{
		this.m.IsSpecial = true;
	}

	function assignSpecialProperties()
	{
		this.m.EventKey <- "";
	}

	function assignPropertiesByName( _properName )
	{
		this.setEventKey(_properName);
		this.assignIDByName(_properName);
		this.assignTitle();
	}

	function assignIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("event.ap_%s", formattedName.tolower());
	}

	function assignTitle()
	{
		this.m.Title = this.getString("Title");
	}

	function compileStringFragments( _stringKey )
	{
		return ::AP.Strings.getFragmentsAsCompiledString(_stringKey, "Events", this.m.EventKey, null);
	}

	function constructScreen( _screenKey )
	{
		local screen =
		{
			Image = "",
			Banner = "",
			Characters = [],
			List = [],
			Options = []
		};
		screen.ID <- this.getNewScreenID();
		screen.Text <- this.getScreenTextWithImage(_screenKey);
		return screen;
	}

	function formatName( _properName, _replacementSubstring = "" )
	{
		return ::AP.Standard.replaceSubstring(" ", _replacementSubstring, _properName);
	}

	function getEventData()
	{
		return ::AP.EventHandler.getEventData(this.m.EventKey);
	}

	function getNewScreenID( _offset = 0 )
	{
		return ::AP.Standard.mapIntegerToAlphabet(this.m.Screens.len() + 1 + _offset);
	}

	function getScreenTextByID( _screenKey )
	{	# NB: all screen text strings are stored as 'fragments'.
		local stringKey = format("%sTextFragment", _screenKey);
		return this.compileStringFragments(stringKey);
	}

	function getScreenTextWithImage( _screenKey )
	{
		local imagePath = "";
		local imagePaths = this.getEventData().ImagePaths;
		local screenText = this.getScreenTextByID(_screenKey);

		if (_screenKey in imagePaths)
		{
			imagePath = format("[img]%s[/img]", imagePaths[_screenKey]);
		}

		return format("%s%s", imagePath, screenText);
	}

	function getString( _fieldName )
	{
		return ::AP.EventHandler.getEventStringField(this.m.EventKey)[_fieldName];
	}

	function onUpdateScore()
	{
		return;
	}

	function setEventKey( _properName )
	{
		this.m.EventKey = this.formatName(_properName);
	}
});