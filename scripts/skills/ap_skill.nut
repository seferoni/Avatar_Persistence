this.ap_skill <- ::inherit("scripts/skills/skill",
{
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
		this.m.Order = ::Const.SkillOrder.Trait;
	}

	function assignPropertiesByName( _properName )
	{
		this.assignIDByName(_properName);
		this.assignIconsByName(_properName);
		this.setSkillKey(_properName);
		this.assignDescription();
		this.assignName();
	}

	function assignSpecialProperties()
	{
		this.m.SkillKey <- "";
		this.m.GFXPathPrefix <- "skills/";
	}

	function assignDescription()
	{
		this.m.Description = this.getString("Description");
	}

	function assignIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("effects.ap_%s", formattedName.tolower());
	}

	function assignIconsByName( _properName )
	{
		local iconHandle = format("ap_%s_effect", this.formatName(_properName, "_").lower());
		this.m.Overlay = iconHandle;
		this.m.Icon = format("%s/%s.png", this.m.GFXPathPrefix, iconHandle);
		this.m.IconMini = format("%s_mini", iconHandle);
	}

	function assignName()
	{
		this.m.Name = this.getString("Name");
	}

	function createFlags()
	{
		this.m.Flags <- ::new("scripts/tools/tag_collection");
	}

	function formatName( _properName, _replacementSubstring = "" )
	{
		return ::AP.Standard.replaceSubstring(" ", _replacementSubstring, _properName);
	}

	function getFlags()
	{
		return this.m.Flags;
	}

	function getString( _fieldName )
	{
		return ::AP.Skills.getSkillStringField(this.m.SkillKey)[_fieldName];
	}

	function getTooltip()
	{
		local tooltipArray = [];
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push({id = 1, type = "title", text = this.getName()});
		push({id = 2, type = "description", text = this.getDescription()});
		return tooltipArray;
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

	function setSkillKey( _properName )
	{
		this.m.SkillKey = this.formatName(_properName);
	}

	function spawnOverlayOnCurrentTile()
	{
		this.spawnIcon(this.m.Overlay, this.getContainer().getActor().getTile());
	}
});