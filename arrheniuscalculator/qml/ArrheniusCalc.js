.pragma library

// ── Arrhenius calculation logic ───────────────────────────────────────────
// Shared between BasicCalculationView.qml and FunctionCalculationView.qml.
// No Qt / QML imports needed — pure JS.

// ── Constants ─────────────────────────────────────────────────────────────
var GAS_CONSTANT = 8.314462618   // J/(mol·K)

// ── Input parsing ─────────────────────────────────────────────────────────

// Evaluate a simple arithmetic expression (supports +, -, *, /, scientific
// notation and Math.*).  Returns 0.0 on empty input or parse failure.
function parseVal(text) {
    var s = text.trim()
    if (s === "") return 0.0
    try {
        var result = Function('"use strict"; return (' + s + ')')()
        var v = Number(result)
        return isFinite(v) ? v : 0.0
    } catch (e) {
        var v2 = parseFloat(s)
        return isNaN(v2) ? 0.0 : v2
    }
}

// Build a JS function(t) from a user-supplied expression string.
// The expression may reference 't' and standard Math functions.
// Returns a callable, or null on parse / sanity-check failure.
function buildTFunc(expr) {
    var s = expr.trim()
    if (s === "") return null
    try {
        var f = Function('"use strict"; return function(t) { return (' + s + '); }')()
        var probe = Number(f(0))
        if (!isFinite(probe)) return null
        return f
    } catch (e) {
        return null
    }
}

// ── Output formatting ─────────────────────────────────────────────────────

// Format a numeric result for display.  Uses exponential notation for very
// large or very small values, otherwise toPrecision(6).
function formatResult(val) {
    if (isNaN(val) || !isFinite(val)) return "—"
    if (Math.abs(val) >= 1e6 || (Math.abs(val) < 1e-3 && val !== 0))
        return val.toExponential(4)
    return val.toPrecision(6)
}

// ── Basic Arrhenius (single time-step) ────────────────────────────────────

// Ω = A · exp(−Ea / (R · T)) · Δt
function calcOmegaBasic(A, Ea, T, dt) {
    if (T <= 0) return NaN
    return A * Math.exp(-Ea / (GAS_CONSTANT * T)) * dt
}

// ── Numerical integration (adaptive Simpson's rule) ───────────────────────

// Integrates func(t) from a to b with absolute tolerance tol and a
// maximum recursion depth of maxDepth.
// Returns NaN if func is null or the limits are not finite.
function adaptiveSimpson(func, a, b, tol, maxDepth) {
    if (func === null || !isFinite(a) || !isFinite(b)) return NaN

    function simpsonStep(fa, fm, fb, h) {
        return (h / 6.0) * (fa + 4.0 * fm + fb)
    }

    function recurse(a, b, fa, fm, fb, whole, depth) {
        var m1  = (a + (a + b) / 2.0) / 2.0
        var m2  = ((a + b) / 2.0 + b) / 2.0
        var h   = (b - a) / 2.0
        var fm1 = func(m1)
        var fm2 = func(m2)
        var mid = (a + b) / 2.0
        var left  = simpsonStep(fa,  fm1, fm,  h / 2.0)
        var right = simpsonStep(fm,  fm2, fb,  h / 2.0)
        var delta = left + right - whole
        if (depth >= maxDepth || Math.abs(delta) <= 15.0 * tol)
            return left + right + delta / 15.0
        return recurse(a,   mid, fa,  fm1, fm,  left,  depth + 1) +
               recurse(mid, b,   fm,  fm2, fb,  right, depth + 1)
    }

    var fa  = func(a)
    var fb  = func(b)
    var mid = (a + b) / 2.0
    var fm  = func(mid)
    var h   = b - a
    var whole = simpsonStep(fa, fm, fb, h)
    if (!isFinite(fa) || !isFinite(fb) || !isFinite(fm)) return NaN
    return recurse(a, b, fa, fm, fb, whole, 0)
}

// ── Function Arrhenius (numerical integral) ───────────────────────────────

// Ω = ∫[t1→t2] A · exp(−Ea / (R · T(t))) dt
// Tfunc must be a JS function(t) → temperature in K.
function calcOmegaFunc(A, Ea, Tfunc, t1, t2) {
    if (Tfunc === null || !isFinite(t1) || !isFinite(t2)) return NaN

    var integrand = function(t) {
        var T = Tfunc(t)
        if (T <= 0) return 0.0
        return A * Math.exp(-Ea / (GAS_CONSTANT * T))
    }

    var tol = Math.max(1e-9, Math.abs(t2 - t1) * 1e-7)
    return adaptiveSimpson(integrand, t1, t2, tol, 30)
}

// ── VHS combination ───────────────────────────────────────────────────────

// (1/Ω_vhs)^p = (1/Ω₁)^p + (1/Ω₂)^p
// Returns NaN when either omega is zero / NaN, or p is zero.
function calcOmegaVHS(omega1, omega2, p) {
    if (isNaN(omega1) || isNaN(omega2) ||
        omega1 === 0  || omega2 === 0  || p === 0) return NaN
    var inv = Math.pow(1.0 / omega1, p) +
              Math.pow(1.0 / omega2, p)
    return 1.0 / Math.pow(inv, 1.0 / p)
}
