::AP.Patcher.hook("scripts/states/world_state", function( p )
{
	::AP.Patcher.wrap(p, "onUpdate", function()
	{
		if (!::AP.Persistence.getQueueDefeatRoutineState())
		{
			return;
		}

		if (::AP.Utilities.getPlayerInRoster(::World.getPlayerRoster()) == null)
		{
			return;
		}

		::AP.Persistence.executeDefeatRoutine();
	});
});