PROGRAM Section2
VAR
	FIC102_AcidFlow_SP_FromRatio : real;
	FT101_AmmoniaFlow_PV : real;
	LT104_ReactorLevel_PV : real;
	PH105_ReactorPH_PV : real;
	VS107_Scrubber_Permissive : bool;
	VS107_Scrubber_Running_DI : bool;
	FT101_Raw_mA : real;
	FT102_Raw_mA : real;
	LT104_Raw_mA : real;
	PH105_Raw_mA : real;
	TIC103_Temperature_PV : real;
	FFIC_102 : RATIO_CONTROL;
	FIC_102 : PID_BASIC;
	FIC_101 : PID_BASIC;
	TIC_103 : PID_BASIC;
	FT_101 : ANALOG_IN;
	FT_102 : ANALOG_IN;
	LT_104 : ANALOG_IN;
	PH_105 : ANALOG_IN;
	FV_102 : VALVE_ELECTRIC;
	FV_101 : VALVE_ELECTRIC;
	VS_107 : BOOL_INPUT;
	AcidInhibit_OR : bool;
	VS107_Fault_NOT : bool;
	AmmoniaInhibit_OR : bool;
END_VAR

FT_102(
    Raw_Signal := FT102_Raw_mA);
FIC_102(
    AUTO := TRUE,
    PV := FT_102.PV,
    SP := FFIC_102.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    PV_Low := 10.0,
    Inhibit := AcidInhibit_OR);
FT_101(
    Raw_Signal := FT101_Raw_mA,
    PV_Low := 10.0,
    Scaling_Slope := 31.25,
    Scaling_Offset := -125.0,
    Alarm_Enable := TRUE);
LT_104(
    Raw_Signal := LT104_Raw_mA,
    PV_High := 90.0,
    PV_Low := 20.0,
    Alarm_Enable := TRUE);
TIC_103(
    PV := TIC103_Temperature_PV,
    PV_High := 190.0);
AcidInhibit_OR := LT_104.High_Alarm OR LT_104.Low_Alarm OR FT_101.Low_Alarm OR FIC_102.PV_Low_Alarm OR TIC_103.PV_High_Alarm;
FFIC_102(
    Auto := TRUE,
    PrimaryPV := FT_101.PV,
    SecondaryPV := FT_102.PV,
    RatioSP := 1.8,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := AcidInhibit_OR);
VS_107(
    Bool_In := VS107_Scrubber_Running_DI,
    Alarm_OnFalse := TRUE);
VS107_Fault_NOT := NOT VS_107.Bool_Out;
AmmoniaInhibit_OR := VS107_Fault_NOT OR TIC_103.PV_High_Alarm OR FT_101.Low_Alarm;
FIC_101(
    AUTO := FALSE,
    PV := FT_101.PV,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    Inhibit := AmmoniaInhibit_OR);
PH_105(
    Raw_Signal := PH105_Raw_mA,
    PV_High := 7.3,
    PV_Low := 6.7,
    Alarm_Enable := TRUE);
FV_102(
    Control_Signal := FIC_102.XOUT,
    Inhibit := AcidInhibit_OR);
FV_101(
    Control_Signal := FIC_101.XOUT,
    Inhibit := AmmoniaInhibit_OR);

(* Outputs published to other sections / HMI. *)
FIC102_AcidFlow_SP_FromRatio := FFIC_102.SlaveSP;
FT101_AmmoniaFlow_PV := FT_101.PV;
LT104_ReactorLevel_PV := LT_104.PV;
PH105_ReactorPH_PV := PH_105.PV;
VS107_Scrubber_Permissive := VS_107.Bool_Out;

END_PROGRAM
