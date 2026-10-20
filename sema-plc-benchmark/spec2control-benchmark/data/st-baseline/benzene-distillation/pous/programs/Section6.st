PROGRAM Section6
VAR
	FT105_FeedFlowRate : real;
	FT106_BottomsFlowRate : real;
	FT106_SP_From_IIC104 : real;
	LIC002_LevelPV : real;
	FT_105 : ANALOG_IN;
	FT_106 : ANALOG_IN;
	FV_101 : VALVE_ELECTRIC;
	IIC_104 : RATIO_CONTROL;
	FIC_106 : PID_BASIC;
	LIC_002 : PID_BASIC;
	LIC_002_LOW_LEVEL_ILK : BOOL_INPUT;
	FEED_PUMP_RUN : DIGITAL_IN;
	BOTTOMS_PUMP_RUN : DIGITAL_IN;
	FeedAboveCutoff_GT : bool;
	PumpsRunning_AND : bool;
	PumpsNotRunning_NOT : bool;
	RatioInhibit_OR : bool;
END_VAR

FT_105(
    PV_Low := 50.0,
    Scaling_Slope := 62.5,
    Scaling_Offset := -250.0,
    Alarm_Enable := TRUE);
FT_106(
    Scaling_Slope := 62.5,
    Scaling_Offset := -250.0,
    Alarm_Enable := TRUE);
FeedAboveCutoff_GT := (FT_105.PV > 50.0);
BOTTOMS_PUMP_RUN();
FEED_PUMP_RUN();
LIC_002(
    PV := LIC002_LevelPV);
LIC_002_LOW_LEVEL_ILK(
    Bool_In := LIC_002.PV_Low_Alarm,
    Alarm_OnTrue := TRUE);
PumpsRunning_AND := FEED_PUMP_RUN.DI_Out AND BOTTOMS_PUMP_RUN.DI_Out;
PumpsNotRunning_NOT := NOT PumpsRunning_AND;
RatioInhibit_OR := LIC_002_LOW_LEVEL_ILK.Bool_Out OR PumpsNotRunning_NOT OR FT_105.General_Fault OR FT_106.General_Fault OR FEED_PUMP_RUN.Fault_State OR BOTTOMS_PUMP_RUN.Fault_State;
IIC_104(
    Auto := FeedAboveCutoff_GT,
    PrimaryPV := FT_105.PV,
    SecondaryPV := FT_106.PV,
    RatioSP := 1.5,
    MV_MIN := 0.0,
    MV_MAX := 1000.0,
    Inhibit := RatioInhibit_OR);
FIC_106(
    AUTO := FeedAboveCutoff_GT,
    PV := FT_106.PV,
    SP := IIC_104.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := RatioInhibit_OR);
FV_101(
    Control_Signal := FIC_106.XOUT,
    Inhibit := RatioInhibit_OR);

(* Outputs published to other sections / HMI. *)
FT105_FeedFlowRate := FT_105.PV;
FT106_BottomsFlowRate := FT_106.PV;
FT106_SP_From_IIC104 := IIC_104.SlaveSP;

END_PROGRAM