#lang racket

(require "prover_core.rkt")
(provide convert-expr
         remove-bracketed-expressions
         remove-bracketed-expressions-from-file
         flux-substitute
         generate-lax-friedrichs-scalar-1d
         generate-lax-friedrichs-scalar-1d-second-order
         generate-roe-scalar-1d
         generate-roe-scalar-1d-second-order)

;; Lightweight converter from Racket expressions (expr) into strings representing equivalent C code.
(define (convert-expr expr)
  (match expr
    ;; If expr is a symbol, then convert it directly to a string.
    [(? symbol? symb) (symbol->string symb)]

    ;; If expr is a numerical constant, then convert it directly to a string.
    [(? number? num) (number->string num)]

    ;; If expr is a sum of the form (+ expr1 expr2 ...), then convert it to "(expr1 + expr2 + ...)" in C.
    [`(+ . ,terms)
     (let ([c-terms (map convert-expr terms)])
       (string-append "(" (string-join c-terms " + ") ")"))]
    ;; Likewise for differences.
    [`(- . ,terms)
     (let ([c-terms (map convert-expr terms)])
       (string-append "(" (string-join c-terms " - ") ")"))]

    ;; If expr is a product of the form (* expr1 expr2 ...), then convert it to "(expr1 * expr2 * ...)" in C.
    [`(* . ,terms)
     (let ([c-terms (map convert-expr terms)])
       (string-append "(" (string-join c-terms " * ") ")"))]
    ;; Likewise for quotients.
    [`(/ . ,terms)
     (let ([c-terms (map convert-expr terms)])
       (string-append "(" (string-join c-terms " / ") ")"))]

    ;; If expr is an absolute value of the form (abs expr1), then convert it to "fabs(expr1)" in C.
    [`(abs ,arg)
     (format "fabs(~a)" (convert-expr arg))]

    ;; If expr is a square root of the form (sqrt expr1), then convert it to "sqrt(expr1)" in C.
    [`(sqrt ,arg)
     (format "sqrt(~a)" (convert-expr arg))]

    ;; If expr is a maximum of the form (max expr1 expr2), then convert it to "fmax(expr1, expr2)" in C.
    [`(max ,arg1 ,arg2)
     (format "fmax(~a, ~a)" (convert-expr arg1) (convert-expr arg2))]

    ;; If expr is a maximum of the form (max expr1 expr2 expr2), then convert it to "fmax(expr1, expr2, expr3)" in C.
    [`(max ,arg1 ,arg2 ,arg3)
     (format "fmax3(~a, ~a, ~a)" (convert-expr arg1) (convert-expr arg2) (convert-expr arg3))]

    ;; If expr is a minimum of the form (max expr1 expr2), then convert it to "fmin(expr1, expr2)" in C.
    [`(min ,arg1 ,arg2)
     (format "fmin(~a, ~a)" (convert-expr arg1) (convert-expr arg2))]

    ;; If expr is a minimum of the form (max expr1 expr2 expr2), then convert it to "fmin(expr1, expr2, expr3)" in C.
    [`(min ,arg1 ,arg2 ,arg3)
     (format "fmin3(~a, ~a, ~a)" (convert-expr arg1) (convert-expr arg2) (convert-expr arg3))]

    ;; If expr is a variable assignment of the form (define expr1 expr2), then convert it to "expr1 = expr2" in C.
    [`(define ,arg1 ,arg2)
     (format "~a = ~a" (convert-expr arg1) (convert-expr arg2))]

    ;; If expr is a strict comparison of the form (< expr1 expr2), then convert it to "expr1 < expr2" in C.
    [`(< ,arg1 ,arg2)
     (format "~a < ~a" (convert-expr arg1) (convert-expr arg2))]

    ;; If expr is a comparison of the form (<= expr1 expr2), then convert it to "expr1 <= expr2" in C.
    [`(<= ,arg1 ,arg2)
     (format "~a <= ~a" (convert-expr arg1) (convert-expr arg2))]

    ;; If expr is a strict comparison of the form (> expr1 expr2), then convert it to "expr1 > expr2" in C.
    [`(> ,arg1 ,arg2)
     (format "~a > ~a" (convert-expr arg1) (convert-expr arg2))]

    ;; If expr is a comparison of the form (>= expr1 expr2), then convert it to "expr1 >= expr2" in C.
    [`(>= ,arg1 ,arg2)
     (format "~a >= ~a" (convert-expr arg1) (convert-expr arg2))]

    ;; If expr is an equality comparison of the form (equal? expr1 expr2), then convert it to "expr1 == expr2" in C.
    [`(equal? ,arg1 ,arg2)
     (format "~a == ~a" (convert-expr arg1) (convert-expr arg2))]

    ;; If expr is a conditional of the form [(cond [cond1 expr1] [else expr2])], then convert it to the ternary operator "(cond1) ? expr1 : expr2" in C.
    [`(cond
        [,cond1 ,expr1]
        [else ,expr2])
     (format "(~a) ? ~a : ~a" (convert-expr cond1) (convert-expr expr1) (convert-expr expr2))]))

;; A simple boilerplate function for removing bracketed expressions from strings.
(define (remove-bracketed-expressions str)
  (regexp-replace* #rx"\\[.*?\\]" str ""))

;; A simple boilerplate function for removing bracketed expressions from files.
(define (remove-bracketed-expressions-from-file output-file)
  (define content
    (with-input-from-file output-file
      (lambda ()
        (port->string (current-input-port)))))
  (define cleaned
    (remove-bracketed-expressions content))
  (with-output-to-file output-file #:exists 'replace
    (lambda ()
      (display cleaned))))

(define (flux-substitute flux-expr cons-expr var-name)
  (string-replace flux-expr cons-expr var-name))

;; -------------------------------------------------------------
;; Lax–Friedrichs (Finite-Difference) Solver for a 1D Scalar PDE
;; -------------------------------------------------------------
(define (generate-lax-friedrichs-scalar-1d pde
                                           #:nx [nx 200]
                                           #:x0 [x0 0.0]
                                           #:x1 [x1 2.0]
                                           #:t-final [t-final 1.0]
                                           #:cfl [cfl 0.95]
                                           #:init-func [init-func `(cond
                                                                     [(< x 1.0) 1.0]
                                                                     [else 0.0])])
 "Generate C code that solves the 1D scalar PDE specified by `pde` using the Lax-Friedrichs finite-difference method.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-func`: Racket expression for the initial condition, e.g. piecewise constant."

  (define name (hash-ref pde 'name))
  (define cons-expr (hash-ref pde 'cons-expr))
  (define flux-expr (hash-ref pde 'flux-expr))
  (define max-speed-expr (hash-ref pde 'max-speed-expr))
  (define parameters (hash-ref pde 'parameters))

  (define cons-code (convert-expr cons-expr))
  (define flux-code (convert-expr flux-expr))
  (define max-speed-code (convert-expr max-speed-expr))
  (define init-func-code (convert-expr init-func))

  (define flux-um (flux-substitute flux-code cons-code "um"))
  (define flux-ui (flux-substitute flux-code cons-code "ui"))
  (define flux-up (flux-substitute flux-code cons-code "up"))

  (define max-speed-local (flux-substitute max-speed-code cons-code "u[i]"))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR SCALAR PDE: ~a
// Lax–Friedrichs first-order finite-difference solver for a scalar PDE in 1D.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Additional PDE parameters (if any).
~a

int main() {
  // Spatial domain setup.
  const int nx = ~a;
  const double x0 = ~a;
  const double x1 = ~a;
  const double L = (x1 - x0);
  const double dx = L / nx;

  // Time-stepper setup.
  const double cfl = ~a;
  const double t_final = ~a;

  // Arrays for storing solution.
  double *u = (double*) malloc((nx + 2) * sizeof(double));
  double *un = (double*) malloc((nx + 2) * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    double x = x0 + (i - 0.5) * dx;
    
    u[i] = ~a; // init-func in C.
    un[i] = ~a; // init-func in C.
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 1; i <= nx; i++) {
      double local_alpha = ~a; // max-speed-expr in C.
      
      if (local_alpha > alpha) {
        alpha = local_alpha;
      }
    }

    // Avoid division by zero.
    if (alpha < 1e-14) {
      alpha = 1e-14;
    }

    // Compute stable time step from alpha.
    double dt = cfl * dx / alpha;

    // If stepping beyond t_final, adjust dt accordingly.
    if (t + dt > t_final) {
      dt = t_final - t;
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable.
    for (int i = 1; i <= nx; i++) {
      double um = u[i - 1];
      double ui = u[i];
      double up = u[i + 1];

      // Evaluate flux for each value of the conserved variable.
      double f_um = ~a; // f(u_{i - 1}).
      double f_ui = ~a; // f(u_i).
      double f_up = ~a; // f(u_{i + 1}).

      // Left interface flux: F_{i - 1/2} = 0.5 * (f(u_{i - 1}) + f(u_i)) - 0.5 * alpha * (u_i - u_{i - 1}).
      double fluxL = 0.5 * (f_um + f_ui) - 0.5 * alpha * (ui - um);

      // Right interface flux: F_{i + 1/2} = 0.5 * (f(u_{i + 1}) + f(u_i)) - 0.5 * alpha * (u_{i + 1} - u_i).
      double fluxR = 0.5 * (f_ui + f_up) - 0.5 * alpha * (up - ui);

      // Update the conserved variable.
      un[i] = ui - (dt / dx) * (fluxR - fluxL);
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 1; i++) {
      u[i] = un[i];
    }

    // Apply simple boundary conditions (transmissive).
    u[0] = u[1];
    u[nx + 1] = u[nx];

    // Output solution to disk.
    const char *fmt = \"%s_output_%d.csv\";
    int sz = snprintf(0, 0, fmt, \"~a\", n);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", n);
    
    FILE *fptr = fopen(file_nm, \"w\");
    if (fptr != NULL) {
      for (int i = 1; i <= nx; i++) {
        double x = x0 + (i - 0.5) * dx;
        fprintf(fptr, \"%f, %f\\n\", x, u[i]);
      }

      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(un);
   
  return 0;
}
"
           ;; PDE name for code comments.
           name
           ;; Additional PDE parameters (e.g. a = 1.0 for linear advection).
           parameter-code
           ;; Number of cells.
           nx
           ;; Left boundary.
           x0
           ;; Right boundary.
           x1
           ;; CFL coefficient.
           cfl
           ;; Final time.
           t-final
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           init-func-code
           init-func-code
           ;; Expression for local wave-speed estimate.
           max-speed-local
           ;; Left flux f(u_{i - 1}).
           flux-um
           ;; Middle flux f(u_i).
           flux-ui
           ;; Right flux f(u_{i + 1}).
           flux-up
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ----------------------------------------------------------------------------------------------------
;; Lax–Friedrichs (Finite-Difference) Solver for a 1D Scalar PDE with a Second-Order Flux Extrapolation
;; ----------------------------------------------------------------------------------------------------
(define (generate-lax-friedrichs-scalar-1d-second-order pde limiter
                                                        #:nx [nx 200]
                                                        #:x0 [x0 0.0]
                                                        #:x1 [x1 2.0]
                                                        #:t-final [t-final 1.0]
                                                        #:cfl [cfl 0.95]
                                                        #:init-func [init-func `(cond
                                                                                  [(< x 1.0) 1.0]
                                                                                  [else 0.0])])
 "Generate C code that solves the 1D scalar PDE specified by `pde` using the Lax-Friedrichs finite-difference method with a second-order flux extrapolation using flux limiter `limiter`.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-func`: Racket expression for the initial condition, e.g. piecewise constant."

  (define name (hash-ref pde 'name))
  (define cons-expr (hash-ref pde 'cons-expr))
  (define flux-expr (hash-ref pde 'flux-expr))
  (define max-speed-expr (hash-ref pde 'max-speed-expr))
  (define parameters (hash-ref pde 'parameters))

  (define limiter-name (hash-ref limiter 'name))
  (define limiter-expr (hash-ref limiter 'limiter-expr))
  (define limiter-ratio (hash-ref limiter 'limiter-ratio))

  (define limiter-code (convert-expr limiter-expr))
  (define limiter-ratio-code (convert-expr limiter-ratio))

  (define cons-code (convert-expr cons-expr))
  (define flux-code (convert-expr flux-expr))
  (define max-speed-code (convert-expr max-speed-expr))
  (define init-func-code (convert-expr init-func))

  (define limiter-r (flux-substitute limiter-code limiter-ratio-code "r"))

  (define flux-umL (flux-substitute flux-code cons-code "umL"))
  (define flux-umR (flux-substitute flux-code cons-code "umR"))
  (define flux-uiL (flux-substitute flux-code cons-code "uiL"))
  (define flux-uiR (flux-substitute flux-code cons-code "uiR"))
  (define flux-upL (flux-substitute flux-code cons-code "upL"))
  (define flux-upR (flux-substitute flux-code cons-code "upR"))

  (define flux-umR-evol (flux-substitute flux-code cons-code "umR_evol"))
  (define flux-uiL-evol (flux-substitute flux-code cons-code "uiL_evol"))
  (define flux-uiR-evol (flux-substitute flux-code cons-code "uiR_evol"))
  (define flux-upL-evol (flux-substitute flux-code cons-code "upL_evol"))

  (define max-speed-local (flux-substitute max-speed-code cons-code "u[i]"))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR SCALAR PDE: ~a
// FLUX LIMITER: ~a
// Lax–Friedrichs first-order finite-difference solver for a scalar PDE in 1D, with a second-order flux extrapolation.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Additional PDE parameters (if any).
~a

int main() {
  // Spatial domain setup.
  const int nx = ~a;
  const double x0 = ~a;
  const double x1 = ~a;
  const double L = (x1 - x0);
  const double dx = L / nx;

  // Time-stepper setup.
  const double cfl = ~a;
  const double t_final = ~a;

  // Array for storing slopes.
  double *slope = (double*) malloc((nx + 4) * sizeof(double));

  // Arrays for storing solution.
  double *u = (double*) malloc((nx + 4) * sizeof(double));
  double *un = (double*) malloc((nx + 4) * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    double x = x0 + (i - 1.5) * dx;
    
    u[i] = ~a; // init-func in C.
    un[i] = ~a; // init-func in C.
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 2; i <= nx + 1; i++) {
      double local_alpha = ~a; // max-speed-expr in C.
      
      if (local_alpha > alpha) {
        alpha = local_alpha;
      }
    }

    // Avoid division by zero.
    if (alpha < 1e-14) {
      alpha = 1e-14;
    }

    // Compute stable time step from alpha.
    double dt = cfl * dx / alpha;

    // If stepping beyond t_final, adjust dt accordingly.
    if (t + dt > t_final) {
      dt = t_final - t;
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      double r = (u[i] - u[i - 1]) / (u[i + 1] - u[i]);
      double limiter = ~a; // limiter-r in C.

      slope[i] = limiter * (0.5 * ((u[i] - u[i - 1]) + (u[i + 1] - u[i])));
    }

    // Compute fluxes with Lax-Friedrichs approximation (with a second-order flux extrapolation) and update the conserved variable.
    for (int i = 2; i <= nx + 1; i++) {
      // Extrapolate boundary states.
      double umL = u[i - 1] - (0.5 * slope[i - 1]);
      double umR = u[i - 1] + (0.5 * slope[i - 1]);

      double uiL = u[i] - (0.5 * slope[i]);
      double uiR = u[i] + (0.5 * slope[i]);

      double upL = u[i + 1] - (0.5 * slope[i + 1]);
      double upR = u[i + 1] + (0.5 * slope[i + 1]);

      // Evaluate flux for each extrapolated boundary state.
      double f_umL = ~a;
      double f_umR = ~a;

      double f_uiL = ~a;
      double f_uiR = ~a;

      double f_upL = ~a;
      double f_upR = ~a;

      // Evolve each extrapolated boundary state.
      double umR_evol = umR + ((dt / (2.0 * dx)) * (f_umL - f_umR));

      double uiL_evol = uiL + ((dt / (2.0 * dx)) * (f_uiL - f_uiR));
      double uiR_evol = uiR + ((dt / (2.0 * dx)) * (f_uiL - f_uiR));

      double upL_evol = upL + ((dt / (2.0 * dx)) * (f_upL - f_upR));

      // Evaluate flux for each value of the (evolved) conserved variable.
      double f_umR_evol = ~a;
      double f_uiL_evol = ~a;

      double f_uiR_evol = ~a;
      double f_upL_evol = ~a;

      // Left interface flux: F_{i - 1/2} = 0.5 * (f(u_{i - 1, R+}) + f(u_{i, L+})) - 0.5 * alpha * (u_{i, L+} - u_{i - 1, R+}).
      double fluxL = 0.5 * (f_umR_evol + f_uiL_evol) - 0.5 * alpha * (uiL_evol - umR_evol);

      // Right interface flux: F_{i + 1/2} = 0.5 * (f(u_{i + 1, L+}) + f(u_{i, R+})) - 0.5 * alpha * (u_{i + 1, L+} - u_{i, R+}).
      double fluxR = 0.5 * (f_uiR_evol + f_upL_evol) - 0.5 * alpha * (upL_evol - uiR_evol);

      // Update the conserved variable.
      un[i] = u[i] - (dt / dx) * (fluxR - fluxL);
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 3; i++) {
      u[i] = un[i];
    }

    // Apply simple boundary conditions (transmissive).
    u[0] = u[2];
    u[1] = u[2];
    u[nx + 2] = u[nx + 1];
    u[nx + 3] = u[nx + 1];

    // Output solution to disk.
    const char *fmt = \"%s_output_%d.csv\";
    int sz = snprintf(0, 0, fmt, \"~a\", n);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", n);
    
    FILE *fptr = fopen(file_nm, \"w\");
    if (fptr != NULL) {
      for (int i = 2; i <= nx + 1; i++) {
        double x = x0 + (i - 1.5) * dx;
        fprintf(fptr, \"%f, %f\\n\", x, u[i]);
      }

      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(un);
  free(slope);
   
  return 0;
}
"
           ;; PDE name for code comments.
           name
           ;; Flux limiter name for code comments.
           limiter-name
           ;; Additional PDE parameters (e.g. a = 1.0 for linear advection).
           parameter-code
           ;; Number of cells.
           nx
           ;; Left boundary.
           x0
           ;; Right boundary.
           x1
           ;; CFL coefficient.
           cfl
           ;; Final time.
           t-final
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           init-func-code
           init-func-code
           ;; Expression for local wave-speed estimate.
           max-speed-local
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left negative flux f(u_{i - 1, L}).
           flux-umL
           ;; Right negative flux f(u_{i - 1, R}).
           flux-umR
           ;; Left central flux f(u_{i, L}).
           flux-uiL
           ;; Right central flux f(u_{i, R}).
           flux-uiR
           ;; Left positive flux f(u_{i + 1, L}).
           flux-upL
           ;; Right positive flux f(u_{i + 1, R}).
           flux-upR
           ;; Evolved right negative flux f(u_{i - 1, R+}).
           flux-umR-evol
           ;; Evolved left central flux f(u_{i, L+}).
           flux-uiL-evol
           ;; Evolved right central flux f(u_{i, R+}).
           flux-uiR-evol
           ;; Evolved left positive flux f(u_{i + 1, L+}).
           flux-upL-evol
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ----------------------------------------------
;; Roe (Finite-Volume) Solver for a 1D Scalar PDE
;; ----------------------------------------------
(define (generate-roe-scalar-1d pde
                                #:nx [nx 200]
                                #:x0 [x0 0.0]
                                #:x1 [x1 2.0]
                                #:t-final [t-final 1.0]
                                #:cfl [cfl 0.95]
                                #:init-func [init-func `(cond
                                                          [(< x 1.0) 1.0]
                                                          [else 0.0])])
 "Generate C code that solves the 1D scalar PDE specified by `pde` using the Roe finite-volume method.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-func`: Racket expression for the initial condition, e.g. piecewise constant."

  (define name (hash-ref pde 'name))
  (define cons-expr (hash-ref pde 'cons-expr))
  (define flux-expr (hash-ref pde 'flux-expr))
  (define max-speed-expr (hash-ref pde 'max-speed-expr))
  (define parameters (hash-ref pde 'parameters))

  (define flux-deriv (symbolic-simp (symbolic-diff flux-expr cons-expr)))

  (define cons-code (convert-expr cons-expr))
  (define flux-code (convert-expr flux-expr))
  (define flux-deriv-code (convert-expr flux-deriv))
  (define max-speed-code (convert-expr max-speed-expr))
  (define init-func-code (convert-expr init-func))

  (define flux-um (flux-substitute flux-code cons-code "um"))
  (define flux-ui (flux-substitute flux-code cons-code "ui"))
  (define flux-up (flux-substitute flux-code cons-code "up"))

  (define flux-deriv-um (flux-substitute flux-deriv-code cons-code "um"))
  (define flux-deriv-ui (flux-substitute flux-deriv-code cons-code "ui"))
  (define flux-deriv-up (flux-substitute flux-deriv-code cons-code "up"))

  (define max-speed-local (flux-substitute max-speed-code cons-code "u[i]"))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR SCALAR PDE: ~a
// Roe higher-order finite-volume solver for a scalar PDE in 1D.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Additional PDE parameters (if any).
~a

int main() {
  // Spatial domain setup.
  const int nx = ~a;
  const double x0 = ~a;
  const double x1 = ~a;
  const double L = (x1 - x0);
  const double dx = L / nx;

  // Time-stepper setup.
  const double cfl = ~a;
  const double t_final = ~a;

  // Arrays for storing solution.
  double *u = (double*) malloc((nx + 2) * sizeof(double));
  double *un = (double*) malloc((nx + 2) * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    double x = x0 + (i - 0.5) * dx;
    
    u[i] = ~a; // init-func in C.
    un[i] = ~a; // init-func in C.
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 1; i <= nx; i++) {
      double local_alpha = ~a; // max-speed-expr in C.
      
      if (local_alpha > alpha) {
        alpha = local_alpha;
      }
    }

    // Avoid division by zero.
    if (alpha < 1e-14) {
      alpha = 1e-14;
    }

    // Compute stable time step from alpha.
    double dt = cfl * dx / alpha;

    // If stepping beyond t_final, adjust dt accordingly.
    if (t + dt > t_final) {
      dt = t_final - t;
    }

    // Compute fluxes with Roe approximation and update the conserved variable.
    for (int i = 1; i <= nx; i++) {
      double um = u[i - 1];
      double ui = u[i];
      double up = u[i + 1];

      // Evaluate flux for each value of the conserved variable.
      double f_um = ~a; // f(u_{i - 1}).
      double f_ui = ~a; // f(u_i).
      double f_up = ~a; // f(u_{i + 1}).

      // Evaluate flux derivative for each value of the conserved variable.
      double f_deriv_um = ~a; // f'(u_{i - 1}).
      double f_deriv_ui = ~a; // f'(u_i).
      double f_deriv_up = ~a; // f'(u_{i + 1}).

      // Left interface flux: F_{i - 1/2} = 0.5 * (f(u_{i - 1}) + f(u_i)) - 0.5 * |aL_roe| * (u_i - u_{i - 1}).
      double aL_roe = 0.5 * (f_deriv_um + f_deriv_ui);
      double fluxL = 0.5 * (f_um + f_ui) - 0.5 * fabs(aL_roe) * (ui - um);

      // Right interface flux: F_{i + 1/2} = 0.5 * (f(u_{i + 1}) + f(u_i)) - 0.5 * |aR_roe| * (u_{i + 1} - u_i).
      double aR_roe = 0.5 * (f_deriv_ui + f_deriv_up);
      double fluxR = 0.5 * (f_ui + f_up) - 0.5 * fabs(aR_roe) * (up - ui);

      // Update the conserved variable.
      un[i] = ui - (dt / dx) * (fluxR - fluxL);
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 1; i++) {
      u[i] = un[i];
    }

    // Apply simple boundary conditions (transmissive).
    u[0] = u[1];
    u[nx + 1] = u[nx];

    // Output solution to disk.
    const char *fmt = \"%s_output_%d.csv\";
    int sz = snprintf(0, 0, fmt, \"~a\", n);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", n);
    
    FILE *fptr = fopen(file_nm, \"w\");
    if (fptr != NULL) {
      for (int i = 1; i <= nx; i++) {
        double x = x0 + (i - 0.5) * dx;
        fprintf(fptr, \"%f, %f\\n\", x, u[i]);
      }

      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(un);
   
  return 0;
}
"
           ;; PDE name for code comments.
           name
           ;; Additional PDE parameters (e.g. a = 1.0 for linear advection).
           parameter-code
           ;; Number of cells.
           nx
           ;; Left boundary.
           x0
           ;; Right boundary.
           x1
           ;; CFL coefficient.
           cfl
           ;; Final time.
           t-final
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           init-func-code
           init-func-code
           ;; Expression for local wave-speed estimate.
           max-speed-local
           ;; Left flux f(u_{i - 1}).
           flux-um
           ;; Middle flux f(u_i).
           flux-ui
           ;; Right flux f(u_{i + 1}).
           flux-up
           ;; Left flux derivative f'(u_{i - 1}).
           flux-deriv-um
           ;; Middle flux derivative f'(u_i).
           flux-deriv-ui
           ;; Right flux derivative f'(u_{i + 1}).
           flux-deriv-up
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; -------------------------------------------------------------------------------------
;; Roe (Finite-Volume) Solver for a 1D Scalar PDE with a Second-Order Flux Extrapolation
;; -------------------------------------------------------------------------------------
(define (generate-roe-scalar-1d-second-order pde limiter
                                             #:nx [nx 200]
                                             #:x0 [x0 0.0]
                                             #:x1 [x1 2.0]
                                             #:t-final [t-final 1.0]
                                             #:cfl [cfl 0.95]
                                             #:init-func [init-func `(cond
                                                                       [(< x 1.0) 1.0]
                                                                       [else 0.0])])
 "Generate C code that solves the 1D scalar PDE specified by `pde` using the Roe finite-volume method with a second-order flux extrapolation using flux limiter `limiter`.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-func`: Racket expression for the initial condition, e.g. piecewise constant."

  (define name (hash-ref pde 'name))
  (define cons-expr (hash-ref pde 'cons-expr))
  (define flux-expr (hash-ref pde 'flux-expr))
  (define max-speed-expr (hash-ref pde 'max-speed-expr))
  (define parameters (hash-ref pde 'parameters))

  (define limiter-name (hash-ref limiter 'name))
  (define limiter-expr (hash-ref limiter 'limiter-expr))
  (define limiter-ratio (hash-ref limiter 'limiter-ratio))

  (define limiter-code (convert-expr limiter-expr))
  (define limiter-ratio-code (convert-expr limiter-ratio))

  (define flux-deriv (symbolic-simp (symbolic-diff flux-expr cons-expr)))

  (define cons-code (convert-expr cons-expr))
  (define flux-code (convert-expr flux-expr))
  (define flux-deriv-code (convert-expr flux-deriv))
  (define max-speed-code (convert-expr max-speed-expr))
  (define init-func-code (convert-expr init-func))

  (define limiter-r (flux-substitute limiter-code limiter-ratio-code "r"))

  (define flux-umL (flux-substitute flux-code cons-code "umL"))
  (define flux-umR (flux-substitute flux-code cons-code "umR"))
  (define flux-uiL (flux-substitute flux-code cons-code "uiL"))
  (define flux-uiR (flux-substitute flux-code cons-code "uiR"))
  (define flux-upL (flux-substitute flux-code cons-code "upL"))
  (define flux-upR (flux-substitute flux-code cons-code "upR"))

  (define flux-umR-evol (flux-substitute flux-code cons-code "umR_evol"))
  (define flux-uiL-evol (flux-substitute flux-code cons-code "uiL_evol"))
  (define flux-uiR-evol (flux-substitute flux-code cons-code "uiR_evol"))
  (define flux-upL-evol (flux-substitute flux-code cons-code "upL_evol"))

  (define flux-deriv-umR-evol (flux-substitute flux-deriv-code cons-code "umR_evol"))
  (define flux-deriv-uiL-evol (flux-substitute flux-deriv-code cons-code "uiL_evol"))
  (define flux-deriv-uiR-evol (flux-substitute flux-deriv-code cons-code "uiR_evol"))
  (define flux-deriv-upL-evol (flux-substitute flux-deriv-code cons-code "upL_evol"))

  (define max-speed-local (flux-substitute max-speed-code cons-code "u[i]"))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR SCALAR PDE: ~a
// FLUX LIMITER: ~a
// Roe higher-order finite-volume solver for a scalar PDE in 1D, with a second-order flux extrapolation.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Additional PDE parameters (if any).
~a

int main() {
  // Spatial domain setup.
  const int nx = ~a;
  const double x0 = ~a;
  const double x1 = ~a;
  const double L = (x1 - x0);
  const double dx = L / nx;

  // Time-stepper setup.
  const double cfl = ~a;
  const double t_final = ~a;

  // Array for storing slopes.
  double *slope = (double*) malloc((nx + 4) * sizeof(double));
  
  // Arrays for storing solution.
  double *u = (double*) malloc((nx + 4) * sizeof(double));
  double *un = (double*) malloc((nx + 4) * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    double x = x0 + (i - 1.5) * dx;
    
    u[i] = ~a; // init-func in C.
    un[i] = ~a; // init-func in C.
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 2; i <= nx + 1; i++) {
      double local_alpha = ~a; // max-speed-expr in C.
      
      if (local_alpha > alpha) {
        alpha = local_alpha;
      }
    }

    // Avoid division by zero.
    if (alpha < 1e-14) {
      alpha = 1e-14;
    }

    // Compute stable time step from alpha.
    double dt = cfl * dx / alpha;

    // If stepping beyond t_final, adjust dt accordingly.
    if (t + dt > t_final) {
      dt = t_final - t;
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      double r = (u[i] - u[i - 1]) / (u[i + 1] - u[i]);
      double limiter = ~a; // limiter-r in C.

      slope[i] = limiter * (0.5 * ((u[i] - u[i - 1]) + (u[i + 1] - u[i])));
    }

    // Compute fluxes with Roe approximation (with a second-order flux extrapolation) and update the conserved variable.
    for (int i = 2; i <= nx + 1; i++) {
      // Extrapolate boundary states.
      double umL = u[i - 1] - (0.5 * slope[i - 1]);
      double umR = u[i - 1] + (0.5 * slope[i - 1]);

      double uiL = u[i] - (0.5 * slope[i]);
      double uiR = u[i] + (0.5 * slope[i]);

      double upL = u[i + 1] - (0.5 * slope[i + 1]);
      double upR = u[i + 1] + (0.5 * slope[i + 1]);

      // Evaluate flux for each extrapolated boundary state.
      double f_umL = ~a;
      double f_umR = ~a;

      double f_uiL = ~a;
      double f_uiR = ~a;

      double f_upL = ~a;
      double f_upR = ~a;

      // Evolve each extrapolated boundary state.
      double umR_evol = umR + ((dt / (2.0 * dx)) * (f_umL - f_umR));

      double uiL_evol = uiL + ((dt / (2.0 * dx)) * (f_uiL - f_uiR));
      double uiR_evol = uiR + ((dt / (2.0 * dx)) * (f_uiL - f_uiR));

      double upL_evol = upL + ((dt / (2.0 * dx)) * (f_upL - f_upR));

      // Evaluate flux for each value of the (evolved) conserved variable.
      double f_umR_evol = ~a;
      double f_uiL_evol = ~a;

      double f_uiR_evol = ~a;
      double f_upL_evol = ~a;

      // Evaluate flux derivative for each value of the (evolved) conserved variable.
      double f_deriv_umR_evol = ~a;
      double f_deriv_uiL_evol = ~a;

      double f_deriv_uiR_evol = ~a;
      double f_deriv_upL_evol = ~a;

      // Left interface flux: F_{i - 1/2} = 0.5 * (f(u_{i - 1, R+}) + f(u_{i, L+})) - 0.5 * |aL_roe| * (u_{i, L+} - u_{i - 1, R+}).
      double aL_roe = 0.5 * (f_deriv_umR_evol + f_deriv_uiL_evol);
      double fluxL = 0.5 * (f_umR_evol + f_uiL_evol) - 0.5 * fabs(aL_roe) * (uiL_evol - umR_evol);

      // Right interface flux: F_{i + 1/2} = 0.5 * (f(u_{i + 1, L+}) + f(u_{i, R+})) - 0.5 * |aR_roe| * (u_{i + 1, L+} - u_{i, R+}).
      double aR_roe = 0.5 * (f_deriv_uiR_evol + f_deriv_upL_evol);
      double fluxR = 0.5 * (f_uiR_evol + f_upL_evol) - 0.5 * fabs(aR_roe) * (upL_evol - uiR_evol);

      // Update the conserved variable.
      un[i] = u[i] - (dt / dx) * (fluxR - fluxL);
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 3; i++) {
      u[i] = un[i];
    }

    // Apply simple boundary conditions (transmissive).
    u[0] = u[2];
    u[1] = u[2];
    u[nx + 2] = u[nx + 1];
    u[nx + 3] = u[nx + 1];

    // Output solution to disk.
    const char *fmt = \"%s_output_%d.csv\";
    int sz = snprintf(0, 0, fmt, \"~a\", n);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", n);
    
    FILE *fptr = fopen(file_nm, \"w\");
    if (fptr != NULL) {
      for (int i = 2; i <= nx + 1; i++) {
        double x = x0 + (i - 1.5) * dx;
        fprintf(fptr, \"%f, %f\\n\", x, u[i]);
      }

      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(un);
  free(slope);
   
  return 0;
}
"
           ;; PDE name for code comments.
           name
           ;; Flux limiter name for code comments.
           limiter-name
           ;; Additional PDE parameters (e.g. a = 1.0 for linear advection).
           parameter-code
           ;; Number of cells.
           nx
           ;; Left boundary.
           x0
           ;; Right boundary.
           x1
           ;; CFL coefficient.
           cfl
           ;; Final time.
           t-final
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           init-func-code
           init-func-code
           ;; Expression for local wave-speed estimate.
           max-speed-local
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left negative flux f(u_{i - 1, L}).
           flux-umL
           ;; Right negative flux f(u_{i - 1, R}).
           flux-umR
           ;; Left central flux f(u_{i, L}).
           flux-uiL
           ;; Right central flux f(u_{i, R}).
           flux-uiR
           ;; Left positive flux f(u_{i + 1, L}).
           flux-upL
           ;; Right positive flux f(u_{i + 1, R}).
           flux-upR
           ;; Evolved right negative flux f(u_{i - 1, R+}).
           flux-umR-evol
           ;; Evolved left central flux f(u_{i, L+}).
           flux-uiL-evol
           ;; Evolved right central flux f(u_{i, R+}).
           flux-uiR-evol
           ;; Evolved left positive flux f(u_{i + 1, L+}).
           flux-upL-evol
           ;; Evolved right negative flux derivative f'(u_{i - 1, R+}).
           flux-deriv-umR-evol
           ;; Evolved left central flux derivative f'(u_{i, L+}).
           flux-deriv-uiL-evol
           ;; Evolved right central flux derivative f'(u_{i, R+}).
           flux-deriv-uiR-evol
           ;; Evolved left positive flux derivative f'(u_{i + 1, L+}).
           flux-deriv-upL-evol
           ;; PDE name for file output.
           name
           name
           ))
  code)