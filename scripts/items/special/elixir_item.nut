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
		this.initialiseText();
		this.initialiseWarnings();
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

	function createWarningEntry()
	{
		local warning = this.getActiveWarning();

		if (warning == null)
		{
			return null;
		}
	}

	function conferAvatarStatus( _actor )
	{
		if (AP.Persistence.isPlayerInRoster())
		{
			this.setWarning("AvatarAlreadyPresent", true);
			return;
		}
	}

	function getActiveWarning()
	{
		foreach( warning, warningState in this.m.Warnings )
		{
			if (warningState) return warning;
		}

		return null;
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

	function getInstructionText()
	{
		return this.m.InstructionText;
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
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Instruction, text = this.getInstructionText()});
		push({id = 65, type = "text", text = this.getUsageText()});

		return tooltipArray;
	}

	function getUsageText()
	{
		return this.m.UsageText;
	}

	function initialiseText()
	{
		this.m.InstructionText <- "Will remove all temporary or permanent injuries, but only for player characters.";
		this.m.UsageText <- "Right-click or drag onto the currently selected character in order to drink. This item will be consumed in the process.";
	}

	function initialiseWarning()
	{
		this.m.Warnings <- {};
		this.m.Warnings.AvatarAlreadyPresent <- false;
		this.m.Warnings.CharacterNotEligible <- false;
		this.m.Warnings.NoInjuriesPresent <- false;
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

	function setWarning( _warning, _boolean )
	{
		this.m.Warnings[_warning] = _boolean;
		::Tooltip.reload();
	}

	function onUse( _actor, _item = null )
	{ // TODO: revise
		if (!this.isActorViable(_actor) && !)
		{
			this.conferAvatarStatus(_actor);
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

