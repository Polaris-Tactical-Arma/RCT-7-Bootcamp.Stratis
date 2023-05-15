/*
	ORDER:
	. Radio
	. 3D Report
	. Shoothouse (targets, timer, delay for diagram)
	. Grenade
	. Map Training
	. Launcher
	. formation
	. Bounding
	. Medical
	
	
	TODO:
	- add check for backend connection
	
	
*/

titleText ["Initializing Bootcamp...", "PLAIN DOWN", 10];

sleep 3;

titleText ["", "PLAIN", 1];

_completedSectionName = "CompletedSections";

_sectionList = [
	"Radio",
	"3DReport",
	// "Shoothouse", 
	"Grenade",
	"Map",
	"LauncherAT",
	"LauncherAA",
	"Formation",
	"BoundingSuccessive",
	"BoundingAlternate",
	"Medical",
	"MedicalSelf"
];

private _lastItem = _sectionList # (count _sectionList - 1);

_isSectionCompleted = {
	private _sectionToCheck = _this # 0;
	private _completedSectionsKey = _this # 1;
	private _data = RCT7playerData;

	if (count _data isEqualTo 0) exitWith {
		false
	};

	    private _dataArray = _data select 0 select 1; // Get the "data" array
	private _completedSections = [];

	{
		private _key = _x select 0;
		if (_key == _completedSectionsKey) then {
			_completedSections = _x select 1;
		};
	} forEach _dataArray;

	private _isCompleted = false;

	{
		private _section = _x select 0;
		private _completed = _x select 1;
		if (_section == _sectionToCheck && _completed) then {
			_isCompleted = true;
		};
	} forEach _completedSections;

	_isCompleted
};

{
	_section = _x;

	if ([_section, _completedSectionName] call _isSectionCompleted) then {
		continue;
	};

	[player, _section] call RCT7Bootcamp_fnc_teleportPlayer;

	switch (_section) do {
		case "Radio": {
			[] call RCT7Bootcamp_fnc_radioModule;
		};
		case "3DReport": {
			Gun3DReport call RCT7Bootcamp_fnc_3DReportTrainingModule;
		};
		case "Shoothouse": {
			[] call RCT7Bootcamp_fnc_shoothouse;
		};
		case "Grenade": {
			["rhs_mag_m67", "Grenade", GrenadeTraining] call RCT7Bootcamp_fnc_grenadeTrainingModule;
		};
		case "Map": {
			GunGridTraining call RCT7Bootcamp_fnc_mapTrainingModule;
		};
		case "LauncherAT": {
			["rhs_weap_M136", "AT", ATTraining] call RCT7Bootcamp_fnc_launcherTrainingModule;
		};
		case "LauncherAA": {
			["rhs_weap_fim92", "AA", AATraining] call RCT7Bootcamp_fnc_launcherTrainingModule;
		};
		case "Formation": {
			private _group = FormationGroup;
			[position ((units _group) # 0)] call RCT7Bootcamp_fnc_playerLookAtPos;

			[_group] call RCT7Bootcamp_fnc_formation;
		};
		case "BoundingAlternate": {
			[UnitBoundingAlternate, "Alternate", "Alternate Bounding differs from Successive in that buddy groups do not move to be on line with each other, instead whichever group is moving pushes to a position beyond the other.<br/><br/>Move to your Partner and start the training with the scroll-wheel action.<br/>Follow your Partner and stay in line while moving."] call RCT7Bootcamp_fnc_bounding;
		};
		case "BoundingSuccessive": {
			[UnitBoundingSuccessive, "Successive", "Bounding is a fireteam movement which splits the fireteam in half - one buddy group moves and one buddy group covers - this ensures two guns are always available when the fireteam must advance towards an enemy or cross clearings safely.<br/><br/>The first type of bounding is called 'Successive Bounding' - In this, the moving group advances quickly and takes cover, while the other group suppresses the enemy. Then, the suppressing group moves to be on line with the first group to provide cover for the next movement.<br/><br/>This process repeats until the final position has been reached.<br/><br/>Move to your Partner and start the training with the scroll-wheel action.<br/>Follow your Partner and stay in line while moving."] call RCT7Bootcamp_fnc_bounding;
		};
		case "Medical": {
			private _unit = UnitMedical;
			[position _unit] call RCT7Bootcamp_fnc_playerLookAtPos;
			[_unit] call RCT7Bootcamp_fnc_ACEMedical;
		};
		case "MedicalSelf": {
			[player] call RCT7Bootcamp_fnc_ACEMedical;
		};
	};

	[[player, _completedSectionName, _section, true]] remoteExec ["RCT7_addToDBQueue", 2];

	if (_lastItem isEqualTo _section) exitWith {};
	titleText ["Training Complete!<br/>Starting next Training", "PLAIN", 0.4, false, true];
} forEach _sectionList;

hint "Bootcamp complete!";
sleep 3;
["Bootcamp finished", true, 3] remoteExec ["BIS_fnc_endMission", 0, true];