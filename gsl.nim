import strutils, os
import nimterop / cimport

static:
  cDebug()

const
  cSourcesPath* = currentSourcePath.parentDir() / "gsl"
  #baseDir = GslCacheDir
  #srcDir = baseDir / "gsl"
  #buildDir = srcDir / "buildcache"
  #includeDir = srcDir / "include"

const dlurl = "https://github.com/ampl/gsl"

{.passL: "-lgsl -lm -lcblas".}
# {.passC: "-fobjc-arc -fmodules -x objective-c".}

#getHeader(
#  "gsl.h",
#  dlurl = dlurl,
#  outdir = srcDir,
#  altNames = "GSL"
#)


cIncludeDir(cSourcesPath)

cOverride:
  type
    gsl_function_vec_struct {.importc: "gsl_function_vec", header: cSourcesPath / "gsl_math.h".} = object

#cImport(cSourcesPath / "config.h.in")
cImport(cSourcesPath / "gsl_math.h")
cImport(cSourcesPath / "integration/gsl_integration.h")

#cCompile(cSourcesPath / "integration/*.c")
