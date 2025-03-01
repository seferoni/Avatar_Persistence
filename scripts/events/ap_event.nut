this.ap_event <- ::inherit("scripts/events/event",
{
	m = {},
	function create()
	{
		this.assignGenericProperties();
	}

	function assignGenericProperties()
	{
		this.m.ID = "event.ap_event";
		this.m.IsSpecial = true;
	}

	function buildScreenText( _eventKey, _screenID )
	{
		local imagePath = ::AP.Database.Events[_eventKey][format("Screen%sImagePath", _screenID)];
		local screenText = ::AP.Strings.getFragmentsAsCompiledString(format("Screen%sTextFragment", _screenID), "Events", _eventKey, null);
		return format("[img]%s[/img]{%s}", imagePath, screenText);
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
		screen.Title <- this.getScreenTitle(_eventKey, screen.ID);
		return screen;
	}

	function getNewScreenID()
	{
		local newID = ::AP.Standard.mapIntegerToAlphabet(this.m.Screens.len() + 1);
		::logInfo("got new screen ID as " + newID);
		return newID;
	}

	function getScreenTitle( _eventKey, _screenID )
	{
		return ::AP.Strings.Events[_eventKey][format("Screen%sTitle", _screenID)];
	}

	function onUpdateScore()
	{
		return;
	}
});