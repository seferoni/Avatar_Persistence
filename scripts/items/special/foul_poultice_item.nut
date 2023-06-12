this.foul_poultice_item <- this.inherit("scripts/items/item", {
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
		this.m.Value = 0;
	}

	function getTooltip()
	{
		local result = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			}
		];
		result.push({
			id = 66,
			type = "text",
			text = this.getValueString()
		});

		if (this.getIconLarge() != null)
		{
			result.push({
				id = 3,
				type = "image",
				image = this.getIconLarge(),
				isLarge = true
			});
		}
		else
		{
			result.push({
				id = 3,
				type = "image",
				image = this.getIcon()
			});
		}

		result.push({
			id = 6,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Will remove all temporary or permanent injuries, but only for those that can stomach its noxious vapours"
		});
		result.push({
			id = 65,
			type = "text",
			text = "Right-click or drag onto the currently selected character in order to drink. This item will be consumed in the process."
		});
		return result;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play("sounds/bottle_01.wav", ::Const.Sound.Volume.Inventory);
	}

	function onUse( _actor, _item = null )
	{

        if (!_actor.getFlags().get("IsPlayerCharacter"))
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
		_actor.setHitpoints(_actor.getHitpointsMax());
		_actor.getSprite("permanent_injury_1").Visible = false;
		_actor.getSprite("permanent_injury_2").Visible = false;
		_actor.getSprite("permanent_injury_3").Visible = false;
		_actor.getSprite("permanent_injury_4").Visible = false;
		_actor.getSprite("permanent_injury_1").resetBrush();
		_actor.getSprite("permanent_injury_2").resetBrush();
		_actor.getSprite("permanent_injury_3").resetBrush();
		_actor.getSprite("permanent_injury_4").resetBrush();
		return true;
	}

});

