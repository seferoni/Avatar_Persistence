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
		local newID = this.getNewScreenID();
		local screenText = this.buildScreenText(_eventKey, newID);
		local screenTitle = this.getScreenTitle(_eventKey, newID);
		return
		{
			ID = newID,
			Text = screenText,
			Title = screenTitle,
			Image = "",
			Banner = "",
			Characters = [],
			List = [],
			Options = []
		};
	}

	function getNewScreenID()
	{
		return ::AP.Standard.mapIntegerToAlphabet(this.m.Screens.len() + 1);
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