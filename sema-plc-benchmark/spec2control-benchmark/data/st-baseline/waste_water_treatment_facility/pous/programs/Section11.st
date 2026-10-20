PROGRAM Section11
VAR
	FIT_104_InfluentFlow_PV : real;
	FIC_106_SP_From_FFIC_107 : real;
	FIT_104 : ANALOG_IN;
	FFIC_107 : RATIO_CONTROL;
	FIC_106 : PID_BASIC;
	CD_1001 : MOTOR_VSD;
	PV_101 : VALVE_ELECTRIC;
	XV_102 : VALVE_ON_OFF;
	PumpInhibitAggregator : bool;
	RatioCtrlInhibitAggregator : bool;
	PumpOpenedInverter : bool;
END_VAR

FIT_104(
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
FIC_106(
    AUTO := TRUE,
    PV := CD_1001.FB_ActualSpeed,
    SP := FFIC_107.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Deviation_Limit := 3.0);
PV_101(
    Open_Limit := 100.0,
    Close_Limit := 0.0);
XV_102();
PumpOpenedInverter := NOT XV_102.FB_Opened;
PumpInhibitAggregator := PumpOpenedInverter OR FIT_104.Low_Alarm OR FIT_104.General_Fault OR XV_102.Alarm_General OR XV_102.Alarm_Position_Error OR PV_101.Alarm OR PV_101.Position_Error OR CD_1001.Alarm_Comm_Fail OR CD_1001.FB_Fault OR CD_1001.Alarm_Speed_Deviation;
CD_1001(
    Speed_SP := FIC_106.XOUT,
    Inhibit := PumpInhibitAggregator);
RatioCtrlInhibitAggregator := FIT_104.Low_Alarm OR FIT_104.High_Alarm OR FIT_104.General_Fault OR CD_1001.FB_Fault OR CD_1001.Alarm_Comm_Fail OR CD_1001.Alarm_Speed_Deviation;
FFIC_107(
    Auto := TRUE,
    PrimaryPV := FIT_104.PV,
    SecondaryPV := CD_1001.FB_ActualSpeed,
    RatioSP := 2.5,
    Bias := 0.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := RatioCtrlInhibitAggregator);

(* Outputs published to other sections / HMI. *)
FIT_104_InfluentFlow_PV := FIT_104.PV;
FIC_106_SP_From_FFIC_107 := FFIC_107.SlaveSP;

END_PROGRAM
