local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("entity/tactical/player", function( _object )
{
	AP.Standard.wrap(_object, "isReallyKilled", function( _fatalityType )
	{
		if (!AP.Persistence.isActorViable(this))
		{
			return;
		}

		if (!AP.Persistence.isWithinInjuryThreshold(this))
		{
			return;
		}

		if (::Math.rand(1, 100) > AP.Standard.getSetting("PermanentInjuryChance"))
		{
			return AP.Persistence.executePersistenceRoutine(this, AP.Persistence.FlavourText.Uninjured);
		}

		local injuryCandidates = AP.Persistence.generateInjuryCandidates(this);

		if (injuryCandidates.len() == 0)
		{
			AP.Standard.log("No injury candidates were found viable for application to the player.", true);
			return AP.Persistence.executePersistenceRoutine(this, AP.Persistence.FlavourText.Uninjured);
		}

		this.getSkills().add(::new(format("scripts/skills/%s", injuryCandidates[::Math.rand(0, injuryCandidates.len() - 1)].Script)));
		return AP.Persistence.executePersistenceRoutine(this, AP.Persistence.FlavourText.Injured);
	}, "overrideMethod");
});