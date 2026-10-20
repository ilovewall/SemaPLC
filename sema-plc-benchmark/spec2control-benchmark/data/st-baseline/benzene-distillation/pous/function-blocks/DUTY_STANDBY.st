FUNCTION_BLOCK DUTY_STANDBY
VAR_INPUT
	Enable : bool;
	StartRequest : bool;
	AlternateEnable : bool;
	ForcePumpA : bool;
	ForcePumpB : bool;
	DutyElapsed : bool;
	MinRunElapsed : bool;
	SwitchoverDelayElapsed : bool;
	StartTimeoutElapsed : bool;
	PumpA_RunFB : bool;
	PumpB_RunFB : bool;
	PumpA_Fault : bool;
	PumpB_Fault : bool;
	Reset : bool;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	CmdPumpA : bool;
	CmdPumpB : bool;
	ActiveIsA : bool;
	SwitchedDueToDuty : bool;
	SwitchedDueToFailure : bool;
	Alarm_FailedStart_A : bool;
	Alarm_FailedStart_B : bool;
	Alarm_NoAvailablePump : bool;
END_VAR

ActiveIsA := NOT AlternateEnable;
IF Enable AND StartRequest AND NOT Inhibit THEN
    CmdPumpA := ActiveIsA AND NOT PumpA_Fault;
    CmdPumpB := (NOT ActiveIsA OR PumpA_Fault) AND NOT PumpB_Fault;
ELSE
    CmdPumpA := FALSE;
    CmdPumpB := FALSE;
END_IF;
IF ForcePumpA THEN
    CmdPumpA := Enable AND NOT Inhibit;
    CmdPumpB := FALSE;
END_IF;
IF ForcePumpB THEN
    CmdPumpA := FALSE;
    CmdPumpB := Enable AND NOT Inhibit;
END_IF;
SwitchedDueToDuty := DutyElapsed;
SwitchedDueToFailure := PumpA_Fault OR PumpB_Fault;
Alarm_FailedStart_A := PumpA_Fault;
Alarm_FailedStart_B := PumpB_Fault;
Alarm_NoAvailablePump := PumpA_Fault AND PumpB_Fault;

END_FUNCTION_BLOCK