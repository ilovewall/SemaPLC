PROGRAM main
VAR
	Heartbeat : bool;
END_VAR

(* Entry point required by OpenPLC Editor v4. The process sections run as parallel program instances under task0; main only provides a scan heartbeat. *)
Heartbeat := NOT Heartbeat;

END_PROGRAM
