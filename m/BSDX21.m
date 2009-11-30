BSDX21	; IHS/OIT/HMW - WINDOWS SCHEDULING RPCS ;
	;;2.0;IHS WINDOWS SCHEDULING;;NOV 01, 2007
	;
	;
ADDAGD(BSDXY,BSDXVAL)	;EP
	;Entry point for debugging
	;
	;D DEBUG^%Serenji("ADDAG^BSDX21(.BSDXY,BSDXVAL)")
	Q
	;
ADDAG(BSDXY,BSDXVAL)	;EP
	;Called by BSDX ADD/EDIT ACCESS GROUP
	;Add a new BSDX ACCESS GROUP entry
	;BSDXVAL is NAME of the entry
	;
	S X="ERROR^BSDX21",@^%ZOSF("TRAP")
	N BSDXIENS,BSDXFDA,BSDXMSG,BSDXIEN,BSDX,BSDXNAM
	S BSDXY="^BSDXTMP("_$J_")"
	S ^BSDXTMP($J,0)="I00020ACCESSGROUPID^T00030ERRORTEXT"_$C(30)
	I BSDXVAL="" D ERR(0,"BSDX21: Invalid null input Parameter") Q
	S BSDXIEN=$P(BSDXVAL,"|")
	S BSDXNAM=$P(BSDXVAL,"|",2)
	I +BSDXIEN D
	. S BSDX="EDIT"
	. S BSDXIENS=BSDXIEN_","
	E  D
	. S BSDX="ADD"
	. S BSDXIENS="+1,"
	;
	S BSDXNAM=$P(BSDXVAL,"|",2)
	I BSDXNAM="" D ERR(0,"BSDX14: Invalid null Access Type name.") Q
	;
	;Prevent adding entry with duplicate name
	I $D(^BSDXAGP("B",BSDXNAM)),$O(^BSDXAGP("B",BSDXNAM,0))'=BSDXIEN D  Q
	. D ERR(0,"BSDX21: Cannot have two Access Groups with the same name.")
	. Q
	;
	S BSDXFDA(9002018.38,BSDXIENS,.01)=BSDXNAM ;NAME
	I BSDX="ADD" D
	. K BSDXIEN
	. D UPDATE^DIE("","BSDXFDA","BSDXIEN","BSDXMSG")
	. S BSDXIEN=+$G(BSDXIEN(1))
	E  D
	. D FILE^DIE("","BSDXFDA","BSDXMSG")
	S ^BSDXTMP($J,1)=$G(BSDXIEN)_"^"_$C(30)_$C(31)
	Q
	;
DELAGD(BSDXY,BSDXGRP)	;EP
	;Entry point for debugging
	;
	;D DEBUG^%Serenji("DELAG^BSDX21(.BSDXY,BSDXGRP)")
	Q
	;
DELAG(BSDXY,BSDXGRP)	;EP
	;Deletes entry having IEN BSDXGRP from BSDX ACCESS GROUP file
	;Also deletes all entries in BSDX ACCESS GROUP TYPE that point to this group
	;Return recordset containing error message or "" if no error
	;Called by BSDX DELETE ACCESS GROUP
	;Test Line:
	;D DELAG^BSDX21(.RES,99)
	;
	S X="ERROR^BSDX21",@^%ZOSF("TRAP")
	N BSDXI,DIK,DA,BSDXIEN,BSDXIEN1
	S BSDXI=0
	S BSDXY="^BSDXTMP("_$J_")"
	S ^BSDXTMP($J,0)="I00020ACCESSGROUPID^T00030ERRORTEXT"_$C(30)
	S BSDXIEN=BSDXGRP
	;I '$D(^BSDXAGP("B",BSDXGRP)) D ERR(BSDXI,0,0) Q
	;S BSDXIEN=$O(^BSDXAGP("B",BSDXGRP,0))
	I '+BSDXIEN D ERR(BSDXI,BSDXIEN,70) Q
	I '$D(^BSDXAGP(BSDXIEN,0)) D ERR(0,"BSDX14: Invalid Access Group ID name.") Q
	;
	;Delete BSDXACCESS GROUP TYPE entries
	;
	S BSDXIEN1=0 F  S BSDXIEN1=$O(^BSDXAGTP("B",BSDXIEN,BSDXIEN1)) Q:'BSDXIEN1  D
	. S DIK="^BSDXAGTP("
	. S DA=BSDXIEN1
	. D ^DIK
	. Q
	;
	;Delete entry BSDXIEN in BSDX ACCESS GROUP
	S DIK="^BSDXAGP("
	S DA=BSDXIEN
	D ^DIK
	;
	S BSDXI=BSDXI+1
	S ^BSDXTMP($J,BSDXI)=BSDXIEN_"^"_""_$C(30)_$C(31)
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
ERROR	;
	D ^%ZTER
	I '+$G(BSDXI) N BSDXI S BSDXI=999999
	S BSDXI=BSDXI+1
	D ERR(0,"BSDX21 M Error: <"_$G(%ZTERROR)_">")
	Q
