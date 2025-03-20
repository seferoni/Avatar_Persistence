this.ap_momentum_effect <- ::inherit("scripts/skills/ap_skill",
{
	m = {},
	function create()
	{
		this.ap_skill.create();
		this.assignPropertiesByName("Momentum");
	}

	function assignGenericProperties()
	{
		this.ap_skill.assignGenericProperties();
		this.m.IsHidden = false;
	}

	function assignSpecialProperties()
	{
		this.ap_skill.assignSpecialProperties();
		this.initialiseFlags();
	}

	function applySkillBonuses( _currentProperties )
	{
		local viableAttributes = this.getViableAttributes();

		foreach( attribute in viableAttributes )
		{
			local bonus = this.getAttributeBonus(attribute);
			_currentProperties[attribute] += bonus;
		}
	}

	function applySpecialEffects( _currentProperties )
	{
		if (!this.isWithinRosterThreshold())
		{
			return;
		}

		local activeEffects = this.getActiveEffects();

		foreach( effectTable in activeEffects )
		{
			_currentProperties[effectTable.Property] += effectTable.Offset;
		}
	}

	function createAttributeEntries()
	{
		local entries = [];
		local viableAttributes = this.getViableAttributes();

		foreach( attribute in viableAttributes )
		{
			local bonus = this.getAttributeBonus(attribute);

			if (bonus == 0)
			{
				continue;
			}

			::AP.Standard.constructEntry
			(
				attribute,
				format("%s %s", ::AP.Standard.colourWrap(format("+%i", bonus), ::AP.Standard.Colour.Green), ::AP.Strings.Generic[attribute]),
				entries
			);
		}

		if (entries.len() == 0)
		{
			::AP.Standard.constructEntry
			(
				"Warning",
				::AP.Standard.colourWrap(::AP.Strings.Skills.MomentumNoBonusesText, ::AP.Standard.Colour.Red),
				entries
			);
		}

		return entries;
	}

	function createMomentumStateEntry()
	{
		local colour = ::AP.Standard.Colour.Green;
		local suffix = ::AP.Strings.Skills.MomentumStateBelowRosterThreshold;

		if (!this.isWithinRosterThreshold())
		{
			colour = ::AP.Standard.Colour.Red;
			suffix = ::AP.Strings.Skills.MomentumStateRosterThresholdExceeded;
		}

		return ::AP.Standard.constructEntry
		(
			"Momentum",
			format("%s %s", ::AP.Strings.Skills.MomentumStatePrefix, ::AP.Standard.colourWrap(suffix, colour))
		);
	}

	function createSpecialEffectEntries()
	{
		local entries = [];

		if (!this.isWithinRosterThreshold())
		{
			return entries;
		}

		local activeEffects = this.getActiveEffects();

		if (activeEffects.len() == 0)
		{
			return entries;
		}

		foreach( effectTable in activeEffects )
		{
			::AP.Standard.constructEntry
			(
				Property,
				format("%s %s", ::AP.Standard.colourWrap(format("+%i", effectTable.Offset), ::AP.Standard.Colour.Green), ::AP.Strings.Generic[Property]),
				entries
			);
		}

		return entries;
	}

	function getActiveEffects()
	{
		local activeEffects = [];
		local specialEffects = this.getSpecialEffectTables();
		local enemiesKilled = this.getEnemiesSlain();

		foreach( effectTable in specialEffects )
		{
			if (effectTable.EnemiesSlain > enemiesKilled)
			{
				continue;
			}

			activeEffects.push(effectTable);
		}

		return activeEffects;
	}

	function getAttributeBonus( _attributeKey )
	{
		return ::AP.Standard.getFlag(_attributeKey, this);
	}

	function getAttributeBonusOffset()
	{
		local nominalOffset = ::AP.Persistence.getPermanentInjuryCount(this.getContainer().getActor());

		if (nominalOffset == 0)
		{
			nominalOffset++;
		}

		if (this.isWithinRosterThreshold())
		{
			nominalOffset *= 2;
		}

		return nominalOffset;
	}

	function getEligibleAttributeByEntity( _targetEntity )
	{
		local eligibleAttributes = [];
		local viableAttributes = this.getViableAttributes();
		local playerProperties = this.getContainer().getActor().getBaseProperties();
		local targetProperties = _targetEntity.getBaseProperties();

		foreach( attribute in viableAttributes )
		{
			if (targetProperties[attribute] <= playerProperties[attribute] + this.getAttributeBonus(attribute))
			{
				continue;
			}

			eligibleAttributes.push(attribute);
		}

		if (eligibleAttributes.len() == 0)
		{
			return null;
		}

		return eligibleAttributes[::Math.rand(0, eligibleAttributes)];
	}

	function getEnemiesSlain()
	{
		return ::AP.Standard.getFlag("EnemiesSlain", this);
	}

	function getSpecialEffectTables()
	{
		return this.getField("MomentumSpecialEffects");
	}

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push(this.createMomentumStateEntry());
		push(this.createSpecialEffectEntries());
		push(this.createAttributeEntries());
		return tooltipArray;
	}

	function getViableAttributes()
	{
		return this.getField("MomentumAttributes");
	}

	function incrementAttributeBonus( _attributeKey )
	{
		local currentBonus = this.getAttributeBonus(_attributeKey);
		this.setAttributeBonus(_attributeKey, currentBonus + this.getAttributeBonusOffset());
	}

	function incrementEnemiesSlain()
	{
		local currentValue = this.getEnemiesSlain();
		this.setEnemiesSlain(currentValue + 1);
	}

	function initialiseFlags()
	{
		if (this.getEnemiesSlain() == false)
		{
			this.setEnemiesSlain(0);
		}

		local viableAttributes = this.getViableAttributes();

		foreach( attribute in viableAttributes )
		{
			if (this.getAttributeBonus(attribute) != false)
			{
				continue;
			}

			this.setAttributeBonus(attribute, 0);
		}
	}

	function isWithinRosterThreshold()
	{
		return ::World.getPlayerRoster().getAll().len() <= ::AP.Standard.getParameter("MomentumRosterThreshold");
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		local eligibleAttribute = this.getEligibleAttributeByEntity(_targetEntity);

		if (eligibleAttribute == null)
		{
			return;
		}

		this.incrementAttributeBonus(eligibleAttribute);
		this.incrementEnemiesSlain();
	}

	function onUpdate( _properties )
	{
		this.ap_skill.onUpdate(_properties);
		this.refreshStateByConfiguration();

		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return;
		}

		this.applySkillBonuses(_properties);
		this.applySpecialEffects(_properties);
	}

	function refreshStateByConfiguration()
	{
		this.m.IsHidden = !::AP.Standard.getParameter("EnableMomentum");
	}

	function resetMomentum()
	{
		local viableAttributes = this.getViableAttributes();

		foreach( attribute in viableAttributes )
		{
			this.setAttributeBonus(attribute, 0);
		}
	}

	function setAttributeBonus( _attributeKey, _attributeBonus )
	{
		::AP.Standard.setFlag(_attributeKey, _attributeBonus, this);
	}

	function setEnemiesSlain( _newValue )
	{
		::AP.Standard.setFlag("EnemiesSlain", _newValue, this);
	}
});