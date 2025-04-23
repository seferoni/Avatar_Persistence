::AP.StashHandler <-
{
	function isItemViableForRemoval( _itemObject )
	{
		local removalParameters = ::AP.Utilities.getField("ItemRemovalParameters");

		foreach( itemType in removalParameters.ForbiddenTypesInclusive )
		{
			if (_itemObject.isItemType(itemType))
			{
				return false;
			}
		}

		foreach( itemType in removalParameters.ForbiddenTypesExclusive )
		{
			if (_itemObject.m.ItemType == itemType)
			{
				return false;
			}
		}

		foreach( itemID in removalParameters.ForbiddenItemIDs )
		{
			if (_itemObject.getID() == itemID)
			{
				return false;
			}
		}

		return true;
	}

	function removeItems( _playerObject, _itemsArray )
	{
		local excess = [];
		local playerContainer = _playerObject.getItems();
		local stash = ::World.Assets.getStash().getItems();

		foreach( item in _itemsArray )
		{
			local index = stash.find(item);

			if (index == null)
			{
				excess.push(item);
				continue;
			}

			stash.remove(index);
		}

		foreach( item in excess )
		{
			local index = playerContainer.getAllItems().find(item);

			if (index != null)
			{
				playerContainer.unequip(item);
			}
		}

		::World.Assets.updateFood();
	}
};