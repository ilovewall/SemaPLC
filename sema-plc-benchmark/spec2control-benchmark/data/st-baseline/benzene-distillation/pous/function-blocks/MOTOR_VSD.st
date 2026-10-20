FUNCTION_BLOCK MOTOR_VSD
VAR_INPUT
	Start_Cmd : bool;
	Stop_Cmd : bool;
	Speed_SP : real;
	Accel_Ramp : time;
	Decel_Ramp : time;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	Speed_Out : real;
	FB_Running : bool;
	FB_Fault : bool;
	FB_Ready : bool;
	FB_ActualSpeed : real;
	Alarm_Speed_Deviation : bool;
	Alarm_Comm_Fail : bool;
END_VAR

IF Inhibit OR Stop_Cmd THEN
    FB_Running := FALSE;
ELSIF Start_Cmd THEN
    FB_Running := TRUE;
END_IF;
IF FB_Running THEN
    Speed_Out := Speed_SP;
ELSE
    Speed_Out := 0.0;
END_IF;
FB_Ready := NOT Inhibit;
FB_Fault := FALSE;
FB_ActualSpeed := Speed_Out;
Alarm_Speed_Deviation := FALSE;
Alarm_Comm_Fail := FALSE;

END_FUNCTION_BLOCK