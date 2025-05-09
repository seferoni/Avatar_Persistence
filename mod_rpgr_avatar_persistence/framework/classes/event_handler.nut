::AP.EventHandler <-
{
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

	function fireDefeatEvent()
	{
		if (!this.canFireEvent())
		{
			return;
		}

		::AP.Persistence.setQueueDefeatRoutineState(false);
		::World.Events.fire("event.ap_defeat");
	}

	function getEventData( _fieldName )
	{
		return this.getField("EventData")[_fieldName];
	}

	function getEventStringField( _fieldName )
	{
		return ::AP.Strings.getField("Events", _fieldName);
	}

	function getField( _fieldName )
	{
		return ::AP.Database.getField("Events", _fieldName);
	}
};