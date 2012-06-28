BSDXUT2 ; VEN/SMH - Unit Tests for Scheduling GUI - cont. ; 6/28/12 11:55am
	;;1.7T1;BSDX;;Aug 31, 2011;Build 18
	;
UT25 ; Unit Tests for BSDX25
	; Make appointment, checkin, then uncheckin
	N $ET S $ET="W ""An Error Occured. Breaking."",! BREAK"
	N RESNAM S RESNAM="UTCLINIC"
	N HLRESIENS ; holds output of UTCR^BSDXUT - HL IEN^Resource IEN
	D
	. N $ET S $ET="D ^%ZTER B"
	. S HLRESIENS=$$UTCR^BSDXUT(RESNAM)
	. I HLRESIENS<0 S $EC=",U1," ; not supposed to happen - hard crash if so
	;
	N HLIEN,RESIEN
	S HLIEN=$P(HLRESIENS,U)
	S RESIEN=$P(HLRESIENS,U,2)
	;
	; Get start and end times
	N TIMES S TIMES=$$TIMES^BSDXUT ; appt time^end time
	N APPTTIME S APPTTIME=$P(TIMES,U)
	N ENDTIME S ENDTIME=$P(TIMES,U,2)
	;
	; Test 1: Make normal appointment and cancel it. See if every thing works
	N ZZZ,DFN
	S DFN=5
	N ZZZ
	D APPADD^BSDX07(.ZZZ,APPTTIME,ENDTIME,DFN,RESNAM,30,"Sam's Note",1)
	N APPTID S APPTID=+^BSDXTMP($J,1)
	N HL S HL=$$GET1^DIQ(9002018.4,APPTID,".07:.04","I")
	D CHECKIN^BSDX25(.ZZZ,APPTID,$$NOW^XLFDT())
	IF '$P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN CHECKIN 1",!
	IF '+$G(^SC(HL,"S",APPTTIME,1,1,"C")) WRITE "ERROR IN CHECKIN 2",!
	D RMCI^BSDX25(.ZZZ,APPTID)
	IF $P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN UNCHECKIN 1",!
	IF $G(^SC(HL,"S",APPTTIME,1,1,"C")) WRITE "ERROR IN UNCHECKIN 2",!
	D RMCI^BSDX25(.ZZZ,APPTID)  ; again, test sanity in repeat
	IF $P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN UNCHECKIN 1",!
	IF $G(^SC(HL,"S",APPTTIME,1,1,"C")) WRITE "ERROR IN UNCHECKIN 2",!
	; now test various error conditions
	; Test Error 1
	D RMCI^BSDX25(.ZZZ,)
	IF +^BSDXTMP($J,1)'=-1 WRITE "ERROR IN ETest 1",!
	; Test Error 2
	D RMCI^BSDX25(.ZZZ,234987234398)
	IF +^BSDXTMP($J,1)'=-2 WRITE "ERROR IN Etest 2",!
	; Tests for 3 to 5 difficult to produce
	; Error tests follow: Mumps error test; Transaction restartability
	N bsdxdie S bsdxdie=1
	D RMCI^BSDX25(.ZZZ,APPTID)
	IF +^BSDXTMP($J,1)'=-100 WRITE "ERROR IN Etest 3",!
	K bsdxdie
	N bsdxrestart S bsdxrestart=1
	D RMCI^BSDX25(.ZZZ,APPTID)
	IF +^BSDXTMP($J,1)'=0 WRITE "Error in Etest 4",!
	;
	; Unlinked Clinic Tests
	N RESNAM S RESNAM="UTCLINICUL" ; Unlinked Clinic
	N RESIEN
	D
	. N $ET S $ET="D ^%ZTER B"
	. S RESIEN=$$UTCRRES^BSDXUT(RESNAM)
	. I RESIEN<0 S $EC=",U1," ; not supposed to happen - hard crash if so
	;
	; Get start and end times
	N TIMES S TIMES=$$TIMES^BSDXUT ; appt time^end time
	N APPTTIME S APPTTIME=$P(TIMES,U)
	N ENDTIME S ENDTIME=$P(TIMES,U,2)
	;
	N ZZZ,DFN
	S DFN=4
	N ZZZ
	D APPADD^BSDX07(.ZZZ,APPTTIME,ENDTIME,DFN,RESNAM,30,"Sam's Note",1)
	N APPTID S APPTID=+^BSDXTMP($J,1)
	N HL S HL=$$GET1^DIQ(9002018.4,APPTID,".07:.04","I")
	I HL'="" W "Error. Hospital Location Exists",!
	;
	D CHECKIN^BSDX25(.ZZZ,APPTID,$$NOW^XLFDT())
	IF '$P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN CHECKIN 3",!
	;test
	D RMCI^BSDX25(.ZZZ,APPTID)
	IF $P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN UNCHECKIN 3",!
	D RMCI^BSDX25(.ZZZ,APPTID)  ; again, test sanity in repeat
	IF $P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN UNCHECKIN 3",!
	; now test various error conditions
	; Test Error 1
	D RMCI^BSDX25(.ZZZ,)
	IF +^BSDXTMP($J,1)'=-1 WRITE "ERROR IN ETest 5",!
	; Test Error 2
	D RMCI^BSDX25(.ZZZ,234987234398)
	IF +^BSDXTMP($J,1)'=-2 WRITE "ERROR IN Etest 6",!
	; Tests for 3 to 5 difficult to produce
	; Error tests follow: Mumps error test; Transaction restartability
	N bsdxdie S bsdxdie=1
	D RMCI^BSDX25(.ZZZ,APPTID)
	IF +^BSDXTMP($J,1)'=-100 WRITE "ERROR IN Etest 7",!
	K bsdxdie
	N bsdxrestart S bsdxrestart=1
	D RMCI^BSDX25(.ZZZ,APPTID)
	IF +^BSDXTMP($J,1)'=0 WRITE "Error in Etest 8",!
	;
	; Tests for running PIMS by itself.
	N APPTTIME S APPTTIME=$$TIMEHL^BSDXUT(HLIEN) ; appt time
	N DFN S DFN=2
	N % S %=$$MAKE1^BSDXAPI(DFN,HLIEN,3,APPTTIME,15,"Sam Test Appt"_DFN)
	I % W "Error in $$MAKE1^BSDXAPI for TIME "_APPTTIME_" for DFN "_DFN,!,%,!
	I '$D(^BSDXAPPT("APAT",DFN,APPTTIME)) W "No BSDX Appointment Created",!
	;TODO: Index doesn't include resource.
	N APPTID S APPTID=$O(^(APPTTIME,""))
	I 'APPTID W "Can't get appointment",!
	IF $P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN CHECKIN 3",!
	N % S %=$$CHECKIN1^BSDXAPI(DFN,HLIEN,APPTTIME) ; Checkin via PIMS
	I % W "Error in Checking in via BSDXAPI",!
	IF '+$G(^SC(HLIEN,"S",APPTTIME,1,1,"C")) WRITE "ERROR IN CHECKIN 10",!
	IF '$P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN CHECKIN 11",!
	N % S %=$$RMCI^BSDXAPI(DFN,HLIEN,APPTTIME)
	I % W "Error removing Check-in via PIMS",!
	I +$G(^SC(HLIEN,"S",APPTTIME,1,1,"C")) WRITE "ERROR IN UNCHECKIN 12",!
	IF $P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN CHECKIN 13",!
	N % S %=$$CHECKIN1^BSDXAPI(DFN,HLIEN,APPTTIME) ; Checkin via PIMS again
	I % W "Error in Checking in via BSDXAPI",!
	IF '+$G(^SC(HLIEN,"S",APPTTIME,1,1,"C")) WRITE "ERROR IN CHECKIN 14",!
	IF '$P(^BSDXAPPT(APPTID,0),U,3) WRITE "ERROR IN CHECKIN 15",!
	QUIT
