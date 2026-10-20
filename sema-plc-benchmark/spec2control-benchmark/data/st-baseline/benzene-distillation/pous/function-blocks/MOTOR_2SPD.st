FUNCTION_BLOCK MOTOR_2SPD
VAR_INPUT
	Start_Cmd : bool;
	Stop_Cmd : bool;
	Speed_High_Cmd : bool;
	Speed_Low_Cmd : bool;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	Motor_Start_Out : bool;
	FB_Running : bool;
	FB_Trip : bool;
	FB_HighSpeed : bool;
	FB_LowSpeed : bool;
	Alarm_Speed_Error : bool;
END_VAR

IF Inhibit OR Stop_Cmd THEN
    Motor_Start_Out := FALSE;
ELSIF Start_Cmd THEN
    Motor_Start_Out := TRUE;
END_IF;
FB_Running := Motor_Start_Out;
FB_HighSpeed := Motor_Start_Out AND Speed_High_Cmd;
FB_LowSpeed := Motor_Start_Out AND Speed_Low_Cmd AND NOT Speed_High_Cmd;
FB_Trip := FALSE;
Alarm_Speed_Error := Speed_High_Cmd AND Speed_Low_Cmd;

END_FUNCTION_BLOCK