::AP.Patcher.hook("scripts/entity/tactical/actor", function( p )
{
	::AP.Patcher.wrap(p, "kill", function( _killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = true )
	{
		if (!::AP.Persistence.isActorViable(this))
		{
			return;
		}

		if (::AP.Persistence.getPermanentInjuryThresholdDifferential(this) > 0)
		{
			return;
		}

		return [_killer, _skill, ::Const.FatalityType.None, _silent];
	}, "overrideArguments");
});