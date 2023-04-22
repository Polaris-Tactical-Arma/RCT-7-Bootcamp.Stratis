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
	_targetList = [];

	{
		private _syncedObj = _x;

		if (_syncedObj isKindOf "Logic") then {
			continue;
		};

		_targetList pushBack _x;
	} forEach (synchronizedObjects _this);

	_targetList;
};

_targetList = _targetClusterLogic call _getTargetList;

RCTLauncherTargetList = _targetList;
RCTLauncherClusterLogic = _targetClusterLogic;

_index = 0;
_count = count(_targetList);

_firedCheck = {
	if (firedCount > 0) then {
		_actionId = _this # 0;
		if (typeName _actionId isEqualTo typeName 0) then {
			player removeAction _actionId;
		};
		["Follow the instructions on your screen!<br/><br/> Try again in:", 5] call RCT7Bootcamp_fnc_cooldownHint;
		continue;
	};
};

_vehicleIsHit = {
	_vehicle = param[0, objNull, [objNull]];
	private _isDamaged = false;

	{
		if (_x isNotEqualTo 0) exitWith {
			_isDamaged = true;
		};
	} forEach (getAllHitPointsDamage _vehicle) # 2;

	_isDamaged;
};

_handleVehicleRespawn = {
	private _vehicle = param[0, objNull, [objNull]];
	private _targetClusterLogic = param[1, objNull, [objNull]];

	_pos = getPos _vehicle;
	_dir = direction _vehicle;
	_type = typeOf _vehicle;
	_isAir = _type isKindOf "Air";

	private _special = "NONE";

	if (_isAir) then {
		_special = "FLY";
	};

	_targetClusterLogic synchronizeObjectsRemove [_vehicle];
	deleteVehicleCrew _vehicle;
	deleteVehicle _vehicle;

	sleep 0.5;

	private _veh = createVehicle [_type, _pos, [], 0, _special];
	_veh setDir _dir;

	if (_veh isKindOf "Air") then {
		_crew = createVehicleCrew _veh;
		_crew setBehaviour "CARELESS";
		_veh flyInHeight (_pos # 2);
		_veh call RCT7Bootcamp_fnc_unlimitedFuel;
	};

	_targetClusterLogic synchronizeObjectsAdd [_veh];

	_veh;
};

_mag = (getArray (configFile >> "CfgWeapons" >> _launcher >> "magazines") # 0);
_magSize = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");
_launcherAmmo = getText(configfile >> "CfgMagazines" >> _mag >> "ammo");

call RCT7Bootcamp_fnc_earplugTask;

player call RCT7Bootcamp_fnc_sectionStart;
_mainTaskId = "Launcher";
[_mainTaskId, "Finish the Launcher Training", "Follow the instructions", "intel", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

while { _count isNotEqualTo _index } do {
	_targetList = _targetClusterLogic call _getTargetList;
	_target = _targetList select 0;

	[_launcher] call RCT7Bootcamp_fnc_handleLauncher;
	[ player ] call ACE_medical_treatment_fnc_fullHealLocal;
	player setDamage 0;

	_invalidTargetList=  + _targetList; // copy array
	_invalidTargetList deleteAt (_invalidTargetList find _target);

	shotsValid = 0;
	shotsInvalid = 0;
	_shotsMissed = 0;
	firedCount = 0;

	_time = time;

	_equipDescription = ["A", call _getLauncherName, "was added to your inventory!<br/>Equip it!"] joinString " ";
	_taskEquipId = "LauncherEquip";
	[[_taskEquipId, _mainTaskId], "Equip your launcher", _equipDescription, "use"] call RCT7Bootcamp_fnc_taskCreate;
	waitUntil {
		currentWeapon player isEqualTo secondaryWeapon player;
	};
	[_taskEquipId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;
	player call RCT7Bootcamp_fnc_targetHitValid;

	_reloadButton = actionKeysNames "ReloadMagazine" regexReplace ["""", ""];
	_prepareDescription = ["Prepare your launcher with:<br/>", _reloadButton] joinString "";
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
				"Zero your gun on:<br/>",
				_distance,
				"<br/><br/>",
				"Zeroing Up:<br/>", ((actionKeysNames "zeroingUp") splitString """" joinString ""), "<br/><br/>",
				"Zeroing Down:<br/>", ((actionKeysNames "zeroingDown") splitString """" joinString "")
			] joinString "";
			_taskZeroingId = "LauncherZeroing";
			[[_taskZeroingId, _mainTaskId], "Set the right zeroing", _zeroingDescription, "target"] call RCT7Bootcamp_fnc_taskCreate;

			waitUntil {
				currentZeroing player isEqualTo _distance || firedCount > 0;
			};

			[_taskZeroingId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;
			player call RCT7Bootcamp_fnc_targetHitValid;
		};
		call _firedCheck;
	};

	_taskBackblastId = "LauncherBackblast";
	[[_taskBackblastId, _mainTaskId], "Check your backblast!", "Use your scrollwheel to confirm, that you checked your backplast", "danger"] call RCT7Bootcamp_fnc_taskCreate;

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
		hint (["Shoulder the launcher and aim it at the helicopter. When the beeping intensifies click to fire.\n\n
		Helicopters need to be at least", _minDistance, "away for a successful lock."] joinString " ");
		sleep 7;
	};

	_typeOfTarget = typeOf _target;
	_name = gettext (configfile >> "CfgVehicles" >> _typeOfTarget >> "displayName");

	_dir = round(([player, (_target)] call BIS_fnc_dirTo));

	_shootDescription = ["Shoot at the ", _name, "<br/><br/>", "direction: ", _dir, "<br/>", _distance, " meters"] joinString "";
	_taskShootId = "LauncherShoot";
	[[_taskShootId, _mainTaskId], "Shoot at the target", _shootDescription, "destroy"] call RCT7Bootcamp_fnc_taskCreate;

	dbSectionName = [_sectionName, _typeOfTarget] joinString "-";

	{
		_invalidTarget = _x;
		_invalidTarget addMPEventHandler ["MPHit", {
			params ["_unit", "_source", "_damage", "_instigator"];
			// invalid
			if (_unit animationPhase "terc" isEqualTo 0) then {
				player call RCT7Bootcamp_fnc_targetHitInvalid;
				shotsInvalid = shotsInvalid + 1;
				_name = gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");
				[[player, dbSectionName, "success", false, [["vehicle", _name], ["distance", _unit distance _instigator]]]] remoteExec ["RCT7_addToDBQueue", 2];
				_unit removeAllMPEventHandlers "MPHit";
			};
		}];
	} forEach _invalidTargetList;

	_target addMPEventHandler ["MPHit", {
		params ["_unit", "_source", "_damage", "_instigator"];
		player call RCT7Bootcamp_fnc_targetHitValid;
		shotsValid = shotsValid + 1;
		_name = gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");
		[[player, dbSectionName, "vehicle", _name, [["distance", _unit distance _instigator]]]] remoteExec ["RCT7_addToDBQueue", 2];
		_unit removeAllMPEventHandlers "MPHit";
	}];

	waitUntil {
		_count isEqualTo shotsValid || _magSize isEqualTo firedCount
	};

	_hasDamage = player call _checkDamage;
	[_taskShootId, "SUCCEEDED", false, true] call RCT7Bootcamp_fnc_taskSetState;
	[[player, dbSectionName, "time", time - _time - 2, [["backblast_cleared", !_hasDamage]]]] remoteExec ["RCT7_addToDBQueue", 2];

	_index = _index + 1;

	if (_hasDamage) then {
		hint "You were to close to a structure, make sure to have at least 20 meters safe distance!";
		sleep 10;
	};

	if (getNumber(configfile >> "CfgWeapons" >> _launcher >> "rhs_disposable") isEqualTo 1) then {
		_taskDropId = "LauncherDrop";
		[[_taskDropId, _mainTaskId], "Drop your Launcher", "This Launcher is disposabel. Equip your primary Weapon to drop it.", "rifle"] call RCT7Bootcamp_fnc_taskCreate;

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
	_isSuccess = _shotsMissed isEqualTo 0;

	[[player, dbSectionName, "shotsMissed", _shotsMissed, [["success", _isSuccess]]]] remoteExec ["RCT7_addToDBQueue", 2];

	sleep 3;

	_tmpTargetList = +_targetList;

	{
		_x removeAllMPEventHandlers "MPHit";

		_isHit = _x call _vehicleIsHit;

		if !(_isHit) then {
			continue;
		};

		_targetList deleteAt (_targetList find _x);
		_veh = [_x, _targetClusterLogic] call _handleVehicleRespawn;
		_targetList pushBack _veh;
	} forEach _tmpTargetList;

	RCTLauncherTargetList = _targetList;

	if (_count > _index) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

[ player ] call ACE_medical_treatment_fnc_fullHealLocal;
player setDamage 0;
player removeEventHandler ["Fired", _firedIndex];
player removeWeapon (secondaryWeapon player);

[_mainTaskId, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;