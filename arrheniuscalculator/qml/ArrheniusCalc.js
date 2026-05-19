.pragma library

// ── Arrhenius calculation logic ───────────────────────────────────────────
// Shared between BasicCalculationView.qml, FunctionCalculationView.qml,
// and TextDataCalculationView.qml.
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

// Parse a whitespace/comma/semicolon-separated list of numbers.
// Returns an array of finite numbers; non-parseable tokens are silently skipped.
function parseList(text) {
    var s = text.trim()
    if (s === "") return []
    // Split on any combination of: spaces, tabs, commas, semicolons, pipes
    var tokens = s.split(/[\s,;|]+/)
    var out = []
    for (var i = 0; i < tokens.length; i++) {
        var tok = tokens[i].trim()
        if (tok === "") continue
        var v = Number(tok)
        if (isFinite(v)) out.push(v)
    }
    return out
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

// ── Text-data Arrhenius (discrete sum over paired t/T lists) ─────────────

// Ω = Σᵢ A · exp(−Eₐ / (R · Tᵢ)) · Δtᵢ
//
// where Δtᵢ = tᵢ₊₁ − tᵢ  for i < N−1  (forward difference),
// and the last interval uses the same Δt as the previous step so that
// a single-point list still yields a non-zero contribution.
//
// tList and TList must be JS arrays of numbers with equal length ≥ 1.
// Any step where Tᵢ ≤ 0 contributes zero (consistent with other methods).
// Returns NaN if either list is empty, lengths differ, or A / Ea are not
// finite numbers.
function calcOmegaTextData(A, Ea, tList, TList) {
    if (!isFinite(A) || !isFinite(Ea)) return NaN
    if (!Array.isArray(tList) || !Array.isArray(TList)) return NaN
    var n = tList.length
    if (n === 0 || TList.length !== n) return NaN

    var omega = 0.0
    for (var i = 0; i < n; i++) {
        var T = TList[i]
        if (T <= 0) continue

        // Δt: forward difference, last point reuses previous interval
        var dt
        if (i < n - 1) {
            dt = tList[i + 1] - tList[i]
        } else if (n > 1) {
            dt = tList[n - 1] - tList[n - 2]
        } else {
            dt = 1.0   // single-point fallback: Δt = 1 s
        }

        if (!isFinite(dt)) continue
        omega += A * Math.exp(-Ea / (GAS_CONSTANT * T)) * dt
    }
    return omega
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

// ── Validation helpers ────────────────────────────────────────────────────
// Each function returns { ok: bool, severity: string, message: string }.
// severity is "ok" | "warn" | "error" — maps directly to CalcStatusBar.

// Validate inputs for BasicCalculationView before calling calcOmegaBasic.
function validateBasic(A, Ea, T_K, dt) {
    if (!isFinite(A) || A === 0)
        return { ok: false, severity: "error",
                 message: "A is zero or invalid — enter a non-zero pre-exponential factor." }
    if (!isFinite(Ea))
        return { ok: false, severity: "error",
                 message: "Eₐ is invalid — enter a numeric activation energy." }
    if (!isFinite(T_K) || T_K <= 0)
        return { ok: false, severity: "error",
                 message: "Temperature must be greater than 0 K." }
    if (!isFinite(dt))
        return { ok: false, severity: "error",
                 message: "Δt is invalid — enter a numeric time step." }
    if (dt === 0)
        return { ok: false, severity: "warn",
                 message: "Δt is zero — Ω will be zero regardless of other inputs." }
    return { ok: true, severity: "ok", message: "Calculation successful." }
}

// Validate inputs for FunctionCalculationView before calling calcOmegaFunc.
// rawExpr is the raw string from the T(t) field (for the error message).
function validateFunc(A, Ea, Tfunc, rawExpr, t1, t2) {
    if (!isFinite(A) || A === 0)
        return { ok: false, severity: "error",
                 message: "A is zero or invalid — enter a non-zero pre-exponential factor." }
    if (!isFinite(Ea))
        return { ok: false, severity: "error",
                 message: "Eₐ is invalid — enter a numeric activation energy." }
    if (Tfunc === null)
        return { ok: false, severity: "error",
                 message: "T(t) expression could not be parsed or returned a non-finite value at t = 0. "
                        + "Check the syntax and make sure it returns a valid temperature in K (or °C)." }
    if (!isFinite(t1) || !isFinite(t2))
        return { ok: false, severity: "error",
                 message: "Integration limits t₁ and t₂ must be finite numbers." }
    if (t1 === t2)
        return { ok: false, severity: "warn",
                 message: "t₁ equals t₂ — the integration interval is zero, so Ω = 0." }
    return { ok: true, severity: "ok", message: "Calculation successful." }
}

// Validate inputs for TextDataCalculationView before calling calcOmegaTextData.
// tList and TList are already-parsed JS arrays.
function validateTextData(A, Ea, tList, TList) {
    if (!isFinite(A) || A === 0)
        return { ok: false, severity: "error",
                 message: "A is zero or invalid — enter a non-zero pre-exponential factor." }
    if (!isFinite(Ea))
        return { ok: false, severity: "error",
                 message: "Eₐ is invalid — enter a numeric activation energy." }
    if (tList.length === 0)
        return { ok: false, severity: "error",
                 message: "t list is empty — enter at least one time value." }
    if (TList.length === 0)
        return { ok: false, severity: "error",
                 message: "T list is empty — enter at least one temperature value." }
    if (tList.length !== TList.length)
        return { ok: false, severity: "error",
                 message: "List length mismatch: t has " + tList.length
                        + " value(s), T has " + TList.length
                        + " value(s). Both lists must be the same length." }
    return { ok: true, severity: "ok", message: "Calculation successful." }
}
