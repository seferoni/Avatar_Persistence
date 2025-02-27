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

	function constructScreen( _key )
	{
		local newID = this.getNewScreenID();
		local getString = @(_keyPrefix) ::AP.Strings.Events[_key][format("%s%s", _keyPrefix, newID)];
		local getPath = @(_keyPrefix) ::AP.Database.Events[_key][format("%s%s", _keyPrefix, newID)];
		return
		{
			ID = newID,
			Title = getString("Title"),
			Text = getString("Text"),
			Banner = getPath("Banner"),
			Image = getPath("Image"),
			List = [],
			Options = []
		};
	}

	function getNewScreenID()
	{	// TODO: looks pretty ugly. refactor asap
		local intID = this.m.Screens.len() + 65;
		::logInfo("getting screen ID as " + intID.tochar());
		return intID.tochar();
	}

	function onUpdateScore()
	{
		return;
	}
});