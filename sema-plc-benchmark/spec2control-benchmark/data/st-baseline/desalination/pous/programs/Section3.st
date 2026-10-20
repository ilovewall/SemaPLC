PROGRAM Section3
VAR
	FT102_SP_FromRatio : real;
	FV105_Feedback_Position : real;
	FFIC_103 : RATIO_CONTROL;
	FIC_104 : PID_BASIC;
	FV_105 : VALVE_ELECTRIC;
	FT_101 : ANALOG_IN;
	FT_102 : ANALOG_IN;
	PT_103 : ANALOG_IN;
	PT_104 : ANALOG_IN;
	PIT_105 : ANALOG_IN;
	PIT_106 : ANALOG_IN;
	PT_108 : ANALOG_IN;
	SW_SCREEN_1 : BOOL_INPUT;
	SW_SCREEN_2 : BOOL_INPUT;
	SW_SCREEN_3 : BOOL_INPUT;
	SW_SCREEN_4 : BOOL_INPUT;
	SW_SCREEN_5 : BOOL_INPUT;
	SW_SCREEN_6 : BOOL_INPUT;
	RES_SCREEN_1 : BOOL_INPUT;
	RES_SCREEN_2 : BOOL_INPUT;
	RES_SCREEN_3 : BOOL_INPUT;
	RES_SCREEN_4 : BOOL_INPUT;
	LowFlowOn : bool;
	LowFlowOff : bool;
	LowFlowLatch : bool;
	AutoEnableInv : bool;
	DownstreamOutOfRange : bool;
	SupplyPressureTrip : bool;
	ValveInhibit : bool;
	Screen1Others : bool;
	Screen2Others : bool;
	Screen3Others : bool;
	Screen4Others : bool;
	Screen5Others : bool;
	Screen6Others : bool;
	Res1Others : bool;
	Res2Others : bool;
	Res3Others : bool;
	Res4Others : bool;
	Screen1WithAnother : bool;
	Screen2WithAnother : bool;
	Screen3WithAnother : bool;
	Screen4WithAnother : bool;
	Screen5WithAnother : bool;
	Screen6WithAnother : bool;
	Res1WithAnother : bool;
	Res2WithAnother : bool;
	Res3WithAnother : bool;
	Res4WithAnother : bool;
	ScreenConflict : bool;
	RatioInhibit : bool;
END_VAR

FT_101(
    PV_Low := 50.0,
    Scaling_Slope := 31.25,
    Scaling_Offset := -125.0,
    Alarm_Enable := TRUE);
FT_102(
    Scaling_Slope := 31.25,
    Scaling_Offset := -125.0);
PIT_105(
    Alarm_Enable := TRUE);
PIT_106(
    Alarm_Enable := TRUE);
DownstreamOutOfRange := PIT_105.Low_Alarm OR PIT_105.High_Alarm OR PIT_106.Low_Alarm OR PIT_106.High_Alarm;
LowFlowOff := (FT_101.PV > 50.0);
LowFlowOn := (FT_101.PV < 50.0);
LowFlowLatch := (LowFlowOn OR LowFlowLatch) AND NOT LowFlowOff;
AutoEnableInv := NOT LowFlowLatch;
FIC_104(
    AUTO := AutoEnableInv,
    PV := FT_102.PV,
    SP := FFIC_103.SlaveSP);
PT_108(
    PV_High := 9.0,
    PV_Low := 5.0,
    Alarm_Enable := TRUE);
SupplyPressureTrip := PT_108.Low_Alarm OR PT_108.High_Alarm;
ValveInhibit := DownstreamOutOfRange OR SupplyPressureTrip;
FV_105(
    Control_Signal := FIC_104.XOUT,
    Timeout := T#2s,
    Inhibit := ValveInhibit);
PT_103(
    Alarm_Enable := TRUE);
PT_104(
    Alarm_Enable := TRUE);
RES_SCREEN_1();
RES_SCREEN_2();
RES_SCREEN_3();
RES_SCREEN_4();
SW_SCREEN_1();
SW_SCREEN_2();
SW_SCREEN_3();
SW_SCREEN_4();
SW_SCREEN_5();
SW_SCREEN_6();
Res1Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_2.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_5.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_3.Bool_Out OR RES_SCREEN_4.Bool_Out;
Res1WithAnother := RES_SCREEN_1.Bool_Out AND Res1Others;
Res2Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_2.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_5.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_3.Bool_Out OR RES_SCREEN_4.Bool_Out;
Res2WithAnother := RES_SCREEN_2.Bool_Out AND Res2Others;
Res3Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_2.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_5.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_4.Bool_Out;
Res3WithAnother := RES_SCREEN_3.Bool_Out AND Res3Others;
Res4Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_2.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_5.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_3.Bool_Out;
Res4WithAnother := RES_SCREEN_4.Bool_Out AND Res4Others;
Screen1Others := SW_SCREEN_2.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_5.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_3.Bool_Out OR RES_SCREEN_4.Bool_Out;
Screen1WithAnother := SW_SCREEN_1.Bool_Out AND Screen1Others;
Screen2Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_5.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_3.Bool_Out OR RES_SCREEN_4.Bool_Out;
Screen2WithAnother := SW_SCREEN_2.Bool_Out AND Screen2Others;
Screen3Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_2.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_5.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_3.Bool_Out OR RES_SCREEN_4.Bool_Out;
Screen3WithAnother := SW_SCREEN_3.Bool_Out AND Screen3Others;
Screen4Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_2.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_5.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_3.Bool_Out OR RES_SCREEN_4.Bool_Out;
Screen4WithAnother := SW_SCREEN_4.Bool_Out AND Screen4Others;
Screen5Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_2.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_6.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_3.Bool_Out OR RES_SCREEN_4.Bool_Out;
Screen5WithAnother := SW_SCREEN_5.Bool_Out AND Screen5Others;
Screen6Others := SW_SCREEN_1.Bool_Out OR SW_SCREEN_2.Bool_Out OR SW_SCREEN_3.Bool_Out OR SW_SCREEN_4.Bool_Out OR SW_SCREEN_5.Bool_Out OR RES_SCREEN_1.Bool_Out OR RES_SCREEN_2.Bool_Out OR RES_SCREEN_3.Bool_Out OR RES_SCREEN_4.Bool_Out;
Screen6WithAnother := SW_SCREEN_6.Bool_Out AND Screen6Others;
ScreenConflict := Screen1WithAnother OR Screen2WithAnother OR Screen3WithAnother OR Screen4WithAnother OR Screen5WithAnother OR Screen6WithAnother OR Res1WithAnother OR Res2WithAnother OR Res3WithAnother OR Res4WithAnother;
RatioInhibit := PT_103.Low_Alarm OR DownstreamOutOfRange OR SupplyPressureTrip OR FV_105.Position_Error OR ScreenConflict OR FIC_104.Deviation_Alarm OR LowFlowLatch OR PT_104.Low_Alarm;
FFIC_103(
    PrimaryPV := FT_101.PV,
    SecondaryPV := FT_102.PV,
    RatioSP := 2.0,
    MV_MIN := 0.0,
    MV_MAX := 500.0,
    Inhibit := RatioInhibit);

(* Outputs published to other sections / HMI. *)
FT102_SP_FromRatio := FFIC_103.SlaveSP;
FV105_Feedback_Position := FV_105.Feedback_Pos;

END_PROGRAM
