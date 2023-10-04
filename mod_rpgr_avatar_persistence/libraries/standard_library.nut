local AP = ::RPGR_Avatar_Persistence;
AP.Standard <-
{
    function cacheHookedMethod( _object, _functionName )
    {
        local naiveMethod = null;

        if (_functionName in _object)
        {
            naiveMethod = _object[_functionName];
        }

        return naiveMethod;
    }

    function colourWrap( _text, _colour )
    {
        local string = _text;

        if (typeof _text != "string")
        {
            string = _text.tostring();
        }

        return format("[color=%s] %s [/color]", ::Const.UI.Color[_colour], string)
    }

    function getDescriptor( _valueToMatch, _referenceTable )
    {
        foreach( descriptor, value in _referenceTable )
        {
            if (value == _valueToMatch)
            {
                return descriptor;
            }
        }
    }

    function getPercentageSetting( _settingID )
    {
        return (this.getSetting(_settingID) / 100.0)
    }

    function getSetting( _settingID )
    {
        if (AP.Internal.MSUFound)
        {
            return AP.Mod.ModSettings.getSetting(_settingID).getValue();
        }

        if (!(_settingID in AP.Defaults))
        {
            this.log(format("Invalid settingID %s passed to getSetting, returning null.", _settingID), true);
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

    function log( _string, _isError = false )
    {
        if (_isError)
        {
            ::logError(format("[Avatar Persistence] %s", _string));
            return;
        }

        if (!this.getSetting("VerboseLogging"))
        {
            return;
        }

        ::logInfo(format("[Avatar Persistence] %s", _string));
    }

    function overrideArguments( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls new method and passes result onto original method; if null, calls original method with original arguments.
        # It is the responsibility of the overriding function to return appropriate arguments.
        local returnValue = _function.acall(_argumentsArray);
        local newArguments = returnValue == null ? _argumentsArray : this.prependContextObject(_object, returnValue);
        return _originalMethod.acall(newArguments);
    }

    function overrideMethod( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls and returns new method; if return value is null, calls and returns original method.
        local returnValue = _function.acall(_argumentsArray);
        return returnValue == null ? _originalMethod.acall(_argumentsArray) : (returnValue == AP.Internal.TERMINATE ? null : returnValue);
    }

    function overrideReturn( _object, _function, _originalMethod, _argumentsArray )
    {   # Calls original method and passes result onto new method, returns new result. Ideal for tooltips.
        # It is the responsibility of the overriding function to ensure it takes on the appropriate arguments and returns appropriate values.
        local originalValue = _originalMethod.acall(_argumentsArray);
        if (originalValue != null) _argumentsArray.insert(1, originalValue);
        local returnValue = _function.acall(_argumentsArray);
        return returnValue == null ? originalValue : (returnValue == AP.Internal.TERMINATE ? null : returnValue);
    }

    function prependContextObject( _object, _arguments )
    {
        local array = [_object];

        if (typeof _arguments != "array")
        {
            array.push(_arguments);
            return array;
        }

        foreach( entry in _arguments )
        {
            array.push(entry);
        }

        return array;
    }

    function validateParameters( _originalFunction, _newParameters )
    {
        local originalInfo = _originalFunction.getinfos(), originalParameters = originalInfo.parameters;

        if (originalParameters[originalParameters.len() - 1] == "...")
        {
            return true;
        }

        local newLength = _newParameters.len() + 1;

        if (newLength <= originalParameters.len() && newLength >= originalParameters.len() - originalInfo.defparams.len())
        {
            return true;
        }

        return false;
    }

    function wrap( _object, _functionName, _function, _procedure )
    {
        local cachedMethod = this.cacheHookedMethod(_object, _functionName),
        AP = ::RPGR_Avatar_Persistence,
        parentName = _object.SuperName;

        _object.rawset(_functionName, function( ... )
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod;

            if (!AP.Standard.validateParameters(originalMethod, vargv))
            {
                AP.Standard.log(format("An invalid number of parameters were passed to %s, aborting wrap procedure.", _functionName), true);
                return;
            }

            local argumentsArray = AP.Standard.prependContextObject(this, vargv);
            return AP.Standard[_procedure](this, _function, originalMethod, argumentsArray);
        });
    }
};

