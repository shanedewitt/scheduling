BSDX13	; IHS/OIT/HMW - WINDOWS SCHEDULING RPCS ; 4/28/11 10:19am
	;;1.7;BSDX;;Jun 01, 2013;Build 24
	; Licensed under LGPL
	;
	; Change Log:
	; V 1.3 - i18n support - Dates passed to Routine as FM Date - WV/SMH
	Q
AVDELDTD(BSDXY,BSDXRESD,BSDXSTART,BSDXEND)	;EP
	;Entry point for debugging
	;
	;D DEBUG^%Serenji("AVDELDT^BSDX13(.BSDXY,BSDXRESD,BSDXSTART,BSDXEND)")
	Q
	;
AVDELDT(BSDXY,BSDXRESD,BSDXSTART,BSDXEND)	;EP
	;Cancel availability in a date range
	;Called by BSDX CANCEL AV BY DATE
	;
	;BSDXRESD is BSDX RESOURCE ien
	;BSDXSTART and BSDXEND are FM dates (change in v 1.3)
	;
	S X="ERROR^BSDX13",@^%ZOSF("TRAP")
	N BMXIEN,BSDXI
	S BSDXI=0
	S BSDXY="^BSDXTMP("_$J_")"
	K ^BSDXTMP($J)
	S ^BSDXTMP($J,BSDXI)="I00020ERRORID^T00030ERRORTEXT"_$C(30)
	; S X=BSDXSTART ; commented out *v1.3
	; S %DT="X" D ^%DT
	; I Y=-1 D ERR(0,"AVDELDT-BSDX13: Invalid Start Date") Q
	; S BSDXSTART=$P(Y,".")
	; S X=BSDXEND
	; S %DT="X" D ^%DT
	; I Y=-1 D ERR(0,"AVDELDT-BSDX13: Invalid End Date") Q
	S BSDXEND=$P(BSDXEND,".")_".99999"
	I '+BSDXRESD D ERR(0,"AVDELDT-BSDX13: Invalid Resource ID") Q
	;
	F  S BSDXSTART=$O(^BSDXAB("ARSCT",BSDXRESD,BSDXSTART)) Q:'+BSDXSTART  Q:BSDXSTART>BSDXEND  D
	. S BMXIEN=0
	. F  S BMXIEN=$O(^BSDXAB("ARSCT",BSDXRESD,BSDXSTART,BMXIEN)) Q:'+BMXIEN  D
	. . D CALLDIK(BMXIEN)
	;
	S BSDXI=BSDXI+1
	S ^BSDXTMP($J,BSDXI)="-1^"_$C(30)_$C(31)
	Q
ERROR	;
	D ^%ZTER
	I '+$G(BSDXI) N BSDXI S BSDXI=999999
	S BSDXI=BSDXI+1
	D ERR(0,"BSDX13 M Error: <"_$G(%ZTERZE)_">")
	Q
	;
ERR(BSDXERID,ERRTXT)	;Error processing
	S:'+$G(BSDXI) BSDXI=999999
	S BSDXI=BSDXI+1
	S ^BSDXTMP($J,BSDXI)=BSDXERID_"^"_ERRTXT_$C(30)
	S BSDXI=BSDXI+1
	S ^BSDXTMP($J,BSDXI)=$C(31)
	Q
	;
AVDEL(BSDXY,BSDXAVID)	;EP
	;Called by BSDX CANCEL AVAILABILITY
	;Deletes Access block
	;BSDXAVID is entry number in BSDX AVAILABILITY file
	;Returns error code in recordset field ERRORID
	;
	S X="ERROR^BSDX13",@^%ZOSF("TRAP")
	N BSDXNOD,BSDXSTART,DIK,DA,BSDXID,BSDXI,BSDXEND,BSDXRSID
	;
	S BSDXI=0
	S BSDXY="^BSDXTMP("_$J_")"
	K ^BSDXTMP($J)
	S ^BSDXTMP($J,0)="I00020ERRORID^T00030ERRORTEXT"_$C(30)
	I '+BSDXAVID D ERR(70) Q
	I '$D(^BSDXAB(BSDXAVID,0)) D ERR(70) Q
	;
	;
	;TODO: Test for existing appointments in availability block
	; (corresponds to old qryAppointmentBlocksOverlapC
	;  and AVBlockHasAppointments)
	;
	;I $$APTINBLK(BSDXAVID) D ERR(20) Q
	;
	;Delete AVAILABILITY entries
	D CALLDIK(BSDXAVID)
	;
	S BSDXI=BSDXI+1
	S ^BSDXTMP($J,BSDXI)="-1^"_$C(30)_$C(31)
	Q
	;
CALLDIK(BSDXAVID)	;
	;Delete AVAILABILITY entries
	;
	S DIK="^BSDXAB("
	S DA=BSDXAVID
	D ^DIK
	;
	Q
	;
APTINBLK(BSDXAVID)	;
	;
	;NOTE: This Subroutine Not called in current version.  Keep code for later use.
	;
	;N BSDXS,BSDXID,BSDXHIT,BSDXNOD,BSDXE,BSDXSTART,BSDXEND,BSDXRSID
	;S BSDXNOD=^BSDXAB(BSDXAVID,0)
	;S BSDXSTART=$P(BSDXNOD,U,3)
	;S BSDXEND=$P(BSDXNOD,U,4)
	;S BSDXRSID=$P(BSDXNOD,U,1)
	;I '$D(^BSDXDAPRS("ARSRC",BSDXRSID)) Q 0
	;;If any appointments start at the AV block start time:
	;I $D(^BSDXDAPRS("ARSRC",BSDXRSID,BSDXSTART)) Q 1
	;;Find the first appt time BSDXS on the same day as the av block
	;S BSDXS=$O(^BSDXDAPRS("ARSRC",BSDXRSID,$P(BSDXSTART,".")))
	;I BSDXS>BSDXEND Q 0
	;;For all the appts that day with start times less
	;;than the av block's end time, find any whose end time is
	;;greater than the av block's start time
	;S BSDXHIT=0
	;S BSDXS=BSDXS-.0001
	;F  S BSDXS=$O(^BSDXDAPRS("ARSRC",BSDXRSID,BSDXS)) Q:'+BSDXS  Q:BSDXS'<BSDXEND  D  Q:BSDXHIT
	;. S BSDXID=0 F  S BSDXID=$O(^BSDXDAPRS("ARSRC",BSDXRSID,BSDXS,BSDXID)) Q:'+BSDXID  D  Q:BSDXHIT
	;. . Q:'$D(^BSDXDAPT(BSDXID,0))
	;. . S BSDXNOD=^BSDXDAPT(BSDXID,0)
	;. . S BSDXE=$P(BSDXNOD,U,2)
	;. . I BSDXE>BSDXSTART S BSDXHIT=1 Q
	;;
	;I BSDXHIT Q 1
	Q 0
	;
	;ERR(ERRNO) ;Error processing
	;N BSDXERR
	;S BSDXERR=ERRNO+134234112 ;vbObjectError
	;S BSDXI=BSDXI+1
	;S ^BSDXTMP($J,BSDXI)=BSDXERR_$C(30)
	;S BSDXI=BSDXI+1
	;S ^BSDXTMP($J,BSDXI)=$C(31)
	;Q
