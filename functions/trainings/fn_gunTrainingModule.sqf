
_args = _this # 3; 
_controller = _args # 0;
_targetClusterList = _args # 1;
_sectionNameCode = _args # 2;
_hintCode = _args # 3;

if (_sectionNameCode isEqualTo "") exitWith { systemChat "No section provided!" };

if (_hintCode isEqualTo "") exitWith { systemChat "No hint code provided!" };


[_controller, 0] call RCT7Bootcamp_fnc_handleTargets;

firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	firedCount = firedCount + 1;
}];

_index = 0;
_magSize = getNumber (configfile >> "CfgMagazines" >> (getArray (configFile >> "CfgWeapons" >> currentWeapon player >> "magazines") # 0) >> "count");
_count = count(_targetClusterList);

if (!(player getVariable ["ACE_hasEarPlugsIn", false])) then {
	_keybind = ["ACE3 Common", "ACE_Interact_Menu_SelfInteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
	_earplugs = [call RCT7Bootcamp_fnc_getACESelfInfo, "and under Equipment, put your earplugs in"] joinString "";
	hint _earplugs;
};

waitUntil { player getVariable ["ACE_hasEarPlugsIn", false]; };

player call RCT7Bootcamp_fnc_sectionStart;

while {  _count isNotEqualTo _index  } do {
	
	call RCT7Bootcamp_fnc_handleMags;
	_targetCluster = _targetClusterList select _index;

	_targetList = [];
	{
		if (_x isKindOf "TargetBase") then {
			_targetList pushBack _x;
		};
		
	} forEach (synchronizedObjects _targetCluster);

	_targetCount = count(_targetList);

	_invalidTargetCluster =  + _targetClusterList; // copy array
	_invalidTargetCluster deleteAt _index;

	dbSectionName = call compile _sectionNameCode;
	

	shotsValid = 0;
	shotsInvalid = 0;
	_shotsMissed = 0;
	firedCount = 0;


	hint (call compile _hintCode);

	{
		_x addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
					player call RCT7Bootcamp_fnc_targetHitValid;
					shotsValid = shotsValid + 1;
					[player, dbSectionName, "shotsValid", shotsValid] remoteExec ["RCT7_writeToDb", 2];
					_unit removeAllMPEventHandlers "MPHit";
			}];
		
	} forEach _targetList;


	{
		{
			_invalidTarget = _x;
			_invalidTarget addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
				// invalid
				if (_unit animationPhase "terc" isEqualTo 0) then {
					player call RCT7Bootcamp_fnc_targetHitInvalid;
					shotsInvalid = shotsInvalid + 1;
					[player, dbSectionName, "shotsInvalid", shotsInvalid] remoteExec ["RCT7_writeToDb", 2];
					_unit removeAllMPEventHandlers "MPHit";
				};

			}];
			
		} forEach synchronizedObjects _x;
		
	} forEach _invalidTargetCluster;

	waitUntil { _targetCount isEqualTo shotsValid || _magSize isEqualTo firedCount };

	_index = _index + 1;
	_shotsMissed = firedCount - (shotsInvalid + shotsValid);
	[player, dbSectionName, "shotsMissed", _shotsMissed] remoteExec ["RCT7_writeToDb", 2];
	sleep 1;

	(synchronizedObjects _controller) apply { _x animate["terc", 0]; _x removeAllMPEventHandlers "MPHit"; };
	
	if ( _count > _index ) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

player removeEventHandler ["Fired", _firedIndex];

[_controller, 1] call RCT7Bootcamp_fnc_handleTargets;

player call RCT7Bootcamp_fnc_sectionFinished;
hint "Traning completed!";