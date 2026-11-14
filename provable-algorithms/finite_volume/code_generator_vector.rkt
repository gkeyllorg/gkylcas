#lang racket

(require "prover_core.rkt")
(require "prover_vector.rkt")
(require "code_generator_core.rkt")
(provide generate-lax-friedrichs-vector2-1d
         generate-lax-friedrichs-vector2-1d-second-order
         generate-roe-vector2-1d
         generate-roe-vector2-1d-second-order)

;; ----------------------------------------------------------------------------------
;; Lax–Friedrichs (Finite-Difference) Solver for a 1D Coupled Vector System of 2 PDEs
;; ----------------------------------------------------------------------------------
(define (generate-lax-friedrichs-vector2-1d pde-system
                                            #:nx [nx 200]
                                            #:x0 [x0 0.0]
                                            #:x1 [x1 2.0]
                                            #:t-final [t-final 1.0]
                                            #:cfl [cfl 0.95]
                                            #:init-funcs [init-funcs (list
                                                                      `(cond
                                                                         [(< x 0.5) 3.0]
                                                                         [else 1.0])
                                                                      `(cond
                                                                         [(< x 0.5) 1.5]
                                                                         [else 0.0]))])
 "Generate C code that solves the 1D coupled vector system of 2 PDEs specified by `pde-system` using the Lax-Friedrichs finite-difference method.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define max-speed-exprs (hash-ref pde-system 'max-speed-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes (map (lambda (flux-expr)
                            (convert-expr flux-expr)) flux-exprs))
  (define max-speed-codes (map (lambda (max-speed-expr)
                                 (convert-expr max-speed-expr)) max-speed-exprs))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define flux-ums (map (lambda (flux-code)
                          (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "um[0]")
                                           (list-ref cons-codes 1) "um[1]")) flux-codes))
  (define flux-uis (map (lambda (flux-code)
                          (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "ui[0]")
                                           (list-ref cons-codes 1) "ui[1]")) flux-codes))
  (define flux-ups (map (lambda (flux-code)
                          (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "up[0]")
                                           (list-ref cons-codes 1) "up[1]")) flux-codes))
  
  (define max-speed-locals (map (lambda (max-speed-code)
                                  (flux-substitute (flux-substitute max-speed-code (list-ref cons-codes 0) "u[(i * 2) + 0]")
                                                   (list-ref cons-codes 1) "u[(i * 2) + 1]")) max-speed-codes))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR COUPLED VECTOR PDE SYSTEM: ~a
// Lax–Friedrichs first-order finite-difference solver for a coupled vector system of 2 PDEs in 1D.

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
  double *u = (double*) malloc((nx + 2) * 2 * sizeof(double));
  double *un = (double*) malloc((nx + 2) * 2 * sizeof(double));

  // Arrays for storing other intermediate values.
  double *local_alpha = (double*) malloc(2 * sizeof(double));
  
  double *um = (double*) malloc(2 * sizeof(double));
  double *ui = (double*) malloc(2 * sizeof(double));
  double *up = (double*) malloc(2 * sizeof(double));

  double *f_um = (double*) malloc(2 * sizeof(double));
  double *f_ui = (double*) malloc(2 * sizeof(double));
  double *f_up = (double*) malloc(2 * sizeof(double));

  double *fluxL = (double*) malloc(2 * sizeof(double));
  double *fluxR = (double*) malloc(2 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    double x = x0 + (i - 0.5) * dx;
    
    u[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    u[(i * 2) + 1] = ~a; // init-funcs[1] in C.
    un[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    un[(i * 2) + 1] = ~a; // init-funcs[1] in C.
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 1; i <= nx; i++) {
      local_alpha[0] = ~a; // max-speed-exprs[0] in C.
      local_alpha[1] = ~a; // max-speed-exprs[1] in C.
      
      for (int j = 0; j < 2; j++) {
        if (local_alpha[j] > alpha) {
          alpha = local_alpha[j];
        }
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

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector.
    for (int i = 1; i <= nx; i++) {
      for (int j = 0; j < 2; j++) {
        um[j] = u[((i - 1) * 2) + j];
        ui[j] = u[(i * 2) + j];
        up[j] = u[((i + 1) * 2) + j];
      }

      // Evaluate flux vector for each value of the conserved variable vector.
      f_um[0] = ~a;
      f_um[1] = ~a; // F(U_{i - 1}).
      
      f_ui[0] = ~a;
      f_ui[1] = ~a; // F(U_i).
      
      f_up[0] = ~a;
      f_up[1] = ~a; // F(U_{i + 1}).

      // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1}) + F(U_i)) - 0.5 * alpha * (U_i - U_{i - 1}).
      for (int j = 0; j < 2; j++) {
        fluxL[j] = 0.5 * (f_um[j] + f_ui[j]) - 0.5 * alpha * (ui[j] - um[j]);
      }

      // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1}) + F(U_i)) - 0.5 * alpha * (U_{i + 1} - U_i).
      for (int j = 0; j < 2; j++) {
        fluxR[j] = 0.5 * (f_ui[j] + f_up[j]) - 0.5 * alpha * (up[j] - ui[j]);
      }

      // Update the conserved variable vector.
      for (int j = 0; j < 2; j++) {
        un[(i * 2) + j] = ui[j] - (dt / dx) * (fluxR[j] - fluxL[j]);
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j < 2; j++) {
        u[(i * 2) + j] = un[(i * 2) + j];
      }
    }

    // Apply simple boundary conditions (transmissive).
    for (int j = 0; j < 2; j++) {
      u[(0 * 2) + j] = u[(1 * 2) + j];
      u[((nx + 1) * 2) + j] = u[(nx * 2) + j];
    }

    // Output solution to disk.
    for (int j = 0; j < 2; j++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", j, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", j, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 1; i <= nx; i++) {
          double x = x0 + (i - 0.5) * dx;
          fprintf(fptr, \"%f, %f\\n\", x, u[(i * 2) + j]);
        }

        fclose(fptr);
      }
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(un);

  free(local_alpha);
  
  free(um);
  free(ui);
  free(up);

  free(f_um);
  free(f_ui);
  free(f_up);

  free(fluxL);
  free(fluxR);
  
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
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals 0)
           (list-ref max-speed-locals 1)
           ;; Left flux vector F(u_{i - 1}).
           (list-ref flux-ums 0)
           (list-ref flux-ums 1)
           ;; Middle flux vector F(u_i).
           (list-ref flux-uis 0)
           (list-ref flux-uis 1)
           ;; Right flux vector F(u_{i + 1}).
           (list-ref flux-ups 0)
           (list-ref flux-ups 1)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; -------------------------------------------------------------------------------------------------------------------------
;; Lax–Friedrichs (Finite-Difference) Solver for a 1D Coupled Vector System of 2 PDEs with a Second-Order Flux Extrapolation
;; -------------------------------------------------------------------------------------------------------------------------
(define (generate-lax-friedrichs-vector2-1d-second-order pde-system limiter
                                                         #:nx [nx 200]
                                                         #:x0 [x0 0.0]
                                                         #:x1 [x1 2.0]
                                                         #:t-final [t-final 1.0]
                                                         #:cfl [cfl 0.95]
                                                         #:init-funcs [init-funcs (list
                                                                                   `(cond
                                                                                      [(< x 0.5) 3.0]
                                                                                      [else 1.0])
                                                                                   `(cond
                                                                                      [(< x 0.5) 1.5]
                                                                                      [else 0.0]))])
 "Generate C code that solves the 1D coupled vector system of 2 PDEs specified by `pde-system` using the Lax-Friedrichs finite-difference method with a
  second-order flux extrapolation using flux limiter `limiter`.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define max-speed-exprs (hash-ref pde-system 'max-speed-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (define limiter-name (hash-ref limiter 'name))
  (define limiter-expr (hash-ref limiter 'limiter-expr))
  (define limiter-ratio (hash-ref limiter 'limiter-ratio))

  (define limiter-code (convert-expr limiter-expr))
  (define limiter-ratio-code (convert-expr limiter-ratio))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes (map (lambda (flux-expr)
                            (convert-expr flux-expr)) flux-exprs))
  (define max-speed-codes (map (lambda (max-speed-expr)
                                 (convert-expr max-speed-expr)) max-speed-exprs))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define limiter-r (flux-substitute limiter-code limiter-ratio-code "r"))

  (define flux-umLs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umL[0]")
                                            (list-ref cons-codes 1) "umL[1]")) flux-codes))
  (define flux-umRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umR[0]")
                                            (list-ref cons-codes 1) "umR[1]")) flux-codes))
  (define flux-uiLs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiL[0]")
                                            (list-ref cons-codes 1) "uiL[1]")) flux-codes))
  (define flux-uiRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiR[0]")
                                            (list-ref cons-codes 1) "uiR[1]")) flux-codes))
  (define flux-upLs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upL[0]")
                                            (list-ref cons-codes 1) "upL[1]")) flux-codes))
  (define flux-upRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upR[0]")
                                            (list-ref cons-codes 1) "upR[1]")) flux-codes))
  
  (define flux-umR-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umR_evol[0]")
                                                 (list-ref cons-codes 1) "umR_evol[1]")) flux-codes))
  (define flux-uiL-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiL_evol[0]")
                                                 (list-ref cons-codes 1) "uiL_evol[1]")) flux-codes))
  (define flux-uiR-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiR_evol[0]")
                                                 (list-ref cons-codes 1) "uiR_evol[1]")) flux-codes))
  (define flux-upL-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upL_evol[0]")
                                                 (list-ref cons-codes 1) "upL_evol[1]")) flux-codes))
  
  (define max-speed-locals (map (lambda (max-speed-code)
                                  (flux-substitute (flux-substitute max-speed-code (list-ref cons-codes 0) "u[(i * 2) + 0]")
                                                   (list-ref cons-codes 1) "u[(i * 2) + 1]")) max-speed-codes))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR COUPLED VECTOR PDE SYSTEM: ~a
// FLUX LIMITER: ~a
// Lax–Friedrichs first-order finite-difference solver for a coupled vector system of 2 PDEs in 1D, with a second-order flux extrapolation.

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
  double *slope = (double*) malloc((nx + 4) * 2 * sizeof(double));

  // Arrays for storing solution.
  double *u = (double*) malloc((nx + 4) * 2 * sizeof(double));
  double *un = (double*) malloc((nx + 4) * 2 * sizeof(double));

  // Arrays for storing other intermediate values.
  double *local_alpha = (double*) malloc(2 * sizeof(double));
  
  double *umL = (double*) malloc(2 * sizeof(double));
  double *umR = (double*) malloc(2 * sizeof(double));
  double *uiL = (double*) malloc(2 * sizeof(double));
  double *uiR = (double*) malloc(2 * sizeof(double));
  double *upL = (double*) malloc(2 * sizeof(double));
  double *upR = (double*) malloc(2 * sizeof(double));

  double *f_umL = (double*) malloc(2 * sizeof(double));
  double *f_umR = (double*) malloc(2 * sizeof(double));
  double *f_uiL = (double*) malloc(2 * sizeof(double));
  double *f_uiR = (double*) malloc(2 * sizeof(double));
  double *f_upL = (double*) malloc(2 * sizeof(double));
  double *f_upR = (double*) malloc(2 * sizeof(double));

  double *umR_evol = (double*) malloc(2 * sizeof(double));
  double *uiL_evol = (double*) malloc(2 * sizeof(double));
  double *uiR_evol = (double*) malloc(2 * sizeof(double));
  double *upL_evol = (double*) malloc(2 * sizeof(double));

  double *f_umR_evol = (double*) malloc(2 * sizeof(double));
  double *f_uiL_evol = (double*) malloc(2 * sizeof(double));
  double *f_uiR_evol = (double*) malloc(2 * sizeof(double));
  double *f_upL_evol = (double*) malloc(2 * sizeof(double));

  double *fluxL = (double*) malloc(2 * sizeof(double));
  double *fluxR = (double*) malloc(2 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    double x = x0 + (i - 1.5) * dx;
    
    u[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    u[(i * 2) + 1] = ~a; // init-funcs[1] in C.
    un[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    un[(i * 2) + 1] = ~a; // init-funcs[1] in C.
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 2; i <= nx + 1; i++) {
      local_alpha[0] = ~a; // max-speed-exprs[0] in C.
      local_alpha[1] = ~a; // max-speed-exprs[1] in C.
      
      for (int j = 0; j < 2; j++) {
        if (local_alpha[j] > alpha) {
          alpha = local_alpha[j];
        }
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
      for (int j = 0; j < 2; j++) {
        double r = (u[(i * 2) + j] - u[((i - 1) * 2) + j]) / (u[((i + 1) * 2) + j] - u[(i * 2) + j]);
        double limiter = ~a; // limiter-r in C.

        slope[(i * 2) + j] = limiter * (0.5 * ((u[(i * 2) + j] - u[((i - 1) * 2) + j]) + (u[((i + 1) * 2) + j] - u[(i * 2) + j])));
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector.
    for (int i = 2; i <= nx + 1; i++) {
      // Extrapolate boundary states.
      for (int j = 0; j < 2; j++) {
        umL[j] = u[((i - 1) * 2) + j] - (0.5 * slope[((i - 1) * 2) + j]);
        umR[j] = u[((i - 1) * 2) + j] + (0.5 * slope[((i - 1) * 2) + j]);

        uiL[j] = u[(i * 2) + j] - (0.5 * slope[(i * 2) + j]);
        uiR[j] = u[(i * 2) + j] + (0.5 * slope[(i * 2) + j]);

        upL[j] = u[((i + 1) * 2) + j] - (0.5 * slope[((i + 1) * 2) + j]);
        upR[j] = u[((i + 1) * 2) + j] + (0.5 * slope[((i + 1) * 2) + j]);
      }

      // Evaluate flux vector for each extrapolated boundary state.
      f_umL[0] = ~a;
      f_umL[1] = ~a;
      f_umR[0] = ~a;
      f_umR[1] = ~a;

      f_uiL[0] = ~a;
      f_uiL[1] = ~a;
      f_uiR[0] = ~a;
      f_uiR[1] = ~a;

      f_upL[0] = ~a;
      f_upL[1] = ~a;
      f_upR[0] = ~a;
      f_upR[1] = ~a;

      // Evolve each extrapolated boundary state.
      for (int j = 0; j < 2; j++) {
        umR_evol[j] = umR[j] + ((dt / (2.0 * dx)) * (f_umL[j] - f_umR[j]));

        uiL_evol[j] = uiL[j] + ((dt / (2.0 * dx)) * (f_uiL[j] - f_uiR[j]));
        uiR_evol[j] = uiR[j] + ((dt / (2.0 * dx)) * (f_uiL[j] - f_uiR[j]));

        upL_evol[j] = upL[j] + ((dt / (2.0 * dx)) * (f_upL[j] - f_upR[j]));
      }

      // Evaluate flux vector for each value of the (evolved) conserved variable vector.
      f_umR_evol[0] = ~a;
      f_umR_evol[1] = ~a; // F(U_{i - 1, R+})
      f_uiL_evol[0] = ~a;
      f_uiL_evol[1] = ~a; // F(U_{i, L+})
      
      f_uiR_evol[0] = ~a;
      f_uiR_evol[1] = ~a; // F(U_{i, R+})
      f_upL_evol[0] = ~a;
      f_upL_evol[1] = ~a; // F(U_{i + 1, L+})

      // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1, R+}) + F(U_{i, L+})) - 0.5 * alpha * (U_{i, L+} - U_{i - 1, R+}).
      for (int j = 0; j < 2; j++) {
        fluxL[j] = 0.5 * (f_umR_evol[j] + f_uiL_evol[j]) - 0.5 * alpha * (uiL_evol[j] - umR_evol[j]);
      }

      // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1, L+}) + F(U_{i, R+})) - 0.5 * alpha * (U_{i + 1, L+} - U_{i, R+}).
      for (int j = 0; j < 2; j++) {
        fluxR[j] = 0.5 * (f_uiR_evol[j] + f_upL_evol[j]) - 0.5 * alpha * (upL_evol[j] - uiR_evol[j]);
      }

      // Update the conserved variable vector.
      for (int j = 0; j < 2; j++) {
        un[(i * 2) + j] = u[(i * 2) + j] - (dt / dx) * (fluxR[j] - fluxL[j]);
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j < 2; j++) {
        u[(i * 2) + j] = un[(i * 2) + j];
      }
    }

    // Apply simple boundary conditions (transmissive).
    for (int j = 0; j < 2; j++) {
      u[(0 * 2) + j] = u[(2 * 2) + j];
      u[(1 * 2) + j] = u[(2 * 2) + j];
      u[((nx + 2) * 2) + j] = u[((nx + 1) * 2) + j];
      u[((nx + 3) * 2) + j] = u[((nx + 1) * 2) + j];
    }

    // Output solution to disk.
    for (int j = 0; j < 2; j++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", j, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", j, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 2; i <= nx + 1; i++) {
          double x = x0 + (i - 1.5) * dx;
          fprintf(fptr, \"%f, %f\\n\", x, u[(i * 2) + j]);
        }

        fclose(fptr);
      }
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(un);
  free(slope);

  free(local_alpha);
  
  free(umL);
  free(umR);
  free(uiL);
  free(uiR);
  free(upL);
  free(upR);

  free(f_umL);
  free(f_umR);
  free(f_uiL);
  free(f_uiR);
  free(f_upL);
  free(f_upR);

  free(umR_evol);
  free(uiL_evol);
  free(uiR_evol);
  free(upL_evol);

  free(f_umR_evol);
  free(f_uiL_evol);
  free(f_uiR_evol);
  free(f_upL_evol);

  free(fluxL);
  free(fluxR);
  
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
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals 0)
           (list-ref max-speed-locals 1)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left negative flux vector F(U_{i - 1, L}).
           (list-ref flux-umLs 0)
           (list-ref flux-umLs 1)
           ;; Right negative flux vector F(U_{i - 1, R}).
           (list-ref flux-umRs 0)
           (list-ref flux-umRs 1)
           ;; Left central flux vector F(U_{i, L}).
           (list-ref flux-uiLs 0)
           (list-ref flux-uiLs 1)
           ;; Right central flux vector F(U_{i, R}).
           (list-ref flux-uiRs 0)
           (list-ref flux-uiRs 1)
           ;; Left positive flux vector F(U_{i + 1, L}).
           (list-ref flux-upLs 0)
           (list-ref flux-upLs 1)
           ;; Right positive flux vector F(U_{i + 1, R}).
           (list-ref flux-upRs 0)
           (list-ref flux-upRs 1)
           ;; Evolved right negative flux vector F(U_{i - 1, R+}).
           (list-ref flux-umR-evols 0)
           (list-ref flux-umR-evols 1)
           ;; Evolved left central flux vector F(U_{i, L+}).
           (list-ref flux-uiL-evols 0)
           (list-ref flux-uiL-evols 1)
           ;; Evolved right central flux vector F(U_{i, R+}).
           (list-ref flux-uiR-evols 0)
           (list-ref flux-uiR-evols 1)
           ;; Evolved left positive flux vector F(U_{i + 1, L+}).
           (list-ref flux-upL-evols 0)
           (list-ref flux-upL-evols 1)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; -------------------------------------------------------------------
;; Roe (Finite-Volume) Solver for a 1D Coupled Vector System of 2 PDEs
;; -------------------------------------------------------------------
(define (generate-roe-vector2-1d pde-system
                                 #:nx [nx 200]
                                 #:x0 [x0 0.0]
                                 #:x1 [x1 2.0]
                                 #:t-final [t-final 1.0]
                                 #:cfl [cfl 0.95]
                                 #:init-funcs [init-funcs (list
                                                           `(cond
                                                              [(< x 0.5) 3.0]
                                                              [else 1.0])
                                                           `(cond
                                                              [(< x 0.5) 1.5]
                                                              [else 0.0]))])
 "Generate C code that solves the 1D coupled vector system of 2 PDEs specified by `pde-system` using the Roe finite-volume method.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define max-speed-exprs (hash-ref pde-system 'max-speed-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (define flux-jacobian-eigvals (symbolic-eigvals2 (symbolic-jacobian flux-exprs cons-exprs)))
  (define flux-jacobian-eigvals-simp (list (symbolic-simp (list-ref flux-jacobian-eigvals 0))
                                           (symbolic-simp (list-ref flux-jacobian-eigvals 1))))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes (map (lambda (flux-expr)
                            (convert-expr flux-expr)) flux-exprs))
  (define flux-deriv-codes (map (lambda (flux-deriv-expr)
                                  (convert-expr flux-deriv-expr)) flux-jacobian-eigvals-simp))
  (define max-speed-codes (map (lambda (max-speed-expr)
                                 (convert-expr max-speed-expr)) max-speed-exprs))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define flux-ums (map (lambda (flux-code)
                          (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "um[0]")
                                           (list-ref cons-codes 1) "um[1]")) flux-codes))
  (define flux-uis (map (lambda (flux-code)
                          (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "ui[0]")
                                           (list-ref cons-codes 1) "ui[1]")) flux-codes))
  (define flux-ups (map (lambda (flux-code)
                          (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "up[0]")
                                           (list-ref cons-codes 1) "up[1]")) flux-codes))

  (define flux-deriv-ums (map (lambda (flux-deriv-code)
                                (flux-substitute (flux-substitute flux-deriv-code (list-ref cons-codes 0) "um[0]")
                                                 (list-ref cons-codes 1) "um[1]")) flux-deriv-codes))
  (define flux-deriv-uis (map (lambda (flux-deriv-code)
                                (flux-substitute (flux-substitute flux-deriv-code (list-ref cons-codes 0) "ui[0]")
                                                 (list-ref cons-codes 1) "ui[1]")) flux-deriv-codes))
  (define flux-deriv-ups (map (lambda (flux-deriv-code)
                                (flux-substitute (flux-substitute flux-deriv-code (list-ref cons-codes 0) "up[0]")
                                                 (list-ref cons-codes 1) "up[1]")) flux-deriv-codes))
  
  (define max-speed-locals (map (lambda (max-speed-code)
                                  (flux-substitute (flux-substitute max-speed-code (list-ref cons-codes 0) "u[(i * 2) + 0]")
                                                   (list-ref cons-codes 1) "u[(i * 2) + 1]")) max-speed-codes))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))
  
  (define code
    (format "
// AUTO-GENERATED CODE FOR COUPLED VECTOR PDE SYSTEM: ~a
// Roe higher-order finite-volume solver for a coupled vector system of 2 PDEs in 1D.

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
  double *u = (double*) malloc((nx + 2) * 2 * sizeof(double));
  double *un = (double*) malloc((nx + 2) * 2 * sizeof(double));

  // Arrays for storing other intermediate values.
  double *local_alpha = (double*) malloc(2 * sizeof(double));
  
  double *um = (double*) malloc(2 * sizeof(double));
  double *ui = (double*) malloc(2 * sizeof(double));
  double *up = (double*) malloc(2 * sizeof(double));

  double *f_um = (double*) malloc(2 * sizeof(double));
  double *f_ui = (double*) malloc(2 * sizeof(double));
  double *f_up = (double*) malloc(2 * sizeof(double));

  double *f_deriv_um = (double*) malloc(2 * sizeof(double));
  double *f_deriv_ui = (double*) malloc(2 * sizeof(double));
  double *f_deriv_up = (double*) malloc(2 * sizeof(double));

  double *aL_roe = (double*) malloc(2 * sizeof(double));
  double *aR_roe = (double*) malloc(2 * sizeof(double));

  double *fluxL = (double*) malloc(2 * sizeof(double));
  double *fluxR = (double*) malloc(2 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    double x = x0 + (i - 0.5) * dx;
    
    u[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    u[(i * 2) + 1] = ~a; // init-funcs[1] in C.
    un[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    un[(i * 2) + 1] = ~a; // init-funcs[1] in C.
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 1; i <= nx; i++) {
      local_alpha[0] = ~a; // max-speed-exprs[0] in C.
      local_alpha[1] = ~a; // max-speed-exprs[1] in C.
      
      for (int j = 0; j < 2; j++) {
        if (local_alpha[j] > alpha) {
          alpha = local_alpha[j];
        }
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

    // Compute fluxes with Roe approximation and update the conserved variable vector.
    for (int i = 1; i <= nx; i++) {
      for (int j = 0; j < 2; j++) {
        um[j] = u[((i - 1) * 2) + j];
        ui[j] = u[(i * 2) + j];
        up[j] = u[((i + 1) * 2) + j];
      }

      // Evaluate flux vector for each value of the conserved variable vector.
      f_um[0] = ~a;
      f_um[1] = ~a; // F(U_{i - 1}).
      
      f_ui[0] = ~a;
      f_ui[1] = ~a; // F(U_i).
      
      f_up[0] = ~a;
      f_up[1] = ~a; // F(U_{i + 1}).

      // Evaluate eigenvalues of the flux Jacobian for each value of the conserved variable vector.
      f_deriv_um[0] = ~a;
      f_deriv_um[1] = ~a; // Eigenvalues of F'(U_{i - 1}).
      
      f_deriv_ui[0] = ~a;
      f_deriv_ui[1] = ~a; // Eigenvalues of F'(U_i).
      
      f_deriv_up[0] = ~a;
      f_deriv_up[1] = ~a; // Eigenvalues of F'(U_{i + 1}).

      // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1}) + F(U_i)) - 0.5 * |aL_roe| * (U_i - U_{i - 1}).
      for (int j = 0; j < 2; j++) {
        aL_roe[j] = 0.5 * (f_deriv_um[j] + f_deriv_ui[j]);
      }
      for (int j = 0; j < 2; j++) {
        fluxL[j] = 0.5 * (f_um[j] + f_ui[j]) - 0.5 * fabs(aL_roe[j]) * (ui[j] - um[j]);
      }

      // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1}) + F(U_i)) - 0.5 * |aR_roe| * (U_{i + 1} - u_i).
      for (int j = 0; j < 2; j++) {
        aR_roe[j] = 0.5 * (f_deriv_ui[j] + f_deriv_up[j]);
      }
      for (int j = 0; j < 2; j++) {
        fluxR[j] = 0.5 * (f_ui[j] + f_up[j]) - 0.5 * fabs(aR_roe[j]) * (up[j] - ui[j]);
      }

      // Update the conserved variable.
      for (int j = 0; j < 2; j++) {
        un[(i * 2) + j] = ui[j] - (dt / dx) * (fluxR[j] - fluxL[j]);
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j < 2; j++) {
        u[(i * 2) + j] = un[(i * 2) + j];
      }
    }

    // Apply simple boundary conditions (transmissive).
    for (int j = 0; j < 2; j++) {
      u[(0 * 2) + j] = u[(1 * 2) + j];
      u[((nx + 1) * 2) + j] = u[(nx * 2) + j];
    }

    // Output solution to disk.
    for (int j = 0; j < 2; j++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", j, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", j, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 1; i <= nx; i++) {
          double x = x0 + (i - 0.5) * dx;
          fprintf(fptr, \"%f, %f\\n\", x, u[(i * 2) + j]);
        }

        fclose(fptr);
      }
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(un);

  free(local_alpha);
  
  free(um);
  free(ui);
  free(up);

  free(f_um);
  free(f_ui);
  free(f_up);

  free(f_deriv_um);
  free(f_deriv_ui);
  free(f_deriv_up);

  free(aL_roe);
  free(aR_roe);

  free(fluxL);
  free(fluxR);
  
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
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals 0)
           (list-ref max-speed-locals 1)
           ;; Left flux vector F(u_{i - 1}).
           (list-ref flux-ums 0)
           (list-ref flux-ums 1)
           ;; Middle flux vector F(u_i).
           (list-ref flux-uis 0)
           (list-ref flux-uis 1)
           ;; Right flux vector F(u_{i + 1}).
           (list-ref flux-ups 0)
           (list-ref flux-ups 1)
           ;; Eigenvalues of left flux Jacobian F'(u_{i - 1}).
           (list-ref flux-deriv-ums 0)
           (list-ref flux-deriv-ums 1)
           ;; Eigenvalues of middle flux Jacobian F'(u_i).
           (list-ref flux-deriv-uis 0)
           (list-ref flux-deriv-uis 1)
           ;; Eigenvalues of right flux Jacobian F'(u_{i + 1}).
           (list-ref flux-deriv-ups 0)
           (list-ref flux-deriv-ups 1)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ----------------------------------------------------------------------------------------------------------
;; Roe (Finite-Volume) Solver for a 1D Coupled Vector System of 2 PDEs with a Second-Order Flux Extrapolation
;; ----------------------------------------------------------------------------------------------------------
(define (generate-roe-vector2-1d-second-order pde-system limiter
                                              #:nx [nx 200]
                                              #:x0 [x0 0.0]
                                              #:x1 [x1 2.0]
                                              #:t-final [t-final 1.0]
                                              #:cfl [cfl 0.95]
                                              #:init-funcs [init-funcs (list
                                                                        `(cond
                                                                           [(< x 0.5) 3.0]
                                                                           [else 1.0])
                                                                        `(cond
                                                                           [(< x 0.5) 1.5]
                                                                           [else 0.0]))])
 "Generate C code that solves the 1D coupled vector system of 2 PDEs specified by `pde-system` using the Roe finite-volume method with a
  second-order flux extrapolation using flux limiter `limiter`.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define max-speed-exprs (hash-ref pde-system 'max-speed-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (define limiter-name (hash-ref limiter 'name))
  (define limiter-expr (hash-ref limiter 'limiter-expr))
  (define limiter-ratio (hash-ref limiter 'limiter-ratio))

  (define limiter-code (convert-expr limiter-expr))
  (define limiter-ratio-code (convert-expr limiter-ratio))

  (define flux-jacobian-eigvals (symbolic-eigvals2 (symbolic-jacobian flux-exprs cons-exprs)))
  (define flux-jacobian-eigvals-simp (list (symbolic-simp (list-ref flux-jacobian-eigvals 0))
                                           (symbolic-simp (list-ref flux-jacobian-eigvals 1))))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes (map (lambda (flux-expr)
                            (convert-expr flux-expr)) flux-exprs))
  (define flux-deriv-codes (map (lambda (flux-deriv-expr)
                                  (convert-expr flux-deriv-expr)) flux-jacobian-eigvals-simp))
  (define max-speed-codes (map (lambda (max-speed-expr)
                                 (convert-expr max-speed-expr)) max-speed-exprs))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define limiter-r (flux-substitute limiter-code limiter-ratio-code "r"))

  (define flux-umLs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umL[0]")
                                            (list-ref cons-codes 1) "umL[1]")) flux-codes))
  (define flux-umRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umR[0]")
                                            (list-ref cons-codes 1) "umR[1]")) flux-codes))
  (define flux-uiLs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiL[0]")
                                            (list-ref cons-codes 1) "uiL[1]")) flux-codes))
  (define flux-uiRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiR[0]")
                                            (list-ref cons-codes 1) "uiR[1]")) flux-codes))
  (define flux-upLs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upL[0]")
                                            (list-ref cons-codes 1) "upL[1]")) flux-codes))
  (define flux-upRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upR[0]")
                                            (list-ref cons-codes 1) "upR[1]")) flux-codes))
  
  (define flux-umR-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umR_evol[0]")
                                                 (list-ref cons-codes 1) "umR_evol[1]")) flux-codes))
  (define flux-uiL-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiL_evol[0]")
                                                 (list-ref cons-codes 1) "uiL_evol[1]")) flux-codes))
  (define flux-uiR-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiR_evol[0]")
                                                 (list-ref cons-codes 1) "uiR_evol[1]")) flux-codes))
  (define flux-upL-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upL_evol[0]")
                                                 (list-ref cons-codes 1) "upL_evol[1]")) flux-codes))

  (define flux-deriv-umR-evols (map (lambda (flux-deriv-code)
                                      (flux-substitute (flux-substitute flux-deriv-code (list-ref cons-codes 0) "umR_evol[0]")
                                                       (list-ref cons-codes 1) "umR_evol[1]")) flux-deriv-codes))
  (define flux-deriv-uiL-evols (map (lambda (flux-deriv-code)
                                      (flux-substitute (flux-substitute flux-deriv-code (list-ref cons-codes 0) "uiL_evol[0]")
                                                       (list-ref cons-codes 1) "uiL_evol[1]")) flux-deriv-codes))
  (define flux-deriv-uiR-evols (map (lambda (flux-deriv-code)
                                      (flux-substitute (flux-substitute flux-deriv-code (list-ref cons-codes 0) "uiR_evol[0]")
                                                       (list-ref cons-codes 1) "uiR_evol[1]")) flux-deriv-codes))
  (define flux-deriv-upL-evols (map (lambda (flux-deriv-code)
                                      (flux-substitute (flux-substitute flux-deriv-code (list-ref cons-codes 0) "upL_evol[0]")
                                                       (list-ref cons-codes 1) "upL_evol[1]")) flux-deriv-codes))
  
  (define max-speed-locals (map (lambda (max-speed-code)
                                  (flux-substitute (flux-substitute max-speed-code (list-ref cons-codes 0) "u[(i * 2) + 0]")
                                                   (list-ref cons-codes 1) "u[(i * 2) + 1]")) max-speed-codes))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))
  
  (define code
    (format "
// AUTO-GENERATED CODE FOR COUPLED VECTOR PDE SYSTEM: ~a
// FLUX LIMITER: ~a
// Roe higher-order finite-volume solver for a coupled vector system of 2 PDEs in 1D, with a second-order flux extrapolation.

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
  double *slope = (double*) malloc((nx + 4) * 2 * sizeof(double));

  // Arrays for storing solution.
  double *u = (double*) malloc((nx + 4) * 2 * sizeof(double));
  double *un = (double*) malloc((nx + 4) * 2 * sizeof(double));

  // Arrays for storing other intermediate values.
  double *local_alpha = (double*) malloc(2 * sizeof(double));
  
  double *umL = (double*) malloc(2 * sizeof(double));
  double *umR = (double*) malloc(2 * sizeof(double));
  double *uiL = (double*) malloc(2 * sizeof(double));
  double *uiR = (double*) malloc(2 * sizeof(double));
  double *upL = (double*) malloc(2 * sizeof(double));
  double *upR = (double*) malloc(2 * sizeof(double));

  double *f_umL = (double*) malloc(2 * sizeof(double));
  double *f_umR = (double*) malloc(2 * sizeof(double));
  double *f_uiL = (double*) malloc(2 * sizeof(double));
  double *f_uiR = (double*) malloc(2 * sizeof(double));
  double *f_upL = (double*) malloc(2 * sizeof(double));
  double *f_upR = (double*) malloc(2 * sizeof(double));

  double *umR_evol = (double*) malloc(2 * sizeof(double));
  double *uiL_evol = (double*) malloc(2 * sizeof(double));
  double *uiR_evol = (double*) malloc(2 * sizeof(double));
  double *upL_evol = (double*) malloc(2 * sizeof(double));

  double *f_umR_evol = (double*) malloc(2 * sizeof(double));
  double *f_uiL_evol = (double*) malloc(2 * sizeof(double));
  double *f_uiR_evol = (double*) malloc(2 * sizeof(double));
  double *f_upL_evol = (double*) malloc(2 * sizeof(double));

  double *f_deriv_umR_evol = (double*) malloc(2 * sizeof(double));
  double *f_deriv_uiL_evol = (double*) malloc(2 * sizeof(double));
  double *f_deriv_uiR_evol = (double*) malloc(2 * sizeof(double));
  double *f_deriv_upL_evol = (double*) malloc(2 * sizeof(double));

  double *aL_roe = (double*) malloc(2 * sizeof(double));
  double *aR_roe = (double*) malloc(2 * sizeof(double));

  double *fluxL = (double*) malloc(2 * sizeof(double));
  double *fluxR = (double*) malloc(2 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    double x = x0 + (i - 1.5) * dx;
    
    u[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    u[(i * 2) + 1] = ~a; // init-funcs[1] in C.
    un[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    un[(i * 2) + 1] = ~a; // init-funcs[1] in C.
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 2; i <= nx + 1; i++) {
      local_alpha[0] = ~a; // max-speed-exprs[0] in C.
      local_alpha[1] = ~a; // max-speed-exprs[1] in C.
      
      for (int j = 0; j < 2; j++) {
        if (local_alpha[j] > alpha) {
          alpha = local_alpha[j];
        }
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
      for (int j = 0; j < 2; j++) {
        double r = (u[(i * 2) + j] - u[((i - 1) * 2) + j]) / (u[((i + 1) * 2) + j] - u[(i * 2) + j]);
        double limiter = ~a; // limiter-r in C.

        slope[(i * 2) + j] = limiter * (0.5 * ((u[(i * 2) + j] - u[((i - 1) * 2) + j]) + (u[((i + 1) * 2) + j] - u[(i * 2) + j])));
      }
    }

    // Compute fluxes with Roe approximation and update the conserved variable vector.
    for (int i = 2; i <= nx + 1; i++) {
      // Extrapolate boundary states.
      for (int j = 0; j < 2; j++) {
        umL[j] = u[((i - 1) * 2) + j] - (0.5 * slope[((i - 1) * 2) + j]);
        umR[j] = u[((i - 1) * 2) + j] + (0.5 * slope[((i - 1) * 2) + j]);

        uiL[j] = u[(i * 2) + j] - (0.5 * slope[(i * 2) + j]);
        uiR[j] = u[(i * 2) + j] + (0.5 * slope[(i * 2) + j]);

        upL[j] = u[((i + 1) * 2) + j] - (0.5 * slope[((i + 1) * 2) + j]);
        upR[j] = u[((i + 1) * 2) + j] + (0.5 * slope[((i + 1) * 2) + j]);
      }

      // Evaluate flux vector for each extrapolated boundary state.
      f_umL[0] = ~a;
      f_umL[1] = ~a;
      f_umR[0] = ~a;
      f_umR[1] = ~a;

      f_uiL[0] = ~a;
      f_uiL[1] = ~a;
      f_uiR[0] = ~a;
      f_uiR[1] = ~a;

      f_upL[0] = ~a;
      f_upL[1] = ~a;
      f_upR[0] = ~a;
      f_upR[1] = ~a;

      // Evolve each extrapolated boundary state.
      for (int j = 0; j < 2; j++) {
        umR_evol[j] = umR[j] + ((dt / (2.0 * dx)) * (f_umL[j] - f_umR[j]));

        uiL_evol[j] = uiL[j] + ((dt / (2.0 * dx)) * (f_uiL[j] - f_uiR[j]));
        uiR_evol[j] = uiR[j] + ((dt / (2.0 * dx)) * (f_uiL[j] - f_uiR[j]));

        upL_evol[j] = upL[j] + ((dt / (2.0 * dx)) * (f_upL[j] - f_upR[j]));
      }

      // Evaluate flux vector for each value of the (evolved) conserved variable vector.
      f_umR_evol[0] = ~a;
      f_umR_evol[1] = ~a; // F(U_{i - 1, R+})
      f_uiL_evol[0] = ~a;
      f_uiL_evol[1] = ~a; // F(U_{i, L+})
      
      f_uiR_evol[0] = ~a;
      f_uiR_evol[1] = ~a; // F(U_{i, R+})
      f_upL_evol[0] = ~a;
      f_upL_evol[1] = ~a; // F(U_{i + 1, L+})

      // Evaluate eigenvalues of the flux Jacobian for each value of the (evolved) conserved variable vector.
      f_deriv_umR_evol[0] = ~a;
      f_deriv_umR_evol[1] = ~a; // F'(U_{i - 1, R+})
      f_deriv_uiL_evol[0] = ~a;
      f_deriv_uiL_evol[1] = ~a; // F'(U_{i, L+})
      
      f_deriv_uiR_evol[0] = ~a;
      f_deriv_uiR_evol[1] = ~a; // F'(U_{i, R+})
      f_deriv_upL_evol[0] = ~a;
      f_deriv_upL_evol[1] = ~a; // F'(U_{i + 1, L+})

      // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1, R+}) + F(U_{i, L+})) - 0.5 * |aL_roe| * (U_{i, L+} - U_{i - 1, R+}).
      for (int j = 0; j < 2; j++) {
        aL_roe[j] = 0.5 * (f_deriv_umR_evol[j] + f_deriv_uiL_evol[j]);
      }
      for (int j = 0; j < 2; j++) {
        fluxL[j] = 0.5 * (f_umR_evol[j] + f_uiL_evol[j]) - 0.5 * fabs(aL_roe[j]) * (uiL_evol[j] - umR_evol[j]);
      }

      // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1, L+}) + F(U_{i, R+})) - 0.5 * |aR_roe| * (U_{i + 1, L+} - u_{i, R+}).
      for (int j = 0; j < 2; j++) {
        aR_roe[j] = 0.5 * (f_deriv_uiR_evol[j] + f_deriv_upL_evol[j]);
      }
      for (int j = 0; j < 2; j++) {
        fluxR[j] = 0.5 * (f_uiR_evol[j] + f_upL_evol[j]) - 0.5 * fabs(aR_roe[j]) * (upL_evol[j] - uiR_evol[j]);
      }

      // Update the conserved variable.
      for (int j = 0; j < 2; j++) {
        un[(i * 2) + j] = u[(i * 2) + j] - (dt / dx) * (fluxR[j] - fluxL[j]);
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j < 2; j++) {
        u[(i * 2) + j] = un[(i * 2) + j];
      }
    }

    // Apply simple boundary conditions (transmissive).
    for (int j = 0; j < 2; j++) {
      u[(0 * 2) + j] = u[(2 * 2) + j];
      u[(1 * 2) + j] = u[(2 * 2) + j];
      u[((nx + 2) * 2) + j] = u[((nx + 1) * 2) + j];
      u[((nx + 3) * 2) + j] = u[((nx + 1) * 2) + j];
    }
    
    // Output solution to disk.
    for (int j = 0; j < 2; j++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", j, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", j, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 2; i <= nx + 1; i++) {
          double x = x0 + (i - 1.5) * dx;
          fprintf(fptr, \"%f, %f\\n\", x, u[(i * 2) + j]);
        }

        fclose(fptr);
      }
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(un);
  free(slope);

  free(local_alpha);
  
  free(umL);
  free(umR);
  free(uiL);
  free(uiR);
  free(upL);
  free(upR);

  free(f_umL);
  free(f_umR);
  free(f_uiL);
  free(f_uiR);
  free(f_upL);
  free(f_upR);

  free(umR_evol);
  free(uiL_evol);
  free(uiR_evol);
  free(upL_evol);

  free(f_umR_evol);
  free(f_uiL_evol);
  free(f_uiR_evol);
  free(f_upL_evol);

  free(f_deriv_umR_evol);
  free(f_deriv_uiL_evol);
  free(f_deriv_uiR_evol);
  free(f_deriv_upL_evol);

  free(fluxL);
  free(fluxR);
  
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
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals 0)
           (list-ref max-speed-locals 1)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left negative flux vector F(U_{i - 1, L}).
           (list-ref flux-umLs 0)
           (list-ref flux-umLs 1)
           ;; Right negative flux vector F(U_{i - 1, R}).
           (list-ref flux-umRs 0)
           (list-ref flux-umRs 1)
           ;; Left central flux vector F(U_{i, L}).
           (list-ref flux-uiLs 0)
           (list-ref flux-uiLs 1)
           ;; Right central flux vector F(U_{i, R}).
           (list-ref flux-uiRs 0)
           (list-ref flux-uiRs 1)
           ;; Left positive flux vector F(U_{i + 1, L}).
           (list-ref flux-upLs 0)
           (list-ref flux-upLs 1)
           ;; Right positive flux vector F(U_{i + 1, R}).
           (list-ref flux-upRs 0)
           (list-ref flux-upRs 1)
           ;; Evolved right negative flux vector F(U_{i - 1, R+}).
           (list-ref flux-umR-evols 0)
           (list-ref flux-umR-evols 1)
           ;; Evolved left central flux vector F(U_{i, L+}).
           (list-ref flux-uiL-evols 0)
           (list-ref flux-uiL-evols 1)
           ;; Evolved right central flux vector F(U_{i, R+}).
           (list-ref flux-uiR-evols 0)
           (list-ref flux-uiR-evols 1)
           ;; Evolved left positive flux vector F(U_{i + 1, L+}).
           (list-ref flux-upL-evols 0)
           (list-ref flux-upL-evols 1)
           ;; Eigenvalues of evolved right negative flux Jacobian F'(U_{i - 1, R+}).
           (list-ref flux-deriv-umR-evols 0)
           (list-ref flux-deriv-umR-evols 1)
           ;; Eigenvalues of evolved left central flux Jacobian F'(U_{i, L+}).
           (list-ref flux-deriv-uiL-evols 0)
           (list-ref flux-deriv-uiL-evols 1)
           ;; Eigenvalues of evolved right central flux Jacobian F'(U_{i, R+}).
           (list-ref flux-deriv-uiR-evols 0)
           (list-ref flux-deriv-uiR-evols 1)
           ;; Eigenvalues of evolved left positive flux Jacobian F'(U_{i + 1, L+}).
           (list-ref flux-deriv-upL-evols 0)
           (list-ref flux-deriv-upL-evols 1)
           ;; PDE name for file output.
           name
           name
           ))
  code)