PROGRAM Section8
VAR
	FT702_AirFlow_SP : real;
	FT_701 : ANALOG_IN;
	FT_702 : ANALOG_IN;
	PT_701 : ANALOG_IN;
	FD_701 : BOOL_INPUT;
	FFIC_701 : RATIO_CONTROL;
	FIC_702 : PID_BASIC;
	LIC_101 : PID_BASIC;
	FV_701 : VALVE_ELECTRIC;
	FV_702 : VALVE_ELECTRIC;
	FlameNotProven_NOT : bool;
	FFIC701_Inhibit_OR : bool;
	FIC702_Inhibit_OR : bool;
	FV701_Inhibit_OR : bool;
	FV702_Inhibit_OR : bool;
END_VAR

FT_701(
    PV_High := 450.0,
    PV_Low := 50.0,
    Alarm_Enable := TRUE);
FT_702(
    Alarm_Enable := TRUE);
PT_701(
    Alarm_Enable := TRUE);
FD_701();
LIC_101();
FV701_Inhibit_OR := LIC_101.PV_High_Alarm OR LIC_101.PV_Low_Alarm OR PT_701.Low_Alarm;
FlameNotProven_NOT := NOT FD_701.Bool_Out;
FFIC701_Inhibit_OR := FlameNotProven_NOT OR FV701_Inhibit_OR OR FT_701.General_Fault OR FT_702.General_Fault;
FFIC_701(
    Auto := TRUE,
    PrimaryPV := FT_701.PV,
    SecondaryPV := FT_702.PV,
    RatioSP := 10.0,
    Bias := 0.0,
    MV_MIN := 500.0,
    MV_MAX := 5000.0,
    ManOut := 2500.0,
    Inhibit := FFIC701_Inhibit_OR);
FIC702_Inhibit_OR := FV701_Inhibit_OR OR FT_701.General_Fault OR FT_702.General_Fault;
FIC_702(
    AUTO := TRUE,
    PV := FT_702.PV,
    SP := FFIC_701.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Deviation_Limit := 500.0,
    Inhibit := FIC702_Inhibit_OR);
FV_701(
    Inhibit := FV701_Inhibit_OR);
FV702_Inhibit_OR := FV701_Inhibit_OR OR FT_701.Low_Alarm;
FV_702(
    Control_Signal := FIC_702.XOUT,
    Inhibit := FV702_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
FT702_AirFlow_SP := FFIC_701.SlaveSP;

END_PROGRAM
