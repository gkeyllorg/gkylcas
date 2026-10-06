#lang racket

(require "prover_core.rkt")
(require "code_generator_core.rkt")
(provide generate-lax-friedrichs-scalar-2d
         generate-lax-friedrichs-scalar-2d-second-order
         generate-roe-scalar-2d
         generate-roe-scalar-2d-second-order)

;; -------------------------------------------------------------
;; Lax–Friedrichs (Finite-Difference) Solver for a 2D Scalar PDE
;; -------------------------------------------------------------
(define (generate-lax-friedrichs-scalar-2d pde
                                           #:nx [nx 200]
                                           #:ny [ny 200]
                                           #:x0 [x0 0.0]
                                           #:x1 [x1 2.0]
                                           #:y0 [y0 0.0]
                                           #:y1 [y1 2.0]
                                           #:t-final [t-final 1.0]
                                           #:cfl [cfl 0.95]
                                           #:init-func [init-func `(cond
                                                                     [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.5) 1.0]
                                                                     [else 0.0])])
 "Generate C code that solves the 2D scalar PDE specified by `pde` using the Lax-Friedrichs finite-difference method.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-func`: Racket expression for the initial condition, e.g. piecewise constant."

  (define name (hash-ref pde 'name))
  (define cons-expr (hash-ref pde 'cons-expr))
  (define flux-expr-x (hash-ref pde 'flux-expr-x))
  (define flux-expr-y (hash-ref pde 'flux-expr-y))
  (define max-speed-expr-x (hash-ref pde 'max-speed-expr-x))
  (define max-speed-expr-y (hash-ref pde 'max-speed-expr-y))
  (define parameters (hash-ref pde 'parameters))

  (define cons-code (convert-expr cons-expr))
  (define flux-code-x (convert-expr flux-expr-x))
  (define flux-code-y (convert-expr flux-expr-y))
  (define max-speed-code-x (convert-expr max-speed-expr-x))
  (define max-speed-code-y (convert-expr max-speed-expr-y))
  (define init-func-code (convert-expr init-func))

  (define flux-um-x (flux-substitute flux-code-x cons-code "um_x"))
  (define flux-ui-x (flux-substitute flux-code-x cons-code "ui_x"))
  (define flux-up-x (flux-substitute flux-code-x cons-code "up_x"))

  (define flux-um-y (flux-substitute flux-code-y cons-code "um_y"))
  (define flux-ui-y (flux-substitute flux-code-y cons-code "ui_y"))
  (define flux-up-y (flux-substitute flux-code-y cons-code "up_y"))

  (define max-speed-local-x (flux-substitute max-speed-code-x cons-code "u[i][j]"))
  (define max-speed-local-y (flux-substitute max-speed-code-y cons-code "u[i][j]"))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR SCALAR PDE: ~a
// Lax–Friedrichs first-order finite-difference solver for a scalar PDE in 2D.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Additional PDE parameters (if any).
~a

int main() {
  // Spatial domain setup.
  const int nx = ~a;
  const int ny = ~a;
  const double x0 = ~a;
  const double x1 = ~a;
  const double y0 = ~a;
  const double y1 = ~a;
  const double Lx = (x1 - x0);
  const double Ly = (y1 - y0);
  const double dx = Lx / nx;
  const double dy = Ly / ny;

  // Time-stepper setup.
  const double cfl = ~a;
  const double t_final = ~a;

  // Arrays for storing solution.
  double **u = (double**) malloc((nx + 2) * sizeof(double*));
  double **un = (double**) malloc((nx + 2) * sizeof(double*));
  for (int i = 0; i <= nx + 1; i++) {
    u[i] = (double*) malloc((ny + 2) * sizeof(double));
    un[i] = (double*) malloc((ny + 2) * sizeof(double));
  }

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    for (int j = 0; j <= ny + 1; j++) {
      double x = x0 + (i - 0.5) * dx;
      double y = y0 + (j - 0.5) * dy;
    
      u[i][j] = ~a; // init-func in C.
      un[i][j] = ~a; // init-func in C.
    }
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha_x = 0.0;
    double alpha_y = 0.0;
    
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        double local_alpha_x = ~a; // max-speed-expr-x in C.
        double local_alpha_y = ~a; // max-speed-expr-y in C.
      
        if (local_alpha_x > alpha_x) {
          alpha_x = local_alpha_x;
        }
        if (local_alpha_y > alpha_y) {
          alpha_y = local_alpha_y;
        }
      }
    }

    // Avoid division by zero.
    if (alpha_x < 1e-14) {
      alpha_x = 1e-14;
    }
    if (alpha_y < 1e-14) {
      alpha_y = 1e-14;
    }

    // Compute stable time step from alpha.
    double dt = fmin(cfl * dx / alpha_x, cfl * dy / alpha_y);

    // If stepping beyond t_final, adjust dt accordingly.
    if (t + dt > t_final) {
      dt = t_final - t;
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable in the y-direction by half a time-step.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        double um_y = u[i][j - 1];
        double ui_y = u[i][j];
        double up_y = u[i][j + 1];
        
        // Evaluate flux for each value of the conserved variable.
        double f_um_y = ~a; // f(u_{j - 1}).
        double f_ui_y = ~a; // f(u_j).
        double f_up_y = ~a; // f(u_{j + 1}).

        // Left interface flux: F_{j - 1/2} = 0.5 * (f(u_{j - 1}) + f(u_j)) - 0.5 * alpha_y * (u_j - u_{j - 1}).
        double fluxL_y = 0.5 * (f_um_y + f_ui_y) - 0.5 * alpha_y * (ui_y - um_y);

        // Right interface flux: F_{j + 1/2} = 0.5 * (f(u_{j + 1}) + f(u_j)) - 0.5 * alpha_y * (u_{j + 1} - u_j).
        double fluxR_y = 0.5 * (f_ui_y + f_up_y) - 0.5 * alpha_y * (up_y - ui_y);

        // Update the conserved variable.
        un[i][j] = ui_y - (dt / (2.0 * dy)) * (fluxR_y - fluxL_y);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      u[0][j] = u[1][j];
      u[nx + 1][j] = u[nx][j];

      un[0][j] = un[1][j];
      un[nx + 1][j] = un[nx][j];
    }
    
    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      u[i][0] = u[i][1];
      u[i][ny + 1] = u[i][ny];

      un[i][0] = un[i][1];
      un[i][ny + 1] = un[i][ny];
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable in the x-direction.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        double um_x = u[i - 1][j];
        double ui_x = u[i][j];
        double up_x = u[i + 1][j];

        // Evaluate flux for each value of the conserved variable.
        double f_um_x = ~a; // f(u_{i - 1}).
        double f_ui_x = ~a; // f(u_i).
        double f_up_x = ~a; // f(u_{i + 1}).

        // Left interface flux: F_{i - 1/2} = 0.5 * (f(u_{i - 1}) + f(u_i)) - 0.5 * alpha_x * (u_i - u_{i - 1}).
        double fluxL_x = 0.5 * (f_um_x + f_ui_x) - 0.5 * alpha_x * (ui_x - um_x);

        // Right interface flux: F_{i + 1/2} = 0.5 * (f(u_{i + 1}) + f(u_i)) - 0.5 * alpha_x * (u_{i + 1} - u_i).
        double fluxR_x = 0.5 * (f_ui_x + f_up_x) - 0.5 * alpha_x * (up_x - ui_x);

        // Update the conserved variable.
        un[i][j] = ui_x - (dt / dx) * (fluxR_x - fluxL_x);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      u[0][j] = u[1][j];
      u[nx + 1][j] = u[nx][j];

      un[0][j] = un[1][j];
      un[nx + 1][j] = un[nx][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      u[i][0] = u[i][1];
      u[i][ny + 1] = u[i][ny];

      un[i][0] = un[i][1];
      un[i][ny + 1] = un[i][ny];
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable in the y-direction by half a time-step.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        double um_y = u[i][j - 1];
        double ui_y = u[i][j];
        double up_y = u[i][j + 1];
        
        // Evaluate flux for each value of the conserved variable.
        double f_um_y = ~a; // f(u_{j - 1}).
        double f_ui_y = ~a; // f(u_j).
        double f_up_y = ~a; // f(u_{j + 1}).

        // Left interface flux: F_{j - 1/2} = 0.5 * (f(u_{j - 1}) + f(u_j)) - 0.5 * alpha_y * (u_j - u_{j - 1}).
        double fluxL_y = 0.5 * (f_um_y + f_ui_y) - 0.5 * alpha_y * (ui_y - um_y);

        // Right interface flux: F_{j + 1/2} = 0.5 * (f(u_{j + 1}) + f(u_j)) - 0.5 * alpha_y * (u_{j + 1} - u_j).
        double fluxR_y = 0.5 * (f_ui_y + f_up_y) - 0.5 * alpha_y * (up_y - ui_y);

        // Update the conserved variable.
        un[i][j] = ui_y - (dt / (2.0 * dy)) * (fluxR_y - fluxL_y);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      u[0][j] = u[1][j];
      u[nx + 1][j] = u[nx][j];

      un[0][j] = un[1][j];
      un[nx + 1][j] = un[nx][j];
    }
    
    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      u[i][0] = u[i][1];
      u[i][ny + 1] = u[i][ny];

      un[i][0] = un[i][1];
      un[i][ny + 1] = un[i][ny];
    }

    // Output solution to disk.
    const char *fmt = \"%s_output_%d.csv\";
    int sz = snprintf(0, 0, fmt, \"~a\", n);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", n);
    
    FILE *fptr = fopen(file_nm, \"w\");
    if (fptr != NULL) {
      for (int i = 1; i <= nx; i++) {
        for (int j = 1; j <= ny; j++) {
          double x = x0 + (i - 0.5) * dx;
          double y = y0 + (j - 0.5) * dy;
          fprintf(fptr, \"%f, %f, %f\\n\", x, y, u[i][j]);
        }
      }

      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  for (int i = 0; i <= nx + 1; i++) {
    free(u[i]);
    free(un[i]);
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
           ;; Number of cells in each coordinate direction.
           nx
           ny
           ;; Left/right boundaries.
           x0
           x1
           ;; Up/down boundaries
           y0
           y1
           ;; CFL coefficient.
           cfl
           ;; Final time.
           t-final
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           init-func-code
           init-func-code
           ;; Expressions for local wave-speed estimates.
           max-speed-local-x
           max-speed-local-y
           ;; Left, middle, right fluxes in y-direction f(u_{j - 1}), f(u_j), f(u_{j + 1}).
           flux-um-y
           flux-ui-y
           flux-up-y
           ;; Left, middle, right fluxes in x-direction f(u_{i - 1}), f(u_i), f(u_{i + 1}).
           flux-um-x
           flux-ui-x
           flux-up-x
           ;; Left, middle, right fluxes in y-direction f(u_{j - 1}), f(u_j), f(u_{j + 1}).
           flux-um-y
           flux-ui-y
           flux-up-y
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ----------------------------------------------------------------------------------------------------
;; Lax–Friedrichs (Finite-Difference) Solver for a 2D Scalar PDE with a Second-Order Flux Extrapolation
;; ----------------------------------------------------------------------------------------------------
(define (generate-lax-friedrichs-scalar-2d-second-order pde limiter
                                                        #:nx [nx 200]
                                                        #:ny [ny 200]
                                                        #:x0 [x0 0.0]
                                                        #:x1 [x1 2.0]
                                                        #:y0 [y0 0.0]
                                                        #:y1 [y1 2.0]
                                                        #:t-final [t-final 1.0]
                                                        #:cfl [cfl 0.95]
                                                        #:init-func [init-func `(cond
                                                                                  [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.5) 1.0]
                                                                                  [else 0.0])])
 "Generate C code that solves the 2D scalar PDE specified by `pde` using the Lax-Friedrichs finite-difference method with a second-order flux extrapolation using flux limiter `limiter`.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-func`: Racket expression for the initial condition, e.g. piecewise constant."

  (define name (hash-ref pde 'name))
  (define cons-expr (hash-ref pde 'cons-expr))
  (define flux-expr-x (hash-ref pde 'flux-expr-x))
  (define flux-expr-y (hash-ref pde 'flux-expr-y))
  (define max-speed-expr-x (hash-ref pde 'max-speed-expr-x))
  (define max-speed-expr-y (hash-ref pde 'max-speed-expr-y))
  (define parameters (hash-ref pde 'parameters))

  (define limiter-name (hash-ref limiter 'name))
  (define limiter-expr (hash-ref limiter 'limiter-expr))
  (define limiter-ratio (hash-ref limiter 'limiter-ratio))

  (define limiter-code (convert-expr limiter-expr))
  (define limiter-ratio-code (convert-expr limiter-ratio))

  (define cons-code (convert-expr cons-expr))
  (define flux-code-x (convert-expr flux-expr-x))
  (define flux-code-y (convert-expr flux-expr-y))
  (define max-speed-code-x (convert-expr max-speed-expr-x))
  (define max-speed-code-y (convert-expr max-speed-expr-y))
  (define init-func-code (convert-expr init-func))

  (define limiter-r (flux-substitute limiter-code limiter-ratio-code "r"))

  (define flux-umL-x (flux-substitute flux-code-x cons-code "umL_x"))
  (define flux-umR-x (flux-substitute flux-code-x cons-code "umR_x"))
  (define flux-uiL-x (flux-substitute flux-code-x cons-code "uiL_x"))
  (define flux-uiR-x (flux-substitute flux-code-x cons-code "uiR_x"))
  (define flux-upL-x (flux-substitute flux-code-x cons-code "upL_x"))
  (define flux-upR-x (flux-substitute flux-code-x cons-code "upR_x"))

  (define flux-umR-evol-x (flux-substitute flux-code-x cons-code "umR_evol_x"))
  (define flux-uiL-evol-x (flux-substitute flux-code-x cons-code "uiL_evol_x"))
  (define flux-uiR-evol-x (flux-substitute flux-code-x cons-code "uiR_evol_x"))
  (define flux-upL-evol-x (flux-substitute flux-code-x cons-code "upL_evol_x"))

  (define flux-umL-y (flux-substitute flux-code-y cons-code "umL_y"))
  (define flux-umR-y (flux-substitute flux-code-y cons-code "umR_y"))
  (define flux-uiL-y (flux-substitute flux-code-y cons-code "uiL_y"))
  (define flux-uiR-y (flux-substitute flux-code-y cons-code "uiR_y"))
  (define flux-upL-y (flux-substitute flux-code-y cons-code "upL_y"))
  (define flux-upR-y (flux-substitute flux-code-y cons-code "upR_y"))

  (define flux-umR-evol-y (flux-substitute flux-code-y cons-code "umR_evol_y"))
  (define flux-uiL-evol-y (flux-substitute flux-code-y cons-code "uiL_evol_y"))
  (define flux-uiR-evol-y (flux-substitute flux-code-y cons-code "uiR_evol_y"))
  (define flux-upL-evol-y (flux-substitute flux-code-y cons-code "upL_evol_y"))

  (define max-speed-local-x (flux-substitute max-speed-code-x cons-code "u[i][j]"))
  (define max-speed-local-y (flux-substitute max-speed-code-y cons-code "u[i][j]"))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR SCALAR PDE: ~a
// FLUX LIMITER: ~a
// Lax–Friedrichs first-order finite-difference solver for a scalar PDE in 2D, with a second-order flux extrapolation.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Additional PDE parameters (if any).
~a

int main() {
  // Spatial domain setup.
  const int nx = ~a;
  const int ny = ~a;
  const double x0 = ~a;
  const double x1 = ~a;
  const double y0 = ~a;
  const double y1 = ~a;
  const double Lx = (x1 - x0);
  const double Ly = (y1 - y0);
  const double dx = Lx / nx;
  const double dy = Ly / ny;

  // Time-stepper setup.
  const double cfl = ~a;
  const double t_final = ~a;

  // Arrays for storing slopes.
  double **slope_x = (double**) malloc((nx + 4) * sizeof(double*));
  double **slope_y = (double**) malloc((nx + 4) * sizeof(double*));
  for (int i = 0; i <= nx + 3; i++) {
    slope_x[i] = (double*) malloc((ny + 4) * sizeof(double));
    slope_y[i] = (double*) malloc((ny + 4) * sizeof(double));
  }

  // Arrays for storing solution.
  double **u = (double**) malloc((nx + 4) * sizeof(double*));
  double **un = (double**) malloc((nx + 4) * sizeof(double*));
  for (int i = 0; i <= nx + 3; i++) {
    u[i] = (double*) malloc((ny + 4) * sizeof(double));
    un[i] = (double*) malloc((ny + 4) * sizeof(double));
  }

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    for (int j = 0; j <= ny + 3; j++) {
      double x = x0 + (i - 1.5) * dx;
      double y = y0 + (j - 1.5) * dy;
    
      u[i][j] = ~a; // init-func in C.
      un[i][j] = ~a; // init-func in C.
    }
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha_x = 0.0;
    double alpha_y = 0.0;
    
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        double local_alpha_x = ~a; // max-speed-expr-x in C.
        double local_alpha_y = ~a; // max-speed-expr-y in C.
      
        if (local_alpha_x > alpha_x) {
          alpha_x = local_alpha_x;
        }
        if (local_alpha_y > alpha_y) {
          alpha_y = local_alpha_y;
        }
      }
    }

    // Avoid division by zero.
    if (alpha_x < 1e-14) {
      alpha_x = 1e-14;
    }
    if (alpha_y < 1e-14) {
      alpha_y = 1e-14;
    }

    // Compute stable time step from alpha.
    double dt = fmin(cfl * dx / alpha_x, cfl * dy / alpha_y);

    // If stepping beyond t_final, adjust dt accordingly.
    if (t + dt > t_final) {
      dt = t_final - t;
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        double r = (u[i][j] - u[i][j - 1]) / (u[i][j + 1] - u[i][j]);
        double limiter = ~a; // limiter-r in C.
        
        slope_y[i][j] = limiter * (0.5 * ((u[i][j] - u[i][j - 1]) + (u[i][j + 1] - u[i][j])));
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation (with a second-order flux extrapolation) and update the conserved variable in the y-direction by half a time-step.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j<= ny + 1; j++) {
        // Extrapolate boundary states.
        double umL_y = u[i][j - 1] - (0.5 * slope_y[i][j - 1]);
        double umR_y = u[i][j - 1] + (0.5 * slope_y[i][j - 1]);
        
        double uiL_y = u[i][j] - (0.5 * slope_y[i][j]);
        double uiR_y = u[i][j] + (0.5 * slope_y[i][j]);

        double upL_y = u[i][j + 1] - (0.5 * slope_y[i][j + 1]);
        double upR_y = u[i][j + 1] + (0.5 * slope_y[i][j + 1]);

        // Evaluate flux for each extrapolated boundary state.
        double f_umL_y = ~a;
        double f_umR_y = ~a;

        double f_uiL_y = ~a;
        double f_uiR_y = ~a;

        double f_upL_y = ~a;
        double f_upR_y = ~a;

        // Evolve each extrapolated boundary state.
        double umR_evol_y = umR_y + ((dt / (4.0 * dy)) * (f_umL_y - f_umR_y));

        double uiL_evol_y = uiL_y + ((dt / (4.0 * dy)) * (f_uiL_y - f_uiR_y));
        double uiR_evol_y = uiR_y + ((dt / (4.0 * dy)) * (f_uiL_y - f_uiR_y));

        double upL_evol_y = upL_y + ((dt / (4.0 * dy)) * (f_upL_y - f_upR_y));

        // Evaluate flux for each value of the (evolved) conserved variable.
        double f_umR_evol_y = ~a;
        double f_uiL_evol_y = ~a;

        double f_uiR_evol_y = ~a;
        double f_upL_evol_y = ~a;

        // Left interface flux: F_{j - 1/2} = 0.5 * (f(u_{j - 1, R+}) + f(u_{j, L+})) - 0.5 * alpha * (u_{j, L+} - u_{j - 1, R+}).
        double fluxL_y = 0.5 * (f_umR_evol_y + f_uiL_evol_y) - 0.5 * alpha_y * (uiL_evol_y - umR_evol_y);

        // Right interface flux: F_{j + 1/2} = 0.5 * (f(u_{j + 1, L+}) + f(u_{j, R+})) - 0.5 * alpha * (u_{j + 1, L+} - u_{j, R+}).
        double fluxR_y = 0.5 * (f_uiR_evol_y + f_upL_evol_y) - 0.5 * alpha_y * (upL_evol_y - uiR_evol_y);

        // Update the conserved variable.
        un[i][j] = u[i][j] - (dt / (2.0 * dy)) * (fluxR_y - fluxL_y);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      u[0][j] = u[2][j];
      u[1][j] = u[2][j];
      u[nx + 2][j] = u[nx + 1][j];
      u[nx + 3][j] = u[nx + 1][j];

      un[0][j] = un[2][j];
      un[1][j] = un[2][j];
      un[nx + 2][j] = un[nx + 1][j];
      un[nx + 3][j] = un[nx + 1][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      u[i][0] = u[i][2];
      u[i][1] = u[i][2];
      u[i][ny + 2] = u[i][ny + 1];
      u[i][ny + 3] = u[i][ny + 1];

      un[i][0] = un[i][2];
      un[i][1] = un[i][2];
      un[i][ny + 2] = un[i][ny + 1];
      un[i][ny + 3] = un[i][ny + 1];
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        double r = (u[i][j] - u[i - 1][j]) / (u[i + 1][j] - u[i][j]);
        double limiter = ~a; // limiter-r in C.

        slope_x[i][j] = limiter * (0.5 * ((u[i][j] - u[i - 1][j]) + (u[i + 1][j] - u[i][j])));
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation (with a second-order flux extrapolation) and update the conserved variable in the x-direction.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j<= ny + 1; j++) {
        // Extrapolate boundary states.
        double umL_x = u[i - 1][j] - (0.5 * slope_x[i - 1][j]);
        double umR_x = u[i - 1][j] + (0.5 * slope_x[i - 1][j]);

        double uiL_x = u[i][j] - (0.5 * slope_x[i][j]);
        double uiR_x = u[i][j] + (0.5 * slope_x[i][j]);

        double upL_x = u[i + 1][j] - (0.5 * slope_x[i + 1][j]);
        double upR_x = u[i + 1][j] + (0.5 * slope_x[i + 1][j]);

        // Evaluate flux for each extrapolated boundary state.
        double f_umL_x = ~a;
        double f_umR_x = ~a;

        double f_uiL_x = ~a;
        double f_uiR_x = ~a;

        double f_upL_x = ~a;
        double f_upR_x = ~a;

        // Evolve each extrapolated boundary state.
        double umR_evol_x = umR_x + ((dt / (2.0 * dx)) * (f_umL_x - f_umR_x));

        double uiL_evol_x = uiL_x + ((dt / (2.0 * dx)) * (f_uiL_x - f_uiR_x));
        double uiR_evol_x = uiR_x + ((dt / (2.0 * dx)) * (f_uiL_x - f_uiR_x));

        double upL_evol_x = upL_x + ((dt / (2.0 * dx)) * (f_upL_x - f_upR_x));

        // Evaluate flux for each value of the (evolved) conserved variable.
        double f_umR_evol_x = ~a;
        double f_uiL_evol_x = ~a;

        double f_uiR_evol_x = ~a;
        double f_upL_evol_x = ~a;

        // Left interface flux: F_{i - 1/2} = 0.5 * (f(u_{i - 1, R+}) + f(u_{i, L+})) - 0.5 * alpha * (u_{i, L+} - u_{i - 1, R+}).
        double fluxL_x = 0.5 * (f_umR_evol_x + f_uiL_evol_x) - 0.5 * alpha_x * (uiL_evol_x - umR_evol_x);

        // Right interface flux: F_{i + 1/2} = 0.5 * (f(u_{i + 1, L+}) + f(u_{i, R+})) - 0.5 * alpha * (u_{i + 1, L+} - u_{i, R+}).
        double fluxR_x = 0.5 * (f_uiR_evol_x + f_upL_evol_x) - 0.5 * alpha_x * (upL_evol_x - uiR_evol_x);

        // Update the conserved variable.
        un[i][j] = u[i][j] - (dt / dx) * (fluxR_x - fluxL_x);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      u[0][j] = u[2][j];
      u[1][j] = u[2][j];
      u[nx + 2][j] = u[nx + 1][j];
      u[nx + 3][j] = u[nx + 1][j];

      un[0][j] = un[2][j];
      un[1][j] = un[2][j];
      un[nx + 2][j] = un[nx + 1][j];
      un[nx + 3][j] = un[nx + 1][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      u[i][0] = u[i][2];
      u[i][1] = u[i][2];
      u[i][ny + 2] = u[i][ny + 1];
      u[i][ny + 3] = u[i][ny + 1];

      un[i][0] = un[i][2];
      un[i][1] = un[i][2];
      un[i][ny + 2] = un[i][ny + 1];
      un[i][ny + 3] = un[i][ny + 1];
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        double r = (u[i][j] - u[i][j - 1]) / (u[i][j + 1] - u[i][j]);
        double limiter = ~a; // limiter-r in C.
        
        slope_y[i][j] = limiter * (0.5 * ((u[i][j] - u[i][j - 1]) + (u[i][j + 1] - u[i][j])));
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation (with a second-order flux extrapolation) and update the conserved variable in the y-direction by half a time-step.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j<= ny + 1; j++) {
        // Extrapolate boundary states.
        double umL_y = u[i][j - 1] - (0.5 * slope_y[i][j - 1]);
        double umR_y = u[i][j - 1] + (0.5 * slope_y[i][j - 1]);
        
        double uiL_y = u[i][j] - (0.5 * slope_y[i][j]);
        double uiR_y = u[i][j] + (0.5 * slope_y[i][j]);

        double upL_y = u[i][j + 1] - (0.5 * slope_y[i][j + 1]);
        double upR_y = u[i][j + 1] + (0.5 * slope_y[i][j + 1]);

        // Evaluate flux for each extrapolated boundary state.
        double f_umL_y = ~a;
        double f_umR_y = ~a;

        double f_uiL_y = ~a;
        double f_uiR_y = ~a;

        double f_upL_y = ~a;
        double f_upR_y = ~a;

        // Evolve each extrapolated boundary state.
        double umR_evol_y = umR_y + ((dt / (4.0 * dy)) * (f_umL_y - f_umR_y));

        double uiL_evol_y = uiL_y + ((dt / (4.0 * dy)) * (f_uiL_y - f_uiR_y));
        double uiR_evol_y = uiR_y + ((dt / (4.0 * dy)) * (f_uiL_y - f_uiR_y));

        double upL_evol_y = upL_y + ((dt / (4.0 * dy)) * (f_upL_y - f_upR_y));

        // Evaluate flux for each value of the (evolved) conserved variable.
        double f_umR_evol_y = ~a;
        double f_uiL_evol_y = ~a;

        double f_uiR_evol_y = ~a;
        double f_upL_evol_y = ~a;

        // Left interface flux: F_{j - 1/2} = 0.5 * (f(u_{j - 1, R+}) + f(u_{j, L+})) - 0.5 * alpha * (u_{j, L+} - u_{j - 1, R+}).
        double fluxL_y = 0.5 * (f_umR_evol_y + f_uiL_evol_y) - 0.5 * alpha_y * (uiL_evol_y - umR_evol_y);

        // Right interface flux: F_{j + 1/2} = 0.5 * (f(u_{j + 1, L+}) + f(u_{j, R+})) - 0.5 * alpha * (u_{j + 1, L+} - u_{j, R+}).
        double fluxR_y = 0.5 * (f_uiR_evol_y + f_upL_evol_y) - 0.5 * alpha_y * (upL_evol_y - uiR_evol_y);

        // Update the conserved variable.
        un[i][j] = u[i][j] - (dt / (2.0 * dy)) * (fluxR_y - fluxL_y);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      u[0][j] = u[2][j];
      u[1][j] = u[2][j];
      u[nx + 2][j] = u[nx + 1][j];
      u[nx + 3][j] = u[nx + 1][j];

      un[0][j] = un[2][j];
      un[1][j] = un[2][j];
      un[nx + 2][j] = un[nx + 1][j];
      un[nx + 3][j] = un[nx + 1][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      u[i][0] = u[i][2];
      u[i][1] = u[i][2];
      u[i][ny + 2] = u[i][ny + 1];
      u[i][ny + 3] = u[i][ny + 1];

      un[i][0] = un[i][2];
      un[i][1] = un[i][2];
      un[i][ny + 2] = un[i][ny + 1];
      un[i][ny + 3] = un[i][ny + 1];
    }

    // Output solution to disk.
    const char *fmt = \"%s_output_%d.csv\";
    int sz = snprintf(0, 0, fmt, \"~a\", n);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", n);
    
    FILE *fptr = fopen(file_nm, \"w\");
    if (fptr != NULL) {
      for (int i = 2; i <= nx + 1; i++) {
        for (int j = 2; j <= ny + 1; j++) {
          double x = x0 + (i - 1.5) * dx;
          double y = y0 + (j - 1.5) * dy;
          fprintf(fptr, \"%f, %f, %f\\n\", x, y, u[i][j]);
        }
      }

      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  for (int i = 0; i <= nx + 3; i++) {
    free(u[i]);
    free(un[i]);
    free(slope_x[i]);
    free(slope_y[i]);
  }
  free(u);
  free(un);
  free(slope_x);
  free(slope_y);
   
  return 0;
}
"
           ;; PDE name for code comments.
           name
           ;; Flux limiter name for code comments.
           limiter-name
           ;; Additional PDE parameters (e.g. a = 1.0 for linear advection).
           parameter-code
           ;; Number of cells in each coordinate direction.
           nx
           ny
           ;; Left/right boundaries.
           x0
           x1
           ;; Up/down boundaries
           y0
           y1
           ;; CFL coefficient.
           cfl
           ;; Final time.
           t-final
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           init-func-code
           init-func-code
           ;; Expressions for local wave-speed estimates.
           max-speed-local-x
           max-speed-local-y
           ;; Expressions for flux limiter function.
           limiter-r
           ;; Left/right negative fluxes in y-direction f(u_{j - 1, L}), f(u_{j - 1, R}).
           flux-umL-y
           flux-umR-y
           ;; Left/right central fluxes in y-direction f(u_{j, L}), f(u_{j, R}).
           flux-uiL-y
           flux-uiR-y
           ;; Left/right positive fluxes in y-direction f(u_{j + 1, L}), f(u_{j + 1, R}).
           flux-upL-y
           flux-upR-y
           ;; Evolved right negative flux in y-direction f(u_{j - 1, R+}).
           flux-umR-evol-y
           ;; Evolved left/right central fluxes in y-direction f(u_{j, L+}), f(u_{j, R+}).
           flux-uiL-evol-y
           flux-uiR-evol-y
           ;; Evolved left positive flux in y-direction f(u_{j + 1, L+}).
           flux-upL-evol-y
           ;; Expressions for flux limiter function.
           limiter-r
           ;; Left/right negative fluxes in x-direction f(u_{i - 1, L}), f(u_{i - 1, R}).
           flux-umL-x
           flux-umR-x
           ;; Left/right central fluxes in x-direction f(u_{i, L}), f(u_{i, R}).
           flux-uiL-x
           flux-uiR-x
           ;; Left/right positive fluxes in x-direction f(u_{i + 1, L}), f(u_{i + 1, R}).
           flux-upL-x
           flux-upR-x
           ;; Evolved right negative flux in x-direction f(u_{i - 1, R+}).
           flux-umR-evol-x
           ;; Evolved left/right central fluxes in x-direction f(u_{i, L+}), f(u_{i, R+}).
           flux-uiL-evol-x
           flux-uiR-evol-x
           ;; Evolved left positive flux in x-direction f(u_{i + 1, L+}).
           flux-upL-evol-x
           ;; Expressions for flux limiter function.
           limiter-r
           ;; Left/right negative fluxes in y-direction f(u_{j - 1, L}), f(u_{j - 1, R}).
           flux-umL-y
           flux-umR-y
           ;; Left/right central fluxes in y-direction f(u_{j, L}), f(u_{j, R}).
           flux-uiL-y
           flux-uiR-y
           ;; Left/right positive fluxes in y-direction f(u_{j + 1, L}), f(u_{j + 1, R}).
           flux-upL-y
           flux-upR-y
           ;; Evolved right negative flux in y-direction f(u_{j - 1, R+}).
           flux-umR-evol-y
           ;; Evolved left/right central fluxes in y-direction f(u_{j, L+}), f(u_{j, R+}).
           flux-uiL-evol-y
           flux-uiR-evol-y
           ;; Evolved left positive flux in y-direction f(u_{j + 1, L+}).
           flux-upL-evol-y
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ----------------------------------------------
;; Roe (Finite-Volume) Solver for a 2D Scalar PDE
;; ----------------------------------------------
(define (generate-roe-scalar-2d pde
                                #:nx [nx 200]
                                #:ny [ny 200]
                                #:x0 [x0 0.0]
                                #:x1 [x1 2.0]
                                #:y0 [y0 0.0]
                                #:y1 [y1 2.0]
                                #:t-final [t-final 1.0]
                                #:cfl [cfl 0.95]
                                #:init-func [init-func `(cond
                                                          [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.5) 1.0]
                                                          [else 0.0])])
 "Generate C code that solves the 2D scalar PDE specified by `pde` using the Roe finite-volume method.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-func`: Racket expression for the initial condition, e.g. piecewise constant."

  (define name (hash-ref pde 'name))
  (define cons-expr (hash-ref pde 'cons-expr))
  (define flux-expr-x (hash-ref pde 'flux-expr-x))
  (define flux-expr-y (hash-ref pde 'flux-expr-y))
  (define max-speed-expr-x (hash-ref pde 'max-speed-expr-x))
  (define max-speed-expr-y (hash-ref pde 'max-speed-expr-y))
  (define parameters (hash-ref pde 'parameters))

  (define flux-deriv-x (symbolic-simp (symbolic-diff flux-expr-x cons-expr)))
  (define flux-deriv-y (symbolic-simp (symbolic-diff flux-expr-y cons-expr)))

  (define cons-code (convert-expr cons-expr))
  (define flux-code-x (convert-expr flux-expr-x))
  (define flux-code-y (convert-expr flux-expr-y))
  (define flux-deriv-code-x (convert-expr flux-deriv-x))
  (define flux-deriv-code-y (convert-expr flux-deriv-y))
  (define max-speed-code-x (convert-expr max-speed-expr-x))
  (define max-speed-code-y (convert-expr max-speed-expr-y))
  (define init-func-code (convert-expr init-func))

  (define flux-um-x (flux-substitute flux-code-x cons-code "um_x"))
  (define flux-ui-x (flux-substitute flux-code-x cons-code "ui_x"))
  (define flux-up-x (flux-substitute flux-code-x cons-code "up_x"))

  (define flux-um-y (flux-substitute flux-code-y cons-code "um_y"))
  (define flux-ui-y (flux-substitute flux-code-y cons-code "ui_y"))
  (define flux-up-y (flux-substitute flux-code-y cons-code "up_y"))

  (define flux-deriv-um-x (flux-substitute flux-deriv-code-x cons-code "um_x"))
  (define flux-deriv-ui-x (flux-substitute flux-deriv-code-x cons-code "ui_x"))
  (define flux-deriv-up-x (flux-substitute flux-deriv-code-x cons-code "up_x"))

  (define flux-deriv-um-y (flux-substitute flux-deriv-code-y cons-code "um_y"))
  (define flux-deriv-ui-y (flux-substitute flux-deriv-code-y cons-code "ui_y"))
  (define flux-deriv-up-y (flux-substitute flux-deriv-code-y cons-code "up_y"))

  (define max-speed-local-x (flux-substitute max-speed-code-x cons-code "u[i][j]"))
  (define max-speed-local-y (flux-substitute max-speed-code-y cons-code "u[i][j]"))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR SCALAR PDE: ~a
// Roe higher-order finite-volume solver for a scalar PDE in 2D.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Additional PDE parameters (if any).
~a

int main() {
  // Spatial domain setup.
  const int nx = ~a;
  const int ny = ~a;
  const double x0 = ~a;
  const double x1 = ~a;
  const double y0 = ~a;
  const double y1 = ~a;
  const double Lx = (x1 - x0);
  const double Ly = (y1 - y0);
  const double dx = Lx / nx;
  const double dy = Ly / ny;

  // Time-stepper setup.
  const double cfl = ~a;
  const double t_final = ~a;

  // Arrays for storing solution.
  double **u = (double**) malloc((nx + 2) * sizeof(double*));
  double **un = (double**) malloc((nx + 2) * sizeof(double*));
  for (int i = 0; i <= nx + 1; i++) {
    u[i] = (double*) malloc((ny + 2) * sizeof(double));
    un[i] = (double*) malloc((ny + 2) * sizeof(double));
  }

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    for (int j = 0; j <= ny + 1; j++) {
      double x = x0 + (i - 0.5) * dx;
      double y = y0 + (j - 0.5) * dy;
    
      u[i][j] = ~a; // init-func in C.
      un[i][j] = ~a; // init-func in C.
    }
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha_x = 0.0;
    double alpha_y = 0.0;
    
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        double local_alpha_x = ~a; // max-speed-expr-x in C.
        double local_alpha_y = ~a; // max-speed-expr-y in C.
      
        if (local_alpha_x > alpha_x) {
          alpha_x = local_alpha_x;
        }
        if (local_alpha_y > alpha_y) {
          alpha_y = local_alpha_y;
        }
      }
    }

    // Avoid division by zero.
    if (alpha_x < 1e-14) {
      alpha_x = 1e-14;
    }
    if (alpha_y < 1e-14) {
      alpha_y = 1e-14;
    }

    // Compute stable time step from alpha.
    double dt = fmin(cfl * dx / alpha_x, cfl * dy / alpha_y);

    // If stepping beyond t_final, adjust dt accordingly.
    if (t + dt > t_final) {
      dt = t_final - t;
    }

    // Compute fluxes with Roe approximation and update the conserved variable in the y-direction by half a time-step.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        double um_y = u[i][j - 1];
        double ui_y = u[i][j];
        double up_y = u[i][j + 1];

        // Evaluate flux for each value of the conserved variable.
        double f_um_y = ~a; // f(u_{j - 1}).
        double f_ui_y = ~a; // f(u_j).
        double f_up_y = ~a; // f(u_{j + 1}).

        // Evaluate flux derivative for each value of the conserved variable.
        double f_deriv_um_y = ~a; // f'(u_{j - 1}).
        double f_deriv_ui_y = ~a; // f'(u_j).
        double f_deriv_up_y = ~a; // f'(u_{j + 1}).

        // Left interface flux: F_{j - 1/2} = 0.5 * (f(u_{j - 1}) + f(u_j)) - 0.5 * |aL_roe_y| * (u_j - u_{j - 1}).
        double aL_roe_y = 0.5 * (f_deriv_um_y + f_deriv_ui_y);
        double fluxL_y = 0.5 * (f_um_y + f_ui_y) - 0.5 * fabs(aL_roe_y) * (ui_y - um_y);

        // Right interface flux: F_{j + 1/2} = 0.5 * (f(u_{j + 1}) + f(u_j)) - 0.5 * |aR_roe_y| * (u_{j + 1} - u_j).
        double aR_roe_y = 0.5 * (f_deriv_ui_y + f_deriv_up_y);
        double fluxR_y = 0.5 * (f_ui_y + f_up_y) - 0.5 * fabs(aR_roe_y) * (up_y - ui_y);

        // Update the conserved variable.
        un[i][j] = ui_y - (dt / (2.0 * dy)) * (fluxR_y - fluxL_y);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      u[0][j] = u[1][j];
      u[nx + 1][j] = u[nx][j];

      un[0][j] = un[1][j];
      un[nx + 1][j] = un[nx][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      u[i][0] = u[i][1];
      u[i][ny + 1] = u[i][ny];

      un[i][0] = un[i][1]; 
      un[i][ny + 1] = un[i][ny];
    }

    // Compute fluxes with Roe approximation and update the conserved variable in the x-direction.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        double um_x = u[i - 1][j];
        double ui_x = u[i][j];
        double up_x = u[i + 1][j];

        // Evaluate flux for each value of the conserved variable.
        double f_um_x = ~a; // f(u_{i - 1}).
        double f_ui_x = ~a; // f(u_i).
        double f_up_x = ~a; // f(u_{i + 1}).

        // Evaluate flux derivative for each value of the conserved variable.
        double f_deriv_um_x = ~a; // f'(u_{i - 1}).
        double f_deriv_ui_x = ~a; // f'(u_i).
        double f_deriv_up_x = ~a; // f'(u_{i + 1}).

        // Left interface flux: F_{i - 1/2} = 0.5 * (f(u_{i - 1}) + f(u_i)) - 0.5 * |aL_roe_x| * (u_i - u_{i - 1}).
        double aL_roe_x = 0.5 * (f_deriv_um_x + f_deriv_ui_x);
        double fluxL_x = 0.5 * (f_um_x + f_ui_x) - 0.5 * fabs(aL_roe_x) * (ui_x - um_x);

        // Right interface flux: F_{i + 1/2} = 0.5 * (f(u_{i + 1}) + f(u_i)) - 0.5 * |aR_roe_x| * (u_{i + 1} - u_i).
        double aR_roe_x = 0.5 * (f_deriv_ui_x + f_deriv_up_x);
        double fluxR_x = 0.5 * (f_ui_x + f_up_x) - 0.5 * fabs(aR_roe_x) * (up_x - ui_x);

        // Update the conserved variable.
        un[i][j] = ui_x - (dt / dx) * (fluxR_x - fluxL_x);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      u[0][j] = u[1][j];
      u[nx + 1][j] = u[nx][j];

      un[0][j] = un[1][j];
      un[nx + 1][j] = un[nx][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      u[i][0] = u[i][1];
      u[i][ny + 1] = u[i][ny];

      un[i][0] = un[i][1]; 
      un[i][ny + 1] = un[i][ny];
    }

    // Compute fluxes with Roe approximation and update the conserved variable in the y-direction by half a time-step.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        double um_y = u[i][j - 1];
        double ui_y = u[i][j];
        double up_y = u[i][j + 1];

        // Evaluate flux for each value of the conserved variable.
        double f_um_y = ~a; // f(u_{j - 1}).
        double f_ui_y = ~a; // f(u_j).
        double f_up_y = ~a; // f(u_{j + 1}).

        // Evaluate flux derivative for each value of the conserved variable.
        double f_deriv_um_y = ~a; // f'(u_{j - 1}).
        double f_deriv_ui_y = ~a; // f'(u_j).
        double f_deriv_up_y = ~a; // f'(u_{j + 1}).

        // Left interface flux: F_{j - 1/2} = 0.5 * (f(u_{j - 1}) + f(u_j)) - 0.5 * |aL_roe_y| * (u_j - u_{j - 1}).
        double aL_roe_y = 0.5 * (f_deriv_um_y + f_deriv_ui_y);
        double fluxL_y = 0.5 * (f_um_y + f_ui_y) - 0.5 * fabs(aL_roe_y) * (ui_y - um_y);

        // Right interface flux: F_{j + 1/2} = 0.5 * (f(u_{j + 1}) + f(u_j)) - 0.5 * |aR_roe_y| * (u_{j + 1} - u_j).
        double aR_roe_y = 0.5 * (f_deriv_ui_y + f_deriv_up_y);
        double fluxR_y = 0.5 * (f_ui_y + f_up_y) - 0.5 * fabs(aR_roe_y) * (up_y - ui_y);

        // Update the conserved variable.
        un[i][j] = ui_y - (dt / (2.0 * dy)) * (fluxR_y - fluxL_y);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      u[0][j] = u[1][j];
      u[nx + 1][j] = u[nx][j];

      un[0][j] = un[1][j];
      un[nx + 1][j] = un[nx][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      u[i][0] = u[i][1];
      u[i][ny + 1] = u[i][ny];

      un[i][0] = un[i][1]; 
      un[i][ny + 1] = un[i][ny];
    }

    // Output solution to disk.
    const char *fmt = \"%s_output_%d.csv\";
    int sz = snprintf(0, 0, fmt, \"~a\", n);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", n);
    
    FILE *fptr = fopen(file_nm, \"w\");
    if (fptr != NULL) {
      for (int i = 1; i <= nx; i++) {
        for (int j = 1; j <= ny; j++) {
          double x = x0 + (i - 0.5) * dx;
          double y = y0 + (j - 0.5) * dy;
          fprintf(fptr, \"%f, %f, %f\\n\", x, y, u[i][j]);
        }
      }

      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  for (int i = 0; i <= nx + 1; i++) {
    free(u[i]);
    free(un[i]);
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
           ;; Number of cells in each coordinate direction.
           nx
           ny
           ;; Left/right boundaries.
           x0
           x1
           ;; Up/down boundaries
           y0
           y1
           ;; CFL coefficient.
           cfl
           ;; Final time.
           t-final
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           init-func-code
           init-func-code
           ;; Expressions for local wave-speed estimates.
           max-speed-local-x
           max-speed-local-y
           ;; Left, middle, right fluxes in y-direction f(u_{j - 1}), f(u_j), f(u_{j + 1}).
           flux-um-y
           flux-ui-y
           flux-up-y
           ;; Left, middle, right flux derivatives in y-direction f'(u_{j - 1}), f'(u_j), f'(u_{j + 1}).
           flux-deriv-um-y
           flux-deriv-ui-y
           flux-deriv-up-y
           ;; Left, middle, right fluxes in x-direction f(u_{i - 1}), f(u_i), f(u_{i + 1}).
           flux-um-x
           flux-ui-x
           flux-up-x
           ;; Left, middle, right flux derivatives in x-direction f'(u_{i - 1}), f'(u_i), f'(u_{i + 1}).
           flux-deriv-um-x
           flux-deriv-ui-x
           flux-deriv-up-x
           ;; Left, middle, right fluxes in y-direction f(u_{j - 1}), f(u_j), f(u_{j + 1}).
           flux-um-y
           flux-ui-y
           flux-up-y
           ;; Left, middle, right flux derivatives in y-direction f'(u_{j - 1}), f'(u_j), f'(u_{j + 1}).
           flux-deriv-um-y
           flux-deriv-ui-y
           flux-deriv-up-y
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; -------------------------------------------------------------------------------------
;; Roe (Finite-Volume) Solver for a 2D Scalar PDE with a Second-Order Flux Extrapolation
;; -------------------------------------------------------------------------------------
(define (generate-roe-scalar-2d-second-order pde limiter
                                             #:nx [nx 200]
                                             #:ny [ny 200]
                                             #:x0 [x0 0.0]
                                             #:x1 [x1 2.0]
                                             #:y0 [y0 0.0]
                                             #:y1 [y1 2.0]
                                             #:t-final [t-final 1.0]
                                             #:cfl [cfl 0.95]
                                             #:init-func [init-func `(cond
                                                                       [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.5) 1.0]
                                                                       [else 0.0])])
 "Generate C code that solves the 2D scalar PDE specified by `pde` using the Roe finite-volume method with a second-order flux extrapolation using flux limiter `limiter`.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-func`: Racket expression for the initial condition, e.g. piecewise constant."

  (define name (hash-ref pde 'name))
  (define cons-expr (hash-ref pde 'cons-expr))
  (define flux-expr-x (hash-ref pde 'flux-expr-x))
  (define flux-expr-y (hash-ref pde 'flux-expr-y))
  (define max-speed-expr-x (hash-ref pde 'max-speed-expr-x))
  (define max-speed-expr-y (hash-ref pde 'max-speed-expr-y))
  (define parameters (hash-ref pde 'parameters))

  (define limiter-name (hash-ref limiter 'name))
  (define limiter-expr (hash-ref limiter 'limiter-expr))
  (define limiter-ratio (hash-ref limiter 'limiter-ratio))

  (define limiter-code (convert-expr limiter-expr))
  (define limiter-ratio-code (convert-expr limiter-ratio))

  (define flux-deriv-x (symbolic-simp (symbolic-diff flux-expr-x cons-expr)))
  (define flux-deriv-y (symbolic-simp (symbolic-diff flux-expr-y cons-expr)))

  (define cons-code (convert-expr cons-expr))
  (define flux-code-x (convert-expr flux-expr-x))
  (define flux-code-y (convert-expr flux-expr-y))
  (define flux-deriv-code-x (convert-expr flux-deriv-x))
  (define flux-deriv-code-y (convert-expr flux-deriv-y))
  (define max-speed-code-x (convert-expr max-speed-expr-x))
  (define max-speed-code-y (convert-expr max-speed-expr-y))
  (define init-func-code (convert-expr init-func))

  (define limiter-r (flux-substitute limiter-code limiter-ratio-code "r"))

  (define flux-umL-x (flux-substitute flux-code-x cons-code "umL_x"))
  (define flux-umR-x (flux-substitute flux-code-x cons-code "umR_x"))
  (define flux-uiL-x (flux-substitute flux-code-x cons-code "uiL_x"))
  (define flux-uiR-x (flux-substitute flux-code-x cons-code "uiR_x"))
  (define flux-upL-x (flux-substitute flux-code-x cons-code "upL_x"))
  (define flux-upR-x (flux-substitute flux-code-x cons-code "upR_x"))

  (define flux-umR-evol-x (flux-substitute flux-code-x cons-code "umR_evol_x"))
  (define flux-uiL-evol-x (flux-substitute flux-code-x cons-code "uiL_evol_x"))
  (define flux-uiR-evol-x (flux-substitute flux-code-x cons-code "uiR_evol_x"))
  (define flux-upL-evol-x (flux-substitute flux-code-x cons-code "upL_evol_x"))

  (define flux-deriv-umR-evol-x (flux-substitute flux-deriv-code-x cons-code "umR_evol_x"))
  (define flux-deriv-uiL-evol-x (flux-substitute flux-deriv-code-x cons-code "uiL_evol_x"))
  (define flux-deriv-uiR-evol-x (flux-substitute flux-deriv-code-x cons-code "uiR_evol_x"))
  (define flux-deriv-upL-evol-x (flux-substitute flux-deriv-code-x cons-code "upL_evol_x"))

  (define flux-umL-y (flux-substitute flux-code-y cons-code "umL_y"))
  (define flux-umR-y (flux-substitute flux-code-y cons-code "umR_y"))
  (define flux-uiL-y (flux-substitute flux-code-y cons-code "uiL_y"))
  (define flux-uiR-y (flux-substitute flux-code-y cons-code "uiR_y"))
  (define flux-upL-y (flux-substitute flux-code-y cons-code "upL_y"))
  (define flux-upR-y (flux-substitute flux-code-y cons-code "upR_y"))

  (define flux-umR-evol-y (flux-substitute flux-code-y cons-code "umR_evol_y"))
  (define flux-uiL-evol-y (flux-substitute flux-code-y cons-code "uiL_evol_y"))
  (define flux-uiR-evol-y (flux-substitute flux-code-y cons-code "uiR_evol_y"))
  (define flux-upL-evol-y (flux-substitute flux-code-y cons-code "upL_evol_y"))

  (define flux-deriv-umR-evol-y (flux-substitute flux-deriv-code-y cons-code "umR_evol_y"))
  (define flux-deriv-uiL-evol-y (flux-substitute flux-deriv-code-y cons-code "uiL_evol_y"))
  (define flux-deriv-uiR-evol-y (flux-substitute flux-deriv-code-y cons-code "uiR_evol_y"))
  (define flux-deriv-upL-evol-y (flux-substitute flux-deriv-code-y cons-code "upL_evol_y"))

  (define max-speed-local-x (flux-substitute max-speed-code-x cons-code "u[i][j]"))
  (define max-speed-local-y (flux-substitute max-speed-code-y cons-code "u[i][j]"))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR SCALAR PDE: ~a
// FLUX LIMITER: ~a
// Roe higher-order finite-volume solver for a scalar PDE in 2D, with a second-order flux extrapolation.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Additional PDE parameters (if any).
~a

int main() {
  // Spatial domain setup.
  const int nx = ~a;
  const int ny = ~a;
  const double x0 = ~a;
  const double x1 = ~a;
  const double y0 = ~a;
  const double y1 = ~a;
  const double Lx = (x1 - x0);
  const double Ly = (y1 - y0);
  const double dx = Lx / nx;
  const double dy = Ly / ny;

  // Time-stepper setup.
  const double cfl = ~a;
  const double t_final = ~a;

  // Arrays for storing slopes.
  double **slope_x = (double**) malloc((nx + 4) * sizeof(double*));
  double **slope_y = (double**) malloc((nx + 4) * sizeof(double*));
  for (int i = 0; i <= nx + 3; i++) {
    slope_x[i] = (double*) malloc((ny + 4) * sizeof(double));
    slope_y[i] = (double*) malloc((ny + 4) * sizeof(double));
  }
  
  // Arrays for storing solution.
  double **u = (double**) malloc((nx + 4) * sizeof(double*));
  double **un = (double**) malloc((nx + 4) * sizeof(double*));
  for (int i = 0; i <= nx + 3; i++) {
    u[i] = (double*) malloc((ny + 4) * sizeof(double));
    un[i] = (double*) malloc((ny + 4) * sizeof(double));
  }

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    for (int j = 0; j <= ny + 3; j++) {
      double x = x0 + (i - 1.5) * dx;
      double y = y0 + (j - 1.5) * dy;
    
      u[i][j] = ~a; // init-func in C.
      un[i][j] = ~a; // init-func in C.
    }
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha_x = 0.0;
    double alpha_y = 0.0;
    
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        double local_alpha_x = ~a; // max-speed-expr-x in C.
        double local_alpha_y = ~a; // max-speed-expr-y in C.
      
        if (local_alpha_x > alpha_x) {
          alpha_x = local_alpha_x;
        }
        if (local_alpha_y > alpha_y) {
          alpha_y = local_alpha_y;
        }
      }
    }

    // Avoid division by zero.
    if (alpha_x < 1e-14) {
      alpha_x = 1e-14;
    }
    if (alpha_y < 1e-14) {
      alpha_y = 1e-14;
    }

    // Compute stable time step from alpha.
    double dt = fmin(cfl * dx / alpha_x, cfl * dy / alpha_y);

    // If stepping beyond t_final, adjust dt accordingly.
    if (t + dt > t_final) {
      dt = t_final - t;
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        double r = (u[i][j] - u[i][j - 1]) / (u[i][j + 1] - u[i][j]);
        double limiter = ~a; // limiter-r in C.
        
        slope_y[i][j] = limiter * (0.5 * ((u[i][j] - u[i][j - 1]) + (u[i][j + 1] - u[i][j])));
      }
    }

    // Compute fluxes with Roe approximation (with a second-order flux extrapolation) and update the conserved variable in the y-direction by half a time-step.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j<= ny + 1; j++) {
        // Extrapolate boundary states.
        double umL_y = u[i][j - 1] - (0.5 * slope_y[i][j - 1]);
        double umR_y = u[i][j - 1] + (0.5 * slope_y[i][j - 1]);

        double uiL_y = u[i][j] - (0.5 * slope_y[i][j]);
        double uiR_y = u[i][j] + (0.5 * slope_y[i][j]);

        double upL_y = u[i][j + 1] - (0.5 * slope_y[i][j + 1]);
        double upR_y = u[i][j + 1] + (0.5 * slope_y[i][j + 1]);

        // Evaluate flux for each extrapolated boundary state.
        double f_umL_y = ~a;
        double f_umR_y = ~a;

        double f_uiL_y = ~a;
        double f_uiR_y = ~a;

        double f_upL_y = ~a;
        double f_upR_y = ~a;

        // Evolve each extrapolated boundary state.
        double umR_evol_y = umR_y + ((dt / (4.0 * dy)) * (f_umL_y - f_umR_y));

        double uiL_evol_y = uiL_y + ((dt / (4.0 * dy)) * (f_uiL_y - f_uiR_y));
        double uiR_evol_y = uiR_y + ((dt / (4.0 * dy)) * (f_uiL_y - f_uiR_y));

        double upL_evol_y = upL_y + ((dt / (4.0 * dy)) * (f_upL_y - f_upR_y));

        // Evaluate flux for each value of the (evolved) conserved variable.
        double f_umR_evol_y = ~a;
        double f_uiL_evol_y = ~a;

        double f_uiR_evol_y = ~a;
        double f_upL_evol_y = ~a;

        // Evaluate flux derivative for each value of the (evolved) conserved variable.
        double f_deriv_umR_evol_y = ~a;
        double f_deriv_uiL_evol_y = ~a;

        double f_deriv_uiR_evol_y = ~a;
        double f_deriv_upL_evol_y = ~a;

        // Left interface flux: F_{j - 1/2} = 0.5 * (f(u_{j - 1, R+}) + f(u_{j, L+})) - 0.5 * |aL_roe_y| * (u_{j, L+} - u_{j - 1, R+}).
        double aL_roe_y = 0.5 * (f_deriv_umR_evol_y + f_deriv_uiL_evol_y);
        double fluxL_y = 0.5 * (f_umR_evol_y + f_uiL_evol_y) - 0.5 * fabs(aL_roe_y) * (uiL_evol_y - umR_evol_y);

        // Right interface flux: F_{j + 1/2} = 0.5 * (f(u_{j + 1, L+}) + f(u_{j, R+})) - 0.5 * |aR_roe_y| * (u_{j + 1, L+} - u_{j, R+}).
        double aR_roe_y = 0.5 * (f_deriv_uiR_evol_y + f_deriv_upL_evol_y);
        double fluxR_y = 0.5 * (f_uiR_evol_y + f_upL_evol_y) - 0.5 * fabs(aR_roe_y) * (upL_evol_y - uiR_evol_y);

        // Update the conserved variable.
        un[i][j] = u[i][j] - (dt / (2.0 * dy)) * (fluxR_y - fluxL_y);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      u[0][j] = u[2][j];
      u[1][j] = u[2][j];
      u[nx + 2][j] = u[nx + 1][j];
      u[nx + 3][j] = u[nx + 1][j];

      un[0][j] = un[2][j];
      un[1][j] = un[2][j];
      un[nx + 2][j] = un[nx + 1][j];
      un[nx + 3][j] = un[nx + 1][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      u[i][0] = u[i][2];
      u[i][1] = u[i][2];
      u[i][ny + 2] = u[i][ny + 1];
      u[i][ny + 3] = u[i][ny + 1];

      un[i][0] = un[i][2];
      un[i][1] = un[i][2];
      un[i][ny + 2] = un[i][ny + 1];
      un[i][ny + 3] = un[i][ny + 1];
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        double r = (u[i][j] - u[i - 1][j]) / (u[i + 1][j] - u[i][j]);
        double limiter = ~a; // limiter-r in C.

        slope_x[i][j] = limiter * (0.5 * ((u[i][j] - u[i - 1][j]) + (u[i + 1][j] - u[i][j])));
      }
    }

    // Compute fluxes with Roe approximation (with a second-order flux extrapolation) and update the conserved variable in the x-direction.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j<= ny + 1; j++) {
        // Extrapolate boundary states.
        double umL_x = u[i - 1][j] - (0.5 * slope_x[i - 1][j]);
        double umR_x = u[i - 1][j] + (0.5 * slope_x[i - 1][j]);

        double uiL_x = u[i][j] - (0.5 * slope_x[i][j]);
        double uiR_x = u[i][j] + (0.5 * slope_x[i][j]);

        double upL_x = u[i + 1][j] - (0.5 * slope_x[i + 1][j]);
        double upR_x = u[i + 1][j] + (0.5 * slope_x[i + 1][j]);

        // Evaluate flux for each extrapolated boundary state.
        double f_umL_x = ~a;
        double f_umR_x = ~a;

        double f_uiL_x = ~a;
        double f_uiR_x = ~a;

        double f_upL_x = ~a;
        double f_upR_x = ~a;

        // Evolve each extrapolated boundary state.
        double umR_evol_x = umR_x + ((dt / (2.0 * dx)) * (f_umL_x - f_umR_x));

        double uiL_evol_x = uiL_x + ((dt / (2.0 * dx)) * (f_uiL_x - f_uiR_x));
        double uiR_evol_x = uiR_x + ((dt / (2.0 * dx)) * (f_uiL_x - f_uiR_x));

        double upL_evol_x = upL_x + ((dt / (2.0 * dx)) * (f_upL_x - f_upR_x));

        // Evaluate flux for each value of the (evolved) conserved variable.
        double f_umR_evol_x = ~a;
        double f_uiL_evol_x = ~a;

        double f_uiR_evol_x = ~a;
        double f_upL_evol_x = ~a;

        // Evaluate flux derivative for each value of the (evolved) conserved variable.
        double f_deriv_umR_evol_x = ~a;
        double f_deriv_uiL_evol_x = ~a;

        double f_deriv_uiR_evol_x = ~a;
        double f_deriv_upL_evol_x = ~a;

        // Left interface flux: F_{i - 1/2} = 0.5 * (f(u_{i - 1, R+}) + f(u_{i, L+})) - 0.5 * |aL_roe_x| * (u_{i, L+} - u_{i - 1, R+}).
        double aL_roe_x = 0.5 * (f_deriv_umR_evol_x + f_deriv_uiL_evol_x);
        double fluxL_x = 0.5 * (f_umR_evol_x + f_uiL_evol_x) - 0.5 * fabs(aL_roe_x) * (uiL_evol_x - umR_evol_x);

        // Right interface flux: F_{i + 1/2} = 0.5 * (f(u_{i + 1, L+}) + f(u_{i, R+})) - 0.5 * |aR_roe_x| * (u_{i + 1, L+} - u_{i, R+}).
        double aR_roe_x = 0.5 * (f_deriv_uiR_evol_x + f_deriv_upL_evol_x);
        double fluxR_x = 0.5 * (f_uiR_evol_x + f_upL_evol_x) - 0.5 * fabs(aR_roe_x) * (upL_evol_x - uiR_evol_x);

        // Update the conserved variable.
        un[i][j] = u[i][j] - (dt / dx) * (fluxR_x - fluxL_x);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      u[0][j] = u[2][j];
      u[1][j] = u[2][j];
      u[nx + 2][j] = u[nx + 1][j];
      u[nx + 3][j] = u[nx + 1][j];

      un[0][j] = un[2][j];
      un[1][j] = un[2][j];
      un[nx + 2][j] = un[nx + 1][j];
      un[nx + 3][j] = un[nx + 1][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      u[i][0] = u[i][2];
      u[i][1] = u[i][2];
      u[i][ny + 2] = u[i][ny + 1];
      u[i][ny + 3] = u[i][ny + 1];

      un[i][0] = un[i][2];
      un[i][1] = un[i][2];
      un[i][ny + 2] = un[i][ny + 1];
      un[i][ny + 3] = un[i][ny + 1];
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        double r = (u[i][j] - u[i][j - 1]) / (u[i][j + 1] - u[i][j]);
        double limiter = ~a; // limiter-r in C.
        
        slope_y[i][j] = limiter * (0.5 * ((u[i][j] - u[i][j - 1]) + (u[i][j + 1] - u[i][j])));
      }
    }

    // Compute fluxes with Roe approximation (with a second-order flux extrapolation) and update the conserved variable in the y-direction by half a time-step.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j<= ny + 1; j++) {
        // Extrapolate boundary states.
        double umL_y = u[i][j - 1] - (0.5 * slope_y[i][j - 1]);
        double umR_y = u[i][j - 1] + (0.5 * slope_y[i][j - 1]);

        double uiL_y = u[i][j] - (0.5 * slope_y[i][j]);
        double uiR_y = u[i][j] + (0.5 * slope_y[i][j]);

        double upL_y = u[i][j + 1] - (0.5 * slope_y[i][j + 1]);
        double upR_y = u[i][j + 1] + (0.5 * slope_y[i][j + 1]);

        // Evaluate flux for each extrapolated boundary state.
        double f_umL_y = ~a;
        double f_umR_y = ~a;

        double f_uiL_y = ~a;
        double f_uiR_y = ~a;

        double f_upL_y = ~a;
        double f_upR_y = ~a;

        // Evolve each extrapolated boundary state.
        double umR_evol_y = umR_y + ((dt / (4.0 * dy)) * (f_umL_y - f_umR_y));

        double uiL_evol_y = uiL_y + ((dt / (4.0 * dy)) * (f_uiL_y - f_uiR_y));
        double uiR_evol_y = uiR_y + ((dt / (4.0 * dy)) * (f_uiL_y - f_uiR_y));

        double upL_evol_y = upL_y + ((dt / (4.0 * dy)) * (f_upL_y - f_upR_y));

        // Evaluate flux for each value of the (evolved) conserved variable.
        double f_umR_evol_y = ~a;
        double f_uiL_evol_y = ~a;

        double f_uiR_evol_y = ~a;
        double f_upL_evol_y = ~a;

        // Evaluate flux derivative for each value of the (evolved) conserved variable.
        double f_deriv_umR_evol_y = ~a;
        double f_deriv_uiL_evol_y = ~a;

        double f_deriv_uiR_evol_y = ~a;
        double f_deriv_upL_evol_y = ~a;

        // Left interface flux: F_{j - 1/2} = 0.5 * (f(u_{j - 1, R+}) + f(u_{j, L+})) - 0.5 * |aL_roe_y| * (u_{j, L+} - u_{j - 1, R+}).
        double aL_roe_y = 0.5 * (f_deriv_umR_evol_y + f_deriv_uiL_evol_y);
        double fluxL_y = 0.5 * (f_umR_evol_y + f_uiL_evol_y) - 0.5 * fabs(aL_roe_y) * (uiL_evol_y - umR_evol_y);

        // Right interface flux: F_{j + 1/2} = 0.5 * (f(u_{j + 1, L+}) + f(u_{j, R+})) - 0.5 * |aR_roe_y| * (u_{j + 1, L+} - u_{j, R+}).
        double aR_roe_y = 0.5 * (f_deriv_uiR_evol_y + f_deriv_upL_evol_y);
        double fluxR_y = 0.5 * (f_uiR_evol_y + f_upL_evol_y) - 0.5 * fabs(aR_roe_y) * (upL_evol_y - uiR_evol_y);

        // Update the conserved variable.
        un[i][j] = u[i][j] - (dt / (2.0 * dy)) * (fluxR_y - fluxL_y);
      }
    }

    // Copy un -> u (updated conserved variables to new conserved variables).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        u[i][j] = un[i][j];
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      u[0][j] = u[2][j];
      u[1][j] = u[2][j];
      u[nx + 2][j] = u[nx + 1][j];
      u[nx + 3][j] = u[nx + 1][j];

      un[0][j] = un[2][j];
      un[1][j] = un[2][j];
      un[nx + 2][j] = un[nx + 1][j];
      un[nx + 3][j] = un[nx + 1][j];
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      u[i][0] = u[i][2];
      u[i][1] = u[i][2];
      u[i][ny + 2] = u[i][ny + 1];
      u[i][ny + 3] = u[i][ny + 1];

      un[i][0] = un[i][2];
      un[i][1] = un[i][2];
      un[i][ny + 2] = un[i][ny + 1];
      un[i][ny + 3] = un[i][ny + 1];
    }

    // Output solution to disk.
    const char *fmt = \"%s_output_%d.csv\";
    int sz = snprintf(0, 0, fmt, \"~a\", n);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", n);
    
    FILE *fptr = fopen(file_nm, \"w\");
    if (fptr != NULL) {
      for (int i = 2; i <= nx + 1; i++) {
        for (int j = 2; j <= ny + 1; j++) {
          double x = x0 + (i - 1.5) * dx;
          double y = y0 + (j - 1.5) * dy;
          fprintf(fptr, \"%f, %f, %f\\n\", x, y, u[i][j]);
        }
      }

      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  for (int i = 0; i <= nx + 3; i++) {
    free(u[i]);
    free(un[i]);
    free(slope_x[i]);
    free(slope_y[i]);
  }
  free(u);
  free(un);
  free(slope_x);
  free(slope_y);
   
  return 0;
}
"
           ;; PDE name for code comments.
           name
           ;; Flux limiter name for code comments.
           limiter-name
           ;; Additional PDE parameters (e.g. a = 1.0 for linear advection).
           parameter-code
           ;; Number of cells in each coordinate direction.
           nx
           ny
           ;; Left/right boundaries.
           x0
           x1
           ;; Up/down boundaries
           y0
           y1
           ;; CFL coefficient.
           cfl
           ;; Final time.
           t-final
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           init-func-code
           init-func-code
           ;; Expressions for local wave-speed estimates.
           max-speed-local-x
           max-speed-local-y
           ;; Expressions for flux limiter function.
           limiter-r
           ;; Left/right negative fluxes in y-direction f(u_{j - 1, L}), f(u_{j - 1, R}).
           flux-umL-y
           flux-umR-y
           ;; Left/right central fluxes in y-direction f(u_{j, L}), f(u_{j, R}).
           flux-uiL-y
           flux-uiR-y
           ;; Left/right positive fluxes in y-direction f(u_{j + 1, L}), f(u_{j + 1, R}).
           flux-upL-y
           flux-upR-y
           ;; Evolved right negative flux in y-direction f(u_{j - 1, R+}).
           flux-umR-evol-y
           ;; Evolved left/right central fluxes in y-direction f(u_{j, L+}), f(u_{j, R+}).
           flux-uiL-evol-y
           flux-uiR-evol-y
           ;; Evolved left positive flux in y-direction f(u_{j + 1, L+}).
           flux-upL-evol-y
           ;; Evolved right negative flux derivative in y-direction f'(u_{j - 1, R+}).
           flux-deriv-umR-evol-y
           ;; Evolved left/right central flux derivatives in y-direction f'(u_{j, L+}), f(u_{j, R+}).
           flux-deriv-uiL-evol-y
           flux-deriv-uiR-evol-y
           ;; Evolved left positive flux derivative in y-direction f'(u_{j + 1, L+}).
           flux-deriv-upL-evol-y
           ;; Expressions for flux limiter function.
           limiter-r
           ;; Left/right negative fluxes in x-direction f(u_{i - 1, L}), f(u_{i - 1, R}).
           flux-umL-x
           flux-umR-x
           ;; Left/right central fluxes in x-direction f(u_{i, L}), f(u_{i, R}).
           flux-uiL-x
           flux-uiR-x
           ;; Left/right positive fluxes in x-direction f(u_{i + 1, L}), f(u_{i + 1, R}).
           flux-upL-x
           flux-upR-x
           ;; Evolved right negative flux in x-direction f(u_{i - 1, R+}).
           flux-umR-evol-x
           ;; Evolved left/right central fluxes in x-direction f(u_{i, L+}), f(u_{i, R+}).
           flux-uiL-evol-x
           flux-uiR-evol-x
           ;; Evolved left positive flux in x-direction f(u_{i + 1, L+}).
           flux-upL-evol-x
           ;; Evolved right negative flux derivative in x-direction f'(u_{i - 1, R+}).
           flux-deriv-umR-evol-x
           ;; Evolved left/right central flux derivatives in x-direction f'(u_{i, L+}), f(u_{i, R+}).
           flux-deriv-uiL-evol-x
           flux-deriv-uiR-evol-x
           ;; Evolved left positive flux derivative in x-direction f'(u_{i + 1, L+}).
           flux-deriv-upL-evol-x
           ;; Expressions for flux limiter function.
           limiter-r
           ;; Left/right negative fluxes in y-direction f(u_{j - 1, L}), f(u_{j - 1, R}).
           flux-umL-y
           flux-umR-y
           ;; Left/right central fluxes in y-direction f(u_{j, L}), f(u_{j, R}).
           flux-uiL-y
           flux-uiR-y
           ;; Left/right positive fluxes in y-direction f(u_{j + 1, L}), f(u_{j + 1, R}).
           flux-upL-y
           flux-upR-y
           ;; Evolved right negative flux in y-direction f(u_{j - 1, R+}).
           flux-umR-evol-y
           ;; Evolved left/right central fluxes in y-direction f(u_{j, L+}), f(u_{j, R+}).
           flux-uiL-evol-y
           flux-uiR-evol-y
           ;; Evolved left positive flux in y-direction f(u_{j + 1, L+}).
           flux-upL-evol-y
           ;; Evolved right negative flux derivative in y-direction f'(u_{j - 1, R+}).
           flux-deriv-umR-evol-y
           ;; Evolved left/right central flux derivatives in y-direction f'(u_{j, L+}), f(u_{j, R+}).
           flux-deriv-uiL-evol-y
           flux-deriv-uiR-evol-y
           ;; Evolved left positive flux derivative in y-direction f'(u_{j + 1, L+}).
           flux-deriv-upL-evol-y
           ;; PDE name for file output.
           name
           name
           ))
  code)