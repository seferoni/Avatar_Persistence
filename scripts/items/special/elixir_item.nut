local AP = ::RPGR_Avatar_Persistence;
this.elixir_item <- ::inherit("scripts/items/item",
{
	m = {},
	function create()
	{
		this.item.create();
		this.m.ID = "misc.elixir";
		this.m.Name = "Elixir";
		this.m.Description = "A caustic and volatile concoction, notorious throughout the realms for its propensity to both heal and harm in equal measure.";
		this.m.Icon = "special/elixir_01.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.Value = 1500;
	}
	Tooltip =
	{
		Icons =
		{
			Instruction = "ui/icons/special.png"
		}
	}
	Sounds =
	{
		Inventory = "sounds/bottle_01.wav",
		Use = "sounds/combat/drink_03.wav"
	}

	function getTooltip()
	{
		local tooltipArray = [],
		push = @(_entry) tooltipArray.push(_entry);

		# Create generic entries.
		push({id = 1, type = "title", text = this.getName()});
		push({id = 2, type = "description", text = this.getDescription()});
		push({id = 66, type = "text", text = this.getValueString()});
		push({id = 3, type = "image", image = this.getIcon()});

		# Create instruction entries.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Instruction, text = "Will remove all temporary or permanent injuries, but only for player characters"});
		push({id = 65, type = "text", text = "Right-click or drag onto the currently selected character in order to drink. This item will be consumed in the process."});

		return tooltipArray;
	}

	function getAllSprites()
	{
		local sprites = [];

		for( local i = 1; i <= 4; i++ )
		{
			sprites.push(format("permanent_injury_%i", i));
		}

		return sprites;
	}

	function isActorViable( _actor )
	{
		if (!AP.Persistence.isActorViable(_actor))
		{
			return false;
		}

		if (!_actor.getSkills().hasSkillOfType(::Const.SkillType.Injury))
		{
			return false;
		}

		return true;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play(this.Sounds.Inventory, ::Const.Sound.Volume.Inventory);
	}
	
	function playUseSound()
	{
		::Sound.play(this.Sounds.Use, ::Const.Sound.Volume.Inventory);
	}

	function onUse( _actor, _item = null )
	{
		if (!this.isActorViable(_actor))
		{	// TODO: handle case where avatar status is conferred & add warning entry for invalid uses
			return false;
		}

		this.playUseSound();
		this.updateActor(_actor);
		this.updateSprites(_actor);
		return true;
	}

	function updateActor( _actor )
	{
		_actor.getSkills().removeByType(::Const.SkillType.Injury);
		_actor.getSkills().add(::new("scripts/skills/injury/sickness_injury"));
		_actor.setHitpoints(_actor.getHitpointsMax());
	}

	function updateSprites( _actor )
	{
		local sprites = this.getAllSprites();

		foreach( sprite in sprites )
		{
			local injurySprite = _actor.getSprite(sprite);
			injurySprite.Visible = false;
			injurySprite.resetBrush();
		}
	}
});

