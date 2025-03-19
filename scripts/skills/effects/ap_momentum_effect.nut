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
		this.initialiseAttributeBonuses();
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

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push(this.createAttributeEntries());
		return tooltipArray;
	}

	function getViableAttributes()
	{
		return ::AP.Persistence.getField("MomentumAttributes");
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

		return nominalOffset;
	}

	function incrementAttributeBonus( _attributeKey )
	{
		local currentBonus = this.getAttributeBonus(_attributeKey);
		this.setAttributeBonus(_attributeKey, currentBonus + this.getAttributeBonusOffset());
	}

	function initialiseAttributeBonuses()
	{
		local viableAttributes = this.getViableAttributes();

		foreach( attribute in viableAttributes )
		{
			if (this.getAttributeBonus(attribute) != false)
			{
				continue;
			}

			this.setAttributeBonus(0, attribute);
		}
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
			this.setAttributeBonus(0, attribute);
		}
	}

	function setAttributeBonus( _attributeKey, _attributeBonus )
	{
		::AP.Standard.setFlag(_attributeKey, _attributeBonus, this);
	}

	function setBattlesSurvived( _integer = 0 )
	{
		::AP.Standard.setFlag("BattlesSurvived", _integer, this);
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
});