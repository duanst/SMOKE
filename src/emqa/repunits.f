
        SUBROUTINE REPUNITS( RCNT )

C***********************************************************************
C  subroutine body starts at line 
C
C  DESCRIPTION:
C      The REPUNITS routine is reponsible for generating column header
C      units and data conversion factors
C
C  PRECONDITIONS REQUIRED:
C      From previous subroutines, we should have indices defined for 
C      which columns are for output for each species and pollutant and 
C      the various combinations.
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION  HISTORY:
C     Created 8/2000 by M Houyoux
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

C.........  This module contains report arrays for each output bin
        USE MODREPBN

C.........  This module contains the information about the source category
        USE MODINFO

        IMPLICIT NONE

C...........   INCLUDES
        INCLUDE 'EMCNST3.EXT'   !  emissions constant parameters

C...........   EXTERNAL FUNCTIONS
        CHARACTER*16 MULTUNIT
        EXTERNAL     MULTUNIT

C...........   SUBROUTINE ARGUMENTS
        INTEGER, INTENT (IN) :: RCNT    ! report number

C...........   Other local variables
        INTEGER         E, J, V   ! counters and indices

        INTEGER         IOS               ! i/o status
        INTEGER         NDATA             ! number of data columns
        INTEGER         NV                ! number data or spc variables

        LOGICAL      :: FIRSTIME = .TRUE.  ! true: first time routine called
        LOGICAL      :: SFLAG    = .FALSE. ! true: speciation applies to rpt

        CHARACTER(LEN=IOULEN3) TMPUNIT     !  tmp units buffer
        CHARACTER*300          MESG        !  message buffer

        CHARACTER*16 :: PROGNAME = 'RDREPIN' ! program name

C***********************************************************************
C   begin body of subroutine RDREPIN

C.........  Report-specific local settings
        NDATA = ALLRPT( RCNT )%NUMDATA

        SFLAG = ( ALLRPT( RCNT )%USESLMAT .OR. 
     &            ALLRPT( RCNT )%USESSMAT      )

C.........  Set variable loop maxmimum based on speciation status
        NV = NIPPA
        IF( SFLAG ) NV = NSVARS

C.........  Set up input units and unit conversion factors...

C.........  Allocate memory for needed arrays
        IF( ALLOCATED( OUTUNIT ) ) DEALLOCATE( OUTUNIT, UCNVFAC )
        ALLOCATE( OUTUNIT( NDATA ), STAT=IOS )
        CALL CHECKMEM( IOS, 'OUTUNIT', PROGNAME )
        ALLOCATE( UCNVFAC( NDATA ), STAT=IOS )
        CALL CHECKMEM( IOS, 'UCNVFAC', PROGNAME )

        OUTUNIT = ' '   ! array
        UCNVFAC = 1.    ! array

C.........  If current report has speciation, loop through species and update
C           units arrays
        DO V = 1, NSVARS

C.............  Set index to data arrays based on speciation status
            E = SPCTODAT( V )

C.............  If current variable is a speciated variable and is output for
C               this report
            IF( TOSOUT( V,RCNT )%AGG .GT. 0 ) THEN

C.................  If using mole-speciation matrix
                IF( ALLRPT( RCNT )%USESLMAT ) THEN
                    TMPUNIT = MULTUNIT( SLUNIT( V ), EAUNIT( E ) )

C.................  If using mass-speciation matrix
                ELSE IF( ALLRPT( RCNT )%USESSMAT ) THEN
                    TMPUNIT = MULTUNIT( SSUNIT( V ), EAUNIT( E ) )

                END IF

C.................  Set units and conversion factors for appropriate columns
                CALL UPDATE_OUTUNIT( NDATA, TOSOUT( V,RCNT )%SPC,
     &                               TMPUNIT, OUTUNIT, UCNVFAC )
                CALL UPDATE_OUTUNIT( NDATA, TOSOUT( V,RCNT )%ETPSPC,
     &                               TMPUNIT, OUTUNIT, UCNVFAC )
                CALL UPDATE_OUTUNIT( NDATA, TOSOUT( V,RCNT )%PRCSPC,
     &                               TMPUNIT, OUTUNIT, UCNVFAC )
                CALL UPDATE_OUTUNIT( NDATA, TOSOUT( V,RCNT )%SUMETP,
     &                               TMPUNIT, OUTUNIT, UCNVFAC )
                CALL UPDATE_OUTUNIT( NDATA, TOSOUT( V,RCNT )%SUMPOL,
     &                               TMPUNIT, OUTUNIT, UCNVFAC )

            END IF

        END DO

C.........  Now loop through pol/act/e-type and update units arrays
        DO E = 1, NIPPA

C.............  If current variable is a pol/act/e-type and is used for this
C               report
            IF( TODOUT( E,RCNT )%AGG .GT. 0 ) THEN

                TMPUNIT = EAUNIT( E )

C.................  Set units and conversion factors for appropriate columns
                CALL UPDATE_OUTUNIT( NDATA, TODOUT( E,RCNT )%ETP,
     &                               TMPUNIT, OUTUNIT, UCNVFAC )
                CALL UPDATE_OUTUNIT( NDATA, TODOUT( E,RCNT )%DAT,
     &                               TMPUNIT, OUTUNIT, UCNVFAC )

            END IF

        END DO      ! Done loop for setting input units 
                    
        RETURN

C******************  FORMAT  STATEMENTS   ******************************

C...........   Formatted file I/O formats............ 93xxx

93000   FORMAT( A )

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10( A, :, I10, :, 1X ) )

C******************  INTERNAL SUBPROGRAMS  *****************************
 
        CONTAINS
 
C.............  This internal function updates the units labels 

            SUBROUTINE UPDATE_OUTUNIT( NREC, OUTCOL, I_UNIT, 
     &                                 UNITS, FACTOR )

C.............  External functions
            REAL     UNITFAC
            EXTERNAL UNITFAC

C.............  Subprogram arguments
            INTEGER     , INTENT (IN) :: NREC    ! number of available colums
            INTEGER     , INTENT (IN) :: OUTCOL  ! specific column to update
            CHARACTER(*), INTENT (IN) :: I_UNIT ! input unit string
            CHARACTER(*), INTENT(OUT) :: UNITS( NREC )  ! string of units
            REAL        , INTENT(OUT) :: FACTOR( NREC ) ! conversion factors

C.............  Local subprogram variables
            INTEGER      L, LM1, LP1, L1, L2      ! indices

            INTEGER      UIDX    ! tmp unit array index

            REAL         FAC1    ! factor for converting units numerator
            REAL         FAC2    ! factor for converting units denominator

            CHARACTER( LEN=IOULEN3 ) DEN_I     ! tmp input denominator 
            CHARACTER( LEN=IOULEN3 ) DEN_O     ! tmp output denominator 
            CHARACTER( LEN=IOULEN3 ) O_UNIT    ! tmp output unit 
            CHARACTER( LEN=IOULEN3 ) NUM_I     ! tmp input numerator 
            CHARACTER( LEN=IOULEN3 ) NUM_O     ! tmp output numerator 
            CHARACTER( LEN=IOULEN3 ) T_UNIT    ! tmp unit 

C----------------------------------------------------------------------

C.............  Return immediately if current record is not an output column
            IF( OUTCOL .LE. 0 ) RETURN

C.............  Check if output data records is less than or equal to maximum
C               input records for indexing purposes
C.............  If output number is greater, then no SELECT DATA statement
C               was used, so units, if specified, should be retrieved from
C               the first entry in the specified output units.
            IF( NREC .GT. MXINDAT ) THEN
                UIDX = 1

C.............  If output records are the same as the input records, then
C               the units specified for each data column can be used.
            ELSE
                UIDX = OUTCOL

            END IF

C.............  Set temporary units from input units
            T_UNIT = I_UNIT

C.............  Set output units and conversion factor, if output units are
C               set by the report configuration file
            IF( ALLUSET( UIDX, RCNT ) .NE. ' ' ) THEN

                O_UNIT = ALLUSET( UIDX, RCNT )

C.................  Set the numerators and denominators...
C.................  Make sure if no denominator is given that there won't be
C                   a problem
C.................  For the input units:
                L2 = LEN_TRIM( T_UNIT )
                L  = INDEX( T_UNIT, '/' )
                LM1 = L - 1
                LP1 = L + 1
                IF( L .LE. 0 ) THEN
                    LM1 = L2
                    LP1 = 0
                END IF 
             
                NUM_I = ADJUSTL( T_UNIT( 1:LM1 ) )
                IF( LP1 .GT. 0 ) DEN_I = ADJUSTL( T_UNIT( LP1:L2 ) )

C.................  If input denominator is hourly, but reporting is not
C                   hourly, then sum per day.  Change denominator accordingly.
                IF( DEN_I .EQ. 'hr'  .AND.  
     &                    .NOT. ALLRPT( RCNT )%BYHOUR ) THEN
                    DEN_I = 'day'
                    L2 = LEN_TRIM( NUM_I )
                    T_UNIT = NUM_I( 1:L2 ) // '/' // DEN_I 
                END IF

C.................  For the output units:
                L2 = LEN_TRIM( O_UNIT )
                L  = INDEX( O_UNIT, '/' )
                LM1 = L - 1
                LP1 = L + 1
                IF( L .LE. 0 ) THEN
                    LM1 = L2
                    LP1 = 0
                END IF 
             
                NUM_O = ADJUSTL( O_UNIT( 1:LM1 ) )
                IF( LP1 .GT. 0 ) DEN_O = ADJUSTL( O_UNIT( LP1:L2 ) )

C.................  Get factor for the numerator and denominator
                FAC1 = UNITFAC( T_UNIT, O_UNIT, .TRUE. )
                FAC2 = UNITFAC( T_UNIT, O_UNIT, .FALSE. )

                IF( FAC1 .EQ. 1 ) NUM_O = NUM_I
                IF( FAC2 .EQ. 1 ) DEN_O = DEN_I

C.................  Set the final output units
                L1  = LEN_TRIM( NUM_O )
                L2  = LEN_TRIM( DEN_O )
                UNITS ( OUTCOL ) = NUM_O( 1:L1 ) // '/' // DEN_O( 1:L2 )
                FACTOR( OUTCOL ) = FAC1 / FAC2

C.............  If output units not set, then use input units
C.............  Set conversion factor to 1
            ELSE 

                UNITS ( OUTCOL ) = T_UNIT 
                FACTOR( OUTCOL ) = 1.

            END IF

            RETURN
 
            END SUBROUTINE UPDATE_OUTUNIT

        END SUBROUTINE REPUNITS

