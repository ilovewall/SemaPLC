PROGRAM Section10
VAR
	FT901_NipLoad_kN : real;
	FT902_FlowRate_Lmin : real;
	FIC904_Flow_SP_FromRatio : real;
	FT_901 : ANALOG_IN;
	FT_902 : ANALOG_IN;
	CW_901 : ANALOG_IN;
	FFIC_903 : RATIO_CONTROL;
	FIC_904 : PID_BASIC;
	FV_104 : VALVE_ELECTRIC;
	XV_105 : VALVE_ON_OFF;
	NipLoadOK_NOT : bool;
	SP_LowCut_SEL : real;
	XV105Closed_NOT : bool;
	CW901DevTrip_OR : bool;
	FT901_LowOrFault_OR : bool;
	CW901_DevOrFault_OR : bool;
	Interlock_PermissivesFail1_OR : bool;
	Interlock_PermissivesFail2_OR : bool;
	FFIC903_Inhibit_OR : bool;
END_VAR

FT_901(
    PV_Low := 5.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
FT_902(
    Scaling_Slope := 31.25,
    Scaling_Offset := -125.0,
    Alarm_Enable := TRUE);
CW_901(
    Alarm_Enable := TRUE);
FT901_LowOrFault_OR := FT_901.Low_Alarm OR FT_901.General_Fault;
XV_105();
XV105Closed_NOT := NOT XV_105.FB_Opened;
Interlock_PermissivesFail1_OR := XV105Closed_NOT OR FT901_LowOrFault_OR;
CW901DevTrip_OR := CW_901.High_Alarm OR CW_901.Low_Alarm;
CW901_DevOrFault_OR := CW901DevTrip_OR OR CW_901.General_Fault;
Interlock_PermissivesFail2_OR := FT_902.General_Fault OR CW901_DevOrFault_OR;
FFIC903_Inhibit_OR := Interlock_PermissivesFail1_OR OR Interlock_PermissivesFail2_OR;
FFIC_903(
    Auto := TRUE,
    PrimaryPV := FT_901.PV,
    SecondaryPV := FT_902.PV,
    RatioSP := 2.0,
    Bias := 0.0,
    MV_MIN := 0.0,
    MV_MAX := 500.0,
    Inhibit := FFIC903_Inhibit_OR);
NipLoadOK_NOT := NOT FT_901.Low_Alarm;
SP_LowCut_SEL := SEL(G := NipLoadOK_NOT, IN0 := 0.0, IN1 := FFIC_903.SlaveSP);
FIC_904(
    AUTO := TRUE,
    PV := FT_902.PV,
    SP := SP_LowCut_SEL,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    Deviation_Limit := 5.0);
FV_104(
    Control_Signal := FIC_904.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FFIC903_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
FT901_NipLoad_kN := FT_901.PV;
FT902_FlowRate_Lmin := FT_902.PV;
FIC904_Flow_SP_FromRatio := FFIC_903.SlaveSP;

END_PROGRAM
