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

proc testfn(x: cdouble, params: pointer): cdouble {.cdecl.} =
  echo "x ", x

proc integrate_qagiu(fn: IntegrateFunc) =
  var w: ptr gsl_integration_workspace = gsl_integration_workspace_alloc(1e6.uint)
  var
    res: float
    error: float
    f: gsl_function
  f.function = testfn
  var p = @[1.0, 1.0]
  f.params = addr p[0]
  var auxThing = 1e6.uint
  var thing1 = 1e-5
  echo gsl_integration_qagiu(addr f, 0, 1e-5, thing1, auxThing, w, addr res, addr error);
  gsl_integration_workspace_free(w)

test()
