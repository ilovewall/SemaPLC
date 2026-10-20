PROGRAM Section6
VAR
	PT_501_Pressure_PV : real;
	TT_501_Temperature_PV : real;
	TT_501_MV : real;
	SM_501_EA_POS : real;
	SM_501_EA_CMD : real;
	PT_501 : ANALOG_IN;
	TT_501 : ANALOG_IN;
	SM_501 : VALVE_ELECTRIC;
	TT_501_CTRL : PID_BASIC;
	SM_501_LID_POS : DIGITAL_IN;
	HeatingEnableDelay_TON : TON;
	HeatingInhibit_OR : bool;
	LidNotClosed_NOT : bool;
	EAposLE10_LE : bool;
	HeatingEnableReq_NOT : bool;
	AutoMode_NOT : bool;
END_VAR

PT_501(
    Alarm_Enable := TRUE);
TT_501(
    PV_High := 1650.0,
    PV_Low := 1500.0,
    Scaling_Slope := 37.5,
    Scaling_Offset := 1050.0,
    Alarm_Enable := TRUE);
EAposLE10_LE := (SM_501.Feedback_Pos <= 10.0);
SM_501_LID_POS();
LidNotClosed_NOT := NOT SM_501_LID_POS.DI_Out;
HeatingInhibit_OR := LidNotClosed_NOT OR TT_501.High_Alarm OR PT_501.Low_Alarm OR TT_501.General_Fault OR SM_501.Alarm OR EAposLE10_LE;
HeatingEnableReq_NOT := NOT HeatingInhibit_OR;
HeatingEnableDelay_TON(
    IN := HeatingEnableReq_NOT,
    PT := T#10s);
AutoMode_NOT := NOT HeatingEnableDelay_TON.Q;
TT_501_CTRL(
    AUTO := HeatingEnableDelay_TON.Q,
    PV := TT_501.PV,
    SP := 1620.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := SM_501.Feedback_Pos,
    KP := 3.2,
    TR := 1.5,
    TD := 0.3,
    PV_High := 1650.0,
    PV_Low := 1500.0,
    Deviation_Limit := 2.0,
    Inhibit := HeatingInhibit_OR);
SM_501(
    Control_Signal := TT_501_CTRL.XOUT,
    Manual_Mode := AutoMode_NOT,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#5s,
    Inhibit := HeatingInhibit_OR);

(* Outputs published to other sections / HMI. *)
PT_501_Pressure_PV := PT_501.PV;
TT_501_Temperature_PV := TT_501.PV;
TT_501_MV := TT_501_CTRL.XOUT;
SM_501_EA_POS := SM_501.Feedback_Pos;
SM_501_EA_CMD := SM_501.Valve_Position;

END_PROGRAM
