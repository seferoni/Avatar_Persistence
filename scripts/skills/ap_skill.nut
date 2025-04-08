this.ap_skill <- ::inherit("scripts/skills/skill",
{	// TODO: standardise this with wfr_skill conventions
	m = {},
	function create()
	{
		this.assignGenericProperties();
		this.createFlags();
		this.assignSpecialProperties();
	}

	function assignGenericProperties()
	{
		this.m.IsActive = false;
		this.m.IsHidden = false;
		this.m.Type = ::Const.SkillType.StatusEffect;
		this.m.Order = ::Const.SkillOrder.Trait + 1;
	}

	function assignPropertiesByName( _properName )
	{
		this.setIDByName(_properName);
		this.setDescription(_properName);
		this.setIconByName(_properName);
		this.setName(_properName);
	}

	function assignSpecialProperties()
	{
		this.m.DescriptionPrefix <- "";
		this.m.GFXPathPrefix <- "skills/";
		this.m.LifetimeDays <- 0;
	}

	function createFlags()
	{
		this.m.Flags <- ::new("scripts/tools/tag_collection");
	}

	function formatName( _properName, _replacementSubstring = "" )
	{
		return ::AP.Standard.replaceSubstring(" ", _replacementSubstring, _properName);
	}

	function getAcquisitionDay()
	{
		return ::AP.Standard.getFlag("AcquisitionDay", this);
	}

	function getLastUpdateTime()
	{
		return ::AP.Standard.getFlag("LastUpdateTime", this);
	}

	function getField( _fieldName )
	{
		return ::AP.Persistence.getField(_fieldName);
	}

	function getFlags()
	{
		return this.m.Flags;
	}

	function getRemainingLifetime()
	{
		local timeSinceAcquisition =  ::World.getTime().Days - this.getAcquisitionDay();
		return this.m.LifetimeDays - timeSinceAcquisition;
	}

	function getTooltip()
	{
		local tooltipArray = [];
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push({id = 1, type = "title", text = this.getName()});
		push({id = 2, type = "description", text = this.getDescription()});
		return tooltipArray;
	}

	function setDescription( _properName )
	{
		local key = format("%sDescription", this.formatName(_properName));
		this.m.Description = ::AP.Strings.Skills[key];
	}

	function setIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("effects.ap_%s", formattedName.tolower());
	}

	function setIconByName( _properName )
	{	// TODO: standardise this with wfr_skill conventions
		local formattedName = this.formatName(_properName, "_");
		this.m.Icon = format("%s/ap_%s_effect.png", this.m.GFXPathPrefix, formattedName.tolower());
	}

	function setName( _properName )
	{
		local key = format("%sName", this.formatName(_properName));
		this.m.Name = ::AP.Strings.Skills[key];
	}

	function onAdded()
	{
		this.skill.onAdded();
		this.setAcquisitionDayToNow();
		this.setLastUpdateTimeToNow();
	}

	function onSerialize( _out )
	{
		this.skill.onSerialize(_out);
		this.m.Flags.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.skill.onDeserialize(_in);
		this.m.Flags.onDeserialize(_in);
	}

	function setLastUpdateTimeToNow()
	{
		::AP.Standard.setFlag("LastUpdateTime", ::World.getTime().Days, this);
	}

	function setAcquisitionDayToNow()
	{
		::AP.Standard.setFlag("AcquisitionDay", ::World.getTime().Days, this);
	}
});