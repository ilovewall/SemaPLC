FUNCTION_BLOCK MOTOR_ON_OFF
VAR_INPUT
	Start_Cmd : bool;
	Stop_Cmd : bool;
	Start_Delay : time;
	MinRunTime : time;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	Motor_Start_Out : bool;
	FB_Running : bool;
	FB_Trip : bool;
	Alarm_Start_Fail : bool;
	Alarm_Stop_Fail : bool;
END_VAR

IF Inhibit OR Stop_Cmd THEN
    Motor_Start_Out := FALSE;
ELSIF Start_Cmd THEN
    Motor_Start_Out := TRUE;
END_IF;
FB_Running := Motor_Start_Out;
FB_Trip := FALSE;
Alarm_Start_Fail := FALSE;
Alarm_Stop_Fail := FALSE;

END_FUNCTION_BLOCK