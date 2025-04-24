::AP.Utilities <-
{
	function getAttributeString( _fieldName )
	{
		return this.getStringField("Attributes")[_fieldName];
	}

	function getField( _fieldName )
	{
		return ::AP.Database.getField("Generic", _fieldName);
	}

	function getPlayerInRoster( _rosterObject )
	{
		local rosterArray = _rosterObject.getAll();

		foreach( brother in rosterArray )
		{
			if (this.isActorPlayerCharacter(brother))
			{
				return brother;
			}
		}

		return null;
	}

	function getString( _fieldName )
	{
		return this.getStringField("Common")[_fieldName];
	}

	function getStringField( _fieldName )
	{
		return ::AP.Strings.getField("Generic", _fieldName);
	}

	function getTooltipString( _fieldName )
	{
		return this.getStringField("Tooltips")[_fieldName];
	}

	function isActorPlayerCharacter( _actorObject )
	{
		if (!_actorObject.getSkills().hasSkill("trait.player"))
		{
			return false;
		}

		if (!::AP.Standard.getFlag("IsPlayerCharacter", _actorObject))
		{
			return false;
		}

		return true;
	}

	function isCombatInArena()
	{
		return ::Tactical.State.m.StrategicProperties != null && ::Tactical.State.m.StrategicProperties.IsArenaMode;
	}

	function reduceResources( _reductionTable )
	{
		foreach( resourceString, reducedMagnitude in _reductionTable )
		{
			::World.Assets.m[resourceString] = ::Math.max(0, ::World.Assets.m[resourceString] - reducedMagnitude);
		}
	}
};