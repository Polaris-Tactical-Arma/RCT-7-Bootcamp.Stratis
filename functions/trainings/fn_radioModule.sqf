_micro = "TFAR_microdagr";
_radio = "TFAR_rf7800str_1";
_microDisplayname = getText(configfile >> "CfgWeapons" >> _micro >> "displayName");
_radioDisplayname = getText(configfile >> "CfgWeapons" >> _radio >> "displayName");

_radioTaskId = "Radio";
[_radioTaskId, "Radio Familiarization", "Follow the tasks provided.", "intel", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

_getRadio = "GetRadio";
_getRadioDescription = ["Grab the following out of the box and equip them:<br/>", _microDisplayname, _radioDisplayname] joinString "<br/>";
[[_getRadio, _radioTaskId], "Get a radio", _getRadioDescription] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	_micro in assignedItems player && _radio in assignedItems player
};
[_getRadio] call RCT7Bootcamp_fnc_taskSetState;

_openRadioKeybind = ["TFAR", "OpenSWRadioMenu"] call RCT7Bootcamp_fnc_getCBAKeybind;

_openRadioTaskId = "OpenRadio";
_openRadioDescription = ["Open your radio with:<br/>[", _openRadioKeybind, "]"] joinString "";
[[_openRadioTaskId, _radioTaskId], "Open Radio", _openRadioDescription, "radio"] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	!isNull(findDisplay 4425)
};
[_openRadioTaskId] call RCT7Bootcamp_fnc_taskSetState;

_freq1 = "31";
_frequency1TaskId = ["Frequency", _freq1] joinString "";

_setFrequencyDescription = ["Set your first channel to: ", _freq1, ".<br/>Click and delete the existing frequency, type 31 and click the ENT button."] joinString "";
[[_frequency1TaskId, _radioTaskId], ["Set your first channel to", _freq1, "."] joinString "", _setFrequencyDescription, "radio"] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	([(call TFAR_fnc_activeSwRadio), 1] call TFAR_fnc_getChannelFrequency) isEqualTo _freq1
};
[_frequency1TaskId] call RCT7Bootcamp_fnc_taskSetState;

_freq2 = "31.1";
_setFrequencyDescription = ["Set your second channel to: ", _freq2, ".<br/>Right click the tuning dial in the top left corner once or press", "SHINY REPLACE", "."] joinString "";
_frequency2TaskId = ["Frequency", _freq2] joinString "";
[[_frequency2TaskId, _radioTaskId], ["Set your second channel to: ", _freq2, "."] joinString "", _setFrequencyDescription, "radio"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil{
	[(call TFAR_fnc_activeSwRadio), 2] call TFAR_fnc_getChannelFrequency isEqualTo _freq2
};
[_frequency2TaskId] call RCT7Bootcamp_fnc_taskSetState;

_transmitKeybind = ["TFAR", "SWTransmit"] call RCT7Bootcamp_fnc_getCBAKeybind;

_transmitTaskId = "transmit";
_transmitDesciption = ["You can now transmit with [", _transmitKeybind, "]<br/> You can also switch channels with the keys on your numpad"] joinString "";
[[_transmitTaskId, _radioTaskId], "Transmit on your radio", _transmitDesciption, "radio"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil{
	TF_tangent_sw_pressed;
};

[_transmitTaskId, "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;

[_radioTaskId] call RCT7Bootcamp_fnc_taskSetState;