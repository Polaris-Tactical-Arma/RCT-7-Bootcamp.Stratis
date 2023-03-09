(vehicle _this) spawn
{
	while {alive _this} do
	{
		if (fuel _this < 0.8) then
		{
			_this setFuel 1;
		};
		sleep 120;
	};
};

true;