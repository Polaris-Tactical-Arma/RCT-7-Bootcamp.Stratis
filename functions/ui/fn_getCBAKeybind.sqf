
_mod = _this # 0
_actionName = _this # 1;

_entry = [_mod, _actionName] call CBA_fnc_getKeybind; 
 
_firstKeybind = _entry # 5; 
 
_key = call compile (keyName (_firstKeybind # 0));
_output = [_key]; 
 
_extraKeys = _firstKeybind # 1; 
 
if (_extraKeys # 0) then { 
 _output pushBack "Shift"; 
}; 
 
if (_extraKeys # 1) then { 
 _output pushBack "CTRL"; 
}; 
 
 
if (_extraKeys # 0) then { 
 _output pushBack "Alt"; 
}; 
 
_output joinString " + ";