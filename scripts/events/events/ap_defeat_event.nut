this.ap_defeat_event <- ::inherit("scripts/events/ap_event",
{	// TODO: does fire, but has no text. has image, options. is janky, and awkwardly delayed
	m = {},
	function create()
	{
		this.ap_event.create();
		this.assignPropertiesByName("Defeat");
		this.createScreens();
	}

	function createEventEntries( _itemsArray, _resourceReductionTable )
	{
		local entries = [];
		local push = @(_entry) ::AP.Standard.push(_entry, entries);

		push(this.createEventItemRemovalEntries(_itemsArray));
		push(this.createEventResourceReductionEntries(_resourceReductionTable));
		push(this.createEventMomentumResetEntry());
		return entries;
	}

	function createEventItemRemovalEntries( _itemsArray )
	{
		local entries = [];
		local push = @(_entry) ::AP.Standard.push(_entry, entries);

		foreach( item in _itemsArray )
		{
			local entry = ::AP.Standard.constructEntry
			(
				null,
				format(this.getString("IntroListEntry"), "", item.getName())
			);
			entry.icon <- format("ui/items/%s", item.getIcon());
			push(entry);
		}

		return entries;
	}

	function createEventResourceReductionEntries( _reductionTable )
	{
		local entries = [];
		local colourWrap = @(_string) ::AP.Standard.colourWrap(_string, ::AP.Standard.Colour.Orange);

		foreach( resourceKey, reducedMagnitude in _reductionTable )
		{
			if (reducedMagnitude == 0)
			{
				continue;
			}

			::AP.Standard.constructEntry
			(
				resourceKey,
				format(this.getString("IntroListEntry"), colourWrap(reducedMagnitude.tostring()), ::AP.Utilities.getString(resourceKey)),
				entries
			);
		}

		return entries;
	}

	function createEventMomentumResetEntry()
	{
		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return null;
		}

		return ::AP.Standard.constructEntry
		(
			"Momentum",
			this.compileStringFragments("IntroMomentumLossFragment", ::AP.Standard.Colour.Cyan)
		);
	}

	function createIntroScreen()
	{
		local screen = this.constructScreen("Intro");
		screen.start = function( _event )
		{
			_event.assignTitle("Intro");
			local playerCharacter = ::AP.Utilities.getPlayerInRoster(::World.getPlayerRoster());
			local culledResources = ::AP.Persistence.getCulledResources();
			local culledItems = ::AP.Persistence.getCulledItems(playerCharacter);
			::AP.Standard.push(playerCharacter.getImagePath(), this.Characters);
			::AP.Standard.push(this.createEventEntries(culledItems, culledResources), this.List);
			::AP.Skills.resetMomentum(playerCharacter);
			::AP.Items.removeItemsFromStashAndPlayerCharacter(playerCharacter, culledItems);
			::AP.Utilities.reduceResources(culledResources);
		};
		screen.Options.push(this.createIntroOptionA());
		return screen;
	}

	function createIntroOptionA()
	{
		local optionA =
		{
			Text = this.getString("IntroOptionA"),
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
});