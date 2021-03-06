      PROGRAM CONTOR
C
C    CONTOR CONTOURS A GRID OF DATA GENERATED BY GRID.
C
      CHARACTER*70 LINE
      CHARACTER*40 WGRD, file
      CHARACTER*4 FGRD /'.grd'/
      character*10 word
      REAL*8 GRD,A,CR,SCAL
      REAL*8 XRAN,YRAN,XX,YY,ZZ
C
      DIMENSION GRD(800,800),CTR(200)
C
      COMMON /GRID/ GRID(800,800)
      COMMON /TRANS/ CR(2),SCAL
C
      DATA CTR / 1.0D-3, 2.0D-3, 4.0D-3, 8.0D-3,
     +                   2.0D-2, 4.0D-2, 8.0D-2,
     +                   2.0D-1, 4.0D-1, 8.0D-1,
     +                   2.0D+0, 4.0D+0, 8.0D+0,
     +                   2.0D+1, 4.0D+1, 8.0D+1,
     +                   2.0D+2, 4.0D+2, 8.0D+2, 181*0/
      DATA NCNTR /19/
*     DATA XMIN / 0.0/, XMAX /10.0/, YMIN / 0.0/, YMAX /10.0/
C
      CALL MAKNAME(1,WGRD,ILEN,FGRD)
      IF (ILEN .EQ. 0) STOP 'usage: contor grdfile xw|psfile [nodef]'
      CALL MAKNAME(2,file,ILEN,' ')
      IF (ILEN .EQ. 0) STOP 'usage: contor grdfile xw|psfile [nodef]'
      if (file(1:ilen).eq.'xw') then
          file='/xwindow'
      else
          file=file(1:ilen)//'.ps/VPS'
      endif
      call makname(3,word,ilen,' ')
      if (ilen.ne.0) then
         write (6,*) 'Enter:  1 if you want a linear grid of contour',
     &               ' values'
         write (6,*) '        2 if you want to enter a list of contour',
     &               ' values'
         read (5,*) iansw
         if (iansw .eq. 1) then
            write (6,*) 'Introduce min. and. max value of scalar'
            write (6,*) 'and the number of contour lines'
            read (5,*) smin,smax,ncntr
            if (smax.lt.smin) stop 'MIN> MAX!!'
            if (smin.lt.0d0) stop 'Negative scalars forbidden.'
            if (ncntr.gt.200) stop 'Max. number of isolines exceeded.'
            smin=log(smin+1d-40)
            smax=log(smax+1d-40)
            sdelta=(smax-smin)/(ncntr-1) 
            do i=0, ncntr-1
               ctr(i+1)=exp(smin+sdelta*i)
            enddo
         else
            write (6,*) 'How many contour lines do you want?'
            read (5,*) ncntr
            if (ncntr.gt.200) stop 'Max. number of isolines exceeded.'
            write (6,*) 'Enter the contour values:'
            read (5,*) (ctr(i), i=1,ncntr)
         endif
      endif
      
C
      OPEN (30,FILE=WGRD)
C
C    INITIALIZE PLOTTER AND LINE TYPES
C
C
      READ (30,100) LINE
      READ (30,100) LINE
      READ (30,*) NX,NY,XRAN,YRAN
      READ (30,*) IFUN,NAT
      READ (30,*) XX,YY,ZZ
      CR(1) = XRAN/2D0
      CR(2) = XRAN/2D0 
      XMIN=0
      XMAX=XRAN
      YMIN=0
      YMAX=XRAN
      SCAL = 1.
      CALL PLOTS2 (sngl(xran),sngl(xran),file,LINE)
      DO 30 I = 1,NAT
        READ (30,*) XX,YY,ZZ
        CALL NUCLEI(XX,YY,ZZ)
30    CONTINUE
C
      DO 10 I = 1,NX
        READ (30,*) (GRD(J,I),J=1,NY)
10    CONTINUE
C
      DO 20 I = 1,NX
        DO 20 J = 1,NY
          GRID(I,J) = SNGL(GRD(I,J))
20    CONTINUE
C
      CALL CTPLOT (NX,NY,1,NX,1,NY,XMIN,XMAX,YMIN,YMAX,
     + NCNTR,CTR,IFUN,1)
C
      CALL FLUSH (6)
      CALL PLOT (0.,0.,999)
C
C    FORMATS
C
100   FORMAT(A70)
      END
      SUBROUTINE CONTUR ( IV, JV, KX, NX, KY, NY, CLP)
C
      INTEGER UX1, UY1, COM, REC
C
      COMMON /GRID/ A(800,800)
      COMMON /SCLDAT/ XMIN, YMIN, XINCR, YINCR, KC
      COMMON /CRPTPM/ CLA,KKX,MX,KKY,MY,IZ,NR,NP,IXO,IYO,ISO
      COMMON /TEMP/ X(1000), Y(1000), REC(1000)
C
C    THE 3 ROUTINES, CONTUR, CURVE AND INTERP FORM A
C    GENERAL CONTOUR MAPPING PACKAGE THAT SIMPLY REQUIRES
C    A PLOTTING ROUTINE COUPLR(N) TO PLOT N POINTS
C    WITH COORDINATES IN THE ARRAYS X AND Y.
C    IF CONTOURS WITH MORE THAN 800 POINTS ARE TO BE
C    DRAWN (THIS IS VERY LARGE), THE DIMENSION STATEMENTS
C    MUST BE ADJUSTED.
C
C    SEE IMPORTANT NOTES IN INTERP AND CURVE
C
C    THIS PROGRAM IS BASED ON M.O. DAYHOFF'S PAPER
C    'A CONTOUR MAP PROGRAM FOR X-RAY CRYSTALLOGRAPHY'
C    OCT. 1963 COMMUNICATIONS OF THE ACM. FIRST
C    PROGRAMMED BY BRUCE LANGDON, PLASMA PHYSICS
C    LAB, PRINCETON UNIVERSITY, NOV. 1966.
C
      IZ = MAX(IV,JV)
      KKX = KX
      KKY = KY
      MX = NX
      MY = NY
      CLA = CLP
      NR = 0
C
C    SCAN RIGHT EDGE, BOTTOM TO TOP.
C
      DO 100 J = KY+1, MY
        IF (A(MX,J-1) .LT. CLA .AND. A(MX,J) .GE. CLA)
     1    CALL CURVE( IV, JV, MX, J, 7, IRET)
        IF (IRET .EQ. 1) RETURN
100   CONTINUE
C
C    SCAN TOP EDGE, RIGHT TO LEFT
C
      DO 110 I = MX-1, KX, -1
        IF (A(I+1,MY) .LT. CLA .AND. A(I,MY) .GE. CLA)
     1    CALL CURVE( IV, JV, I, MY, 5, IRET)
        IF (IRET .EQ. 1) RETURN
110   CONTINUE
C
C    SCAN LEFT EDGE TOP TO BOTTOM
C
      DO 120 J = MY-1, KY, -1
        IF (A(KX,J+1) .LT. CLA .AND. A(KX,J) .GE. CLA)
     1    CALL CURVE( IV, JV, KX, J, 3, IRET)
        IF (IRET .EQ. 1) RETURN
120   CONTINUE
C
C    SCAN BOTTOM EDGE AND INTERIOR POINTS
C
      DO 130 J = KY, MY-1
        DO 130 I = KX+1, MX
          IF (A(I-1,J) .GE. CLA .OR. A(I,J) .LT. CLA) GOTO 130
          IF (NR .EQ. 0) GOTO 140
          COM = IZ * I + J
          DO 150 ID = 1, NR
            IF (REC(ID) .EQ. COM) GOTO 130
150       CONTINUE
140   CALL CURVE( IV, JV, I, J, 1, IRET)
      IF (IRET .EQ. 1) RETURN
130   CONTINUE
      RETURN
      END
      SUBROUTINE COUPLR(NN)
C
      INTEGER REC
C
      REAL*8 CR,SCAL 
      COMMON /TEMP/ XX(1000), YY(1000), REC(1000)
      COMMON /SCLDAT/ XMIN, YMIN, XINCR, YINCR, KK
      COMMON /TRANS/ CR(2),SCAL
      DIMENSION AXX(1000),AYY(1000)
C
      AXX(1)=XX(1)-CR(1)*SCAL+CR(1)
      AYY(1)=YY(1)-CR(2)*SCAL+CR(2)
C
      CALL PLOT( AXX(1), AYY(1), 3)
C
C    CHOOSE LINE TYPE
C
      IF (KK .EQ. 1) IPEN = 2
      IF (KK .EQ. 2) IPEN = 5
      IF (KK .EQ. 3) IPEN = 6
      IF (KK .EQ. 4) IPEN = 7
C
        DO 10 I = 2, NN
      AXX(I)=XX(I)-CR(1)*SCAL+CR(1)
      AYY(I)=YY(I)-CR(2)*SCAL+CR(2)
*mdc*if old
*         CALL PLOT( AXX(I), AYY(I), IPEN)
*mdc*endif
10    CONTINUE
*mdc*if new
      CALL PLOT_LINE( NN, AXX, AYY, IPEN)
*mdc*endif
C
      RETURN
      END
      SUBROUTINE CTPLOT
     1            (     IV,      ! ROW DIMENSION OF MATRIX
     1                  JV,      ! COLUMN DIMENSION OF MATRIX
     1                  KX,      ! LOWEST ROW CONSIDERED
     1                  NX,      ! HIGHEST ROW CONSIDERED
     1                  KY,      ! LOWER COLUMN CONSIDERED
     1                  NY,      ! HIGHEST COLUMN CONSIDERED
     1                  XXMIN,
     1                  XXMAX,
     1                  YYMIN,
     1                  YYMAX,
     1                  NCTR,    ! NUMBER OF CONTOURS
     1                  CTR,     ! CONTOUR VALUES
     1                  IFUN,    ! FUNCTION
     1                  ICONN )
C
C THIS PROGRAM PRODUCES CONTOUR PLOTS FROM THE MATRIX A WHICH HAS
C       DIMENSIONS IV AND JV USING THE CONTOURS GIVEN IN THE ARRAY CTR.
C
C KX, NX, KY, AND NY DELINEATE THE PORTION OF THE ARRAY TO BE MAPPED.
C
C XXMIN, XXMAX, YYMIN, AND YYMAX INDICATES THE RANGE OF X AND Y VALUES FOR
C       THIS REGION OF THE ARRAY.
C
C CTR      IS AN ARRAY HOLDING THE VALUES OF THE CONTOURS TO BE DRAWN.
C NCTR       THE NUMBER OF CONTOURS AND THE ARRAY
C ICONN 1 IF NEGATIVE CONTOURS ARE DESIRED THAT ARE THE SAME AS THE POSITIVE
C      CONTOURS (ONLY THE POSITIVE ONES NEED BE SPECIFIED IN CTR AND NCTR).
C ======================================================================-======
C
      COMMON /SCLDAT/ XMIN, YMIN, XINCR, YINCR, KC
      DIMENSION  CTR(NCTR)
C
      XMAX = XXMAX
      YMAX = YYMAX
      XMIN = XXMIN
      YMIN = YYMIN
      XINCR = (XMAX - XMIN)/ (NX - KX + 1)
      YINCR = (YMAX - YMIN)/ (NY - KY + 1)
C
C    CALL CONTUR FOR EACH CONTOUR.
C
      DO 100 NCL = 1, NCTR
        CL = CTR(NCL)
        KC = 1
        IF (IFUN .EQ. 2 ) KC = 2
        IF (IFUN .EQ. 4 ) KC = 4
        CALL CONTUR( IV, JV, KX, NX, KY, NY, CL)
C
C    FOR ICONN = 1, DO AGAIN WITH -VE CONTOURS.
C
      IF (ICONN .EQ. 1) THEN
C       DO 110 NCL = 1, NCTR
          CL = -CTR(NCL)
          KC = 1
          IF (IFUN .EQ. 3) KC = 2
          CALL CONTUR( IV, JV, KX, NX, KY, NY, CL)
C110     CONTINUE
C
      END IF
100   CONTINUE
      RETURN
      END
      SUBROUTINE CURVE( IV, JV, IXP, IYP, ISP, IRT)
C
      INTEGER REC, DX, DY
      LOGICAL PC, LOPC, LPC
      DIMENSION INX(8), INY(8)
C
      COMMON /GRID/ A(800,800)
      COMMON /CRPTPM/ CL, KKX,MX,KKY,MY, IZ,NR,NP, IXO,IYO,ISO
      COMMON /LOGIC/ PC, LOPC
      COMMON /TEMP/ X(1000), Y(1000), REC(1000)
C
      DATA INX /-1, -1, 0, 3*1, 0, -1/
      DATA INY /0, 3*1, 0, 3*-1/
C
C       RECMAX SHOULD BE EQUAL TO THE DIMENSION OF X, Y, REC IN 
C       COMMON /TEMP/
C
      RECMAX=1000
C
      IS = ISP
      IX = IXP
      IY = IYP
      IXO = IX
      IYO = IY
      ISO = IS
      NP = 1
      LOPC = .FALSE.
      CALL INTERP( IX, IY, IS, IRET, IV, JV)
      IF (IRET .EQ. 1 .OR. IRET .EQ. 2) CALL
     1  EXIT1(' BAD RETURN FROM INTERP')
      IF (IRET .EQ. 3) GO TO 3
C
C    ROTATE
C
1     IS = MOD( IS, 8) + 1
      DX = INX(IS)
      DY = INY(IS)
C
C    FIND PLOT POINT
C
2     IRET = 1
      CALL INTERP( IX, IY, IS, IRET, IV, JV)
      IF (IRET .EQ. 1) THEN
C
C    DIAG FAIL
C
        IS = MOD( IS, 8) + 1
        LOPC = .TRUE.
        IRET = 1
        CALL INTERP( IX+INX(IS), IY+INY(IS), IS-3, IRET, IV, JV)
        IF (IRET .EQ. 1 .OR. IRET .EQ. 2)
     1    CALL EXIT1(' BAD RETURN FROM INTERP')
        IF (IRET .EQ. 3) GO TO 10
        IX = IX + DX
        IY = IY + DY
        IS = MOD( IS+3, 8) + 1
        GO TO 2
      ELSE IF (IRET .EQ. 2) THEN
C
C    NON-DIAG FAIL
C
        IX = IX + DX
        IY = IY + DY
        IS = MOD( IS+4, 8) + 1
        LPC = PC
        CALL INTERP( IX, IY, IS, IRET, IV, JV)
        IF (IRET .EQ. 2) CALL EXIT1(' BAD RETURN FROM INTERP')
        IF (IRET .EQ. 3) GO TO 10
        IF (.NOT. (LPC .AND. PC)) GO TO 1
C
C   PLOT POINT SWITCH
C
        IF( NP .LE. 2) GO TO 1
        TEM = X(NP-2)
        X(NP-2) = X(NP-1)
        X(NP-1) = TEM
        TEM = Y(NP-2)
        Y(NP-2) = Y(NP-1)
        Y(NP-1) = TEM
        GO TO 1
      ENDIF
      IF (IRET .EQ. 3) GO TO 10
      IF (IS .NE. 1) GO TO 1
C
C   RECORD A 'CENTER'
C
3     IF (NR .GE. RECMAX) THEN
C
C   REC ARRAY OVERFLOW
C
      WRITE(2,4)
4     FORMAT(' TOO MANY POINTS IN CONTOUR. PROGRAM MUST BE 
     +RE-DIMENSIONED')
        CALL COUPLR(NP-1)
        IRT = 1
        IRET = 1
        RETURN
      ELSE
        NR = NR + 1
        REC(NR) = IZ * IX + IY
        GO TO 1
      ENDIF
10    CALL COUPLR(NP-1)
      IRET = 0
      RETURN
      END
      SUBROUTINE EXIT1( AMESS)
C
C    TERMINATES PLOTTING IN CASE OF AN ABORT.
C
      CHARACTER*(*) AMESS
      WRITE(6,*) AMESS
      STOP ' CONTOR STOPS '
      END
      SUBROUTINE INTERP( IX, IY, ISP, IRET, IV, JV)
C
      INTEGER REC, DX, DY
      LOGICAL PC, LOPC
      DIMENSION INX(8), INY(8)
C
      COMMON /GRID/ A(800,800)
      COMMON /CRPTPM/ CL, KKX,MX,KKY,MY, IZ,NR,NP, IXO,IYO,ISO
      COMMON /LOGIC/ PC, LOPC
      COMMON /SCLDAT/ XMIN, YMIN, XINCR, YINCR, KK
      COMMON /TEMP/ X(1000), Y(1000), REC(1000)
C
      DATA INX /-1, -1, 0, 3*1, 0, -1/
      DATA INY /0, 3*1, 0, 3*-1/
C
      IRET = 0
      IS = ISP
      IF (IS .LT. 1) IS = IS + 8
      DX = INX(IS)
      DY = INY(IS)
      FDX = FLOAT(DX) * XINCR
      FDY = FLOAT(DY) * YINCR
      FIX = FLOAT( IX - KKX) * XINCR + XMIN
      FIY = FLOAT( IY - KKY) * YINCR + YMIN
      IX1 = IX + DX
      IY1 = IY + DY
      IF (IX1 .LT. KKX .OR. IX1 .GT. MX .OR.
     1    IY1 .LT. KKY .OR. IY1 .GT. MY) THEN
        IRET = 3
        RETURN
      ENDIF
      IF ( DX * DY .EQ. 0) THEN
C
C    NON-DIAGONAL CASE
C    CHECK FOR FAIL
C
        IF (A(IX1,IY1) .GE. CL) THEN
          IRET = 2
          RETURN
        ENDIF
        IF (DX .EQ. 0) THEN
          X(NP) = FIX
          Y(NP) = (A(IX,IY) - CL) / (A(IX,IY) - A(IX,IY1)) * FDY + FIY
        ELSE
          Y(NP) = FIY
          X(NP) = (A(IX,IY) - CL) / (A(IX,IY) - A(IX1,IY)) * FDX + FIX
        ENDIF
        PC = .FALSE.
      ELSE
C
C    DIAGONAL CASE
C
        CP = (A(IX,IY) + A(IX1,IY) + A(IX,IY1) + A(IX1,IY1)) / 4.
        IF (CP .GE. CL .OR. LOPC) THEN
C
C    CONTOUR PASSES ON FAR SIDE OF CENTER POINT
C
          IF (A(IX1,IY1) .GE. CL .AND. CP .GE. CL) THEN
            IRET = 1
            RETURN
          ENDIF
          V = (A(IX1,IY1) - CL) / (A(IX1,IY1) - CP) / 2.
          X(NP) = (1. - V) * FDX + FIX
          Y(NP) = (1. - V) * FDY + FIY
          PC = .TRUE.
          LOPC = .FALSE.
        ELSE
C
C    CONTOUR PASSES ON NEAR SIDE OF CENTER POINT
C
          V = (A(IX,IY) - CL) / (A(IX,IY) - CP) / 2.
          X(NP) = V * FDX + FIX
          Y(NP) = V * FDY + FIY
          PC = .FALSE.
        ENDIF
      ENDIF
      NP = NP + 1
      IF (IX .EQ. IXO .AND. IY .EQ. IYO .AND. IS .EQ. ISO) THEN
        IRET = 3
        RETURN
      ENDIF
      IF (NP .LE. 800) RETURN
C
C    PLOT PART OF CURVE AND CONTINUE
C
      CALL COUPLR(NP-1)
      X(1) = X(NP-1)
      Y(1) = Y(NP-1)
      NP = 2
      RETURN
      END
      SUBROUTINE MAKNAME(I,STRING,L,EXT)
      CHARACTER*(*) STRING,EXT
      INTEGER I,J
      CALL GETARG(I,STRING)
      J = LEN(STRING)
      DO 10 N = 1,J
        IF(STRING(N:N) .EQ. ' ') THEN
          L = N - 1
          STRING = STRING(1:L)//EXT
          RETURN
        ENDIF
10    CONTINUE
      STOP ' FAILED TO MAKE A FILE NAME '
      RETURN
      END
      SUBROUTINE NUCLEI(XN,YN,ZN)
C
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
C
      REAL*8 CR,SCAL
      COMMON /TRANS/ CR(2),SCAL
C
      DATA SN1,SN2 /.06,.04/
C
      XN = (XN*SCAL + CR(1))
      YN = (YN*SCAL + CR(2))
C
      CALL PLOT (SNGL(XN-SCAL*SN1),SNGL(YN),3)
C
      IF (DABS(ZN) .GE. 1.0D-01) THEN
        CALL PLOT (SNGL(XN-SCAL*SN2),SNGL(YN),2)
        CALL PLOT (SNGL(XN+SCAL*SN2),SNGL(YN),3)
        CALL PLOT (SNGL(XN+SCAL*SN1),SNGL(YN),2)
        CALL PLOT (SNGL(XN),SNGL(YN-SCAL*SN1),3)
        CALL PLOT (SNGL(XN),SNGL(YN-SCAL*SN2),2)
        CALL PLOT (SNGL(XN),SNGL(YN+SCAL*SN2),3)
        CALL PLOT (SNGL(XN),SNGL(YN+SCAL*SN1),2)
      ELSE 
        CALL PLOT (SNGL(XN+SCAL*SN1),SNGL(YN),2)
        CALL PLOT (SNGL(XN),SNGL(YN-SCAL*SN1),3)
        CALL PLOT (SNGL(XN),SNGL(YN+SCAL*SN1),2)
      END IF
      RETURN
      END

