import gsl, math, sequtils, numericalnim

type
  IntegrateFunc = proc(x: float): float

proc inner(t, y: float): float =
  result = t * t * t / pow((t * t + y * y), 2)

proc outer(x, w, y: float): float =
  let coeff = x * exp(-x * x)
  # wrap the inner call to have an `IntegrateFunc` kind
  let fn = proc(x: float, optional: seq[float]): float =
    result = inner(x, y)
  let
    frm = sqrt(x * x + w) - x
    to = sqrt(x * x + w) + x
  let integral = adaptiveGauss(fn, frm, to)
  result = coeff * integral

type
  FnData = ref object
    fn: IntegrateFunc

template wrap(fn: untyped): untyped =
  proc fnimpl(x: cdouble, params: pointer): cdouble {.cdecl.} =
    var fnData = cast[var FnData](params)
    result = cdouble(fnData.fn(x.float))
  fnimpl

proc integrate_qagiu*(fn: IntegrateFunc,
                      lower: float,
                      epsabs = 1e-8,
                      epsrel = 1e-8): float =
  # high level wrapper for `qagiu`
  const someSpace = 1e6.uint # how to determine that?
  var w: ptr gsl_integration_workspace = gsl_integration_workspace_alloc(someSpace)
  var
    res: float
    error: float
    f: gsl_function
  # wrap the user given function
  var fnData = FnData(fn: fn)
  f.function = wrap(fn) #
  #var p = @[1.0, 1.0]
  f.params = addr fnData
  var auxThing = 1e6.uint
  echo gsl_integration_qagiu(addr f, lower.cdouble,
                             epsabs = epsabs,
                             epsrel = epsrel,
                             someSpace,
                             w,
                             addr res,
                             addr error);
  gsl_integration_workspace_free(w)
  echo "Error ", error
  echo "Res ", res
  result = res.float

proc main =

  # Comparison of numericalnim and gsl
  # integrate `outer` frm `0` to `inf`
  # rewrite via
  # int_a^infty dx f(x) = int_0^1 f(a + (1 - t) / t) / t^2
  # in our case a = 0
  # so express by wrapping `outer` in a new proc
  var numNimRes: float
  var gslRes: float
  block:
    let w = 1.0
    let y = 1.0
    let fnToInt = proc(t: float, optional: seq[float]): float =
      echo t
      if t != 0:
        result = outer(x = (1 - t) / t, w = w, y = y) / (t * t)
      else:
        # workaround singularity by adding epsilon
        result = outer(x = (1 - t) / (t + 1e-8), w = w, y = y) / (t * t)
    # and integrate that from 0 to 1
    numNimRes = adaptiveGauss(fnToInt, 0.0, 1.0)
    echo "numNimRes ", numNimRes
  block:
    # via gsl
    echo "NOW !!! \n\n\n"
    let w = 1.0
    let y = 1.0
    # and integrate that from 0 to 1
    let fnToInt = (proc(x: float): float =
                     result = outer(x = x, w = w, y = y))
    gslRes = integrate_qagiu(fnToInt, lower = 0.0)
    echo "gslRes ", gslRes
  doAssert abs(numNimRes - gslRes) < 1e-4

when isMainModule:
  main()
