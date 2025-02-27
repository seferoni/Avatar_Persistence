this.ap_item <- ::inherit("scripts/items/item",
{
	m = {},
	function create()
	{
		this.item.create();
		this.assignGenericProperties();
		this.assignSoundProperties();
		this.createFlags();
		this.assignSpecialProperties();
	}

	function assignGenericProperties()
	{
		this.m.IsUsable = true;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
	}

	function assignPropertiesByName( _properName )
	{
		this.setIDByName(_properName);
		this.setIconByName(_properName);
		this.setDescription(_properName);
		this.setName(_properName);
	}

	function assignSoundProperties()
	{
		this.m.UseSound <- "";
		this.m.InventorySound <- "";
		this.m.WarningSound <- "sounds/move_pot_clay_01.wav";
	}

	function assignSpecialProperties()
	{
		this.m.DescriptionPrefix <- "";
		this.m.GFXPathPrefix <- "special/";
		this.m.Warnings <- {};
	}

	function createFlags()
	{
		this.m.Flags <- ::new("scripts/tools/tag_collection");
	}

	function createWarningEntries()
	{
		local entries = [];
		local warnings = this.getActiveWarnings();

		if (warnings.len() == 0)
		{
			return null;
		}

		foreach( warning in warnings )
		{
			::AP.Standard.constructEntry
			(
				"Warning",
				::AP.Standard.colourWrap(::AP.Strings.Warnings[warning], ::AP.Standard.Colour.Red),
				entries
			);
		}

		this.resetWarnings();
		return entries;
	}

	function formatName( _properName, _replacementSubstring = "" )
	{
		return ::AP.Standard.replaceSubstring(" ", _replacementSubstring, _properName);
	}

	function getActiveWarnings()
	{
		local warnings = [];

		foreach( warningKey, warningValue in this.m.Warnings )
		{
			if (warningValue)
			{
				warnings.push(warningKey);
			}
		}

		return warnings;
	}

	function getFlags()
	{
		return this.m.Flags;
	}

	function getTooltip()
	{
		local tooltipArray = [];
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push({id = 1, type = "title", text = this.getName()});
		push({id = 2, type = "description", text = this.getDescription()});
		push({id = 66, type = "text", text = this.getValueString()});
		push({id = 3, type = "image", image = this.getIcon()});
		return tooltipArray;
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		this.m.Flags.onDeserialize(_in);
	}

	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		this.m.Flags.onSerialize(_out);
	}

	function playSound( _soundSource )
	{
		if (typeof _soundSource != "array")
		{
			::Sound.play(_soundSource, ::Const.Sound.Volume.Inventory);
			return;
		}

		::Sound.play(_soundSource[::Math.rand(0, _soundSource.len() - 1)], ::Const.Sound.Volume.Inventory);
	}

	function playInventorySound( _eventType )
	{
		this.playSound(this.m.InventorySound);
	}

	function playUseSound()
	{
		this.playSound(this.m.UseSound);
	}

	function playWarningSound()
	{
		this.playSound(this.m.WarningSound);
	}

	function resetWarnings()
	{
		foreach( warningKey, warningValue in this.m.Warnings )
		{
			this.m.Warnings[warningKey] = false;
		}
	}

	function setDescription( _properName )
	{
		local key = format("%sDescription", this.formatName(_properName));
		this.m.Description = ::AP.Strings.Items[key];
	}

	function setIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("special.ap_%s_item", formattedName.tolower());
	}

	function setIconByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.Icon = format("%s/ap_%s_item.png", this.m.GFXPathPrefix, formattedName.tolower());
	}

	function setName( _properName )
	{
		local key = format("%sName", this.formatName(_properName));
		this.m.Name = ::AP.Strings.Items[key];
	}

	function setWarning( _warning, _boolean = true )
	{
		this.m.Warnings[_warning] = _boolean;
		::Tooltip.reload();
	}
});