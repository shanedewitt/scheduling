BSDX34	; IHS/OIT/HMW - WINDOWS SCHEDULING RPCS ; 7/15/10 12:37pm
	;;1.5T1;BSDX;;Apr 06, 2011
	   ;
	   ; Change Log:
	   ; July 10 2010: 
	; CANCLIN AND RBCLIN: Dates passed in FM format for i18n
	;
	Q
	;
RBCLIND(BSDXY,BSDXCLST,BSDXBEG,BSDXEND)	;EP
	;Entry point for debugging
	;
	;D DEBUG^%Serenji("RBCLIN^BSDX34(.BSDXY,BSDXCLST,BSDXBEG,BSDXEND)")
	Q
	;
RBERR	;
	;Called from RBCLIN on error to set up header
	K ^BSDXTMP($J)
	S ^BSDXTMP($J,0)="T00030Name^D00020DOB^T00030Sex^T00030HRN^D00030NewApptDate^T00030Clinic^T00030TypeStatus^I00010RESOURCEID"
	S ^BSDXTMP($J,0)=^(0)_"^T00030APPT_MADE_BY^D00020DATE_APPT_MADE^T00250NOTE^T00030STREET^T00030CITY^T00030STATE^T00030ZIP^T00030HOMEPHONE^D00030OldApptDate"_$C(30)
	D ERR(999)
	Q
	;
CANCLIN(BSDXY,BSDXCLST,BSDXBEG,BSDXEND)	;EP
	;
	;Return recordset of CANCELLED patient appointments
	;between dates BSDXBEG and BSDXEND for each clinic in BSDXCLST.
	;Used in generating cancellation letters for a clinic
	;BSDXCLST is a |-delimited list of BSDX RESOURCE iens.  (The last |-piece is null, so discard it.)
	   ;v 1.3 BSDXBEG and BSDXEND are in fm format
	;Called by BSDX CANCEL CLINIC LIST
	N BSDXCAN
	S BSDXCAN=1
	D RBCLIN(.BSDXY,BSDXCLST,BSDXBEG,BSDXEND)
	;
	Q
	;
RBCLIN(BSDXY,BSDXCLST,BSDXBEG,BSDXEND)	;EP
	;
	;Return recordset of rebooked patient appointments
	;between dates BSDXBEG and BSDXEND for each clinic in BSDXCLST.
	;Used in generating rebook letters for a clinic
	;BSDXCLST is a |-delimited list of BSDX RESOURCE iens.  (The last |-piece is null, so discard it.)
	;Called by BSDX REBOOK CLINIC LIST and BSDX CANCEL CLINIC LIST via entry point CANCLIN above
	;Jul 11 2010 (smh):
	   ;for i18n, pass BSDXBEG and BSDXEND in FM format.
	;
	S X="RBERR^BSDX34",@^%ZOSF("TRAP")
	;
	S BSDXY="^BSDXTMP("_$J_")"
	N %DT,Y,BSDXJ,BSDXCID,BSDXCLN,BSDXSTRT,BSDXAID,BSDXNOD,BSDXLIST,BSDX,BSDY
	;Convert beginning and ending dates
	;TODO: Validation of date to make sure it's a right FM Date
	   S BSDXBEG=$P(BSDXBEG,".")
	   S BSDXEND=$P(BSDXEND,".")
	S BSDXBEG=BSDXBEG-1,BSDXBEG=BSDXBEG_".9999"
	S BSDXEND=BSDXEND_".9999"
	   ;
	I BSDXCLST="" D RBERR Q
	;
	;
	;If BSDXCLST is a list of resource NAMES, look up each name and convert to IEN
	F BSDXJ=1:1:$L(BSDXCLST,"|")-1 S BSDX=$P(BSDXCLST,"|",BSDXJ) D  S $P(BSDXCLST,"|",BSDXJ)=BSDY
	. S BSDY=""
	. I BSDX]"",$D(^BSDXRES(BSDX,0)) S BSDY=BSDX Q
	. I BSDX]"",$D(^BSDXRES("B",BSDX)) S BSDY=$O(^BSDXRES("B",BSDX,0)) Q
	. Q
	;
	;For each clinic in BSDXCLST $O through ^BSDXAPPT("ARSRC",ResourceIEN,FMDate,ApptIEN)
	;
	S BSDXLIST=""
	F BSDXJ=1:1:$L(BSDXCLST,"|")-1 S BSDXCID=$P(BSDXCLST,"|",BSDXJ) D:+BSDXCID
	. S BSDXCLN=$G(^BSDXRES(BSDXCID,0)) S BSDXCLN=$P(BSDXCLN,U) Q:BSDXCLN=""
	. S BSDXSTRT=BSDXBEG F  S BSDXSTRT=$O(^BSDXAPPT("ARSRC",BSDXCID,BSDXSTRT)) Q:'+BSDXSTRT  Q:BSDXSTRT>BSDXEND  D
	. . S BSDXAID=0 F  S BSDXAID=$O(^BSDXAPPT("ARSRC",BSDXCID,BSDXSTRT,BSDXAID)) Q:'+BSDXAID  D
	. . . S BSDXNOD=$G(^BSDXAPPT(BSDXAID,0))
	. . . I $D(BSDXCAN) D  Q
	. . . . I $P(BSDXNOD,U,12) S BSDXLIST=BSDXLIST_BSDXAID_"|" ;Cancelled appt
	. . . I $P(BSDXNOD,U,11) S BSDXLIST=BSDXLIST_BSDXAID_"|" ;Rebooked appt
	D RBLETT(.BSDXY,BSDXLIST)
	Q
	;
RBLETTD(BSDXY,BSDXLIST)	;EP
	;Entry point for debugging
	;
	;D DEBUG^%Serenji("RBLETT^BSDX34(.BSDXY,BSDXLIST)")
	Q
	;
RBLETT(BSDXY,BSDXLIST)	;EP
	;Return recordset of patient appointments used in listing
	;REBOOKED appointments for a list of appointmentIDs.
	;Called by rpc BSDX REBOOK LIST
	;BSDXLIST is a |-delimited list of BSDX APPOINTMENT iens (the last |-piece is null)
	;
	N BSDXI,BSDXIEN,BSDXNOD,BSDXCNID,BSDXCNOD,BSDXMADE,BSDXCLRK,BSDXNOT,BSDXQ,BSDX
	S BSDXY="^BSDXTMP("_$J_")"
	S BSDXI=0
	S ^BSDXTMP($J,BSDXI)="T00030Name^D00020DOB^T00030Sex^T00030HRN^D00030NewApptDate^T00030Clinic^T00030TypeStatus"
	S ^BSDXTMP($J,BSDXI)=^(BSDXI)_"^I00010RESOURCEID^T00030APPT_MADE_BY^D00020DATE_APPT_MADE^T00250NOTE^T00030STREET^T00030CITY^T00030STATE^T00030ZIP^T00030HOMEPHONE^D00030OldApptDate"_$C(30)
	S X="ERROR^BSDX34",@^%ZOSF("TRAP")
	;
	;Iterate through BSDXLIST
	S BSDXIEN=0
	F BSDX=1:1:$L(BSDXLIST,"|")-1 S BSDXIEN=$P(BSDXLIST,"|",BSDX) D
	. N BSDXNOD,BSDXAPT,BSDXCID,BSDXCNOD,BSDXCLN,BSDX44,BSDXDNOD,BSDXSTAT,BSDX,BSDXTYPE,BSDXLIN,BSDXPAT
	. N BSDXSTRE,BSDXCITY,BSDXST,BSDXZIP,BSDXPHON
	. N BSDXNAM,BSDXDOB,BSDXHRN,BSDXSEX
	. N BSDXREBK
	. S BSDXNOD=$G(^BSDXAPPT(BSDXIEN,0))
	. Q:BSDXNOD=""
	. S BSDXPAT=$P(BSDXNOD,U,5) ;PATIENT ien
	. Q:'+BSDXPAT
	. Q:'$D(^DPT(BSDXPAT))
	. D PINFO(BSDXPAT)
	. S Y=$P(BSDXNOD,U)
	. Q:'+Y
	. X ^DD("DD") S Y=$TR(Y,"@"," ")
	. S BSDXAPT=Y ;Appointment date time
	. S BSDXREBK=""
	. S Y=$P(BSDXNOD,U,11)
	. I +Y X ^DD("DD") S Y=$TR(Y,"@"," ") S BSDXREBK=Y ;Rebook date time
	. S BSDXCLRK=$P(BSDXNOD,U,8) ;Appointment made by
	. S:+BSDXCLRK BSDXCLRK=$G(^VA(200,BSDXCLRK,0)),BSDXCLRK=$P(BSDXCLRK,U)
	. S Y=$P(BSDXNOD,U,9) ;Date Appointment Made
	. I +Y X ^DD("DD") S Y=$TR(Y,"@"," ")
	. S BSDXMADE=Y
	. ;NOTE
	. S BSDXNOT=""
	. I $D(^BSDXAPPT(BSDXIEN,1,0)) S BSDXNOT="",BSDXQ=0 F  S BSDXQ=$O(^BSDXAPPT(BSDXIEN,1,BSDXQ)) Q:'+BSDXQ  D
	. . S BSDXLIN=$G(^BSDXAPPT(BSDXIEN,1,BSDXQ,0))
	. . S:(BSDXLIN'="")&($E(BSDXLIN,$L(BSDXLIN)-1,$L(BSDXLIN))'=" ") BSDXLIN=BSDXLIN_" "
	. . S BSDXNOT=BSDXNOT_BSDXLIN
	. ;Resource
	. S BSDXCID=$P(BSDXNOD,U,7) ;IEN of BSDX RESOURCE
	. Q:'+BSDXCID
	. Q:'$D(^BSDXRES(BSDXCID,0))
	. S BSDXCNOD=$G(^BSDXRES(BSDXCID,0)) ;BSDX RESOURCE node
	. Q:BSDXCNOD=""
	. S BSDXCLN=$P(BSDXCNOD,U) ;Text name of BSDX Resource
	. S BSDXTYPE="" ;Unused in this recordset
	. S BSDXI=BSDXI+1
	. S ^BSDXTMP($J,BSDXI)=BSDXNAM_"^"_BSDXDOB_"^"_BSDXSEX_"^"_BSDXHRN_"^"_BSDXREBK_"^"_BSDXCLN_"^"_BSDXTYPE_"^"_BSDXCID_"^"_BSDXCLRK_"^"_BSDXMADE_"^"_BSDXNOT_"^"_BSDXSTRE_"^"_BSDXCITY_"^"_BSDXST_"^"_BSDXZIP_"^"_BSDXPHON_"^"_BSDXAPT_$C(30)
	. Q
	;
	S BSDXI=BSDXI+1
	S ^BSDXTMP($J,BSDXI)=$C(31)
	Q
	;
PINFO(BSDXPAT)	;
	;Get patient info
	N BSDXNOD
	S BSDXNOD=$$PATINFO^BSDX27(BSDXPAT)
	S BSDXNAM=$P(BSDXNOD,U) ;NAME
	S BSDXSEX=$P(BSDXNOD,U,2) ;SEX
	S BSDXDOB=$P(BSDXNOD,U,3) ;DOB
	S BSDXHRN=$P(BSDXNOD,U,4) ;Health Record Number for location DUZ(2)
	S BSDXSTRE=$P(BSDXNOD,U,5) ;Street
	S BSDXCITY=$P(BSDXNOD,U,6) ;City
	S BSDXST=$P(BSDXNOD,U,7) ;State
	S BSDXZIP=$P(BSDXNOD,U,8) ;zip
	S BSDXPHON=$P(BSDXNOD,U,9) ;homephone
	Q
	;
ERROR	;
	D ERR("RPMS Error")
	Q
	;
ERR(ERRNO)	;Error processing
	S:'$D(BSDXI) BSDXI=999
	I +ERRNO S BSDXERR=ERRNO+134234112 ;vbObjectError
	E  S BSDXERR=ERRNO
	S BSDXI=BSDXI+1
	S ^BSDXTMP($J,BSDXI)="^^^^^^^^^^^^^^^^"_$C(30)
	S BSDXI=BSDXI+1
	S ^BSDXTMP($J,BSDXI)=$C(31)
	Q
