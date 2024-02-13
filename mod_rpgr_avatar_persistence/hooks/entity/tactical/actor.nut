local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("entity/tactical/actor", function( _object )
{
	AP.Standard.wrap(_object, "kill", function( _killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = true )
	{
		if (!AP.Persistence.isActorViable(this))
		{
			return;
		}

		if (!AP.Persistence.isWithinInjuryThreshold(this))
		{
			return;
		}

		return [_killer, _skill, ::Const.FatalityType.None, _silent];
	}, "overrideArguments");
});
