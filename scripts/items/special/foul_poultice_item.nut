this.foul_poultice_item <- ::inherit("scripts/items/item",
{
	m = {},
	function create()
	{
		this.item.create();
		this.m.ID = "misc.foul_poultice";
		this.m.Name = "Foul Poultice";
		this.m.Description = "A foul-smelling poultice, repellant to all but the dumb and desperate.";
		this.m.Icon = "consumables/vial_green_01.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.Value = 10;
	}

	function getTooltip()
	{
		local tooltipArray =
		[
			{id = 1, type = "title", text = this.getName()},
			{id = 2, type = "description", text = this.getDescription()},
			{id = 66, type = "text", text = this.getValueString()},
		];

		if (this.getIconLarge() != null)
		{
			tooltipArray.push({id = 3, type = "image", image = this.getIconLarge(), isLarge = true});
		}
		else
		{
			tooltipArray.push({id = 3, type = "image", image = this.getIcon()});
		}

		tooltipArray.extend([
			{id = 6, type = "text", icon = "ui/icons/special.png", text = "Will remove all temporary or permanent injuries, but only for those that can stomach its noxious vapours"},
			{id = 65, type = "text", text = "Right-click or drag onto the currently selected character in order to drink. This item will be consumed in the process."}
		]);

		return tooltipArray;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play("sounds/bottle_01.wav", ::Const.Sound.Volume.Inventory);
	}

	function onUse( _actor, _item = null )
	{
        if (!::RPGR_Avatar_Persistence.Persistence.isActorViable(_actor))
        {
            return false;
        }

		if (!_actor.getSkills().hasSkillOfType(::Const.SkillType.Injury))
		{
			return false;
		}

		::Sound.play("sounds/combat/drink_03.wav", ::Const.Sound.Volume.Inventory);
		_actor.getSkills().removeByType(::Const.SkillType.Injury);
		_actor.getSkills().add(::new("scripts/skills/injury/sickness_injury"));
		local sprites = [];

		for( local i = 1 ; i <= 4 ; i++ )
		{
			sprites.push(format("permanent_injury_%i", i));
		}

		foreach( sprite in sprites )
		{
			local injurySprite = _actor.getSprite(sprite);
			injurySprite.Visible = false;
			injurySprite.resetBrush();
		}

		return true;
	}
});

