 _this setObjectTexture [2, "data\decal_door.paa"];

_this addAction ["Open Door",  
    {  
        params ["_target", "_caller", "_actionId", "_arguments"];
  
        private _isOpen = _target getVariable ["RCT_isOpen", false];  
  
        private _i = 0;   
        private _p = getPosATL _target; 
        private _scale = getObjectScale _target;


        _target removeAction _actionId;
        
        _target setVariable ["RCT_isOpen", !_isOpen, true];  
        _factor = 1.5;

        while {90  > _i} do {   
            _dir = (getDir _target) - (1 * _factor); 
            _target setDir _dir;   
            _pos = _target modelToWorld [0,(0.01 * _factor),0];   
            _target setObjectScale _scale;
            _target setPosATL [_pos # 0, _pos # 1, (_p # 2)];   
            _i = _i + (1 * _factor);  
            sleep 0.001;  
        };  
  
    }
]; 