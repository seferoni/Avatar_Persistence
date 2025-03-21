::AP.Database <-
{
	function createTables()
	{
		this.Settings <- {};
		this.Generic <- {};
		this.Blueprints <- {};
		this.Events <- {};
	}

	function getField( _tableName, _fieldName )
	{
		local field = this.getTopLevelField(_tableName, _fieldName);

		if (field == null)
		{
			field = this.getSubLevelField(_tableName, _fieldName);
		}

		return field;
	}

	function getSubLevelField( _tableName, _fieldName )
	{
		foreach( subtableName, nestedTable in this[_tableName] )
		{
			if (!(_fieldName in nestedTable))
			{
				continue;
			}

			return this[_tableName][subtableName][_fieldName];
		}

		return null;
	}

	function getTopLevelField( _tableName, _fieldName )
	{
		if (!(_fieldName in this[_tableName]))
		{
			return null;
		}

		return this[_tableName][_fieldName];
	}

	function getIcon( _iconKey )
	{
		if (!_iconKey in this.Generic.Icons)
		{
			::AP.Standard.log(format(::AP.Strings.Debug.InvalidIconPath, _iconKey), true);
			return null;
		}

		return this.Generic.Icons[_iconKey];
	}

	function getSettingParameters()
	{
		local agglomeratedParameters = {};

		foreach( parameterType, parameterTable in this.Settings )
		{
			::AP.Standard.extendTable(parameterTable, agglomeratedParameters);
		}

		return agglomeratedParameters;
	}

	function getSettingCategories()
	{
		return ::AP.Standard.getKeys(this.Settings);
	}

	function initialise()
	{
		this.createTables();
		this.loadFiles();
	}

	function loadFolder( _path )
	{
		::AP.Manager.includeFiles(format("mod_rpgr_avatar_persistence/framework/database/%s", _path));
	}

	function loadFiles()
	{
		this.loadFolder("dictionaries/generic");
		this.loadFolder("dictionaries/events");
		this.loadFolder("dictionaries/blueprints");
		this.loadFolder("settings");
	}
};