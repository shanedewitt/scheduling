BSDX03	; IHS/OIT/HMW - WINDOWS SCHEDULING RPCS ; 4/28/11 10:14am
	;;1.6;BSDX;;Aug 31, 2011;Build 25
	;Licensed under LGPL
	;
	;
	Q
	;
XR2S(BSDXDA)	;EP
	;XR2 is the ARSRC xref for the
	;RESOURCE field of the BSDX APPOINTMENT file
	;Format is ^BSDXAPPT("ARSRC",RESOURCEID,STARTTIME,APPTID)
	Q:'$D(^BSDXAPPT(BSDXDA,0))
	N BSDXNOD,BSDXAPPID,BSDXRSID,BSDXS
	S BSDXNOD=^BSDXAPPT(BSDXDA,0)
	S BSDXAPPID=BSDXDA
	S BSDXRSID=$P(BSDXNOD,U,7)
	Q:'+BSDXAPPID>0
	Q:'+BSDXRSID>0
	S BSDXS=$P(BSDXNOD,U)
	Q:'+BSDXS
	S ^BSDXAPPT("ARSRC",BSDXRSID,BSDXS,BSDXAPPID)=""
	Q
	;
XR2K(BSDXA)	;EP
	Q:'$D(^BSDXAPPT(BSDXA,0))
	N BSDXNOD,BSDXAPPID,BSDXRSID,BSDXS
	S BSDXNOD=^BSDXAPPT(BSDXA,0)
	S BSDXAPPID=BSDXA
	S BSDXRSID=$P(BSDXNOD,U,7)
	S BSDXS=$P(BSDXNOD,U)
	Q:'+BSDXAPPID>0
	Q:'+BSDXRSID>0
	Q:'+BSDXS>0
	K ^BSDXAPPT("ARSRC",BSDXRSID,BSDXS,BSDXAPPID)
	Q
XR4S(BSDXDA)	;EP
	;XR4 is the ARSCT xref for the
	;STARTTIME field of the BSDX ACCESS BLOCK file
	;Format is ^BSDXAB("ARSCT",RESOURCEID,STARTTIME,DA)
	Q:'$D(^BSDXAB(BSDXDA,0))
	N BSDXNOD,BSDXR,BSDXS
	S BSDXNOD=^BSDXAB(BSDXDA,0)
	S BSDXR=$P(BSDXNOD,U)
	S BSDXS=$P(BSDXNOD,U,2)
	Q:'+BSDXR>0
	Q:'+BSDXS>0
	S ^BSDXAB("ARSCT",BSDXR,BSDXS,BSDXDA)=""
	Q
	;
XR4K(BSDXDA)	;EP
	Q:'$D(^BSDXAB(BSDXDA,0))
	N BSDXNOD,BSDXR,BSDXS
	S BSDXNOD=^BSDXAB(BSDXDA,0)
	S BSDXR=$P(BSDXNOD,U)
	S BSDXS=$P(BSDXNOD,U,2)
	Q:'+BSDXR>0
	Q:'+BSDXS>0
	K ^BSDXAB("ARSCT",BSDXR,BSDXS,BSDXDA)
	Q
