::AP.Integrations.MSU.Builders.Implicit <-
{
	function addSettingsImplicitly( _settingGroup, _pageID )
	{
		local elements = [];
		local booleanSettings = [];
		local settingIDs = this.getSettingIDsFromGroup(_settingGroup);

		foreach( settingID in settingIDs )
		{
			local settingValues = _settingGroup[settingID];
			local settingElement = this.buildSettingElement(settingID, settingValues);

			if (settingElement == null)
			{
				continue;
			}

			if (settingElement instanceof ::MSU.Class.BooleanSetting)
			{
				booleanSettings.push(settingElement);
				continue;
			}

			elements.push(settingElement);
		}

		elements.push(::AP.Integrations.MSU.createDivider(format("%sDivider", _pageID)));
		elements.extend(booleanSettings);

		foreach( element in elements )
		{
			::AP.Integrations.MSU.appendElementToPage(element, _pageID);
		}
	}

	function build()
	{
		local pageOrder = ::AP.Integrations.MSU.getPageOrder();

		foreach( pageKey in pageOrder )
		{
			this.buildPage(pageKey);
			this.addSettingsImplicitly(::AP.Database.Settings[pageKey], pageKey);
		}
	}

	function buildPage( _pageID )
	{
		local pageName = ::AP.Integrations.MSU.getPageName(_pageID);
		::AP.Integrations.MSU.addPage(_pageID, pageName);
	}

	function buildSettingElement( _settingID, _settingValues )
	{
		local settingElement = null;

		switch (typeof _settingValues.Default)
		{
			case ("bool"): settingElement = this.createBooleanSetting(_settingID, _settingValues); break;
			case ("string"): settingElement = this.createStringSetting(_settingID, _settingValues); break;
			case ("float"):
			case ("integer"): settingElement = this.createNumericalSetting(_settingID, _settingValues); break;
		}

		if (settingElement == null)
		{
			::AP.Standard.log(format("Passed element with ID %s had an unexpected default value type, skipping for implicit construction.", _settingID), true);
			return null;
		}

		::AP.Integrations.MSU.buildDescription(settingElement);
		return settingElement;
	}

	function createBooleanSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.BooleanSetting
		(
			_settingID,
			_settingValues.Default,
			::AP.Integrations.MSU.getElementName(_settingID)
		);
	}

	function createNumericalSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.RangeSetting
		(
			_settingID,
			_settingValues.Default,
			_settingValues.Range[0],
			_settingValues.Range[1],
			_settingValues.Interval,
			::AP.Integrations.MSU.getElementName(_settingID)
		);
	}

	function createStringSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.StringSetting
		(
			_settingID,
			_settingValues.Default,
			::AP.Integrations.MSU.getElementName(_settingID)
		);
	}

	function getSettingIDsFromGroup( _settingGroup )
	{
		local settingIDs = ::AP.Standard.getKeys(_settingGroup);
		::AP.Standard.sortArrayAlphabetically(settingIDs, function( _settingID )
		{
			return ::AP.Integrations.MSU.getElementName(_settingID);
		});
		return settingIDs;
	}
};