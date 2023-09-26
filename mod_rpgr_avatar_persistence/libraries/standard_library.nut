local AP = ::RPGR_Avatar_Persistence;
AP.Standard <-
{
    function cacheHookedMethod( _object, _functionName )
    {
        local naiveMethod = null,
        parentName = _object.SuperName;

        if (_functionName in _object)
        {
            naiveMethod = _object[_functionName];
        }

        return naiveMethod;
    }

    function generateTooltipTableEntry( _id, _type, _icon, _text )
    {
        local tableEntry =
        {
            id = _id,
            type = _type,
            icon = "ui/icons/" + _icon,
            text = _text
        }

        return tableEntry;
    }

    function getSetting( _settingID )
    {
        if (AP.MSUFound)
        {
            return AP.Mod.ModSettings.getSetting(_settingID).getValue();
        }

        if (!(_settingID in AP.Defaults))
        {
            this.logWrapper(format("Invalid settingID %s passed to getSetting, returning null.", _settingID), true);
            return null;
        }

        return AP.Defaults[_settingID];
    }

    function includeFiles( _path )
    {
        foreach( file in ::IO.enumerateFiles(_path) )
        {
            ::include(file);
        }
    }

    function logWrapper( _string, _isError = false )
    {
        if (_isError)
        {
            ::logError(format("[Avatar Persistence] %s", _string));
        }

        if (!this.getSetting("VerboseLogging"))
        {
            return;
        }

        ::logInfo(format("[Avatar Persistence] %s", _string));
    }

    function overrideArguments( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls new method and passes result onto original method; if null, calls original method with original arguments.
        local newArguments = this.prependContextObject(_object, [_function.acall(_argumentsArray)]);
        return newArguments == null ? _originalMethod.acall(_argumentsArray) : _originalMethod.acall(newArguments);
    }

    function overrideMethod( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls and returns new method; if return value is null, calls and returns original method.
        local returnValue = _function.acall(_argumentsArray);
        return returnValue == null ? _originalMethod(_argumentsArray) : returnValue;
    }

    function overrideReturn( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls original method and passes result as an array onto new method, returns new result. Ideal for tooltips.
        local newArguments = this.prependContextObject(_object, [_originalMethod.acall(_argumentsArray)]);
        return _function.acall(newArguments);
    }

    function prependContextObject( _object, _array ) // TODO: prepend should be able to preserve arrays
    {
        local array = [_object];

        foreach( entry in _array )
        {
            array.push(entry);
        }

        return array;
    }


    function wrap( _object, _functionName, _function, _procedure )
    {
        local cachedMethod = this.cacheHookedMethod(_object, _functionName),
        parentName = _object.SuperName;

        _object.rawset(_functionName, function( ... )
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod,
            argumentsArray = ::RPGR_Avatar_Persistence.Standard.prependContextObject(this, vargv);
            return ::RPGR_Avatar_Persistence.Standard[_procedure](this, _function, originalMethod, argumentsArray);
        });
    }
};

