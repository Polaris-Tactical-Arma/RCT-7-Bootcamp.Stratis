_micro = "TFAR_microdagr";
_radio = "TFAR_rf7800str_1";
_microDisplayname = getText(configfile >> "CfgWeapons" >> _micro >> "displayName");
_radioDisplayname = getText(configfile >> "CfgWeapons" >> _radio  >> "displayName");

hint (["Grab the following out of the box:\n", _microDisplayname, _radioDisplayname] joinString "\n");


waitUntil{ _micro in assignedItems player && _radio in assignedItems player };

_openRadioKeybind = ["TFAR", "OpenSWRadioMenu"] call RCT7Bootcamp_fnc_getCBAKeybind;

hint (["Open your Radio with:\n[", _openRadioKeybind, "]"] joinString "");
waitUntil{!isNull(findDisplay 4425)};

_freq1 = "31";
hint (["Set your first Channel to:\n", _freq1] joinString "");

waitUntil{([(call TFAR_fnc_activeSwRadio), 1] call TFAR_fnc_getChannelFrequency) isEqualTo _freq1};

_freq2 = "31.1";
hint (["Set your second Channel to:\n", _freq2] joinString "");

waitUntil{[(call TFAR_fnc_activeSwRadio), 2] call TFAR_fnc_getChannelFrequency isEqualTo _freq2};

_transmitKeybind = ["TFAR", "SWTransmit"] call RCT7Bootcamp_fnc_getCBAKeybind;
hint (["You can now transmit with [", _transmitKeybind, "]\n You can switch Channels with your Numpad"] joinString "");

// Change to just press the button
waitUntil{ player call TFAR_fnc_isSpeaking };

hint "Training complete";