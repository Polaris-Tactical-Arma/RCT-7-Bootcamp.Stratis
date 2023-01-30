private _handleMags = {

	_ammo = getArray (configFile >> "CfgWeapons" >> currentWeapon player >> "magazines") # 0;
	player removePrimaryWeaponItem _ammo;
	player addMagazine [_ammo, 30];
	player reload [];
};

_controller = GridTargetController;

{
	_x animate["terc", 0];
	_x setVariable ["nopop", true];
} forEach synchronizedObjects _controller;



_targetList = synchronizedObjects _controller;

private _index = 0;

// start sound
playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\course_active.wss", player];


while { count(_targetList) isNotEqualTo (_index)  } do {
	
	[] call _handleMags;

	_target = _targetList # _index;

	_invalidTargetList =  + _targetList;
	_invalidTargetList deleteAt _index;

	_grid = mapGridPosition _target;
	hint (["Shoot the target at grid:", _grid] joinString " ");

	gridSection = ["Grid", _grid] joinString "-";
	
	grid_nextTarget = false;

	_target addMPEventHandler ["MPHit", {
		params ["_unit", "_source", "_damage", "_instigator"];
			playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\timer.wss", player];
			grid_nextTarget = true;
			[player, gridSection, "success", true] remoteExec ["RCT7_writeToDb", 2];
			_unit removeAllMPEventHandlers "MPHit";
	}];


	{
		_invalidTarget = _x;
		_invalidTarget addMPEventHandler ["MPHit", {
			params ["_unit", "_source", "_damage", "_instigator"];
			if (_unit animationPhase "terc" isEqualTo 0) then {
				playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\drill_start.wss", player];
				grid_nextTarget = true;
				[player, gridSection, "success", false] remoteExec ["RCT7_writeToDb", 2];
				_reason = ["Wrong target hit at:", mapGridPosition _unit] joinString " ";
				[player, gridSection, "reason", _reason] remoteExec ["RCT7_writeToDb", 2];
				_unit removeAllMPEventHandlers "MPHit";
			};

		}];
		
	} forEach _invalidTargetList;
		

	
	// TODO: Check if mag is empty as well

	waitUntil { grid_nextTarget };

		
	playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\checkpoint_clear.wss", player];
	_index = _index + 1;

	sleep 1;

	(synchronizedObjects _controller) apply { _x animate["terc", 0]; _x removeAllMPEventHandlers "MPHit"; };

};

(synchronizedObjects _controller) apply { _x animate["terc", 1]; };

playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\drill_finish.wss", player];
hint "Grid Traning completed!";