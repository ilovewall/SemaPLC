PROGRAM Section2
VAR
	FT101_FeedFlow_PV_kgphr : real;
	FT102_RefluxFlow_PV_kgphr : real;
	FFIC103_RefluxFlow_SP_kgphr : real;
	FIC104_Output_Percent : real;
	FV104_ValvePosition_Percent : real;
	FV104_FeedbackPos_Percent : real;
	FV104_ValveMoving : bool;
	PIT106_ColumnPressure_bar : real;
	TIT104_Temperature_C : real;
	TIT105_Temperature_C : real;
	TIT107_Temperature_C : real;
	FT_101 : ANALOG_IN;
	FT_102 : ANALOG_IN;
	PIT_106 : ANALOG_IN;
	TIT_104 : ANALOG_IN;
	TIT_105 : ANALOG_IN;
	TIT_107 : ANALOG_IN;
	FFIC_103 : RATIO_CONTROL;
	FIC_104 : PID_BASIC;
	FV_104 : VALVE_ELECTRIC;
	RatioInhibit_OR : bool;
	FeedNotAbove500_NOT : bool;
	ValveInhibit_OR : bool;
END_VAR

FT_101(
    PV_Low := 100.0,
    Scaling_Slope := 312.5,
    Scaling_Offset := -1250.0,
    Alarm_Enable := TRUE);
FT_102(
    Scaling_Slope := 156.25,
    Scaling_Offset := -625.0,
    Alarm_Enable := TRUE);
PIT_106(
    PV_High := 1.5,
    PV_Low := 0.5,
    Alarm_Enable := TRUE);
TIT_104(
    PV_High := 350.0,
    PV_Low := 120.0,
    Alarm_Enable := TRUE);
TIT_105(
    PV_High := 350.0,
    PV_Low := 120.0,
    Alarm_Enable := TRUE);
TIT_107(
    PV_High := 350.0,
    PV_Low := 120.0,
    Alarm_Enable := TRUE);
FIC_104(
    AUTO := TRUE,
    PV := FT_102.PV,
    SP := FFIC_103.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := RatioInhibit_OR);
FeedNotAbove500_NOT := NOT FT_101.High_Alarm;
ValveInhibit_OR := FeedNotAbove500_NOT OR TIT_104.High_Alarm OR TIT_104.Low_Alarm OR TIT_105.High_Alarm OR TIT_105.Low_Alarm OR TIT_107.High_Alarm OR TIT_107.Low_Alarm;
FV_104(
    Control_Signal := FIC_104.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := ValveInhibit_OR);
RatioInhibit_OR := PIT_106.High_Alarm OR PIT_106.Low_Alarm OR TIT_104.High_Alarm OR TIT_104.Low_Alarm OR TIT_105.High_Alarm OR TIT_105.Low_Alarm OR TIT_107.High_Alarm OR TIT_107.Low_Alarm OR FT_101.Low_Alarm OR FT_101.General_Fault OR FT_102.General_Fault OR FV_104.Position_Error;
FFIC_103(
    Auto := TRUE,
    PrimaryPV := FT_101.PV,
    SecondaryPV := FT_102.PV,
    RatioSP := 0.5,
    Bias := 0.0,
    MV_MIN := 0.0,
    MV_MAX := 2500.0,
    Inhibit := RatioInhibit_OR);

(* Outputs published to other sections / HMI. *)
FT101_FeedFlow_PV_kgphr := FT_101.PV;
FT102_RefluxFlow_PV_kgphr := FT_102.PV;
FFIC103_RefluxFlow_SP_kgphr := FFIC_103.SlaveSP;
FIC104_Output_Percent := FIC_104.XOUT;
FV104_ValvePosition_Percent := FV_104.Valve_Position;
FV104_FeedbackPos_Percent := FV_104.Feedback_Pos;
FV104_ValveMoving := FV_104.Valve_Moving;
PIT106_ColumnPressure_bar := PIT_106.PV;
TIT104_Temperature_C := TIT_104.PV;
TIT105_Temperature_C := TIT_105.PV;
TIT107_Temperature_C := TIT_107.PV;

END_PROGRAM
