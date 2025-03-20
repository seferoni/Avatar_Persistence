this.ap_defeat_event <- ::inherit("scripts/events/ap_event",
{
	m = {},
	function create()
	{
		this.ap_event.create();
		this.assignPropertiesByName("Defeat");
		this.createScreens();
	}

	function createIntroScreen()
	{
		local screen = this.constructScreen("Defeat");
		screen.start <- this.onIntro;
		screen.Options.push(this.createIntroOptionA());
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

	function createScreens()
	{
		::AP.Standard.push(this.createIntroScreen(), this.m.Screens);
	}

	function onIntro( _event )
	{
		local playerCharacter = ::AP.Persistence.getPlayerInRoster(::World.getPlayerRoster());
		local culledResources = ::AP.Persistence.getCulledResources();
		local culledItems = ::AP.Persistence.getCulledItems(playerCharacter);

		::AP.Standard.push(playerCharacter.getImagePath(), this.Characters);
		::AP.Standard.push(::AP.Persistence.createMomentumResetEntry(), this.List);
		::AP.Standard.push(::AP.Persistence.createEventItemRemovalEntries(culledItems), this.List);
		::AP.Standard.push(::AP.Persistence.createEventResourceReductionEntries(culledResources), this.List);
		::AP.Persistence.resetMomentum(playerCharacter);
		::AP.Persistence.removeItems(playerCharacter, culledItems);
		::AP.Persistence.reduceResources(culledResources);
	}
});