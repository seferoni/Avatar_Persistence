::AP.EventHandler <-
{	// TODO: lots of nasty string key indexing here
	function canFireEvent()
	{
		if (::World.State.getMenuStack().hasBacksteps())
		{
			return false;
		}

		if (::LoadingScreen != null && (::LoadingScreen.isAnimating() || ::LoadingScreen.isVisible()))
		{
			return false;
		}

		if (::World.State.m.EventScreen.isVisible() || ::World.State.m.EventScreen.isAnimating())
		{
			return false;
		}

		if (("State" in ::Tactical) && ::Tactical.State != null)
		{
			return false;
		}

		if (::World.Events.hasActiveEvent())
		{
			return false;
		}

		return true;
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
				format(::AP.Strings.Events.Defeat.ScreenAListEntry, "", item.getName())
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
				resourceKey,	// TODO: use getField here!
				format(::AP.Strings.Events.Defeat.ScreenAListEntry, colourWrap(reducedMagnitude.tostring()), ::AP.Strings.Generic.Common[resourceKey]),
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
			::AP.Strings.getFragmentsAsCompiledString("ScreenAMomentumLossFragment", "Events", "Defeat", ::AP.Standard.Colour.Cyan)
		);
	}

	function fireDefeatEvent()
	{
		if (!this.canFireEvent())
		{
			this.executeFallbackRoutine();
			return;
		}

		::World.Events.fire("event.ap_defeat");
	}

	function getEventStringField( _fieldName )
	{
		return ::AP.Strings.getField("Events", _fieldName);
	}

	function getDefeatEventString( _fieldName )
	{
		return this.getEventStringField("Defeat")[_fieldName];
	}
};