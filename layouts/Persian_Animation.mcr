#!MC 1300
# Created by Tecplot 360 build 13.1.0.15185
$!VarSet |MFBD| = '/home/iwf'
$!PICK SETMOUSEMODE
  MOUSEMODE = SELECT
$!PICK SETMOUSEMODE
  MOUSEMODE = SELECT
$!OPENLAYOUT  "/archive/Daily_Archive/layouts/Persian/Persian.lay"
$!READDATASET  '/archive/Daily_Archive/PG-IO/20210523/Persian/Persian.plt'
  READDATAOPTION = NEW
  RESETSTYLE = NO
  INCLUDEGEOM = NO
  INCLUDECUSTOMLABELS = NO
  VARLOADMODE = BYNAME
  ASSIGNSTRANDIDS = YES
  VARNAMELIST = '"X" "Y" "Hs" "Mask" "u" "v"'
$!FIELDMAP [1-96]  CONTOUR{CONTOURTYPE = BOTHLINESANDFLOOD}
$!FIELDMAP [1-96]  VECTOR{ARROWHEADSTYLE = FILLED}
$!FIELDMAP [1-96]  POINTS{IJKSKIP{I = 12}}
$!FIELDMAP [1-96]  POINTS{IJKSKIP{J = 9}}
$!EXPORTSETUP EXPORTFORMAT = PNG
$!EXPORTSETUP IMAGEWIDTH = 1000
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 1
END = 1
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/00.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 7
END = 7
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/06.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 13
END = 13
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/12.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 19
END = 19
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/18.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 25
END = 25
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/24.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 31
END = 31
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/30.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 37
END = 37
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/36.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 43
END = 43
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/42.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 49
END = 49
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/48.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 55
END = 55
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/54.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 61
END = 61
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/60.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 67
END = 67
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/66.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 73
END = 73
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/72.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 79
END = 79
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/78.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 85
END = 85
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/84.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!ANIMATEZONES
ZONEANIMATIONMODE = STEPBYNUMBER
START = 91
END = 91
SKIP = 1
CREATEMOVIEFILE = NO
$!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/20210523/Persian/90.png'
$!EXPORT
EXPORTREGION = CURRENTFRAME
$!RemoveVar |MFBD|
