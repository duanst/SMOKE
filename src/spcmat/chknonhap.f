
        SUBROUTINE CHKNONHAP( PNAM, EFLAG )

C***********************************************************************
C  subroutine body starts at line
C
C  DESCRIPTION:
C      This subroutine compares the definition of a NONHAP* pollutant
C      with the definition given in the GSPRO file.  The routine
C      is called once per pollutant.  If the pollutant name is not
C      a NONHAP pollutant or it is the same as the previous pollutant
C      name, them the routine will exit immediately.
C
C  PRECONDITIONS REQUIRED:
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION  HISTORY:
C
C****************************************************************************/
C
C Project Title: Sparse Matrix Operator Kernel Emissions (SMOKE) Modeling
C                System
C File: @(#)$Id$
C
C COPYRIGHT (C) 2002, MCNC Environmental Modeling Center
C All Rights Reserved
C
C See file COPYRIGHT for conditions of use.
C
C Environmental Modeling Center
C MCNC
C P.O. Box 12889
C Research Triangle Park, NC  27709-2889
C
C smoke@emc.mcnc.org
C
C Pathname: $Source$
C Last updated: $Date$ 
C
C**************************************************************************

C.........  MODULES for public variables
C.........  This module contains the lists of unique source characteristics
        USE MODLISTS

C.........  This module contains the speciation profiles
        USE MODSPRO

        IMPLICIT NONE
        
C...........   INCLUDES
        INCLUDE 'EMCNST3.EXT'   !  emissions constant parameters

C...........   EXTERNAL FUNCTIONS:
        CHARACTER*2   CRLF
        INTEGER       INDEX1
        INTEGER       PROMPTFFILE

        EXTERNAL      CRLF, INDEX1, PROMPTFFILE

C...........   Subroutine arguments

        CHARACTER(*), INTENT  (IN) :: PNAM       ! pol name of interest
        LOGICAL     , INTENT (OUT) :: EFLAG      ! error flag
                                
C...........   Local unsorted arrays
      
C...........   Other local variables

        INTEGER         I, J, K  ! counters and indices
        INTEGER         CNT
        INTEGER         TDEV     ! unit number for INVTABLE file

        LOGICAL, SAVE :: FIRSTCHK = .TRUE. ! true: first time for a check

        CHARACTER*256    MESG              ! message buffer

        CHARACTER(LEN=IOVLEN3)       :: PBUF      = ' '   ! tmp pollutant name
        CHARACTER(LEN=IOVLEN3), SAVE :: PREV_PNAM = ' '   ! PNAM from last call

        CHARACTER*16 :: PROGNAME = 'CHKNONHAP' ! program name
       
C***********************************************************************
C   Begin body of subroutine CHKNONHAP

        J = INDEX( PNAM, 'NONHAP' )

C.........  If current pollutant is not a NONHAP* pollutant, exit
        IF( J .LE. 0 .OR. PNAM .EQ. PREV_PNAM ) RETURN

C.........  Store pollutant name to check in next iteration
        PREV_PNAM = PNAM

C.........  Check if this is the first pollutant that we need to chk
        IF( FIRSTCHK ) THEN

C............  Open inventory table
            MESG = 'Enter logical name for INVENTORY DATA TABLE file'
            TDEV = PROMPTFFILE( MESG, .TRUE., .TRUE., 'INVTABLE',
     &                          PROGNAME )

C............  Call inventory table reader
            CALL RDCODNAM( TDEV )

            FIRSTCHK = .FALSE.

        END IF

C.........  Search for pollutant in list of available definitions
        I = INDEX1( PNAM, NSPDEF, SPCDEFPOL )

C............  When pollutant found as having a definition in the
C              speciation profile header, check it
        IF( I .GT. 0 ) THEN

C............  Loop through the INVTABLE pollutants and ensure
C              that all NONHAP contributors are also defined as part
C              of this NONHAP* variable in the GSPRO file.
            CNT = 0
            DO J = 1, MXIDAT
                IF( INVDVTS( J ) .NE. 'N' ) THEN

C...................  Search for data name in GSPRO definition
                    K = INDEX1( INVDNAM(J), NSPLST(I), SPCDEFLST(1,I) )

C...................  If data name not found in definition, then
C                     give an error.  If it is found count it.
                    IF( K .LE. 0 ) THEN
                        EFLAG = .TRUE.
                        MESG = 'ERROR: Pollutant "'// TRIM( INVDNAM(J) )
     &                         // '" part of definition of '// 
     &                         TRIM( PNAM ) // ' in INVTABLE but' //
     &                         CRLF() // BLANK10 // 'is missing from '//
     &                         'the definition in the GSPRO file.'
                        CALL M3MSG2( MESG )
                    ELSE
                        CNT = CNT + 1
                    END IF
                    
                END IF
            END DO

C...................  If the count is different, report the pollutants
C                     that are in the GSPRO def'n, but not the inven's
            IF( CNT .NE. NSPLST(I) ) THEN

                DO K = 1, NSPLST(I)
                    PBUF = SPCDEFLST(K,I)
                    J = INDEX1( PBUF, MXIDAT, ITNAMA )
                    IF( J .GT. 0 ) THEN
                        IF( ITKEEPA( J ) .AND.
     &                      ITVTSA ( J ) .EQ. 'N' ) THEN
                            EFLAG = .TRUE.
                            MESG = 'ERROR: Pollutant "'// TRIM( PBUF )//
     &                         '" part of ' // TRIM( PNAM ) // 
     &                         ' definition in GSPRO but '// CRLF()//
     &                         BLANK10 // 'not in INVTABLE.'
                            CALL M3MSG2( MESG )
                        END IF
                    END IF
                END DO

            END IF

C................  If no definition found, give a warning
        ELSE
            MESG = 'WARNING: No definition found for ' // TRIM( PNAM )
     &             // ' in the GSPRO file.  Spcmat will' //
     &             CRLF() // BLANK10 // 'not be able to check for '//
     &             'consistency between the inventory and the GSPRO '//
     &             'file.'
            CALL M3MSG2( MESG )

        END IF

C******************  FORMAT  STATEMENTS   ******************************

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10( A, :, I8, :, 1X ) )

        END SUBROUTINE CHKNONHAP
