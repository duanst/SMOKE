        MODULE MODMET

!***********************************************************************
!  Module body starts at line
!
!  DESCRIPTION:
!     This module contains the derived meteorology data for applying emission
!     factors to activity data.
!
!  PRECONDITIONS REQUIRED:
!
!  SUBROUTINES AND FUNCTIONS CALLED:
!
!  REVISION HISTORY:
!     Created 6/99 by M. Houyoux
!
!***************************************************************************
!
! Project Title: Sparse Matrix Operator Kernel Emissions (SMOKE) Modeling
!                System
! File: @(#)$Id$
!
! COPYRIGHT (C) 2002, MCNC Environmental Modeling Center
! All Rights Reserved
!
! See file COPYRIGHT for conditions of use.
!
! Environmental Programs Group
! MCNC--North Carolina Supercomputing Center
! P.O. Box 12889
! Research Triangle Park, NC  27709-2889
!
! env_progs@mcnc.org
!
! Pathname: $Source$
! Last updated: $Date$ 
!
!****************************************************************************

        INCLUDE 'EMPRVT3.EXT'

!...........   Setting for range of valid min/max temperatures
        REAL, PUBLIC :: MINTEMP = 0.   ! minimum temperature
        REAL, PUBLIC :: MAXTEMP = 0.   ! maximum temperature

!...........   Source-based meteorology data (dim: NSRC)
        REAL, ALLOCATABLE, PUBLIC :: TASRC   ( : )   ! temperature in Kelvin
        REAL, ALLOCATABLE, PUBLIC :: QVSRC   ( : )   ! water vapor mixing ratio
        REAL, ALLOCATABLE, PUBLIC :: PRESSRC ( : )   ! pressure in pascals

!...........   Hourly meteorology data
!...              for Mobile5 processing, index 0 = 12 AM local time
!...              for Mobile6 processing, index 0 = 6 AM local time
        REAL,    ALLOCATABLE, PUBLIC :: TKHOUR  ( :,: ) ! temps by source per hour
        REAL,    ALLOCATABLE, PUBLIC :: RHHOUR  ( :,: ) ! relative humidity by source per hour
        REAL,    ALLOCATABLE, PUBLIC :: BPHOUR  ( :,: ) ! barometric pressure by source per hour

        REAL,    ALLOCATABLE, PUBLIC :: TDYCNTY ( : )   ! daily temps by county
        REAL,    ALLOCATABLE, PUBLIC :: RHDYCNTY( : )   ! daily relative humidity by county
        REAL,    ALLOCATABLE, PUBLIC :: BPDYCNTY( : )   ! daily barometric pressure by county
        INTEGER, ALLOCATABLE, PUBLIC :: DYCODES ( : )   ! FIPS codes for daily counties

        REAL,    ALLOCATABLE, PUBLIC :: TWKCNTY ( : )   ! weekly temps by county
        REAL,    ALLOCATABLE, PUBLIC :: RHWKCNTY( : )   ! weekly relative humidity by county
        REAL,    ALLOCATABLE, PUBLIC :: BPWKCNTY( : )   ! weekly barometric pressure by county
        INTEGER, ALLOCATABLE, PUBLIC :: WKCODES ( : )   ! FIPS codes for weekly counties

        REAL,    ALLOCATABLE, PUBLIC :: TMNCNTY ( : )   ! monthly temps by county
        REAL,    ALLOCATABLE, PUBLIC :: RHMNCNTY( : )   ! monthly relative humidity by county
        REAL,    ALLOCATABLE, PUBLIC :: BPMNCNTY( : )   ! monthly barometric pressure by county
        INTEGER, ALLOCATABLE, PUBLIC :: MNCODES ( : )   ! FIPS codes for monthly counties

        REAL,    ALLOCATABLE, PUBLIC :: TEPCNTY ( : )   ! episode temps by county
        REAL,    ALLOCATABLE, PUBLIC :: RHEPCNTY( : )   ! episode relative humidity by county
        REAL,    ALLOCATABLE, PUBLIC :: BPEPCNTY( : )   ! episode barometric pressure by county
        INTEGER, ALLOCATABLE, PUBLIC :: EPCODES ( : )   ! FIPS codes for episode counties

!...........   Daily meteorology data
        REAL,    ALLOCATABLE, PUBLIC :: BPDAY( : )      ! average daily barometric pressure by county

        END MODULE MODMET
