this.ap_momentum_effect <- ::inherit("scripts/skills/ap_skill",
{
	m = {},
	function create()
	{
		this.ap_skill.create();
		this.assignPropertiesByName("Momentum");
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
				format("%s %s", ::AP.Standard.colourWrap(format("+%i", bonus), ::AP.Standard.Colour.Green), ::AP.Utilities.getString(attribute)),
				entries
			);
		}

		if (entries.len() == 0)
		{
			::AP.Standard.constructEntry
			(
				"Warning",
				::AP.Standard.colourWrap(::AP.Strings.Skills.Common.MomentumNoBonusesText, ::AP.Standard.Colour.Red),
				entries
			);
		}

		return entries;
	}

	function createMomentumStateEntry()
	{
		local colour = ::AP.Standard.Colour.Green;
		local suffix = ::AP.Strings.Skills.Common.MomentumStateBelowRosterThreshold;

		if (!this.isWithinRosterThreshold())
		{
			colour = ::AP.Standard.Colour.Red;
			suffix = ::AP.Strings.Skills.Common.MomentumStateRosterThresholdExceeded;
		}

		return ::AP.Standard.constructEntry
		(
			"Momentum",
			format("%s %s", ::AP.Strings.Skills.Common.MomentumStatePrefix, ::AP.Standard.colourWrap(suffix, colour))
		);
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
	{	// TODO: try and account for hp here
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

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push(this.createMomentumStateEntry());
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

	function initialiseFlags()
	{
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
});