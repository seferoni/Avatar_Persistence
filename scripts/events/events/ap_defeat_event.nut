this.ap_defeat_event <- ::inherit("scripts/events/ap_event",
{
	m = {},
	function create()
	{
		this.ap_event.create();
		this.assignEventProperties();
		this.createScreens();
	}

	function assignGenericProperties()
	{
		this.ap_event.assignGenericProperties();
		this.m.ID = "event.ap_defeat";
	}

	function assignEventProperties()
	{
		this.m.PlayerCharacter <- ::AP.Persistence.getPlayerInRoster(::World.getPlayerRoster());
	}

	function createScreens()
	{
		::AP.Standard.push(this.createIntroScreen(), this.m.Screens);
	}

	function createIntroScreen()
	{
		local screen = this.constructScreen("Defeat");
		screen.Characters.push(this.m.PlayerCharacter);
		screen.Options.push(this.createIntroOptionA());
		screen.start <- this.onIntro;
		return screen;
	}

	function createIntroOptionA()
	{
		local optionA =
		{
			Text = ::AP.Strings.Events.Defeat.ScreenAOptionA,
			function getResult( _event )
			{	# This convention is borrowed verbatim from the vanilla codebase.
				return 0;
			}
		};
		return optionA;
	}

	function onIntro( _event )
	{
		local culledResources = ::AP.Persistence.getCulledResources();
		local culledItems = ::AP.Persistence.getCulleditems();
		::AP.Standard.push(::AP.Persistence.createEventResourceReductionEntries(culledResources), this.List);
		::AP.Standard.push(::AP.Persistence.createEventItemRemovalEntries(culledItems), this.List);
		::AP.Persistence.reduceResourcesByTable(culledResources);
		::AP.Persistence.removeItemsByArray(culledItems);
	}
});