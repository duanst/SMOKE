
        SUBROUTINE RDRPRTS( FDEV )

C***********************************************************************
C  subroutine body starts at line 
C
C  DESCRIPTION:
C      The RDRPRTS routine reads the report information from the REPCONFIG 
C      and sets report arrays from the MODRPRT module
C
C  PRECONDITIONS REQUIRED:
C    REPCONFIG file is opened
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION  HISTORY:
C     Created 7/2000 by M Houyoux
C
C***********************************************************************
C  
C Project Title: Sparse Matrix Operator Kernel Emissions (SMOKE) Modeling
C                System
C File: @(#)$Id$
C  
C COPYRIGHT (C) 2000, MCNC--North Carolina Supercomputing Center
C All Rights Reserved
C  
C See file COPYRIGHT for conditions of use.
C  
C Environmental Programs Group
C MCNC--North Carolina Supercomputing Center
C P.O. Box 12889
C Research Triangle Park, NC  27709-2889
C  
C env_progs@mcnc.org
C  
C Pathname: $Source$
C Last updated: $Date$ 
C  
C***********************************************************************

C...........   MODULES for public variables
C.........  This module contains Smkreport-specific settings
        USE MODREPRT

C...........  This module contains the information about the source category
        USE MODINFO

        IMPLICIT NONE

C...........   INCLUDES
        INCLUDE 'EMCNST3.EXT'   !  emissions constant parameters

C...........   EXTERNAL FUNCTIONS and their descriptions:
        CHARACTER*2   CRLF
        LOGICAL       BLKORCMT
        INTEGER       GETNLIST

        EXTERNAL   CRLF, BLKORCMT, GETNLIST

C...........   SUBROUTINE ARGUMENTS
        INTEGER     , INTENT (IN) :: FDEV    ! File unit number

C...........   Line parsing array
        CHARACTER*300 SEGMENT( 100 )
 
C...........   Other local variables
        INTEGER          H, I, L, N    ! counters and indices

        INTEGER          IOS     !  i/o status
        INTEGER          IREC    !  record counter
        INTEGER       :: NS = 1  !  no. segments in line
        INTEGER          NUNIT   !  tmp number of units

        LOGICAL       :: EFLAG   = .FALSE. !  true: error found

        CHARACTER*300    BUFFER            !  line work buffer
        CHARACTER*300    LINE              !  line input buffer
        CHARACTER*300    MESG              !  message buffer

        CHARACTER*16 :: PROGNAME = 'RDRPRTS' ! program name

C***********************************************************************
C   begin body of subroutine RDRPRTS

C.........  Allocate memory for report arrays based on previous read of file 
C           and previously determined settings...

c note: Add DELIM and ALLOUTHR; remove OUTTIME?

C.........  Allocate and initialize report arrays
        ALLOCATE( ALLRPT( NREPORT ), STAT=IOS )
        CALL CHECKMEM( IOS, 'ALLRPT', PROGNAME )
        ALLOCATE( ALLOUTHR( 24,NREPORT ), STAT=IOS )
        CALL CHECKMEM( IOS, 'ALLOUTHR', PROGNAME )
        ALLOCATE( ALLUSET( MXINDAT, NREPORT ), STAT=IOS )
        CALL CHECKMEM( IOS, 'ALLUSET', PROGNAME )
        ALLOCATE( INDNAM( MXINDAT, NREPORT ), STAT=IOS )
        CALL CHECKMEM( IOS, 'INDNAM', PROGNAME )
        ALLOCATE( TITLES( MXTITLE, NREPORT ), STAT=IOS )
        CALL CHECKMEM( IOS, 'TITLES', PROGNAME )

        ALLRPT%BEGSUMHR = 0
        ALLRPT%ELEVSTAT = 0
        ALLRPT%OUTTIME  = 0
        ALLRPT%NUMDATA  = -9      ! zero is legitimate
        ALLRPT%NUMTITLE = 0
        ALLRPT%RENDLIN  = 0
        ALLRPT%RSTARTLIN= 0
        ALLRPT%BYCELL   = .FALSE.
        ALLRPT%BYCNRY   = .FALSE.
        ALLRPT%BYCNTY   = .FALSE.
        ALLRPT%BYCONAM  = .FALSE.
        ALLRPT%BYCYNAM  = .FALSE.
        ALLRPT%BYDATE   = .FALSE.
        ALLRPT%BYELEV   = .FALSE.
        ALLRPT%BYHOUR   = .FALSE.
        ALLRPT%BYSCC    = .FALSE.
        ALLRPT%BYSRC    = .FALSE.
        ALLRPT%BYSTAT   = .FALSE.
        ALLRPT%BYSTNAM  = .FALSE.
        ALLRPT%BYRCL    = .FALSE.
        ALLRPT%LAYFRAC  = .FALSE.
        ALLRPT%NORMCELL = .FALSE.
        ALLRPT%O3SEASON = .FALSE.
        ALLRPT%SCCNAM   = .FALSE.
        ALLRPT%SRCNAM   = .FALSE.
        ALLRPT%STKPARM  = .FALSE.
        ALLRPT%USEGMAT  = .FALSE.
        ALLRPT%USEHOUR  = .FALSE.
        ALLRPT%USESLMAT = .FALSE.
        ALLRPT%USESSMAT = .FALSE.
        ALLRPT%DELIM    = ' '
        ALLRPT%DATAFMT  = ' '
        ALLRPT%OFILENAM = ' '
        ALLRPT%REGNNAM  = ' '
        ALLRPT%SUBGNAM  = ' '
        ALLOUTHR = .FALSE.
        ALLUSET  = ' '
        INDNAM  = ' '
        TITLES   = ' '

C.........  Read lines of file and store report characteristics
        IREC = 0
        DO I = 1, NLINE_RC

            READ( FDEV, 93000, END=999, IOSTAT=IOS ) LINE
            IREC = IREC + 1

            IF ( IOS .NE. 0 ) THEN
                EFLAG = .TRUE.
                WRITE( MESG,94010 ) 
     &              'I/O error', IOS, 
     &              'reading report configuration file at line', IREC
                CALL M3MESG( MESG )
                CYCLE
            END IF

C.............  Skip blank lines and comment lines
            IF( BLKORCMT( LINE ) ) CYCLE

C.............  Screen for appended comments and remove them
            CALL RMCOMMNT( '##', LINE )

C.............  Left-justify and convert line to upper case
            LINE = ADJUSTL( LINE )
            BUFFER = LINE
            CALL UPCASE( BUFFER )

C.............  Initialize segment from previous iteration
            SEGMENT( 1:NS ) = ' '

C.............  Parse line into segments
            L = LEN_TRIM( BUFFER )
            NS = GETNLIST( L, BUFFER )
            CALL PARSLINE( BUFFER, NS, SEGMENT )

C.............  Interpret line of code.  Set global variables in MODREPRT.
            CALL PRCLINRC( IREC, NS, LINE, SEGMENT )

C.............  Skip if report section not started yet.
            IF( .NOT. INREPORT ) CYCLE

C.............  Get count of report packets
            N = PKTCOUNT( RPT_IDX )

C.............  Store settings for current report
            ALLRPT( N ) = RPT_

            ALLRPT( N )%RENDLIN  = PKTEND
            ALLRPT( N )%RSTARTLIN= PKTSTART
            ALLRPT( N )%OFILENAM = FIL_ONAME

C.............  Conditional settings - only set if current line is type...
C.............  Title line
            IF( LIN_TITLE   ) 
     &          TITLES( RPT_%NUMTITLE , N ) = TITLE

C.............  Data subselection
            IF( LIN_SUBDATA ) 
     &          INDNAM( 1:RPT_%NUMDATA, N ) = SEGMENT( 3:NS )

C.............  Units - for now, one unit applies to all
C note: Must edit here.
            IF( LIN_UNIT ) THEN
                ALLUSET( :, N ) = UNITSET
            END IF

        END DO    ! End read loop of report configuration file

C.........  Rewind file
        REWIND( FDEV )

C.........  Post-process output times and update logical array
        DO N = 1, NREPORT

C.............  If reportin "BY HOUR" or if temporal allocation not used for 
C               the report, set output for all "hours" to true. 
            IF( ALLRPT( N )%BYHOUR .OR. .NOT. ALLRPT( N )%USEHOUR ) THEN

                ALLOUTHR( 1:24, N ) = .TRUE.

C.............  Output for a specific hour (set as HHMMSS)
            ELSE
                H = MIN( ( ALLRPT( N )%OUTTIME/10000 ) + 1, 24 )
                ALLOUTHR( H, N ) = .TRUE.

            END IF

        END DO

C.........  If there was an error reading the file
        IF( RC_ERROR ) EFLAG = .TRUE. 

C.........  If there was any error, exit 
        IF( EFLAG ) THEN
             MESG = 'Problem reading reports configuration file.'
             CALL M3EXIT( PROGNAME, 0, 0, MESG, 2 )
        END IF

        RETURN

C.........  Error message for reaching the end of file too soon
999     WRITE( MESG,94010 )
     &         'End of file reached unexpectedly at line', IREC, CRLF()
     &         //BLANK10 //'Check format of reports configuration file.'
        CALL M3EXIT( PROGNAME, 0, 0, MESG, 2 )

C******************  FORMAT  STATEMENTS   ******************************

C...........   Formatted file I/O formats............ 93xxx

93000   FORMAT( A )

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10( A, :, I10, :, 1X ) )

        END SUBROUTINE RDRPRTS

