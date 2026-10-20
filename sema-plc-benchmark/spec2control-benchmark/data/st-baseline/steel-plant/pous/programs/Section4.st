PROGRAM Section4
VAR
	FT_301_CoalFlow_PV : real;
	FT_302_AirFlow_PV : real;
	PT_301_Pressure_PV : real;
	TT_301_Temperature_PV : real;
	FIC_302_HotBlastAir_SP_FromRatio : real;
	Ratio_Bias : real;
	FT_301 : ANALOG_IN;
	PT_301 : ANALOG_IN;
	TT_301 : ANALOG_IN;
	FT_302 : ANALOG_IN;
	FFIC_303 : RATIO_CONTROL;
	FIC_302 : PID_BASIC;
	FV_302 : VALVE_ELECTRIC;
	FT301_Range_OR : bool;
	Shutdown_OR : bool;
	CombinedDisable_OR : bool;
	RatioInhibit_OR : bool;
	RatioAuto_NOT : bool;
	AirSP_Fallback_SEL : real;
	AirSP_Shutdown_SEL : real;
END_VAR

FT_301(
    PV_High := 5000.0,
    PV_Low := 100.0,
    Alarm_Enable := TRUE);
PT_301(
    Alarm_Enable := TRUE);
TT_301(
    Alarm_Enable := TRUE);
FT_302();
FT301_Range_OR := FT_301.High_Alarm OR FT_301.Low_Alarm;
Shutdown_OR := TT_301.Low_Alarm OR PT_301.High_Alarm;
CombinedDisable_OR := FT301_Range_OR OR Shutdown_OR;
RatioAuto_NOT := NOT CombinedDisable_OR;
RatioInhibit_OR := PT_301.High_Alarm OR TT_301.Low_Alarm OR FT_301.General_Fault OR PT_301.Low_Alarm;
FFIC_303(
    Auto := RatioAuto_NOT,
    PrimaryPV := FT_301.PV,
    SecondaryPV := FT_302.PV,
    RatioSP := 1.8,
    Bias := Ratio_Bias,
    TrimKp := 0.0,
    TrimTi := T#0s,
    MV_MIN := 200.0,
    MV_MAX := 9000.0,
    Inhibit := RatioInhibit_OR);
AirSP_Fallback_SEL := SEL(G := FT301_Range_OR, IN0 := FFIC_303.SlaveSP, IN1 := 500.0);
AirSP_Shutdown_SEL := SEL(G := Shutdown_OR, IN0 := AirSP_Fallback_SEL, IN1 := 0.0);
FIC_302(
    AUTO := TRUE,
    PV := FT_302.PV,
    SP := AirSP_Shutdown_SEL,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    PV_High := 9000.0,
    PV_Low := 200.0,
    Inhibit := Shutdown_OR);
FV_302(
    Control_Signal := FIC_302.XOUT,
    Inhibit := Shutdown_OR);

(* Outputs published to other sections / HMI. *)
FT_301_CoalFlow_PV := FT_301.PV;
FT_302_AirFlow_PV := FT_302.PV;
PT_301_Pressure_PV := PT_301.PV;
TT_301_Temperature_PV := TT_301.PV;
FIC_302_HotBlastAir_SP_FromRatio := FFIC_303.SlaveSP;

END_PROGRAM
