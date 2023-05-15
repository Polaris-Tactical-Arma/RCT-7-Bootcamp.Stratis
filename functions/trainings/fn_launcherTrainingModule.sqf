_launcher = param[0, "", [""]];
_sectionName = param[1, "", [""]];
_module = param[2, objNull, [objNull]];

firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	firedCount = firedCount + 1;
}];

_syncedObjects = synchronizedObjects _module;

private _triggerObj = nil;
private _targetController = nil;
private _targetClusterList = [];

{
	private _syncedObj = _x;

	if (_syncedObj isKindOf "Logic" && ["TargetCluster", str _syncedObj] call BIS_fnc_inString) then {
		// It is a Target Cluster
		_targetClusterList pushBack _syncedObj;
		continue;
	};

	if (_syncedObj isKindOf "Logic" && ["TargetController", str _syncedObj] call BIS_fnc_inString) then {
		_targetController = _syncedObj;
		continue;
	};
} forEach _syncedObjects;

_checkDamage = {
	_unit = _this;
	private _hasDamage = false;
	_damageList = _unit getVariable ["ace_medical_bodypartdamage", [0, 0, 0, 0, 0, 0]];
	{
		if (_x > 0) exitWith {
			_hasDamage = true;
		};
	} forEach _damageList;

	_hasDamage;
};

_getLauncherName = {
	gettext (configfile >> "CfgWeapons" >> secondaryWeapon player >> "displayName");
};

_targetClusterLogic = _targetClusterList # 0;

_getTargetList = {
	private _targetList = [];

	{
		private _syncedObj = _x;

		if (_syncedObj isKindOf "Logic") then {
			continue;
		};

		_targetList pushBack _x;
	} forEach (synchronizedObjects _this);

	_targetList;
};

RCTLauncherClusterLogic = _targetClusterLogic;
RCT7LauncherTargetList = _targetClusterLogic call _getTargetList;

_index = 0;
_count = count(RCT7LauncherTargetList);

_firedCheck = {
	if (firedCount > 0) then {
		_actionId = _this # 0;
		if (typeName _actionId isEqualTo typeName 0) then {
			player removeAction _actionId;
		};
		["Make sure to follow the instructions on your screen!<br/><br/> Try again in:", 10] call RCT7Bootcamp_fnc_cooldownHint;
		continue;
	};
};

_firedLauncherEvent = player addEventHandler ["Fired", {
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

	[_projectile] spawn {
		private _projectile = _this # 0;

		private _i = 0;

		waitUntil {
			_i = _i + 1;
			!(alive _projectile) || _i > 10;
		};

		sleep 7;

		private _vehicleIsDamaged = {
			_vehicle = param[0, objNull, [objNull]];
			private _isDamaged = false;

			{
				if (_x isNotEqualTo 0) then {
					_isDamaged = true;
					break;
				};
			} forEach (getAllHitPointsDamage _vehicle) # 2;

			_isDamaged;
		};

		{
			if !(_x call _vehicleIsDamaged) then {
				continue;
			};

			[_x] spawn RCT7Bootcamp_fnc_respawnVehicle;
		} forEach RCT7LauncherTargetList;
	};
}];

_mag = (getArray (configFile >> "CfgWeapons" >> _launcher >> "magazines") # 0);
_magSize = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");
_launcherAmmo = getText(configfile >> "CfgMagazines" >> _mag >> "ammo");

call RCT7Bootcamp_fnc_earplugTask;

player call RCT7Bootcamp_fnc_sectionStart;
_mainTaskId = "Launcher";
[_mainTaskId, "Anti-Tank and Anti-Air Usage", "Follow the instructions provided.", "intel", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

while { _count isNotEqualTo _index } do {
	private _target = RCT7LauncherTargetList # 0;

	[_launcher] call RCT7Bootcamp_fnc_handleLauncher;
	[ player ] call ACE_medical_treatment_fnc_fullHealLocal;
	player setDamage 0;

	_invalidTargetList=  + RCT7LauncherTargetList; // copy array
	_invalidTargetList deleteAt (_invalidTargetList find _target);

	shotsValid = 0;
	shotsInvalid = 0;
	_shotsMissed = 0;
	firedCount = 0;
	_targetName = gettext (configfile >> "CfgVehicles" >> typeOf _target >> "displayName");

	{
		_x removeAllMPEventHandlers "MPHit";
	} forEach RCT7LauncherTargetList;

	_time = time;

	_equipDescription = ["An", call _getLauncherName, "was added to your inventory!<br/>Equip it!"] joinString " ";
	_taskEquipId = "LauncherEquip";
	[[_taskEquipId, _mainTaskId], "Equip your launcher", _equipDescription, "use"] call RCT7Bootcamp_fnc_taskCreate;
	waitUntil {
		currentWeapon player isEqualTo secondaryWeapon player;
	};
	[_taskEquipId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;
	player call RCT7Bootcamp_fnc_targetHitValid;

	_reloadButton = "ReloadMagazine" call RCT7Bootcamp_fnc_getArmaKeybind;
	_prepareDescription = ["Prepare your launcher to fire by pressing:<br/>", _reloadButton] joinString "";
	_taskPrepareId = "LauncherPrepare";
	[[_taskPrepareId, _mainTaskId], "Prepare your launcher", _prepareDescription] call RCT7Bootcamp_fnc_taskCreate;
	waitUntil {
		(player ammo secondaryWeapon player) isEqualTo 1;
	};

	[_taskPrepareId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;
	player call RCT7Bootcamp_fnc_targetHitValid;

	_dist = player distance (_target);
	_distance = round(_dist / 50) * 50;

	_zeroingList = getArray(configfile >> "CfgWeapons" >> secondaryWeapon player >> "OpticsModes" >> "ironsight" >> "discreteDistance");

	if (count(_zeroingList) > 0) then {
		_minZeroing = _zeroingList # 0;
		_maxZeroing = _zeroingList # (count(_zeroingList) - 1);

		if (_distance < _minZeroing) then {
			_distance = _minZeroing;
		};
		if (_distance > _maxZeroing) then {
			_distance = _maxZeroing;
		};

		if (currentZeroing player isNotEqualTo _distance) then {
			_zeroingDescription = [
				"Zero your launcher to:<br/>",
				_distance,
				" using the following keys;
				",
				"<br/><br/>",
				"Zeroing Up:<br/>", "zeroingUp" call RCT7Bootcamp_fnc_getArmaKeybind, "<br/><br/>",
				"Zeroing Down:<br/>", "zeroingDown" call RCT7Bootcamp_fnc_getArmaKeybind
			] joinString "";
			_taskZeroingId = "LauncherZeroing";
			[[_taskZeroingId, _mainTaskId], "Set the correct zeroing", _zeroingDescription, "target"] call RCT7Bootcamp_fnc_taskCreate;

			waitUntil {
				currentZeroing player isEqualTo _distance || firedCount > 0;
			};

			[_taskZeroingId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;
			player call RCT7Bootcamp_fnc_targetHitValid;
		};
		call _firedCheck;
	};

	_taskBackblastId = "LauncherBackblast";
	[[_taskBackblastId, _mainTaskId], "Check your backblast!", "Ensure there is around 20m between you and any hard surface to avoid injurying yourself. Use your scrollwheel to confirm, that you checked your backblast.<br/><br/>In a live situation, outside of this bootcamp, you should call out 'backblast!' on local voice so that friendlies can make way - do not fire until someone has confirmed this by responding with 'backblast clear!'", "danger"] call RCT7Bootcamp_fnc_taskCreate;

	_actionId = player addAction ["<t color='#ffe0b5'>Backblast clear!</t>", {
		params ["_target", "_caller", "_actionId", "_arguments"];
		player removeAction _actionId;
		player call RCT7Bootcamp_fnc_targetHitValid;
	}];

	waitUntil {
		!(_actionId in (actionIDs player)) || firedCount > 0;
	};
	[_taskBackblastId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;

	[_actionId] call _firedCheck;

	_target removemagazine "168Rnd_CMFlare_Chaff_Magazine";

	_descShort = getText(configfile >> "CfgWeapons" >> secondaryWeapon player >> "descriptionShort");

	if (toLower "Surface-to-air" in toLower _descShort) then {
		_minDistance = getNumber(configfile >> "CfgAmmo" >> _launcherAmmo >> "missileLockMinDistance");
		hint (["Shoulder the launcher and aim it at the helicopter. A beeping sound will play whilst locking on - when the beeping suddenly intensifies click to fire.\n\n
		Helicopters need to be at least", _minDistance, "away for a successful lock."] joinString " ");
		sleep 7;
	};

	_typeOfTarget = typeOf _target;
	_name = gettext (configfile >> "CfgVehicles" >> _typeOfTarget >> "displayName");

	_dir = round(([player, (_target)] call BIS_fnc_dirTo));

	_shootDescription = ["Shoot at the ", _name, "<br/><br/>", "Direction: ", _dir, "<br/>Range: ", _distance, " meters"] joinString "";
	_taskShootId = "LauncherShoot";
	[[_taskShootId, _mainTaskId], "Shoot at the target", _shootDescription, "destroy"] call RCT7Bootcamp_fnc_taskCreate;

	dbSectionName = [_sectionName, _index] joinString "-";

	{
		_invalidTarget = _x;
		_invalidTarget addMPEventHandler ["MPHit", {
			params ["_unit", "_source", "_damage", "_instigator"];
			_unit removeMPEventHandler ["MPHit", _thisEventHandler];
			player call RCT7Bootcamp_fnc_targetHitInvalid;
			shotsInvalid = shotsInvalid + 1;
			_name = gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");
			[[player, dbSectionName, "target_hit", _name, [["distance", _unit distance _instigator]]]] remoteExec ["RCT7_addToDBQueue", 2];
		}];
	} forEach _invalidTargetList;

	_target addMPEventHandler ["MPHit", {
		params ["_unit", "_source", "_damage", "_instigator"];
		_unit removeMPEventHandler ["MPHit", _thisEventHandler];
		player call RCT7Bootcamp_fnc_targetHitValid;
		shotsValid = shotsValid + 1;
		_name = gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");
		[[player, dbSectionName, "target_hit", _name, [["distance", _unit distance _instigator]]]] remoteExec ["RCT7_addToDBQueue", 2];
	}];

	waitUntil {
		_count isEqualTo shotsValid || _magSize isEqualTo firedCount
	};

	_hasDamage = player call _checkDamage;
	[_taskShootId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;
	[[player, dbSectionName, "time", time - _time - 2, [["backblast_cleared", !_hasDamage]]]] remoteExec ["RCT7_addToDBQueue", 2];

	_index = _index + 1;

	if (_hasDamage) then {
		hint "You were too close to a hard surface, make sure to have at least 20 meters of safe distance to avoid hurting yourself!";
		sleep 10;
	};

	if (getNumber(configfile >> "CfgWeapons" >> _launcher >> "rhs_disposable") isEqualTo 1) then {
		_taskDropId = "LauncherDrop";
		[[_taskDropId, _mainTaskId], "Drop your launcher", "This launcher is disposable. To drop it, equip your primary weapon.", "rifle"] call RCT7Bootcamp_fnc_taskCreate;

		waitUntil {
			secondaryWeapon player isEqualTo ""
		};
		[_taskDropId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;
	};

	_j = 0;
	waitUntil {
		sleep 1;
		_j = _j + 1;
		(damage _target) > 0 || _j > 1;
	};

	_shotsMissed = firedCount - (shotsInvalid + shotsValid);

	[[player, dbSectionName, "shotsMissed", _shotsMissed, [["target", _targetName], ["success", shotsValid > 0]]]] remoteExec ["RCT7_addToDBQueue", 2];

	if (_count > _index) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

[ player ] call ACE_medical_treatment_fnc_fullHealLocal;
player setDamage 0;
player removeEventHandler ["Fired", _firedIndex];
player removeEventHandler ["Fired", _firedLauncherEvent];
player removeWeapon (secondaryWeapon player);

[_mainTaskId, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;