PROGRAM Section4
VAR
	FT301_InfluentFlow_PV : real;
	FT302_SludgeFlow_PV : real;
	LS301_WeirLevel_PV : real;
	PS301_SludgePressure_PV : real;
	FT302_SludgeFlow_SP : real;
	FT_301 : ANALOG_IN;
	FT_302 : ANALOG_IN;
	LS_301 : ANALOG_IN;
	PS_301 : ANALOG_IN;
	SS_301 : DIGITAL_IN;
	FV_102 : VALVE_ELECTRIC;
	FFIC_303 : RATIO_CONTROL;
	FIC_302 : PID_BASIC;
	FlowAboveCutoff_GT : bool;
	MasterInhibit_OR : bool;
END_VAR

FT_301(
    Alarm_Enable := TRUE);
FT_302(
    Alarm_Enable := TRUE);
LS_301(
    PV_High := 5.0,
    PV_Low := 2.0,
    Alarm_Enable := TRUE);
PS_301();
SS_301();
FlowAboveCutoff_GT := (FT_301.PV > 50.0);
MasterInhibit_OR := LS_301.High_Alarm OR LS_301.Low_Alarm OR FT_301.High_Alarm OR FT_301.Low_Alarm OR FT_301.General_Fault OR FT_302.High_Alarm OR FT_302.Low_Alarm OR FT_302.General_Fault OR FIC_302.Deviation_Alarm OR FV_102.Position_Error OR FV_102.Alarm OR SS_301.DI_Out;
FFIC_303(
    Auto := FlowAboveCutoff_GT,
    PrimaryPV := FT_301.PV,
    SecondaryPV := FT_302.PV,
    RatioSP := 0.3,
    Bias := 0.0,
    TrimKp := 0.0,
    TrimTi := T#0s,
    MV_MIN := 0.0,
    MV_MAX := 200.0,
    Inhibit := MasterInhibit_OR);
FIC_302(
    AUTO := FlowAboveCutoff_GT,
    PV := FT_302.PV,
    SP := FFIC_303.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Deviation_Limit := 10.0,
    Inhibit := MasterInhibit_OR);
FV_102(
    Control_Signal := FIC_302.XOUT,
    Manual_Mode := MasterInhibit_OR,
    Manual_Position := 0.0,
    Inhibit := MasterInhibit_OR);

(* Outputs published to other sections / HMI. *)
FT301_InfluentFlow_PV := FT_301.PV;
FT302_SludgeFlow_PV := FT_302.PV;
LS301_WeirLevel_PV := LS_301.PV;
PS301_SludgePressure_PV := PS_301.PV;
FT302_SludgeFlow_SP := FFIC_303.SlaveSP;

END_PROGRAM
