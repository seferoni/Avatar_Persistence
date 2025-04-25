this.ap_event <- ::inherit("scripts/events/event",
{
	m = {},
	function create()
	{
		this.assignGenericProperties();
	}

	function assignGenericProperties()
	{
		this.m.IsSpecial = true;
	}

	function assignPropertiesByName( _properName )
	{
		this.setIDByName(_properName);
		this.setTitleByName(_properName);
	}

	function buildScreenText( _eventKey, _screenID )
	{
		local imagePath = ::AP.Database.getField("Events", _eventKey)[format("Screen%sImagePath", _screenID)];
		local screenText = ::AP.Strings.getFragmentsAsCompiledString(format("Screen%sTextFragment", _screenID), "Events", _eventKey, null);
		return format("[img]%s[/img]%s", imagePath, screenText);
	}

	function constructScreen( _eventKey )
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
		screen.Text <- this.buildScreenText(_eventKey, screen.ID);
		return screen;
	}

	function formatName( _properName, _replacementSubstring = "" )
	{
		return ::AP.Standard.replaceSubstring(" ", _replacementSubstring, _properName);
	}

	function getNewScreenID()
	{
		return ::AP.Standard.mapIntegerToAlphabet(this.m.Screens.len() + 1);
	}

	function onUpdateScore()
	{
		return;
	}

	function setIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("event.ap_%s", formattedName.tolower());
	}

	function setTitleByName( _properName )
	{	// TODO: revise, revise
		local key = this.formatName(_properName, "_");
		this.m.Title = ::AP.Strings.Events[key].Title;
	}
});