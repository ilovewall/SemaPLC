PROGRAM Section8
VAR
	MM701_Raw_mA : real;
	PT701_Raw : real;
	TT102_Raw : real;
	HS701_ON : bool;
	CS701_ON : bool;
	SB701_SheetBreak : bool;
	MM701_Moisture_PV : real;
	PT701_HydraulicPressure_PV : real;
	TT102_ShowerWaterTemp_PV : real;
	PV101_Pressure_Command_Pct : real;
	PV101_Position_Feedback_Pct : real;
	ESD_Trip : bool;
	MM_701 : ANALOG_IN;
	PT_701 : ANALOG_IN;
	TT_102 : ANALOG_IN;
	LIC_701 : PID_BASIC;
	PV_101 : VALVE_ELECTRIC;
	HS_701 : BOOL_INPUT;
	CS_701 : BOOL_INPUT;
	SB_701 : BOOL_INPUT;
	SheetPresent_NOT : bool;
	PressLoopPermissive_AND : bool;
	FailCloseTrip_OR : bool;
	LoopInhibit_OR : bool;
	MoistureTrip_GT : bool;
END_VAR

MM_701(
    Raw_Signal := MM701_Raw_mA,
    PV_High := 58.0,
    PV_Low := 46.0,
    Scaling_Slope := 1.25,
    Scaling_Offset := 35.0,
    Alarm_Enable := TRUE);
PT_701(
    Raw_Signal := PT701_Raw,
    Scaling_Slope := 1.0,
    Scaling_Offset := 0.0,
    Alarm_Enable := TRUE);
TT_102(
    Raw_Signal := TT102_Raw,
    Scaling_Slope := 1.0,
    Scaling_Offset := 0.0,
    Alarm_Enable := TRUE);
MoistureTrip_GT := (MM_701.PV > 65.0);
PV_101(
    Control_Signal := LIC_701.XOUT,
    Manual_Mode := FailCloseTrip_OR,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0);
FailCloseTrip_OR := TT_102.High_Alarm OR MoistureTrip_GT OR PT_701.High_Alarm OR PV_101.Position_Error;
LoopInhibit_OR := MM_701.General_Fault OR FailCloseTrip_OR;
CS_701(
    Bool_In := CS701_ON);
HS_701(
    Bool_In := HS701_ON);
SB_701(
    Bool_In := SB701_SheetBreak);
SheetPresent_NOT := NOT SB_701.Bool_Out;
PressLoopPermissive_AND := HS_701.Bool_Out AND CS_701.Bool_Out AND SheetPresent_NOT;
LIC_701(
    AUTO := PressLoopPermissive_AND,
    PV := MM_701.PV,
    SP := 52.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := PV_101.Feedback_Pos,
    KP := 3.0,
    TR := 1.2,
    TD := 0.2,
    Deviation_Limit := 2.0,
    Inhibit := LoopInhibit_OR);

(* Outputs published to other sections / HMI. *)
MM701_Moisture_PV := MM_701.PV;
PT701_HydraulicPressure_PV := PT_701.PV;
TT102_ShowerWaterTemp_PV := TT_102.PV;
PV101_Pressure_Command_Pct := LIC_701.XOUT;
PV101_Position_Feedback_Pct := PV_101.Feedback_Pos;
ESD_Trip := PT_701.High_Alarm;

END_PROGRAM
