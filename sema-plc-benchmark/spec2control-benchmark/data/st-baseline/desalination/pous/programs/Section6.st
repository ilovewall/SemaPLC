PROGRAM Section6
VAR
	FIT101_BypassFlow_PV : real;
	FIT102_SamplingFlow_PV : real;
	FIC104_SamplingFlow_SP : real;
	FIC104_ActiveRatio : real;
	AT105_Permissive : bool;
	LV103_Permissive : bool;
	FIT_101 : ANALOG_IN;
	FIT_102 : ANALOG_IN;
	FIC_104 : RATIO_CONTROL;
	FIC_104_SLAVE : PID_BASIC;
	FV_102 : VALVE_ELECTRIC;
	AT_105 : BOOL_INPUT;
	MasterInhibit_OR : bool;
	LV103_Permissive_NOT : bool;
END_VAR

FIT_101(
    Scaling_Slope := 62.5,
    Scaling_Offset := -250.0,
    Alarm_Enable := TRUE);
FIT_102(
    Alarm_Enable := TRUE);
AT_105(
    Bool_In := AT105_Permissive,
    Alarm_OnTrue := FALSE,
    Alarm_OnFalse := TRUE,
    Latch_Enable := TRUE);
LV103_Permissive_NOT := NOT LV103_Permissive;
MasterInhibit_OR := FIT_101.Low_Alarm OR FIT_101.General_Fault OR AT_105.Alarm_Active OR LV103_Permissive_NOT;
FIC_104(
    Auto := TRUE,
    PrimaryPV := FIT_101.PV,
    SecondaryPV := FIT_102.PV,
    RatioSP := 0.1,
    MV_MIN := 0.0,
    MV_MAX := 200.0,
    Inhibit := MasterInhibit_OR);
FIC_104_SLAVE(
    AUTO := TRUE,
    PV := FIT_102.PV,
    SP := FIC_104.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 1.0,
    TR := 10.0,
    TD := 0.0,
    Deviation_Limit := 20.0,
    Inhibit := MasterInhibit_OR);
FV_102(
    Control_Signal := FIC_104_SLAVE.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := MasterInhibit_OR);

(* Outputs published to other sections / HMI. *)
FIT101_BypassFlow_PV := FIT_101.PV;
FIT102_SamplingFlow_PV := FIT_102.PV;
FIC104_SamplingFlow_SP := FIC_104.SlaveSP;
FIC104_ActiveRatio := FIC_104.ActiveRatio;

END_PROGRAM
