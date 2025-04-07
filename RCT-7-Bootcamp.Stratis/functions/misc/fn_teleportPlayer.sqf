_unit = param[0, objNull, [objNull]];
_name = param[1, "", [""]];
_objName = ["StartPosition", _name] joinString "_";

if (_name isEqualTo "" || isNil _objName) exitWith {};

[0, "BLACK", 1, 1] spawn BIS_fnc_fadeEffect;

sleep 3;

_obj = call compile (_objName);

_pos = getPosATL _obj;
player setPosATL _pos;

[1, "BLACK", 1, 1] spawn BIS_fnc_fadeEffect;