#lang racket

(require "prover_core.rkt")
(require "prover_vector.rkt")
(require "code_generator_core.rkt")
(provide generate-lax-friedrichs-vector3-2d
         generate-lax-friedrichs-vector3-2d-second-order
         generate-roe-vector3-2d
         generate-roe-vector3-2d-second-order)

;; ----------------------------------------------------------------------------------
;; Lax–Friedrichs (Finite-Difference) Solver for a 2D Coupled Vector System of 3 PDEs
;; ----------------------------------------------------------------------------------
(define (generate-lax-friedrichs-vector3-2d pde-system
                                            #:nx [nx 200]
                                            #:ny [ny 200]
                                            #:x0 [x0 0.0]
                                            #:x1 [x1 2.0]
                                            #:y0 [y0 0.0]
                                            #:y1 [y1 2.0]
                                            #:t-final [t-final 1.0]
                                            #:cfl [cfl 0.95]
                                            #:init-funcs [init-funcs (list
                                                                      `(cond
                                                                         [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.25) 5.0]
                                                                         [else 1.0])
                                                                      `0.0
                                                                      `0.0)])
 "Generate C code that solves the 1D coupled vector system of 2 PDEs specified by `pde-system` using the Lax-Friedrichs finite-difference method.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define max-speed-exprs-x (hash-ref pde-system 'max-speed-exprs-x))
  (define max-speed-exprs-y (hash-ref pde-system 'max-speed-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes-x (map (lambda (flux-expr-x)
                              (convert-expr flux-expr-x)) flux-exprs-x))
  (define flux-codes-y (map (lambda (flux-expr-y)
                              (convert-expr flux-expr-y)) flux-exprs-y))
  (define max-speed-codes-x (map (lambda (max-speed-expr-x)
                                   (convert-expr max-speed-expr-x)) max-speed-exprs-x))
  (define max-speed-codes-y (map (lambda (max-speed-expr-y)
                                   (convert-expr max-speed-expr-y)) max-speed-exprs-y))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define flux-ums-x (map (lambda (flux-code-x)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "um_x[0]")
                                                              (list-ref cons-codes 1) "um_x[1]") (list-ref cons-codes 2) "um_x[2]")) flux-codes-x))
  (define flux-uis-x (map (lambda (flux-code-x)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "ui_x[0]")
                                                              (list-ref cons-codes 1) "ui_x[1]") (list-ref cons-codes 2) "ui_x[2]")) flux-codes-x))
  (define flux-ups-x (map (lambda (flux-code-x)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "up_x[0]")
                                                              (list-ref cons-codes 1) "up_x[1]") (list-ref cons-codes 2) "up_x[2]")) flux-codes-x))

  (define flux-ums-y (map (lambda (flux-code-y)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "um_y[0]")
                                                              (list-ref cons-codes 1) "um_y[1]") (list-ref cons-codes 2) "um_y[2]")) flux-codes-y))
  (define flux-uis-y (map (lambda (flux-code-y)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "ui_y[0]")
                                                              (list-ref cons-codes 1) "ui_y[1]") (list-ref cons-codes 2) "ui_y[2]")) flux-codes-y))
  (define flux-ups-y (map (lambda (flux-code-y)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "up_y[0]")
                                                              (list-ref cons-codes 1) "up_y[1]") (list-ref cons-codes 2) "up_y[2]")) flux-codes-y))

  (define max-speed-locals-x (map (lambda (max-speed-code-x)
                                    (flux-substitute (flux-substitute (flux-substitute max-speed-code-x (list-ref cons-codes 0) "u[i][(j * 3) + 0]")
                                                                      (list-ref cons-codes 1) "u[i][(j * 3) + 1]") (list-ref cons-codes 2) "u[i][(j * 3) + 2]")) max-speed-codes-x))
  (define max-speed-locals-y (map (lambda (max-speed-code-y)
                                    (flux-substitute (flux-substitute (flux-substitute max-speed-code-y (list-ref cons-codes 0) "u[i][(j * 3) + 0]")
                                                                      (list-ref cons-codes 1) "u[i][(j * 3) + 1]") (list-ref cons-codes 2) "u[i][(j * 3) + 2]")) max-speed-codes-y))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR COUPLED VECTOR PDE SYSTEM: ~a
// Lax–Friedrichs first-order finite-difference solver for a coupled vector system of 3 PDEs in 2D.

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
    u[i] = (double*) malloc((ny + 2) * 3 * sizeof(double));
    un[i] = (double*) malloc((ny + 2) * 3 * sizeof(double));
  }

  // Arrays for storing other intermediate values.
  double *local_alpha_x = (double*) malloc(3 * sizeof(double));
  double *local_alpha_y = (double*) malloc(3 * sizeof(double));

  double *um_x = (double*) malloc(3 * sizeof(double));
  double *ui_x = (double*) malloc(3 * sizeof(double));
  double *up_x = (double*) malloc(3 * sizeof(double));

  double *f_um_x = (double*) malloc(3 * sizeof(double));
  double *f_ui_x = (double*) malloc(3 * sizeof(double));
  double *f_up_x = (double*) malloc(3 * sizeof(double));

  double *fluxL_x = (double*) malloc(3 * sizeof(double));
  double *fluxR_x = (double*) malloc(3 * sizeof(double));

  double *um_y = (double*) malloc(3 * sizeof(double));
  double *ui_y = (double*) malloc(3 * sizeof(double));
  double *up_y = (double*) malloc(3 * sizeof(double));

  double *f_um_y = (double*) malloc(3 * sizeof(double));
  double *f_ui_y = (double*) malloc(3 * sizeof(double));
  double *f_up_y = (double*) malloc(3 * sizeof(double));

  double *fluxL_y = (double*) malloc(3 * sizeof(double));
  double *fluxR_y = (double*) malloc(3 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    for (int j = 0; j <= ny + 1; j++) {
      double x = x0 + (i - 0.5) * dx;
      double y = y0 + (j - 0.5) * dy;
    
      u[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      u[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      u[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.

      un[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      un[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      un[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.
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
        local_alpha_x[0] = ~a; // max-speed-exprs-x[0] in C.
        local_alpha_x[1] = ~a; // max-speed-exprs-x[1] in C.
        local_alpha_x[2] = ~a; // max-speed-exprs-x[2] in C.

        local_alpha_y[0] = ~a; // max-speed-exprs-y[0] in C.
        local_alpha_y[1] = ~a; // max-speed-exprs-y[1] in C.
        local_alpha_y[2] = ~a; // max-speed-exprs-y[2] in C.
      
        for (int k = 0; k < 3; k++) {
          if (local_alpha_x[k] > alpha_x) {
            alpha_x = local_alpha_x[k];
          }
          if (local_alpha_y[k] > alpha_y) {
            alpha_y = local_alpha_y[k];
          }
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

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector in the y-direction by half a time-step.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        for (int k = 0; k < 3; k++) {
          um_y[k] = u[i][((j - 1) * 3) + k];
          ui_y[k] = u[i][(j * 3) + k];
          up_y[k] = u[i][((j + 1) * 3) + k];
        }

        // Evaluate flux vector for each value of the conserved variable vector.
        f_um_y[0] = ~a;
        f_um_y[1] = ~a;
        f_um_y[2] = ~a; // F(U_{j - 1}).
      
        f_ui_y[0] = ~a;
        f_ui_y[1] = ~a;
        f_ui_y[2] = ~a; // F(U_j).
      
        f_up_y[0] = ~a;
        f_up_y[1] = ~a;
        f_up_y[2] = ~a; // F(U_{j + 1}).

        // Left interface flux: F_{j - 1/2} = 0.5 * (F(U_{j - 1}) + F(U_j)) - 0.5 * alpha_y * (U_j - U_{j - 1}).
        for (int k = 0; k < 3; k++) {
          fluxL_y[k] = 0.5 * (f_um_y[k] + f_ui_y[k]) - 0.5 * alpha_y * (ui_y[k] - um_y[k]);
        }

        // Right interface flux: F_{j + 1/2} = 0.5 * (F(U_{j + 1}) + F(U_j)) - 0.5 * alpha_y * (U_{j + 1} - U_j).
        for (int k = 0; k < 3; k++) {
          fluxR_y[k] = 0.5 * (f_ui_y[k] + f_up_y[k]) - 0.5 * alpha_y * (up_y[k] - ui_y[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = ui_y[k] - (dt / (2.0 * dy)) * (fluxR_y[k] - fluxL_y[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[1][(j * 3) + k];
        u[nx + 1][(j * 3) + k] = u[nx][(j * 3) + k];

        un[0][(j * 3) + k] = un[1][(j * 3) + k];
        un[nx + 1][(j * 3) + k] = un[nx][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(1 * 3) + k];
        u[i][((ny + 1) * 3) + k] = u[i][(ny * 3) + k];

        un[i][(0 * 3) + k] = un[i][(1 * 3) + k];
        un[i][((ny + 1) * 3) + k] = un[i][(ny * 3) + k];
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector in the x-direction.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        for (int k = 0; k < 3; k++) {
          um_x[k] = u[i - 1][(j * 3) + k];
          ui_x[k] = u[i][(j * 3) + k];
          up_x[k] = u[i + 1][(j * 3) + k];
        }

        // Evaluate flux vector for each value of the conserved variable vector.
        f_um_x[0] = ~a;
        f_um_x[1] = ~a;
        f_um_x[2] = ~a; // F(U_{i - 1}).
      
        f_ui_x[0] = ~a;
        f_ui_x[1] = ~a;
        f_ui_x[2] = ~a; // F(U_i).
      
        f_up_x[0] = ~a;
        f_up_x[1] = ~a;
        f_up_x[2] = ~a; // F(U_{i + 1}).

        // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1}) + F(U_i)) - 0.5 * alpha_x * (U_i - U_{i - 1}).
        for (int k = 0; k < 3; k++) {
          fluxL_x[k] = 0.5 * (f_um_x[k] + f_ui_x[k]) - 0.5 * alpha_x * (ui_x[k] - um_x[k]);
        }

        // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1}) + F(U_i)) - 0.5 * alpha_x * (U_{i + 1} - U_i).
        for (int k = 0; k < 3; k++) {
          fluxR_x[k] = 0.5 * (f_ui_x[k] + f_up_x[k]) - 0.5 * alpha_x * (up_x[k] - ui_x[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = ui_x[k] - (dt / dx) * (fluxR_x[k] - fluxL_x[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[1][(j * 3) + k];
        u[nx + 1][(j * 3) + k] = u[nx][(j * 3) + k];

        un[0][(j * 3) + k] = un[1][(j * 3) + k];
        un[nx + 1][(j * 3) + k] = un[nx][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(1 * 3) + k];
        u[i][((ny + 1) * 3) + k] = u[i][(ny * 3) + k];

        un[i][(0 * 3) + k] = un[i][(1 * 3) + k];
        un[i][((ny + 1) * 3) + k] = un[i][(ny * 3) + k];
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector in the y-direction by half a time-step.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        for (int k = 0; k < 3; k++) {
          um_y[k] = u[i][((j - 1) * 3) + k];
          ui_y[k] = u[i][(j * 3) + k];
          up_y[k] = u[i][((j + 1) * 3) + k];
        }

        // Evaluate flux vector for each value of the conserved variable vector.
        f_um_y[0] = ~a;
        f_um_y[1] = ~a;
        f_um_y[2] = ~a; // F(U_{j - 1}).
      
        f_ui_y[0] = ~a;
        f_ui_y[1] = ~a;
        f_ui_y[2] = ~a; // F(U_j).
      
        f_up_y[0] = ~a;
        f_up_y[1] = ~a;
        f_up_y[2] = ~a; // F(U_{j + 1}).

        // Left interface flux: F_{j - 1/2} = 0.5 * (F(U_{j - 1}) + F(U_j)) - 0.5 * alpha_y * (U_j - U_{j - 1}).
        for (int k = 0; k < 3; k++) {
          fluxL_y[k] = 0.5 * (f_um_y[k] + f_ui_y[k]) - 0.5 * alpha_y * (ui_y[k] - um_y[k]);
        }

        // Right interface flux: F_{j + 1/2} = 0.5 * (F(U_{j + 1}) + F(U_j)) - 0.5 * alpha_y * (U_{j + 1} - U_j).
        for (int k = 0; k < 3; k++) {
          fluxR_y[k] = 0.5 * (f_ui_y[k] + f_up_y[k]) - 0.5 * alpha_y * (up_y[k] - ui_y[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = ui_y[k] - (dt / (2.0 * dy)) * (fluxR_y[k] - fluxL_y[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[1][(j * 3) + k];
        u[nx + 1][(j * 3) + k] = u[nx][(j * 3) + k];

        un[0][(j * 3) + k] = un[1][(j * 3) + k];
        un[nx + 1][(j * 3) + k] = un[nx][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(1 * 3) + k];
        u[i][((ny + 1) * 3) + k] = u[i][(ny * 3) + k];

        un[i][(0 * 3) + k] = un[i][(1 * 3) + k];
        un[i][((ny + 1) * 3) + k] = un[i][(ny * 3) + k];
      }
    }

    // Output solution to disk.
    for (int k = 0; k < 3; k++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", k, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", k, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 1; i <= nx; i++) {
          for (int j = 1; j <= ny; j++) {
            double x = x0 + (i - 0.5) * dx;
            double y = y0 + (j - 0.5) * dy;
            fprintf(fptr, \"%f, %f, %f\\n\", x, y, u[i][(j * 3) + k]);
          }
        }

        fclose(fptr);
      }
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

  free(local_alpha_x);
  free(local_alpha_y);
  
  free(um_x);
  free(ui_x);
  free(up_x);

  free(f_um_x);
  free(f_ui_x);
  free(f_up_x);

  free(fluxL_x);
  free(fluxR_x);

  free(um_y);
  free(ui_y);
  free(up_y);

  free(f_um_y);
  free(f_ui_y);
  free(f_up_y);

  free(fluxL_y);
  free(fluxR_y);
  
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
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals-x 0)
           (list-ref max-speed-locals-x 1)
           (list-ref max-speed-locals-x 2)
           (list-ref max-speed-locals-y 0)
           (list-ref max-speed-locals-y 1)
           (list-ref max-speed-locals-y 2)
           ;; Left, middle, right flux vectors in y-direction F(u_{j - 1}), F(u_j), F(u_{j + 1}).
           (list-ref flux-ums-y 0)
           (list-ref flux-ums-y 1)
           (list-ref flux-ums-y 2)
           (list-ref flux-uis-y 0)
           (list-ref flux-uis-y 1)
           (list-ref flux-uis-y 2)
           (list-ref flux-ups-y 0)
           (list-ref flux-ups-y 1)
           (list-ref flux-ups-y 2)
           ;; Left, middle, right flux vectors in x-direction F(u_{i - 1}), F(u_i), F(u_{i + 1}).
           (list-ref flux-ums-x 0)
           (list-ref flux-ums-x 1)
           (list-ref flux-ums-x 2)
           (list-ref flux-uis-x 0)
           (list-ref flux-uis-x 1)
           (list-ref flux-uis-x 2)
           (list-ref flux-ups-x 0)
           (list-ref flux-ups-x 1)
           (list-ref flux-ups-x 2)
           ;; Left, middle, right flux vectors in y-direction F(u_{j - 1}), F(u_j), F(u_{j + 1}).
           (list-ref flux-ums-y 0)
           (list-ref flux-ums-y 1)
           (list-ref flux-ums-y 2)
           (list-ref flux-uis-y 0)
           (list-ref flux-uis-y 1)
           (list-ref flux-uis-y 2)
           (list-ref flux-ups-y 0)
           (list-ref flux-ups-y 1)
           (list-ref flux-ups-y 2)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; -------------------------------------------------------------------------------------------------------------------------
;; Lax–Friedrichs (Finite-Difference) Solver for a 2D Coupled Vector System of 3 PDEs with a Second-Order Flux Extrapolation
;; -------------------------------------------------------------------------------------------------------------------------
(define (generate-lax-friedrichs-vector3-2d-second-order pde-system limiter
                                                         #:nx [nx 200]
                                                         #:ny [ny 200]
                                                         #:x0 [x0 0.0]
                                                         #:x1 [x1 2.0]
                                                         #:y0 [y0 0.0]
                                                         #:y1 [y1 2.0]
                                                         #:t-final [t-final 1.0]
                                                         #:cfl [cfl 0.95]
                                                         #:init-funcs [init-funcs (list
                                                                                   `(cond
                                                                                      [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.25) 5.0]
                                                                                      [else 1.0])
                                                                                   `0.0
                                                                                   `0.0)])
 "Generate C code that solves the 2D coupled vector system of 3 PDEs specified by `pde-system` using the Lax-Friedrichs finite-difference method with a
  second-order flux extrapolation using flux limiter `limiter`.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define max-speed-exprs-x (hash-ref pde-system 'max-speed-exprs-x))
  (define max-speed-exprs-y (hash-ref pde-system 'max-speed-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (define limiter-name (hash-ref limiter 'name))
  (define limiter-expr (hash-ref limiter 'limiter-expr))
  (define limiter-ratio (hash-ref limiter 'limiter-ratio))

  (define limiter-code (convert-expr limiter-expr))
  (define limiter-ratio-code (convert-expr limiter-ratio))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes-x (map (lambda (flux-expr-x)
                              (convert-expr flux-expr-x)) flux-exprs-x))
  (define flux-codes-y (map (lambda (flux-expr-y)
                              (convert-expr flux-expr-y)) flux-exprs-y))
  (define max-speed-codes-x (map (lambda (max-speed-expr-x)
                                   (convert-expr max-speed-expr-x)) max-speed-exprs-x))
  (define max-speed-codes-y (map (lambda (max-speed-expr-y)
                                   (convert-expr max-speed-expr-y)) max-speed-exprs-y))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define limiter-r (flux-substitute limiter-code limiter-ratio-code "r"))

  (define flux-umLs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "umL_x[0]")
                                                               (list-ref cons-codes 1) "umL_x[1]") (list-ref cons-codes 2) "umL_x[2]")) flux-codes-x))
  (define flux-umRs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "umR_x[0]")
                                                               (list-ref cons-codes 1) "umR_x[1]") (list-ref cons-codes 2) "umR_x[2]")) flux-codes-x))
  (define flux-uiLs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "uiL_x[0]")
                                                               (list-ref cons-codes 1) "uiL_x[1]") (list-ref cons-codes 2) "uiL_x[2]")) flux-codes-x))
  (define flux-uiRs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "uiR_x[0]")
                                                               (list-ref cons-codes 1) "uiR_x[1]") (list-ref cons-codes 2) "uiR_x[2]")) flux-codes-x))
  (define flux-upLs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "upL_x[0]")
                                                               (list-ref cons-codes 1) "upL_x[1]") (list-ref cons-codes 2) "upL_x[2]")) flux-codes-x))
  (define flux-upRs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "upR_x[0]")
                                                               (list-ref cons-codes 1) "upR_x[1]") (list-ref cons-codes 2) "upR_x[2]")) flux-codes-x))
  
  (define flux-umR-evols-x (map (lambda (flux-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "umR_evol_x[0]")
                                                                    (list-ref cons-codes 1) "umR_evol_x[1]") (list-ref cons-codes 2) "umR_evol_x[2]")) flux-codes-x))
  (define flux-uiL-evols-x (map (lambda (flux-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "uiL_evol_x[0]")
                                                                    (list-ref cons-codes 1) "uiL_evol_x[1]") (list-ref cons-codes 2) "uiL_evol_x[2]")) flux-codes-x))
  (define flux-uiR-evols-x (map (lambda (flux-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "uiR_evol_x[0]")
                                                                    (list-ref cons-codes 1) "uiR_evol_x[1]") (list-ref cons-codes 2) "uiR_evol_x[2]")) flux-codes-x))
  (define flux-upL-evols-x (map (lambda (flux-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "upL_evol_x[0]")
                                                                    (list-ref cons-codes 1) "upL_evol_x[1]") (list-ref cons-codes 2) "upL_evol_x[2]")) flux-codes-x))

  (define flux-umLs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "umL_y[0]")
                                                               (list-ref cons-codes 1) "umL_y[1]") (list-ref cons-codes 2) "umL_y[2]")) flux-codes-y))
  (define flux-umRs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "umR_y[0]")
                                                               (list-ref cons-codes 1) "umR_y[1]") (list-ref cons-codes 2) "umR_y[2]")) flux-codes-y))
  (define flux-uiLs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "uiL_y[0]")
                                                               (list-ref cons-codes 1) "uiL_y[1]") (list-ref cons-codes 2) "uiL_y[2]")) flux-codes-y))
  (define flux-uiRs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "uiR_y[0]")
                                                               (list-ref cons-codes 1) "uiR_y[1]") (list-ref cons-codes 2) "uiR_y[2]")) flux-codes-y))
  (define flux-upLs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "upL_y[0]")
                                                               (list-ref cons-codes 1) "upL_y[1]") (list-ref cons-codes 2) "upL_y[2]")) flux-codes-y))
  (define flux-upRs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "upR_y[0]")
                                                               (list-ref cons-codes 1) "upR_y[1]") (list-ref cons-codes 2) "upR_y[2]")) flux-codes-y))
  
  (define flux-umR-evols-y (map (lambda (flux-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "umR_evol_y[0]")
                                                                    (list-ref cons-codes 1) "umR_evol_y[1]") (list-ref cons-codes 2) "umR_evol_y[2]")) flux-codes-y))
  (define flux-uiL-evols-y (map (lambda (flux-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "uiL_evol_y[0]")
                                                                    (list-ref cons-codes 1) "uiL_evol_y[1]") (list-ref cons-codes 2) "uiL_evol_y[2]")) flux-codes-y))
  (define flux-uiR-evols-y (map (lambda (flux-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "uiR_evol_y[0]")
                                                                    (list-ref cons-codes 1) "uiR_evol_y[1]") (list-ref cons-codes 2) "uiR_evol_y[2]")) flux-codes-y))
  (define flux-upL-evols-y (map (lambda (flux-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "upL_evol_y[0]")
                                                                    (list-ref cons-codes 1) "upL_evol_y[1]") (list-ref cons-codes 2) "upL_evol_y[2]")) flux-codes-y))
  
  (define max-speed-locals-x (map (lambda (max-speed-code-x)
                                    (flux-substitute (flux-substitute (flux-substitute max-speed-code-x (list-ref cons-codes 0) "u[i][(j * 3) + 0]")
                                                                      (list-ref cons-codes 1) "u[i][(j * 3) + 1]") (list-ref cons-codes 2) "u[i][(j * 3) + 2]")) max-speed-codes-x))
  (define max-speed-locals-y (map (lambda (max-speed-code-y)
                                    (flux-substitute (flux-substitute (flux-substitute max-speed-code-y (list-ref cons-codes 0) "u[i][(j * 3) + 0]")
                                                                      (list-ref cons-codes 1) "u[i][(j * 3) + 1]") (list-ref cons-codes 2) "u[i][(j * 3) + 2]")) max-speed-codes-y))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR COUPLED VECTOR PDE SYSTEM: ~a
// FLUX LIMITER: ~a
// Lax–Friedrichs first-order finite-difference solver for a coupled vector system of 3 PDEs in 2D, with a second-order flux extrapolation.

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
    slope_x[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
    slope_y[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
  }

  // Arrays for storing solution.
  double **u = (double**) malloc((nx + 4) * sizeof(double*));
  double **un = (double**) malloc((nx + 4) * sizeof(double*));
  for (int i = 0; i <= nx + 3; i++) {
    u[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
    un[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
  }

  // Arrays for storing other intermediate values.
  double *local_alpha_x = (double*) malloc(3 * sizeof(double));
  double *local_alpha_y = (double*) malloc(3 * sizeof(double));
  
  double *umL_x = (double*) malloc(3 * sizeof(double));
  double *umR_x = (double*) malloc(3 * sizeof(double));
  double *uiL_x = (double*) malloc(3 * sizeof(double));
  double *uiR_x = (double*) malloc(3 * sizeof(double));
  double *upL_x = (double*) malloc(3 * sizeof(double));
  double *upR_x = (double*) malloc(3 * sizeof(double));

  double *f_umL_x = (double*) malloc(3 * sizeof(double));
  double *f_umR_x = (double*) malloc(3 * sizeof(double));
  double *f_uiL_x = (double*) malloc(3 * sizeof(double));
  double *f_uiR_x = (double*) malloc(3 * sizeof(double));
  double *f_upL_x = (double*) malloc(3 * sizeof(double));
  double *f_upR_x = (double*) malloc(3 * sizeof(double));

  double *umR_evol_x = (double*) malloc(3 * sizeof(double));
  double *uiL_evol_x = (double*) malloc(3 * sizeof(double));
  double *uiR_evol_x = (double*) malloc(3 * sizeof(double));
  double *upL_evol_x = (double*) malloc(3 * sizeof(double));

  double *f_umR_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_uiL_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_uiR_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_upL_evol_x = (double*) malloc(3 * sizeof(double));

  double *fluxL_x = (double*) malloc(3 * sizeof(double));
  double *fluxR_x = (double*) malloc(3 * sizeof(double));

  double *umL_y = (double*) malloc(3 * sizeof(double));
  double *umR_y = (double*) malloc(3 * sizeof(double));
  double *uiL_y = (double*) malloc(3 * sizeof(double));
  double *uiR_y = (double*) malloc(3 * sizeof(double));
  double *upL_y = (double*) malloc(3 * sizeof(double));
  double *upR_y = (double*) malloc(3 * sizeof(double));

  double *f_umL_y = (double*) malloc(3 * sizeof(double));
  double *f_umR_y = (double*) malloc(3 * sizeof(double));
  double *f_uiL_y = (double*) malloc(3 * sizeof(double));
  double *f_uiR_y = (double*) malloc(3 * sizeof(double));
  double *f_upL_y = (double*) malloc(3 * sizeof(double));
  double *f_upR_y = (double*) malloc(3 * sizeof(double));

  double *umR_evol_y = (double*) malloc(3 * sizeof(double));
  double *uiL_evol_y = (double*) malloc(3 * sizeof(double));
  double *uiR_evol_y = (double*) malloc(3 * sizeof(double));
  double *upL_evol_y = (double*) malloc(3 * sizeof(double));

  double *f_umR_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_uiL_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_uiR_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_upL_evol_y = (double*) malloc(3 * sizeof(double));

  double *fluxL_y = (double*) malloc(3 * sizeof(double));
  double *fluxR_y = (double*) malloc(3 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    for (int j = 0; j <= ny + 3; j++) {
      double x = x0 + (i - 1.5) * dx;
      double y = y0 + (j - 1.5) * dy;
    
      u[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      u[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      u[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.

      un[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      un[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      un[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.
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
        local_alpha_x[0] = ~a; // max-speed-exprs-x[0] in C.
        local_alpha_x[1] = ~a; // max-speed-exprs-x[1] in C.
        local_alpha_x[2] = ~a; // max-speed-exprs-x[2] in C.

        local_alpha_y[0] = ~a; // max-speed-exprs-y[0] in C.
        local_alpha_y[1] = ~a; // max-speed-exprs-y[1] in C.
        local_alpha_y[2] = ~a; // max-speed-exprs-y[2] in C.
      
        for (int k = 0; k < 3; k++) {
          if (local_alpha_x[k] > alpha_x) {
            alpha_x = local_alpha_x[k];
          }
          if (local_alpha_y[k] > alpha_y) {
            alpha_y = local_alpha_y[k];
          }
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
        for (int k = 0; k < 3; k++) {
          double r = (u[i][(j * 3) + k] - u[i][((j - 1) * 3) + k]) / (u[i][((j + 1) * 3) + k] - u[i][(j * 3) + k]);
          double limiter = ~a; // limiter-r in C.

          slope_y[i][(j * 3) + k] = limiter * (0.5 * ((u[i][(j * 3) + k] - u[i][((j - 1) * 3) + k]) + (u[i][((j + 1) * 3) + k] - u[i][(j * 3) + k])));
        }
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector in the y-direction by half a time-step.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        // Extrapolate boundary states.
        for (int k = 0; k < 3; k++) {
          umL_y[k] = u[i][((j - 1) * 3) + k] - (0.5 * slope_y[i][((j - 1) * 3) + k]);
          umR_y[k] = u[i][((j - 1) * 3) + k] + (0.5 * slope_y[i][((j - 1) * 3) + k]);

          uiL_y[k] = u[i][(j * 3) + k] - (0.5 * slope_y[i][(j * 3) + k]);
          uiR_y[k] = u[i][(j * 3) + k] + (0.5 * slope_y[i][(j * 3) + k]);

          upL_y[k] = u[i][((j + 1) * 3) + k] - (0.5 * slope_y[i][((j + 1) * 3) + k]);
          upR_y[k] = u[i][((j + 1) * 3) + k] + (0.5 * slope_y[i][((j + 1) * 3) + k]);
        }

        // Evaluate flux vector for each extrapolated boundary state.
        f_umL_y[0] = ~a;
        f_umL_y[1] = ~a;
        f_umL_y[2] = ~a;
        f_umR_y[0] = ~a;
        f_umR_y[1] = ~a;
        f_umR_y[2] = ~a;

        f_uiL_y[0] = ~a;
        f_uiL_y[1] = ~a;
        f_uiL_y[2] = ~a;
        f_uiR_y[0] = ~a;
        f_uiR_y[1] = ~a;
        f_uiR_y[2] = ~a;

        f_upL_y[0] = ~a;
        f_upL_y[1] = ~a;
        f_upL_y[2] = ~a;
        f_upR_y[0] = ~a;
        f_upR_y[1] = ~a;
        f_upR_y[2] = ~a;

        // Evolve each extrapolated boundary state.
        for (int k = 0; k < 3; k++) {
          umR_evol_y[k] = umR_y[k] + ((dt / (4.0 * dy)) * (f_umL_y[k] - f_umR_y[k]));

          uiL_evol_y[k] = uiL_y[k] + ((dt / (4.0 * dy)) * (f_uiL_y[k] - f_uiR_y[k]));
          uiR_evol_y[k] = uiR_y[k] + ((dt / (4.0 * dy)) * (f_uiL_y[k] - f_uiR_y[k]));

          upL_evol_y[k] = upL_y[k] + ((dt / (4.0 * dy)) * (f_upL_y[k] - f_upR_y[k]));
        }

        // Evaluate flux vector for each value of the (evolved) conserved variable vector.
        f_umR_evol_y[0] = ~a;
        f_umR_evol_y[1] = ~a;
        f_umR_evol_y[2] = ~a; // F(U_{j - 1, R+})
        f_uiL_evol_y[0] = ~a;
        f_uiL_evol_y[1] = ~a;
        f_uiL_evol_y[2] = ~a; // F(U_{j, L+})
      
        f_uiR_evol_y[0] = ~a;
        f_uiR_evol_y[1] = ~a;
        f_uiR_evol_y[2] = ~a; // F(U_{j, R+})
        f_upL_evol_y[0] = ~a;
        f_upL_evol_y[1] = ~a;
        f_upL_evol_y[2] = ~a; // F(U_{j + 1, L+})

        // Left interface flux: F_{j - 1/2} = 0.5 * (F(U_{j - 1, R+}) + F(U_{j, L+})) - 0.5 * alpha_y * (U_{j, L+} - U_{j - 1, R+}).
        for (int k = 0; k < 3; k++) {
          fluxL_y[k] = 0.5 * (f_umR_evol_y[k] + f_uiL_evol_y[k]) - 0.5 * alpha_y * (uiL_evol_y[k] - umR_evol_y[k]);
        }

        // Right interface flux: F_{j + 1/2} = 0.5 * (F(U_{j + 1, L+}) + F(U_{j, R+})) - 0.5 * alpha_y * (U_{j + 1, L+} - U_{j, R+}).
        for (int k = 0; k < 3; k++) {
          fluxR_y[k] = 0.5 * (f_uiR_evol_y[k] + f_upL_evol_y[k]) - 0.5 * alpha_y * (upL_evol_y[k] - uiR_evol_y[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = u[i][(j * 3) + k] - (dt / (2.0 * dy)) * (fluxR_y[k] - fluxL_y[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[2][(j * 3) + k];
        u[1][(j * 3) + k] = u[2][(j * 3) + k];
        u[nx + 2][(j * 3) + k] = u[nx + 1][(j * 3) + k];
        u[nx + 3][(j * 3) + k] = u[nx + 1][(j * 3) + k];

        un[0][(j * 3) + k] = un[2][(j * 3) + k];
        un[1][(j * 3) + k] = un[2][(j * 3) + k];
        un[nx + 2][(j * 3) + k] = un[nx + 1][(j * 3) + k];
        un[nx + 3][(j * 3) + k] = un[nx + 1][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(2 * 3) + k];
        u[i][(1 * 3) + k] = u[i][(2 * 3) + k];
        u[i][((ny + 2) * 3) + k] = u[i][((ny + 1) * 3) + k];
        u[i][((ny + 3) * 3) + k] = u[i][((ny + 1) * 3) + k];

        un[i][(0 * 3) + k] = un[i][(2 * 3) + k];
        un[i][(1 * 3) + k] = un[i][(2 * 3) + k];
        un[i][((ny + 2) * 3) + k] = un[i][((ny + 1) * 3) + k];
        un[i][((ny + 3) * 3) + k] = un[i][((ny + 1) * 3) + k];
      }
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        for (int k = 0; k < 3; k++) {
          double r = (u[i][(j * 3) + k] - u[i - 1][(j * 3) + k]) / (u[i + 1][(j * 3) + k] - u[i][(j * 3) + k]);
          double limiter = ~a; // limiter-r in C.

          slope_x[i][(j * 3) + k] = limiter * (0.5 * ((u[i][(j * 3) + k] - u[i - 1][(j * 3) + k]) + (u[i + 1][(j * 3) + k] - u[i][(j * 3) + k])));
        }
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector in the x-direction.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        // Extrapolate boundary states.
        for (int k = 0; k < 3; k++) {
          umL_x[k] = u[i - 1][(j * 3) + k] - (0.5 * slope_x[i - 1][(j * 3) + k]);
          umR_x[k] = u[i - 1][(j * 3) + k] + (0.5 * slope_x[i - 1][(j * 3) + k]);

          uiL_x[k] = u[i][(j * 3) + k] - (0.5 * slope_x[i][(j * 3) + k]);
          uiR_x[k] = u[i][(j * 3) + k] + (0.5 * slope_x[i][(j * 3) + k]);

          upL_x[k] = u[i + 1][(j * 3) + k] - (0.5 * slope_x[i + 1][(j * 3) + k]);
          upR_x[k] = u[i + 1][(j * 3) + k] + (0.5 * slope_x[i + 1][(j * 3) + k]);
        }

        // Evaluate flux vector for each extrapolated boundary state.
        f_umL_x[0] = ~a;
        f_umL_x[1] = ~a;
        f_umL_x[2] = ~a;
        f_umR_x[0] = ~a;
        f_umR_x[1] = ~a;
        f_umR_x[2] = ~a;

        f_uiL_x[0] = ~a;
        f_uiL_x[1] = ~a;
        f_uiL_x[2] = ~a;
        f_uiR_x[0] = ~a;
        f_uiR_x[1] = ~a;
        f_uiR_x[2] = ~a;

        f_upL_x[0] = ~a;
        f_upL_x[1] = ~a;
        f_upL_x[2] = ~a;
        f_upR_x[0] = ~a;
        f_upR_x[1] = ~a;
        f_upR_x[2] = ~a;

        // Evolve each extrapolated boundary state.
        for (int k = 0; k < 3; k++) {
          umR_evol_x[k] = umR_x[k] + ((dt / (2.0 * dx)) * (f_umL_x[k] - f_umR_x[k]));

          uiL_evol_x[k] = uiL_x[k] + ((dt / (2.0 * dx)) * (f_uiL_x[k] - f_uiR_x[k]));
          uiR_evol_x[k] = uiR_x[k] + ((dt / (2.0 * dx)) * (f_uiL_x[k] - f_uiR_x[k]));

          upL_evol_x[k] = upL_x[k] + ((dt / (2.0 * dx)) * (f_upL_x[k] - f_upR_x[k]));
        }

        // Evaluate flux vector for each value of the (evolved) conserved variable vector.
        f_umR_evol_x[0] = ~a;
        f_umR_evol_x[1] = ~a;
        f_umR_evol_x[2] = ~a; // F(U_{i - 1, R+})
        f_uiL_evol_x[0] = ~a;
        f_uiL_evol_x[1] = ~a;
        f_uiL_evol_x[2] = ~a; // F(U_{i, L+})
      
        f_uiR_evol_x[0] = ~a;
        f_uiR_evol_x[1] = ~a;
        f_uiR_evol_x[2] = ~a; // F(U_{i, R+})
        f_upL_evol_x[0] = ~a;
        f_upL_evol_x[1] = ~a;
        f_upL_evol_x[2] = ~a; // F(U_{i + 1, L+})

        // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1, R+}) + F(U_{i, L+})) - 0.5 * alpha_x * (U_{i, L+} - U_{i - 1, R+}).
        for (int k = 0; k < 3; k++) {
          fluxL_x[k] = 0.5 * (f_umR_evol_x[k] + f_uiL_evol_x[k]) - 0.5 * alpha_x * (uiL_evol_x[k] - umR_evol_x[k]);
        }

        // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1, L+}) + F(U_{i, R+})) - 0.5 * alpha_x * (U_{i + 1, L+} - U_{i, R+}).
        for (int k = 0; k < 3; k++) {
          fluxR_x[k] = 0.5 * (f_uiR_evol_x[k] + f_upL_evol_x[k]) - 0.5 * alpha_x * (upL_evol_x[k] - uiR_evol_x[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = u[i][(j * 3) + k] - (dt / dx) * (fluxR_x[k] - fluxL_x[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[2][(j * 3) + k];
        u[1][(j * 3) + k] = u[2][(j * 3) + k];
        u[nx + 2][(j * 3) + k] = u[nx + 1][(j * 3) + k];
        u[nx + 3][(j * 3) + k] = u[nx + 1][(j * 3) + k];

        un[0][(j * 3) + k] = un[2][(j * 3) + k];
        un[1][(j * 3) + k] = un[2][(j * 3) + k];
        un[nx + 2][(j * 3) + k] = un[nx + 1][(j * 3) + k];
        un[nx + 3][(j * 3) + k] = un[nx + 1][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(2 * 3) + k];
        u[i][(1 * 3) + k] = u[i][(2 * 3) + k];
        u[i][((ny + 2) * 3) + k] = u[i][((ny + 1) * 3) + k];
        u[i][((ny + 3) * 3) + k] = u[i][((ny + 1) * 3) + k];

        un[i][(0 * 3) + k] = un[i][(2 * 3) + k];
        un[i][(1 * 3) + k] = un[i][(2 * 3) + k];
        un[i][((ny + 2) * 3) + k] = un[i][((ny + 1) * 3) + k];
        un[i][((ny + 3) * 3) + k] = un[i][((ny + 1) * 3) + k];
      }
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        for (int k = 0; k < 3; k++) {
          double r = (u[i][(j * 3) + k] - u[i][((j - 1) * 3) + k]) / (u[i][((j + 1) * 3) + k] - u[i][(j * 3) + k]);
          double limiter = ~a; // limiter-r in C.

          slope_y[i][(j * 3) + k] = limiter * (0.5 * ((u[i][(j * 3) + k] - u[i][((j - 1) * 3) + k]) + (u[i][((j + 1) * 3) + k] - u[i][(j * 3) + k])));
        }
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector in the y-direction by half a time-step.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        // Extrapolate boundary states.
        for (int k = 0; k < 3; k++) {
          umL_y[k] = u[i][((j - 1) * 3) + k] - (0.5 * slope_y[i][((j - 1) * 3) + k]);
          umR_y[k] = u[i][((j - 1) * 3) + k] + (0.5 * slope_y[i][((j - 1) * 3) + k]);

          uiL_y[k] = u[i][(j * 3) + k] - (0.5 * slope_y[i][(j * 3) + k]);
          uiR_y[k] = u[i][(j * 3) + k] + (0.5 * slope_y[i][(j * 3) + k]);

          upL_y[k] = u[i][((j + 1) * 3) + k] - (0.5 * slope_y[i][((j + 1) * 3) + k]);
          upR_y[k] = u[i][((j + 1) * 3) + k] + (0.5 * slope_y[i][((j + 1) * 3) + k]);
        }

        // Evaluate flux vector for each extrapolated boundary state.
        f_umL_y[0] = ~a;
        f_umL_y[1] = ~a;
        f_umL_y[2] = ~a;
        f_umR_y[0] = ~a;
        f_umR_y[1] = ~a;
        f_umR_y[2] = ~a;

        f_uiL_y[0] = ~a;
        f_uiL_y[1] = ~a;
        f_uiL_y[2] = ~a;
        f_uiR_y[0] = ~a;
        f_uiR_y[1] = ~a;
        f_uiR_y[2] = ~a;

        f_upL_y[0] = ~a;
        f_upL_y[1] = ~a;
        f_upL_y[2] = ~a;
        f_upR_y[0] = ~a;
        f_upR_y[1] = ~a;
        f_upR_y[2] = ~a;

        // Evolve each extrapolated boundary state.
        for (int k = 0; k < 3; k++) {
          umR_evol_y[k] = umR_y[k] + ((dt / (4.0 * dy)) * (f_umL_y[k] - f_umR_y[k]));

          uiL_evol_y[k] = uiL_y[k] + ((dt / (4.0 * dy)) * (f_uiL_y[k] - f_uiR_y[k]));
          uiR_evol_y[k] = uiR_y[k] + ((dt / (4.0 * dy)) * (f_uiL_y[k] - f_uiR_y[k]));

          upL_evol_y[k] = upL_y[k] + ((dt / (4.0 * dy)) * (f_upL_y[k] - f_upR_y[k]));
        }

        // Evaluate flux vector for each value of the (evolved) conserved variable vector.
        f_umR_evol_y[0] = ~a;
        f_umR_evol_y[1] = ~a;
        f_umR_evol_y[2] = ~a; // F(U_{j - 1, R+})
        f_uiL_evol_y[0] = ~a;
        f_uiL_evol_y[1] = ~a;
        f_uiL_evol_y[2] = ~a; // F(U_{j, L+})
      
        f_uiR_evol_y[0] = ~a;
        f_uiR_evol_y[1] = ~a;
        f_uiR_evol_y[2] = ~a; // F(U_{j, R+})
        f_upL_evol_y[0] = ~a;
        f_upL_evol_y[1] = ~a;
        f_upL_evol_y[2] = ~a; // F(U_{j + 1, L+})

        // Left interface flux: F_{j - 1/2} = 0.5 * (F(U_{j - 1, R+}) + F(U_{j, L+})) - 0.5 * alpha_y * (U_{j, L+} - U_{j - 1, R+}).
        for (int k = 0; k < 3; k++) {
          fluxL_y[k] = 0.5 * (f_umR_evol_y[k] + f_uiL_evol_y[k]) - 0.5 * alpha_y * (uiL_evol_y[k] - umR_evol_y[k]);
        }

        // Right interface flux: F_{j + 1/2} = 0.5 * (F(U_{j + 1, L+}) + F(U_{j, R+})) - 0.5 * alpha_y * (U_{j + 1, L+} - U_{j, R+}).
        for (int k = 0; k < 3; k++) {
          fluxR_y[k] = 0.5 * (f_uiR_evol_y[k] + f_upL_evol_y[k]) - 0.5 * alpha_y * (upL_evol_y[k] - uiR_evol_y[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = u[i][(j * 3) + k] - (dt / (2.0 * dy)) * (fluxR_y[k] - fluxL_y[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[2][(j * 3) + k];
        u[1][(j * 3) + k] = u[2][(j * 3) + k];
        u[nx + 2][(j * 3) + k] = u[nx + 1][(j * 3) + k];
        u[nx + 3][(j * 3) + k] = u[nx + 1][(j * 3) + k];

        un[0][(j * 3) + k] = un[2][(j * 3) + k];
        un[1][(j * 3) + k] = un[2][(j * 3) + k];
        un[nx + 2][(j * 3) + k] = un[nx + 1][(j * 3) + k];
        un[nx + 3][(j * 3) + k] = un[nx + 1][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(2 * 3) + k];
        u[i][(1 * 3) + k] = u[i][(2 * 3) + k];
        u[i][((ny + 2) * 3) + k] = u[i][((ny + 1) * 3) + k];
        u[i][((ny + 3) * 3) + k] = u[i][((ny + 1) * 3) + k];

        un[i][(0 * 3) + k] = un[i][(2 * 3) + k];
        un[i][(1 * 3) + k] = un[i][(2 * 3) + k];
        un[i][((ny + 2) * 3) + k] = un[i][((ny + 1) * 3) + k];
        un[i][((ny + 3) * 3) + k] = un[i][((ny + 1) * 3) + k];
      }
    }

    // Output solution to disk.
    for (int k = 0; k < 3; k++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", k, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", k, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 2; i <= nx + 1; i++) {
          for (int j = 2; j <= ny + 1; j++) {
            double x = x0 + (i - 1.5) * dx;
            double y = y0 + (j - 1.5) * dy;
            fprintf(fptr, \"%f, %f, %f\\n\", x, y, u[i][(j * 3) + k]);
          }
        }

        fclose(fptr);
      }
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

  free(local_alpha_x);
  free(local_alpha_y);
  
  free(umL_x);
  free(umR_x);
  free(uiL_x);
  free(uiR_x);
  free(upL_x);
  free(upR_x);

  free(f_umL_x);
  free(f_umR_x);
  free(f_uiL_x);
  free(f_uiR_x);
  free(f_upL_x);
  free(f_upR_x);

  free(umR_evol_x);
  free(uiL_evol_x);
  free(uiR_evol_x);
  free(upL_evol_x);

  free(f_umR_evol_x);
  free(f_uiL_evol_x);
  free(f_uiR_evol_x);
  free(f_upL_evol_x);

  free(fluxL_x);
  free(fluxR_x);

  free(umL_y);
  free(umR_y);
  free(uiL_y);
  free(uiR_y);
  free(upL_y);
  free(upR_y);

  free(f_umL_y);
  free(f_umR_y);
  free(f_uiL_y);
  free(f_uiR_y);
  free(f_upL_y);
  free(f_upR_y);

  free(umR_evol_y);
  free(uiL_evol_y);
  free(uiR_evol_y);
  free(upL_evol_y);

  free(f_umR_evol_y);
  free(f_uiL_evol_y);
  free(f_uiR_evol_y);
  free(f_upL_evol_y);

  free(fluxL_y);
  free(fluxR_y);
  
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
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals-x 0)
           (list-ref max-speed-locals-x 1)
           (list-ref max-speed-locals-x 2)
           (list-ref max-speed-locals-y 0)
           (list-ref max-speed-locals-y 1)
           (list-ref max-speed-locals-y 2)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left/right negative flux vectors in y-direction F(U_{j - 1, L}), F(U_{j - 1, R}).
           (list-ref flux-umLs-y 0)
           (list-ref flux-umLs-y 1)
           (list-ref flux-umLs-y 2)
           (list-ref flux-umRs-y 0)
           (list-ref flux-umRs-y 1)
           (list-ref flux-umRs-y 2)
           ;; Left/right central flux vectors in y-direction F(U_{j, L}), F(U_{j, R}).
           (list-ref flux-uiLs-y 0)
           (list-ref flux-uiLs-y 1)
           (list-ref flux-uiLs-y 2)
           (list-ref flux-uiRs-y 0)
           (list-ref flux-uiRs-y 1)
           (list-ref flux-uiRs-y 2)
           ;; Left/right positive flux vectors in y-direction F(U_{j + 1, L}), F(U_{j + 1, R}).
           (list-ref flux-upLs-y 0)
           (list-ref flux-upLs-y 1)
           (list-ref flux-upLs-y 2)
           (list-ref flux-upRs-y 0)
           (list-ref flux-upRs-y 1)
           (list-ref flux-upRs-y 2)
           ;; Evolved right negative/left central flux vectors in y-direction F(U_{j - 1, R+}), F(U_{j, L+}).
           (list-ref flux-umR-evols-y 0)
           (list-ref flux-umR-evols-y 1)
           (list-ref flux-umR-evols-y 2)
           (list-ref flux-uiL-evols-y 0)
           (list-ref flux-uiL-evols-y 1)
           (list-ref flux-uiL-evols-y 2)
           ;; Evolved right central/left positive flux vectors in y-direction F(U_{j, R+}), F(U_{j + 1, L+}).
           (list-ref flux-uiR-evols-y 0)
           (list-ref flux-uiR-evols-y 1)
           (list-ref flux-uiR-evols-y 2)
           (list-ref flux-upL-evols-y 0)
           (list-ref flux-upL-evols-y 1)
           (list-ref flux-upL-evols-y 2)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left/right negative flux vectors in x-direction F(U_{i - 1, L}), F(U_{i - 1, R}).
           (list-ref flux-umLs-x 0)
           (list-ref flux-umLs-x 1)
           (list-ref flux-umLs-x 2)
           (list-ref flux-umRs-x 0)
           (list-ref flux-umRs-x 1)
           (list-ref flux-umRs-x 2)
           ;; Left/right central flux vectors in x-direction F(U_{i, L}), F(U_{i, R}).
           (list-ref flux-uiLs-x 0)
           (list-ref flux-uiLs-x 1)
           (list-ref flux-uiLs-x 2)
           (list-ref flux-uiRs-x 0)
           (list-ref flux-uiRs-x 1)
           (list-ref flux-uiRs-x 2)
           ;; Left/right positive flux vectors in x-direction F(U_{i + 1, L}), F(U_{i + 1, R}).
           (list-ref flux-upLs-x 0)
           (list-ref flux-upLs-x 1)
           (list-ref flux-upLs-x 2)
           (list-ref flux-upRs-x 0)
           (list-ref flux-upRs-x 1)
           (list-ref flux-upRs-x 2)
           ;; Evolved right negative/left central flux vectors in x-direction F(U_{i - 1, R+}), F(U_{i, L+}).
           (list-ref flux-umR-evols-x 0)
           (list-ref flux-umR-evols-x 1)
           (list-ref flux-umR-evols-x 2)
           (list-ref flux-uiL-evols-x 0)
           (list-ref flux-uiL-evols-x 1)
           (list-ref flux-uiL-evols-x 2)
           ;; Evolved right central/left positive flux vectors in x-direction F(U_{i, R+}), F(U_{i + 1, L+}).
           (list-ref flux-uiR-evols-x 0)
           (list-ref flux-uiR-evols-x 1)
           (list-ref flux-uiR-evols-x 2)
           (list-ref flux-upL-evols-x 0)
           (list-ref flux-upL-evols-x 1)
           (list-ref flux-upL-evols-x 2)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left/right negative flux vectors in y-direction F(U_{j - 1, L}), F(U_{j - 1, R}).
           (list-ref flux-umLs-y 0)
           (list-ref flux-umLs-y 1)
           (list-ref flux-umLs-y 2)
           (list-ref flux-umRs-y 0)
           (list-ref flux-umRs-y 1)
           (list-ref flux-umRs-y 2)
           ;; Left/right central flux vectors in y-direction F(U_{j, L}), F(U_{j, R}).
           (list-ref flux-uiLs-y 0)
           (list-ref flux-uiLs-y 1)
           (list-ref flux-uiLs-y 2)
           (list-ref flux-uiRs-y 0)
           (list-ref flux-uiRs-y 1)
           (list-ref flux-uiRs-y 2)
           ;; Left/right positive flux vectors in y-direction F(U_{j + 1, L}), F(U_{j + 1, R}).
           (list-ref flux-upLs-y 0)
           (list-ref flux-upLs-y 1)
           (list-ref flux-upLs-y 2)
           (list-ref flux-upRs-y 0)
           (list-ref flux-upRs-y 1)
           (list-ref flux-upRs-y 2)
           ;; Evolved right negative/left central flux vectors in y-direction F(U_{j - 1, R+}), F(U_{j, L+}).
           (list-ref flux-umR-evols-y 0)
           (list-ref flux-umR-evols-y 1)
           (list-ref flux-umR-evols-y 2)
           (list-ref flux-uiL-evols-y 0)
           (list-ref flux-uiL-evols-y 1)
           (list-ref flux-uiL-evols-y 2)
           ;; Evolved right central/left positive flux vectors in y-direction F(U_{j, R+}), F(U_{j + 1, L+}).
           (list-ref flux-uiR-evols-y 0)
           (list-ref flux-uiR-evols-y 1)
           (list-ref flux-uiR-evols-y 2)
           (list-ref flux-upL-evols-y 0)
           (list-ref flux-upL-evols-y 1)
           (list-ref flux-upL-evols-y 2)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; -------------------------------------------------------------------
;; Roe (Finite-Volume) Solver for a 2D Coupled Vector System of 3 PDEs
;; -------------------------------------------------------------------
(define (generate-roe-vector3-2d pde-system
                                 #:nx [nx 200]
                                 #:ny [ny 200]
                                 #:x0 [x0 0.0]
                                 #:x1 [x1 2.0]
                                 #:y0 [y0 0.0]
                                 #:y1 [y1 2.0]
                                 #:t-final [t-final 1.0]
                                 #:cfl [cfl 0.95]
                                 #:init-funcs [init-funcs (list
                                                           `(cond
                                                              [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.25) 5.0]
                                                              [else 1.0])
                                                           `0.0
                                                           `0.0)])
 "Generate C code that solves the 2D coupled vector system of 3 PDEs specified by `pde-system` using the Roe finite-volume method.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define max-speed-exprs-x (hash-ref pde-system 'max-speed-exprs-x))
  (define max-speed-exprs-y (hash-ref pde-system 'max-speed-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (define flux-jacobian-eigvals-x (symbolic-eigvals3 (symbolic-jacobian flux-exprs-x cons-exprs)))
  (define flux-jacobian-eigvals-y (symbolic-eigvals3 (symbolic-jacobian flux-exprs-y cons-exprs)))
  (define flux-jacobian-eigvals-simp-x (list (symbolic-simp (list-ref flux-jacobian-eigvals-x 0))
                                             (symbolic-simp (list-ref flux-jacobian-eigvals-x 1))
                                             (symbolic-simp (list-ref flux-jacobian-eigvals-x 2))))
  (define flux-jacobian-eigvals-simp-y (list (symbolic-simp (list-ref flux-jacobian-eigvals-y 0))
                                             (symbolic-simp (list-ref flux-jacobian-eigvals-y 1))
                                             (symbolic-simp (list-ref flux-jacobian-eigvals-y 2))))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes-x (map (lambda (flux-expr-x)
                              (convert-expr flux-expr-x)) flux-exprs-x))
  (define flux-codes-y (map (lambda (flux-expr-y)
                              (convert-expr flux-expr-y)) flux-exprs-y))
  (define flux-deriv-codes-x (map (lambda (flux-deriv-expr-x)
                                    (convert-expr flux-deriv-expr-x)) flux-jacobian-eigvals-simp-x))
  (define flux-deriv-codes-y (map (lambda (flux-deriv-expr-y)
                                    (convert-expr flux-deriv-expr-y)) flux-jacobian-eigvals-simp-y))
  (define max-speed-codes-x (map (lambda (max-speed-expr-x)
                                   (convert-expr max-speed-expr-x)) max-speed-exprs-x))
  (define max-speed-codes-y (map (lambda (max-speed-expr-y)
                                   (convert-expr max-speed-expr-y)) max-speed-exprs-y))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define flux-ums-x (map (lambda (flux-code-x)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "um_x[0]")
                                                              (list-ref cons-codes 1) "um_x[1]") (list-ref cons-codes 2) "um_x[2]")) flux-codes-x))
  (define flux-uis-x (map (lambda (flux-code-x)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "ui_x[0]")
                                                              (list-ref cons-codes 1) "ui_x[1]") (list-ref cons-codes 2) "ui_x[2]")) flux-codes-x))
  (define flux-ups-x (map (lambda (flux-code-x)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "up_x[0]")
                                                              (list-ref cons-codes 1) "up_x[1]") (list-ref cons-codes 2) "up_x[2]")) flux-codes-x))

  (define flux-deriv-ums-x (map (lambda (flux-deriv-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-x (list-ref cons-codes 0) "um_x[0]")
                                                                    (list-ref cons-codes 1) "um_x[1]") (list-ref cons-codes 2) "um_x[2]")) flux-deriv-codes-x))
  (define flux-deriv-uis-x (map (lambda (flux-deriv-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-x (list-ref cons-codes 0) "ui_x[0]")
                                                                    (list-ref cons-codes 1) "ui_x[1]") (list-ref cons-codes 2) "ui_x[2]")) flux-deriv-codes-x))
  (define flux-deriv-ups-x (map (lambda (flux-deriv-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-x (list-ref cons-codes 0) "up_x[0]")
                                                                    (list-ref cons-codes 1) "up_x[1]") (list-ref cons-codes 2) "up_x[2]")) flux-deriv-codes-x))

  (define flux-ums-y (map (lambda (flux-code-y)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "um_y[0]")
                                                              (list-ref cons-codes 1) "um_y[1]") (list-ref cons-codes 2) "um_y[2]")) flux-codes-y))
  (define flux-uis-y (map (lambda (flux-code-y)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "ui_y[0]")
                                                              (list-ref cons-codes 1) "ui_y[1]") (list-ref cons-codes 2) "ui_y[2]")) flux-codes-y))
  (define flux-ups-y (map (lambda (flux-code-y)
                            (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "up_y[0]")
                                                              (list-ref cons-codes 1) "up_y[1]") (list-ref cons-codes 2) "up_y[2]")) flux-codes-y))

  (define flux-deriv-ums-y (map (lambda (flux-deriv-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-y (list-ref cons-codes 0) "um_y[0]")
                                                                    (list-ref cons-codes 1) "um_y[1]") (list-ref cons-codes 2) "um_y[2]")) flux-deriv-codes-y))
  (define flux-deriv-uis-y (map (lambda (flux-deriv-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-y (list-ref cons-codes 0) "ui_y[0]")
                                                                    (list-ref cons-codes 1) "ui_y[1]") (list-ref cons-codes 2) "ui_y[2]")) flux-deriv-codes-y))
  (define flux-deriv-ups-y (map (lambda (flux-deriv-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-y (list-ref cons-codes 0) "up_y[0]")
                                                                    (list-ref cons-codes 1) "up_y[1]") (list-ref cons-codes 2) "up_y[2]")) flux-deriv-codes-y))
  
  (define max-speed-locals-x (map (lambda (max-speed-code-x)
                                    (flux-substitute (flux-substitute (flux-substitute max-speed-code-x (list-ref cons-codes 0) "u[i][(j * 3) + 0]")
                                                                      (list-ref cons-codes 1) "u[i][(j * 3) + 1]") (list-ref cons-codes 2) "u[i][(j * 3) + 2]")) max-speed-codes-x))
  (define max-speed-locals-y (map (lambda (max-speed-code-y)
                                    (flux-substitute (flux-substitute (flux-substitute max-speed-code-y (list-ref cons-codes 0) "u[i][(j * 3) + 0]")
                                                                      (list-ref cons-codes 1) "u[i][(j * 3) + 1]") (list-ref cons-codes 2) "u[i][(j * 3) + 2]")) max-speed-codes-y))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))
  
  (define code
    (format "
// AUTO-GENERATED CODE FOR COUPLED VECTOR PDE SYSTEM: ~a
// Roe higher-order finite-volume solver for a coupled vector system of 3 PDEs in 2D.

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
    u[i] = (double*) malloc((ny + 2) * 3 * sizeof(double));
    un[i] = (double*) malloc((ny + 2) * 3 * sizeof(double));
  }

  // Arrays for storing other intermediate values.
  double *local_alpha_x = (double*) malloc(3 * sizeof(double));
  double *local_alpha_y = (double*) malloc(3 * sizeof(double));

  double *um_x = (double*) malloc(3 * sizeof(double));
  double *ui_x = (double*) malloc(3 * sizeof(double));
  double *up_x = (double*) malloc(3 * sizeof(double));

  double *f_um_x = (double*) malloc(3 * sizeof(double));
  double *f_ui_x = (double*) malloc(3 * sizeof(double));
  double *f_up_x = (double*) malloc(3 * sizeof(double));

  double *f_deriv_um_x = (double*) malloc(3 * sizeof(double));
  double *f_deriv_ui_x = (double*) malloc(3 * sizeof(double));
  double *f_deriv_up_x = (double*) malloc(3 * sizeof(double));

  double *aL_roe_x = (double*) malloc(3 * sizeof(double));
  double *aR_roe_x = (double*) malloc(3 * sizeof(double));

  double *fluxL_x = (double*) malloc(3 * sizeof(double));
  double *fluxR_x = (double*) malloc(3 * sizeof(double));

  double *um_y = (double*) malloc(3 * sizeof(double));
  double *ui_y = (double*) malloc(3 * sizeof(double));
  double *up_y = (double*) malloc(3 * sizeof(double));

  double *f_um_y = (double*) malloc(3 * sizeof(double));
  double *f_ui_y = (double*) malloc(3 * sizeof(double));
  double *f_up_y = (double*) malloc(3 * sizeof(double));

  double *f_deriv_um_y = (double*) malloc(3 * sizeof(double));
  double *f_deriv_ui_y = (double*) malloc(3 * sizeof(double));
  double *f_deriv_up_y = (double*) malloc(3 * sizeof(double));

  double *aL_roe_y = (double*) malloc(3 * sizeof(double));
  double *aR_roe_y = (double*) malloc(3 * sizeof(double));

  double *fluxL_y = (double*) malloc(3 * sizeof(double));
  double *fluxR_y = (double*) malloc(3 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    for (int j = 0; j <= ny + 1; j++) {
      double x = x0 + (i - 0.5) * dx;
      double y = y0 + (j - 0.5) * dy;
    
      u[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      u[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      u[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.

      un[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      un[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      un[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.
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
        local_alpha_x[0] = ~a; // max-speed-exprs-x[0] in C.
        local_alpha_x[1] = ~a; // max-speed-exprs-x[1] in C.
        local_alpha_x[2] = ~a; // max-speed-exprs-x[2] in C.

        local_alpha_y[0] = ~a; // max-speed-exprs-y[0] in C.
        local_alpha_y[1] = ~a; // max-speed-exprs-y[1] in C.
        local_alpha_y[2] = ~a; // max-speed-exprs-y[2] in C.
      
        for (int k = 0; k < 3; k++) {
          if (local_alpha_x[k] > alpha_x) {
            alpha_x = local_alpha_x[k];
          }
          if (local_alpha_y[k] > alpha_y) {
            alpha_y = local_alpha_y[k];
          }
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

    // Compute fluxes with Roe approximation and update the conserved variable vector in the y-direction by half a time-step.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        for (int k = 0; k < 3; k++) {
          um_y[k] = u[i][((j - 1) * 3) + k];
          ui_y[k] = u[i][(j * 3) + k];
          up_y[k] = u[i][((j + 1) * 3) + k];
        }
        
        // Evaluate flux vector for each value of the conserved variable vector.
        f_um_y[0] = ~a;
        f_um_y[1] = ~a;
        f_um_y[2] = ~a; // F(U_{j - 1}).
        
        f_ui_y[0] = ~a;
        f_ui_y[1] = ~a;
        f_ui_y[2] = ~a; // F(U_j).
      
        f_up_y[0] = ~a;
        f_up_y[1] = ~a;
        f_up_y[2] = ~a; // F(U_{j + 1}).

        // Evaluate eigenvalues of the flux Jacobian for each value of the conserved variable vector.
        f_deriv_um_y[0] = ~a;
        f_deriv_um_y[1] = ~a;
        f_deriv_um_y[2] = ~a; // Eigenvalues of F'(U_{j - 1}).
      
        f_deriv_ui_y[0] = ~a;
        f_deriv_ui_y[1] = ~a;
        f_deriv_ui_y[2] = ~a; // Eigenvalues of F'(U_j).
      
        f_deriv_up_y[0] = ~a;
        f_deriv_up_y[1] = ~a;
        f_deriv_up_y[2] = ~a; // Eigenvalues of F'(U_{j + 1}).
        
        // Left interface flux: F_{j - 1/2} = 0.5 * (F(U_{j - 1}) + F(U_j)) - 0.5 * |aL_roe_y| * (U_j - U_{j - 1}).
        for (int k = 0; k < 3; k++) {
          aL_roe_y[k] = 0.5 * (f_deriv_um_y[k] + f_deriv_ui_y[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxL_y[k] = 0.5 * (f_um_y[k] + f_ui_y[k]) - 0.5 * fabs(aL_roe_y[k]) * (ui_y[k] - um_y[k]);
        }

        // Right interface flux: F_{j + 1/2} = 0.5 * (F(U_{j + 1}) + F(U_j)) - 0.5 * |aR_roe_y| * (U_{j + 1} - U_j).
        for (int k = 0; k < 3; k++) {
          aR_roe_y[k] = 0.5 * (f_deriv_ui_y[k] + f_deriv_up_y[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxR_y[k] = 0.5 * (f_ui_y[k] + f_up_y[k]) - 0.5 * fabs(aR_roe_y[k]) * (up_y[k] - ui_y[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = ui_y[k] - (dt / (2.0 * dy)) * (fluxR_y[k] - fluxL_y[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[1][(j * 3) + k];
        u[nx + 1][(j * 3) + k] = u[nx][(j * 3) + k];

        un[0][(j * 3) + k] = un[1][(j * 3) + k];
        un[nx + 1][(j * 3) + k] = un[nx][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(1 * 3) + k];
        u[i][((ny + 1) * 3) + k] = u[i][(ny * 3) + k];

        un[i][(0 * 3) + k] = un[i][(1 * 3) + k];
        un[i][((ny + 1) * 3) + k] = un[i][(ny * 3) + k];
      }
    }

    // Compute fluxes with Roe approximation and update the conserved variable vector in the x-direction.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        for (int k = 0; k < 3; k++) {
          um_x[k] = u[i - 1][(j * 3) + k];
          ui_x[k] = u[i][(j * 3) + k];
          up_x[k] = u[i + 1][(j * 3) + k];
        }

        // Evaluate flux vector for each value of the conserved variable vector.
        f_um_x[0] = ~a;
        f_um_x[1] = ~a;
        f_um_x[2] = ~a; // F(U_{i - 1}).
      
        f_ui_x[0] = ~a;
        f_ui_x[1] = ~a;
        f_ui_x[2] = ~a; // F(U_i).
      
        f_up_x[0] = ~a;
        f_up_x[1] = ~a;
        f_up_x[2] = ~a; // F(U_{i + 1}).

        // Evaluate eigenvalues of the flux Jacobian for each value of the conserved variable vector.
        f_deriv_um_x[0] = ~a;
        f_deriv_um_x[1] = ~a;
        f_deriv_um_x[2] = ~a; // Eigenvalues of F'(U_{i - 1}).
      
        f_deriv_ui_x[0] = ~a;
        f_deriv_ui_x[1] = ~a;
        f_deriv_ui_x[2] = ~a; // Eigenvalues of F'(U_i).
      
        f_deriv_up_x[0] = ~a;
        f_deriv_up_x[1] = ~a;
        f_deriv_up_x[2] = ~a; // Eigenvalues of F'(U_{i + 1}).
        
        // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1}) + F(U_i)) - 0.5 * |aL_roe_x| * (U_i - U_{i - 1}).
        for (int k = 0; k < 3; k++) {
          aL_roe_x[k] = 0.5 * (f_deriv_um_x[k] + f_deriv_ui_x[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxL_x[k] = 0.5 * (f_um_x[k] + f_ui_x[k]) - 0.5 * fabs(aL_roe_x[k]) * (ui_x[k] - um_x[k]);
        }

        // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1}) + F(U_i)) - 0.5 * |aR_roe_x| * (U_{i + 1} - U_i).
        for (int k = 0; k < 3; k++) {
          aR_roe_x[k] = 0.5 * (f_deriv_ui_x[k] + f_deriv_up_x[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxR_x[k] = 0.5 * (f_ui_x[k] + f_up_x[k]) - 0.5 * fabs(aR_roe_x[k]) * (up_x[k] - ui_x[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = ui_x[k] - (dt / dx) * (fluxR_x[k] - fluxL_x[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[1][(j * 3) + k];
        u[nx + 1][(j * 3) + k] = u[nx][(j * 3) + k];

        un[0][(j * 3) + k] = un[1][(j * 3) + k];
        un[nx + 1][(j * 3) + k] = un[nx][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(1 * 3) + k];
        u[i][((ny + 1) * 3) + k] = u[i][(ny * 3) + k];

        un[i][(0 * 3) + k] = un[i][(1 * 3) + k];
        un[i][((ny + 1) * 3) + k] = un[i][(ny * 3) + k];
      }
    }

    // Compute fluxes with Roe approximation and update the conserved variable vector in the y-direction by half a time-step.
    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        for (int k = 0; k < 3; k++) {
          um_y[k] = u[i][((j - 1) * 3) + k];
          ui_y[k] = u[i][(j * 3) + k];
          up_y[k] = u[i][((j + 1) * 3) + k];
        }
        
        // Evaluate flux vector for each value of the conserved variable vector.
        f_um_y[0] = ~a;
        f_um_y[1] = ~a;
        f_um_y[2] = ~a; // F(U_{j - 1}).
        
        f_ui_y[0] = ~a;
        f_ui_y[1] = ~a;
        f_ui_y[2] = ~a; // F(U_j).
      
        f_up_y[0] = ~a;
        f_up_y[1] = ~a;
        f_up_y[2] = ~a; // F(U_{j + 1}).

        // Evaluate eigenvalues of the flux Jacobian for each value of the conserved variable vector.
        f_deriv_um_y[0] = ~a;
        f_deriv_um_y[1] = ~a;
        f_deriv_um_y[2] = ~a; // Eigenvalues of F'(U_{j - 1}).
      
        f_deriv_ui_y[0] = ~a;
        f_deriv_ui_y[1] = ~a;
        f_deriv_ui_y[2] = ~a; // Eigenvalues of F'(U_j).
      
        f_deriv_up_y[0] = ~a;
        f_deriv_up_y[1] = ~a;
        f_deriv_up_y[2] = ~a; // Eigenvalues of F'(U_{j + 1}).
        
        // Left interface flux: F_{j - 1/2} = 0.5 * (F(U_{j - 1}) + F(U_j)) - 0.5 * |aL_roe_y| * (U_j - U_{j - 1}).
        for (int k = 0; k < 3; k++) {
          aL_roe_y[k] = 0.5 * (f_deriv_um_y[k] + f_deriv_ui_y[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxL_y[k] = 0.5 * (f_um_y[k] + f_ui_y[k]) - 0.5 * fabs(aL_roe_y[k]) * (ui_y[k] - um_y[k]);
        }

        // Right interface flux: F_{j + 1/2} = 0.5 * (F(U_{j + 1}) + F(U_j)) - 0.5 * |aR_roe_y| * (U_{j + 1} - U_j).
        for (int k = 0; k < 3; k++) {
          aR_roe_y[k] = 0.5 * (f_deriv_ui_y[k] + f_deriv_up_y[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxR_y[k] = 0.5 * (f_ui_y[k] + f_up_y[k]) - 0.5 * fabs(aR_roe_y[k]) * (up_y[k] - ui_y[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = ui_y[k] - (dt / (2.0 * dy)) * (fluxR_y[k] - fluxL_y[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j <= ny + 1; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[1][(j * 3) + k];
        u[nx + 1][(j * 3) + k] = u[nx][(j * 3) + k];

        un[0][(j * 3) + k] = un[1][(j * 3) + k];
        un[nx + 1][(j * 3) + k] = un[nx][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(1 * 3) + k];
        u[i][((ny + 1) * 3) + k] = u[i][(ny * 3) + k];

        un[i][(0 * 3) + k] = un[i][(1 * 3) + k];
        un[i][((ny + 1) * 3) + k] = un[i][(ny * 3) + k];
      }
    }

    // Output solution to disk.
    for (int k = 0; k < 3; k++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", k, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", k, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 1; i <= nx; i++) {
          for (int j = 1; j <= ny; j++) {
            double x = x0 + (i - 0.5) * dx;
            double y = y0 + (j - 0.5) * dy;
            fprintf(fptr, \"%f, %f, %f\\n\", x, y, u[i][(j * 3) + k]);
          }
        }

        fclose(fptr);
      }
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

  free(local_alpha_x);
  free(local_alpha_y);
  
  free(um_x);
  free(ui_x);
  free(up_x);

  free(f_um_x);
  free(f_ui_x);
  free(f_up_x);

  free(f_deriv_um_x);
  free(f_deriv_ui_x);
  free(f_deriv_up_x);

  free(aL_roe_x);
  free(aR_roe_x);

  free(fluxL_x);
  free(fluxR_x);

  free(um_y);
  free(ui_y);
  free(up_y);

  free(f_um_y);
  free(f_ui_y);
  free(f_up_y);

  free(f_deriv_um_y);
  free(f_deriv_ui_y);
  free(f_deriv_up_y);

  free(aL_roe_y);
  free(aR_roe_y);

  free(fluxL_y);
  free(fluxR_y);
  
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
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals-x 0)
           (list-ref max-speed-locals-x 1)
           (list-ref max-speed-locals-x 2)
           (list-ref max-speed-locals-y 0)
           (list-ref max-speed-locals-y 1)
           (list-ref max-speed-locals-y 2)
           ;; Left, middle, right flux vectors in y-direction F(u_{j - 1}), F(u_j), F(u_{j + 1}).
           (list-ref flux-ums-y 0)
           (list-ref flux-ums-y 1)
           (list-ref flux-ums-y 2)
           (list-ref flux-uis-y 0)
           (list-ref flux-uis-y 1)
           (list-ref flux-uis-y 2)
           (list-ref flux-ups-y 0)
           (list-ref flux-ups-y 1)
           (list-ref flux-ups-y 2)
           ;; Eigenvalues of left, middle, right flux Jacobians in y-direction F'(u_{j - 1}), F'(u_j), F'(u_{j + 1}).
           (list-ref flux-deriv-ums-y 0)
           (list-ref flux-deriv-ums-y 1)
           (list-ref flux-deriv-ums-y 2)
           (list-ref flux-deriv-uis-y 0)
           (list-ref flux-deriv-uis-y 1)
           (list-ref flux-deriv-uis-y 2)
           (list-ref flux-deriv-ups-y 0)
           (list-ref flux-deriv-ups-y 1)
           (list-ref flux-deriv-ups-y 2)
           ;; Left, middle, right flux vectors in x-direction F(u_{i - 1}), F(u_i), F(u_{i + 1}).
           (list-ref flux-ums-x 0)
           (list-ref flux-ums-x 1)
           (list-ref flux-ums-x 2)
           (list-ref flux-uis-x 0)
           (list-ref flux-uis-x 1)
           (list-ref flux-uis-x 2)
           (list-ref flux-ups-x 0)
           (list-ref flux-ups-x 1)
           (list-ref flux-ups-x 2)
           ;; Eigenvalues of left, middle, right flux Jacobians in x-direction F'(u_{i - 1}), F'(u_i), F'(u_{i + 1}).
           (list-ref flux-deriv-ums-x 0)
           (list-ref flux-deriv-ums-x 1)
           (list-ref flux-deriv-ums-x 2)
           (list-ref flux-deriv-uis-x 0)
           (list-ref flux-deriv-uis-x 1)
           (list-ref flux-deriv-uis-x 2)
           (list-ref flux-deriv-ups-x 0)
           (list-ref flux-deriv-ups-x 1)
           (list-ref flux-deriv-ups-x 2)
           ;; Left, middle, right flux vectors in y-direction F(u_{j - 1}), F(u_j), F(u_{j + 1}).
           (list-ref flux-ums-y 0)
           (list-ref flux-ums-y 1)
           (list-ref flux-ums-y 2)
           (list-ref flux-uis-y 0)
           (list-ref flux-uis-y 1)
           (list-ref flux-uis-y 2)
           (list-ref flux-ups-y 0)
           (list-ref flux-ups-y 1)
           (list-ref flux-ups-y 2)
           ;; Eigenvalues of left, middle, right flux Jacobians in y-direction F'(u_{j - 1}), F'(u_j), F'(u_{j + 1}).
           (list-ref flux-deriv-ums-y 0)
           (list-ref flux-deriv-ums-y 1)
           (list-ref flux-deriv-ums-y 2)
           (list-ref flux-deriv-uis-y 0)
           (list-ref flux-deriv-uis-y 1)
           (list-ref flux-deriv-uis-y 2)
           (list-ref flux-deriv-ups-y 0)
           (list-ref flux-deriv-ups-y 1)
           (list-ref flux-deriv-ups-y 2)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ----------------------------------------------------------------------------------------------------------
;; Roe (Finite-Volume) Solver for a 2D Coupled Vector System of 3 PDEs with a Second-Order Flux Extrapolation
;; ----------------------------------------------------------------------------------------------------------
(define (generate-roe-vector3-2d-second-order pde-system limiter
                                              #:nx [nx 200]
                                              #:ny [ny 200]
                                              #:x0 [x0 0.0]
                                              #:x1 [x1 2.0]
                                              #:y0 [y0 0.0]
                                              #:y1 [y1 2.0]
                                              #:t-final [t-final 1.0]
                                              #:cfl [cfl 0.95]
                                              #:init-funcs [init-funcs (list
                                                                        `(cond
                                                                           [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.25) 5.0]
                                                                           [else 1.0])
                                                                        `0.0
                                                                        `0.0)])
 "Generate C code that solves the 2D coupled vector system of 3 PDEs specified by `pde-system` using the Roe finite-volume method with a
  second-order flux extrapolation using flux limiter `limiter`.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define max-speed-exprs-x (hash-ref pde-system 'max-speed-exprs-x))
  (define max-speed-exprs-y (hash-ref pde-system 'max-speed-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (define limiter-name (hash-ref limiter 'name))
  (define limiter-expr (hash-ref limiter 'limiter-expr))
  (define limiter-ratio (hash-ref limiter 'limiter-ratio))

  (define limiter-code (convert-expr limiter-expr))
  (define limiter-ratio-code (convert-expr limiter-ratio))

  (define flux-jacobian-eigvals-x (symbolic-eigvals3 (symbolic-jacobian flux-exprs-x cons-exprs)))
  (define flux-jacobian-eigvals-y (symbolic-eigvals3 (symbolic-jacobian flux-exprs-y cons-exprs)))
  (define flux-jacobian-eigvals-simp-x (list (symbolic-simp (list-ref flux-jacobian-eigvals-x 0))
                                             (symbolic-simp (list-ref flux-jacobian-eigvals-x 1))
                                             (symbolic-simp (list-ref flux-jacobian-eigvals-x 2))))
  (define flux-jacobian-eigvals-simp-y (list (symbolic-simp (list-ref flux-jacobian-eigvals-y 0))
                                             (symbolic-simp (list-ref flux-jacobian-eigvals-y 1))
                                             (symbolic-simp (list-ref flux-jacobian-eigvals-y 2))))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes-x (map (lambda (flux-expr-x)
                              (convert-expr flux-expr-x)) flux-exprs-x))
  (define flux-codes-y (map (lambda (flux-expr-y)
                              (convert-expr flux-expr-y)) flux-exprs-y))
  (define flux-deriv-codes-x (map (lambda (flux-deriv-expr-x)
                                    (convert-expr flux-deriv-expr-x)) flux-jacobian-eigvals-simp-x))
  (define flux-deriv-codes-y (map (lambda (flux-deriv-expr-y)
                                    (convert-expr flux-deriv-expr-y)) flux-jacobian-eigvals-simp-y))
  (define max-speed-codes-x (map (lambda (max-speed-expr-x)
                                   (convert-expr max-speed-expr-x)) max-speed-exprs-x))
  (define max-speed-codes-y (map (lambda (max-speed-expr-y)
                                   (convert-expr max-speed-expr-y)) max-speed-exprs-y))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define limiter-r (flux-substitute limiter-code limiter-ratio-code "r"))

  (define flux-umLs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "umL_x[0]")
                                                               (list-ref cons-codes 1) "umL_x[1]") (list-ref cons-codes 2) "umL_x[2]")) flux-codes-x))
  (define flux-umRs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "umR_x[0]")
                                                               (list-ref cons-codes 1) "umR_x[1]") (list-ref cons-codes 2) "umR_x[2]")) flux-codes-x))
  (define flux-uiLs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "uiL_x[0]")
                                                               (list-ref cons-codes 1) "uiL_x[1]") (list-ref cons-codes 2) "uiL_x[2]")) flux-codes-x))
  (define flux-uiRs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "uiR_x[0]")
                                                               (list-ref cons-codes 1) "uiR_x[1]") (list-ref cons-codes 2) "uiR_x[2]")) flux-codes-x))
  (define flux-upLs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "upL_x[0]")
                                                               (list-ref cons-codes 1) "upL_x[1]") (list-ref cons-codes 2) "upL_x[2]")) flux-codes-x))
  (define flux-upRs-x (map (lambda (flux-code-x)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "upR_x[0]")
                                                               (list-ref cons-codes 1) "upR_x[1]") (list-ref cons-codes 2) "upR_x[2]")) flux-codes-x))
  
  (define flux-umR-evols-x (map (lambda (flux-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "umR_evol_x[0]")
                                                                    (list-ref cons-codes 1) "umR_evol_x[1]") (list-ref cons-codes 2) "umR_evol_x[2]")) flux-codes-x))
  (define flux-uiL-evols-x (map (lambda (flux-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "uiL_evol_x[0]")
                                                                    (list-ref cons-codes 1) "uiL_evol_x[1]") (list-ref cons-codes 2) "uiL_evol_x[2]")) flux-codes-x))
  (define flux-uiR-evols-x (map (lambda (flux-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "uiR_evol_x[0]")
                                                                    (list-ref cons-codes 1) "uiR_evol_x[1]") (list-ref cons-codes 2) "uiR_evol_x[2]")) flux-codes-x))
  (define flux-upL-evols-x (map (lambda (flux-code-x)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-x (list-ref cons-codes 0) "upL_evol_x[0]")
                                                                    (list-ref cons-codes 1) "upL_evol_x[1]") (list-ref cons-codes 2) "upL_evol_x[2]")) flux-codes-x))

  (define flux-deriv-umR-evols-x (map (lambda (flux-deriv-code-x)
                                        (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-x (list-ref cons-codes 0) "umR_evol_x[0]")
                                                                          (list-ref cons-codes 1) "umR_evol_x[1]") (list-ref cons-codes 2) "umR_evol_x[2]")) flux-deriv-codes-x))
  (define flux-deriv-uiL-evols-x (map (lambda (flux-deriv-code-x)
                                        (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-x (list-ref cons-codes 0) "uiL_evol_x[0]")
                                                                          (list-ref cons-codes 1) "uiL_evol_x[1]") (list-ref cons-codes 2) "uiL_evol_x[2]")) flux-deriv-codes-x))
  (define flux-deriv-uiR-evols-x (map (lambda (flux-deriv-code-x)
                                        (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-x (list-ref cons-codes 0) "uiR_evol_x[0]")
                                                                          (list-ref cons-codes 1) "uiR_evol_x[1]") (list-ref cons-codes 2) "uiR_evol_x[2]")) flux-deriv-codes-x))
  (define flux-deriv-upL-evols-x (map (lambda (flux-deriv-code-x)
                                        (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-x (list-ref cons-codes 0) "upL_evol_x[0]")
                                                                          (list-ref cons-codes 1) "upL_evol_x[1]") (list-ref cons-codes 2) "upL_evol_x[2]")) flux-deriv-codes-x))

  (define flux-umLs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "umL_y[0]")
                                                               (list-ref cons-codes 1) "umL_y[1]") (list-ref cons-codes 2) "umL_y[2]")) flux-codes-y))
  (define flux-umRs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "umR_y[0]")
                                                               (list-ref cons-codes 1) "umR_y[1]") (list-ref cons-codes 2) "umR_y[2]")) flux-codes-y))
  (define flux-uiLs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "uiL_y[0]")
                                                               (list-ref cons-codes 1) "uiL_y[1]") (list-ref cons-codes 2) "uiL_y[2]")) flux-codes-y))
  (define flux-uiRs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "uiR_y[0]")
                                                               (list-ref cons-codes 1) "uiR_y[1]") (list-ref cons-codes 2) "uiR_y[2]")) flux-codes-y))
  (define flux-upLs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "upL_y[0]")
                                                               (list-ref cons-codes 1) "upL_y[1]") (list-ref cons-codes 2) "upL_y[2]")) flux-codes-y))
  (define flux-upRs-y (map (lambda (flux-code-y)
                             (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "upR_y[0]")
                                                               (list-ref cons-codes 1) "upR_y[1]") (list-ref cons-codes 2) "upR_y[2]")) flux-codes-y))
  
  (define flux-umR-evols-y (map (lambda (flux-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "umR_evol_y[0]")
                                                                    (list-ref cons-codes 1) "umR_evol_y[1]") (list-ref cons-codes 2) "umR_evol_y[2]")) flux-codes-y))
  (define flux-uiL-evols-y (map (lambda (flux-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "uiL_evol_y[0]")
                                                                    (list-ref cons-codes 1) "uiL_evol_y[1]") (list-ref cons-codes 2) "uiL_evol_y[2]")) flux-codes-y))
  (define flux-uiR-evols-y (map (lambda (flux-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "uiR_evol_y[0]")
                                                                    (list-ref cons-codes 1) "uiR_evol_y[1]") (list-ref cons-codes 2) "uiR_evol_y[2]")) flux-codes-y))
  (define flux-upL-evols-y (map (lambda (flux-code-y)
                                  (flux-substitute (flux-substitute (flux-substitute flux-code-y (list-ref cons-codes 0) "upL_evol_y[0]")
                                                                    (list-ref cons-codes 1) "upL_evol_y[1]") (list-ref cons-codes 2) "upL_evol_y[2]")) flux-codes-y))

  (define flux-deriv-umR-evols-y (map (lambda (flux-deriv-code-y)
                                        (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-y (list-ref cons-codes 0) "umR_evol_y[0]")
                                                                          (list-ref cons-codes 1) "umR_evol_y[1]") (list-ref cons-codes 2) "umR_evol_y[2]")) flux-deriv-codes-y))
  (define flux-deriv-uiL-evols-y (map (lambda (flux-deriv-code-y)
                                        (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-y (list-ref cons-codes 0) "uiL_evol_y[0]")
                                                                          (list-ref cons-codes 1) "uiL_evol_y[1]") (list-ref cons-codes 2) "uiL_evol_y[2]")) flux-deriv-codes-y))
  (define flux-deriv-uiR-evols-y (map (lambda (flux-deriv-code-y)
                                        (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-y (list-ref cons-codes 0) "uiR_evol_y[0]")
                                                                          (list-ref cons-codes 1) "uiR_evol_y[1]") (list-ref cons-codes 2) "uiR_evol_y[2]")) flux-deriv-codes-y))
  (define flux-deriv-upL-evols-y (map (lambda (flux-deriv-code-y)
                                        (flux-substitute (flux-substitute (flux-substitute flux-deriv-code-y (list-ref cons-codes 0) "upL_evol_y[0]")
                                                                          (list-ref cons-codes 1) "upL_evol_y[1]") (list-ref cons-codes 2) "upL_evol_y[2]")) flux-deriv-codes-y))
  
  (define max-speed-locals-x (map (lambda (max-speed-code-x)
                                    (flux-substitute (flux-substitute (flux-substitute max-speed-code-x (list-ref cons-codes 0) "u[i][(j * 3) + 0]")
                                                                      (list-ref cons-codes 1) "u[i][(j * 3) + 1]") (list-ref cons-codes 2) "u[i][(j * 3) + 2]")) max-speed-codes-x))
  (define max-speed-locals-y (map (lambda (max-speed-code-y)
                                    (flux-substitute (flux-substitute (flux-substitute max-speed-code-y (list-ref cons-codes 0) "u[i][(j * 3) + 0]")
                                                                      (list-ref cons-codes 1) "u[i][(j * 3) + 1]") (list-ref cons-codes 2) "u[i][(j * 3) + 2]")) max-speed-codes-y))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))
  
  (define code
    (format "
// AUTO-GENERATED CODE FOR COUPLED VECTOR PDE SYSTEM: ~a
// FLUX LIMITER: ~a
// Roe higher-order finite-volume solver for a coupled vector system of 3 PDEs in 2D, with a second-order flux extrapolation.

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
    slope_x[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
    slope_y[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
  }

  // Arrays for storing solution.
  double **u = (double**) malloc((nx + 4) * sizeof(double*));
  double **un = (double**) malloc((nx + 4) * sizeof(double*));
  for (int i = 0; i <= nx + 3; i++) {
    u[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
    un[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
  }

  // Arrays for storing other intermediate values.
  double *local_alpha_x = (double*) malloc(3 * sizeof(double));
  double *local_alpha_y = (double*) malloc(3 * sizeof(double));
  
  double *umL_x = (double*) malloc(3 * sizeof(double));
  double *umR_x = (double*) malloc(3 * sizeof(double));
  double *uiL_x = (double*) malloc(3 * sizeof(double));
  double *uiR_x = (double*) malloc(3 * sizeof(double));
  double *upL_x = (double*) malloc(3 * sizeof(double));
  double *upR_x = (double*) malloc(3 * sizeof(double));

  double *f_umL_x = (double*) malloc(3 * sizeof(double));
  double *f_umR_x = (double*) malloc(3 * sizeof(double));
  double *f_uiL_x = (double*) malloc(3 * sizeof(double));
  double *f_uiR_x = (double*) malloc(3 * sizeof(double));
  double *f_upL_x = (double*) malloc(3 * sizeof(double));
  double *f_upR_x = (double*) malloc(3 * sizeof(double));

  double *umR_evol_x = (double*) malloc(3 * sizeof(double));
  double *uiL_evol_x = (double*) malloc(3 * sizeof(double));
  double *uiR_evol_x = (double*) malloc(3 * sizeof(double));
  double *upL_evol_x = (double*) malloc(3 * sizeof(double));

  double *f_umR_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_uiL_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_uiR_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_upL_evol_x = (double*) malloc(3 * sizeof(double));

  double *f_deriv_umR_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_deriv_uiL_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_deriv_uiR_evol_x = (double*) malloc(3 * sizeof(double));
  double *f_deriv_upL_evol_x = (double*) malloc(3 * sizeof(double));

  double *aL_roe_x = (double*) malloc(3 * sizeof(double));
  double *aR_roe_x = (double*) malloc(3 * sizeof(double));

  double *fluxL_x = (double*) malloc(3 * sizeof(double));
  double *fluxR_x = (double*) malloc(3 * sizeof(double));

  double *umL_y = (double*) malloc(3 * sizeof(double));
  double *umR_y = (double*) malloc(3 * sizeof(double));
  double *uiL_y = (double*) malloc(3 * sizeof(double));
  double *uiR_y = (double*) malloc(3 * sizeof(double));
  double *upL_y = (double*) malloc(3 * sizeof(double));
  double *upR_y = (double*) malloc(3 * sizeof(double));

  double *f_umL_y = (double*) malloc(3 * sizeof(double));
  double *f_umR_y = (double*) malloc(3 * sizeof(double));
  double *f_uiL_y = (double*) malloc(3 * sizeof(double));
  double *f_uiR_y = (double*) malloc(3 * sizeof(double));
  double *f_upL_y = (double*) malloc(3 * sizeof(double));
  double *f_upR_y = (double*) malloc(3 * sizeof(double));

  double *umR_evol_y = (double*) malloc(3 * sizeof(double));
  double *uiL_evol_y = (double*) malloc(3 * sizeof(double));
  double *uiR_evol_y = (double*) malloc(3 * sizeof(double));
  double *upL_evol_y = (double*) malloc(3 * sizeof(double));

  double *f_umR_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_uiL_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_uiR_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_upL_evol_y = (double*) malloc(3 * sizeof(double));

  double *f_deriv_umR_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_deriv_uiL_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_deriv_uiR_evol_y = (double*) malloc(3 * sizeof(double));
  double *f_deriv_upL_evol_y = (double*) malloc(3 * sizeof(double));

  double *aL_roe_y = (double*) malloc(3 * sizeof(double));
  double *aR_roe_y = (double*) malloc(3 * sizeof(double));

  double *fluxL_y = (double*) malloc(3 * sizeof(double));
  double *fluxR_y = (double*) malloc(3 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    for (int j = 0; j <= ny + 3; j++) {
      double x = x0 + (i - 1.5) * dx;
      double y = y0 + (j - 1.5) * dy;
    
      u[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      u[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      u[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.

      un[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      un[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      un[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.
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
        local_alpha_x[0] = ~a; // max-speed-exprs-x[0] in C.
        local_alpha_x[1] = ~a; // max-speed-exprs-x[1] in C.
        local_alpha_x[2] = ~a; // max-speed-exprs-x[2] in C.

        local_alpha_y[0] = ~a; // max-speed-exprs-y[0] in C.
        local_alpha_y[1] = ~a; // max-speed-exprs-y[1] in C.
        local_alpha_y[2] = ~a; // max-speed-exprs-y[2] in C.
      
        for (int k = 0; k < 3; k++) {
          if (local_alpha_x[k] > alpha_x) {
            alpha_x = local_alpha_x[k];
          }
          if (local_alpha_y[k] > alpha_y) {
            alpha_y = local_alpha_y[k];
          }
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
        for (int k = 0; k < 3; k++) {
          double r = (u[i][(j * 3) + k] - u[i][((j - 1) * 3) + k]) / (u[i][((j + 1) * 3) + k] - u[i][(j * 3) + k]);
          double limiter = ~a; // limiter-r in C.

          slope_y[i][(j * 3) + k] = limiter * (0.5 * ((u[i][(j * 3) + k] - u[i][((j - 1) * 3) + k]) + (u[i][((j + 1) * 3) + k] - u[i][(j * 3) + k])));
        }
      }
    }

    // Compute fluxes with Roe approximation and update the conserved variable vector in the y-direction by half a time-step.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        // Extrapolate boundary states.
        for (int k = 0; k < 3; k++) {
          umL_y[k] = u[i][((j - 1) * 3) + k] - (0.5 * slope_y[i][((j - 1) * 3) + k]);
          umR_y[k] = u[i][((j - 1) * 3) + k] + (0.5 * slope_y[i][((j - 1) * 3) + k]);

          uiL_y[k] = u[i][(j * 3) + k] - (0.5 * slope_y[i][(j * 3) + k]);
          uiR_y[k] = u[i][(j * 3) + k] + (0.5 * slope_y[i][(j * 3) + k]);

          upL_y[k] = u[i][((j + 1) * 3) + k] - (0.5 * slope_y[i][((j + 1) * 3) + k]);
          upR_y[k] = u[i][((j + 1) * 3) + k] + (0.5 * slope_y[i][((j + 1) * 3) + k]);
        }
        
        // Evaluate flux vector for each extrapolated boundary state.
        f_umL_y[0] = ~a;
        f_umL_y[1] = ~a;
        f_umL_y[2] = ~a;
        f_umR_y[0] = ~a;
        f_umR_y[1] = ~a;
        f_umR_y[2] = ~a;

        f_uiL_y[0] = ~a;
        f_uiL_y[1] = ~a;
        f_uiL_y[2] = ~a;
        f_uiR_y[0] = ~a;
        f_uiR_y[1] = ~a;
        f_uiR_y[2] = ~a;

        f_upL_y[0] = ~a;
        f_upL_y[1] = ~a;
        f_upL_y[2] = ~a;
        f_upR_y[0] = ~a;
        f_upR_y[1] = ~a;
        f_upR_y[2] = ~a;

        // Evolve each extrapolated boundary state.
        for (int k = 0; k < 3; k++) {
          umR_evol_y[k] = umR_y[k] + ((dt / (4.0 * dy)) * (f_umL_y[k] - f_umR_y[k]));

          uiL_evol_y[k] = uiL_y[k] + ((dt / (4.0 * dy)) * (f_uiL_y[k] - f_uiR_y[k]));
          uiR_evol_y[k] = uiR_y[k] + ((dt / (4.0 * dy)) * (f_uiL_y[k] - f_uiR_y[k]));

          upL_evol_y[k] = upL_y[k] + ((dt / (4.0 * dy)) * (f_upL_y[k] - f_upR_y[k]));
        }

        // Evaluate flux vector for each value of the (evolved) conserved variable vector.
        f_umR_evol_y[0] = ~a;
        f_umR_evol_y[1] = ~a;
        f_umR_evol_y[2] = ~a; // F(U_{j - 1, R+})
        f_uiL_evol_y[0] = ~a;
        f_uiL_evol_y[1] = ~a;
        f_uiL_evol_y[2] = ~a; // F(U_{j, L+})
      
        f_uiR_evol_y[0] = ~a;
        f_uiR_evol_y[1] = ~a;
        f_uiR_evol_y[2] = ~a; // F(U_{j, R+})
        f_upL_evol_y[0] = ~a;
        f_upL_evol_y[1] = ~a;
        f_upL_evol_y[2] = ~a; // F(U_{j + 1, L+})

        // Evaluate eigenvalues of the flux Jacobian for each value of the (evolved) conserved variable vector.
        f_deriv_umR_evol_y[0] = ~a;
        f_deriv_umR_evol_y[1] = ~a;
        f_deriv_umR_evol_y[2] = ~a; // F'(U_{j - 1, R+})
        f_deriv_uiL_evol_y[0] = ~a;
        f_deriv_uiL_evol_y[1] = ~a;
        f_deriv_uiL_evol_y[2] = ~a; // F'(U_{j, L+})
      
        f_deriv_uiR_evol_y[0] = ~a;
        f_deriv_uiR_evol_y[1] = ~a;
        f_deriv_uiR_evol_y[2] = ~a; // F'(U_{j, R+})
        f_deriv_upL_evol_y[0] = ~a;
        f_deriv_upL_evol_y[1] = ~a;
        f_deriv_upL_evol_y[2] = ~a; // F'(U_{j + 1, L+})

        // Left interface flux: F_{j - 1/2} = 0.5 * (F(U_{j - 1, R+}) + F(U_{j, L+})) - 0.5 * |aL_roe_y| * (U_{j, L+} - U_{j - 1, R+}).
        for (int k = 0; k < 3; k++) {
          aL_roe_y[k] = 0.5 * (f_deriv_umR_evol_y[k] + f_deriv_uiL_evol_y[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxL_y[k] = 0.5 * (f_umR_evol_y[k] + f_uiL_evol_y[k]) - 0.5 * fabs(aL_roe_y[k]) * (uiL_evol_y[k] - umR_evol_y[k]);
        }

        // Right interface flux: F_{j + 1/2} = 0.5 * (F(U_{j + 1, L+}) + F(U_{j, R+})) - 0.5 * |aR_roe_y| * (U_{j + 1, L+} - u_{j, R+}).
        for (int k = 0; k < 3; k++) {
          aR_roe_y[k] = 0.5 * (f_deriv_uiR_evol_y[k] + f_deriv_upL_evol_y[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxR_y[k] = 0.5 * (f_uiR_evol_y[k] + f_upL_evol_y[k]) - 0.5 * fabs(aR_roe_y[k]) * (upL_evol_y[k] - uiR_evol_y[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = u[i][(j * 3) + k] - (dt / (2.0 * dy)) * (fluxR_y[k] - fluxL_y[k]);
        }
      }
    }
    
    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[2][(j * 3) + k];
        u[1][(j * 3) + k] = u[2][(j * 3) + k];
        u[nx + 2][(j * 3) + k] = u[nx + 1][(j * 3) + k];
        u[nx + 3][(j * 3) + k] = u[nx + 1][(j * 3) + k];

        un[0][(j * 3) + k] = un[2][(j * 3) + k];
        un[1][(j * 3) + k] = un[2][(j * 3) + k];
        un[nx + 2][(j * 3) + k] = un[nx + 1][(j * 3) + k];
        un[nx + 3][(j * 3) + k] = un[nx + 1][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(2 * 3) + k];
        u[i][(1 * 3) + k] = u[i][(2 * 3) + k];
        u[i][((ny + 2) * 3) + k] = u[i][((ny + 1) * 3) + k];
        u[i][((ny + 3) * 3) + k] = u[i][((ny + 1) * 3) + k];

        un[i][(0 * 3) + k] = un[i][(2 * 3) + k];
        un[i][(1 * 3) + k] = un[i][(2 * 3) + k];
        un[i][((ny + 2) * 3) + k] = un[i][((ny + 1) * 3) + k];
        un[i][((ny + 3) * 3) + k] = un[i][((ny + 1) * 3) + k];
      }
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        for (int k = 0; k < 3; k++) {
          double r = (u[i][(j * 3) + k] - u[i - 1][(j * 3) + k]) / (u[i + 1][(j * 3) + k] - u[i][(j * 3) + k]);
          double limiter = ~a; // limiter-r in C.

          slope_x[i][(j * 3) + k] = limiter * (0.5 * ((u[i][(j * 3) + k] - u[i - 1][(j * 3) + k]) + (u[i + 1][(j * 3) + k] - u[i][(j * 3) + k])));
        }
      }
    }

    // Compute fluxes with Roe approximation and update the conserved variable vector in the x-direction.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        // Extrapolate boundary states.
        for (int k = 0; k < 3; k++) {
          umL_x[k] = u[i - 1][(j * 3) + k] - (0.5 * slope_x[i - 1][(j * 3) + k]);
          umR_x[k] = u[i - 1][(j * 3) + k] + (0.5 * slope_x[i - 1][(j * 3) + k]);

          uiL_x[k] = u[i][(j * 3) + k] - (0.5 * slope_x[i][(j * 3) + k]);
          uiR_x[k] = u[i][(j * 3) + k] + (0.5 * slope_x[i][(j * 3) + k]);

          upL_x[k] = u[i + 1][(j * 3) + k] - (0.5 * slope_x[i + 1][(j * 3) + k]);
          upR_x[k] = u[i + 1][(j * 3) + k] + (0.5 * slope_x[i + 1][(j * 3) + k]);
        }

        // Evaluate flux vector for each extrapolated boundary state.
        f_umL_x[0] = ~a;
        f_umL_x[1] = ~a;
        f_umL_x[2] = ~a;
        f_umR_x[0] = ~a;
        f_umR_x[1] = ~a;
        f_umR_x[2] = ~a;

        f_uiL_x[0] = ~a;
        f_uiL_x[1] = ~a;
        f_uiL_x[2] = ~a;
        f_uiR_x[0] = ~a;
        f_uiR_x[1] = ~a;
        f_uiR_x[2] = ~a;

        f_upL_x[0] = ~a;
        f_upL_x[1] = ~a;
        f_upL_x[2] = ~a;
        f_upR_x[0] = ~a;
        f_upR_x[1] = ~a;
        f_upR_x[2] = ~a;

        // Evolve each extrapolated boundary state.
        for (int k = 0; k < 3; k++) {
          umR_evol_x[k] = umR_x[k] + ((dt / (2.0 * dx)) * (f_umL_x[k] - f_umR_x[k]));

          uiL_evol_x[k] = uiL_x[k] + ((dt / (2.0 * dx)) * (f_uiL_x[k] - f_uiR_x[k]));
          uiR_evol_x[k] = uiR_x[k] + ((dt / (2.0 * dx)) * (f_uiL_x[k] - f_uiR_x[k]));

          upL_evol_x[k] = upL_x[k] + ((dt / (2.0 * dx)) * (f_upL_x[k] - f_upR_x[k]));
        }

        // Evaluate flux vector for each value of the (evolved) conserved variable vector.
        f_umR_evol_x[0] = ~a;
        f_umR_evol_x[1] = ~a;
        f_umR_evol_x[2] = ~a; // F(U_{i - 1, R+})
        f_uiL_evol_x[0] = ~a;
        f_uiL_evol_x[1] = ~a;
        f_uiL_evol_x[2] = ~a; // F(U_{i, L+})
      
        f_uiR_evol_x[0] = ~a;
        f_uiR_evol_x[1] = ~a;
        f_uiR_evol_x[2] = ~a; // F(U_{i, R+})
        f_upL_evol_x[0] = ~a;
        f_upL_evol_x[1] = ~a;
        f_upL_evol_x[2] = ~a; // F(U_{i + 1, L+})

        // Evaluate eigenvalues of the flux Jacobian for each value of the (evolved) conserved variable vector.
        f_deriv_umR_evol_x[0] = ~a;
        f_deriv_umR_evol_x[1] = ~a;
        f_deriv_umR_evol_x[2] = ~a; // F'(U_{i - 1, R+})
        f_deriv_uiL_evol_x[0] = ~a;
        f_deriv_uiL_evol_x[1] = ~a;
        f_deriv_uiL_evol_x[2] = ~a; // F'(U_{i, L+})
      
        f_deriv_uiR_evol_x[0] = ~a;
        f_deriv_uiR_evol_x[1] = ~a;
        f_deriv_uiR_evol_x[2] = ~a; // F'(U_{i, R+})
        f_deriv_upL_evol_x[0] = ~a;
        f_deriv_upL_evol_x[1] = ~a;
        f_deriv_upL_evol_x[2] = ~a; // F'(U_{i + 1, L+})

        // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1, R+}) + F(U_{i, L+})) - 0.5 * |aL_roe_x| * (U_{i, L+} - U_{i - 1, R+}).
        for (int k = 0; k < 3; k++) {
          aL_roe_x[k] = 0.5 * (f_deriv_umR_evol_x[k] + f_deriv_uiL_evol_x[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxL_x[k] = 0.5 * (f_umR_evol_x[k] + f_uiL_evol_x[k]) - 0.5 * fabs(aL_roe_x[k]) * (uiL_evol_x[k] - umR_evol_x[k]);
        }

        // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1, L+}) + F(U_{i, R+})) - 0.5 * |aR_roe_x| * (U_{i + 1, L+} - u_{i, R+}).
        for (int k = 0; k < 3; k++) {
          aR_roe_x[k] = 0.5 * (f_deriv_uiR_evol_x[k] + f_deriv_upL_evol_x[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxR_x[k] = 0.5 * (f_uiR_evol_x[k] + f_upL_evol_x[k]) - 0.5 * fabs(aR_roe_x[k]) * (upL_evol_x[k] - uiR_evol_x[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = u[i][(j * 3) + k] - (dt / dx) * (fluxR_x[k] - fluxL_x[k]);
        }
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[2][(j * 3) + k];
        u[1][(j * 3) + k] = u[2][(j * 3) + k];
        u[nx + 2][(j * 3) + k] = u[nx + 1][(j * 3) + k];
        u[nx + 3][(j * 3) + k] = u[nx + 1][(j * 3) + k];

        un[0][(j * 3) + k] = un[2][(j * 3) + k];
        un[1][(j * 3) + k] = un[2][(j * 3) + k];
        un[nx + 2][(j * 3) + k] = un[nx + 1][(j * 3) + k];
        un[nx + 3][(j * 3) + k] = un[nx + 1][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(2 * 3) + k];
        u[i][(1 * 3) + k] = u[i][(2 * 3) + k];
        u[i][((ny + 2) * 3) + k] = u[i][((ny + 1) * 3) + k];
        u[i][((ny + 3) * 3) + k] = u[i][((ny + 1) * 3) + k];

        un[i][(0 * 3) + k] = un[i][(2 * 3) + k];
        un[i][(1 * 3) + k] = un[i][(2 * 3) + k];
        un[i][((ny + 2) * 3) + k] = un[i][((ny + 1) * 3) + k];
        un[i][((ny + 3) * 3) + k] = un[i][((ny + 1) * 3) + k];
      }
    }

    // Compute appropriately flux-limited slopes within each cell.
    for (int i = 1; i <= nx + 2; i++) {
      for (int j = 1; j <= ny + 2; j++) {
        for (int k = 0; k < 3; k++) {
          double r = (u[i][(j * 3) + k] - u[i][((j - 1) * 3) + k]) / (u[i][((j + 1) * 3) + k] - u[i][(j * 3) + k]);
          double limiter = ~a; // limiter-r in C.

          slope_y[i][(j * 3) + k] = limiter * (0.5 * ((u[i][(j * 3) + k] - u[i][((j - 1) * 3) + k]) + (u[i][((j + 1) * 3) + k] - u[i][(j * 3) + k])));
        }
      }
    }

    // Compute fluxes with Roe approximation and update the conserved variable vector in the y-direction by half a time-step.
    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        // Extrapolate boundary states.
        for (int k = 0; k < 3; k++) {
          umL_y[k] = u[i][((j - 1) * 3) + k] - (0.5 * slope_y[i][((j - 1) * 3) + k]);
          umR_y[k] = u[i][((j - 1) * 3) + k] + (0.5 * slope_y[i][((j - 1) * 3) + k]);

          uiL_y[k] = u[i][(j * 3) + k] - (0.5 * slope_y[i][(j * 3) + k]);
          uiR_y[k] = u[i][(j * 3) + k] + (0.5 * slope_y[i][(j * 3) + k]);

          upL_y[k] = u[i][((j + 1) * 3) + k] - (0.5 * slope_y[i][((j + 1) * 3) + k]);
          upR_y[k] = u[i][((j + 1) * 3) + k] + (0.5 * slope_y[i][((j + 1) * 3) + k]);
        }
        
        // Evaluate flux vector for each extrapolated boundary state.
        f_umL_y[0] = ~a;
        f_umL_y[1] = ~a;
        f_umL_y[2] = ~a;
        f_umR_y[0] = ~a;
        f_umR_y[1] = ~a;
        f_umR_y[2] = ~a;

        f_uiL_y[0] = ~a;
        f_uiL_y[1] = ~a;
        f_uiL_y[2] = ~a;
        f_uiR_y[0] = ~a;
        f_uiR_y[1] = ~a;
        f_uiR_y[2] = ~a;

        f_upL_y[0] = ~a;
        f_upL_y[1] = ~a;
        f_upL_y[2] = ~a;
        f_upR_y[0] = ~a;
        f_upR_y[1] = ~a;
        f_upR_y[2] = ~a;

        // Evolve each extrapolated boundary state.
        for (int k = 0; k < 3; k++) {
          umR_evol_y[k] = umR_y[k] + ((dt / (4.0 * dy)) * (f_umL_y[k] - f_umR_y[k]));

          uiL_evol_y[k] = uiL_y[k] + ((dt / (4.0 * dy)) * (f_uiL_y[k] - f_uiR_y[k]));
          uiR_evol_y[k] = uiR_y[k] + ((dt / (4.0 * dy)) * (f_uiL_y[k] - f_uiR_y[k]));

          upL_evol_y[k] = upL_y[k] + ((dt / (4.0 * dy)) * (f_upL_y[k] - f_upR_y[k]));
        }

        // Evaluate flux vector for each value of the (evolved) conserved variable vector.
        f_umR_evol_y[0] = ~a;
        f_umR_evol_y[1] = ~a;
        f_umR_evol_y[2] = ~a; // F(U_{j - 1, R+})
        f_uiL_evol_y[0] = ~a;
        f_uiL_evol_y[1] = ~a;
        f_uiL_evol_y[2] = ~a; // F(U_{j, L+})
      
        f_uiR_evol_y[0] = ~a;
        f_uiR_evol_y[1] = ~a;
        f_uiR_evol_y[2] = ~a; // F(U_{j, R+})
        f_upL_evol_y[0] = ~a;
        f_upL_evol_y[1] = ~a;
        f_upL_evol_y[2] = ~a; // F(U_{j + 1, L+})

        // Evaluate eigenvalues of the flux Jacobian for each value of the (evolved) conserved variable vector.
        f_deriv_umR_evol_y[0] = ~a;
        f_deriv_umR_evol_y[1] = ~a;
        f_deriv_umR_evol_y[2] = ~a; // F'(U_{j - 1, R+})
        f_deriv_uiL_evol_y[0] = ~a;
        f_deriv_uiL_evol_y[1] = ~a;
        f_deriv_uiL_evol_y[2] = ~a; // F'(U_{j, L+})
      
        f_deriv_uiR_evol_y[0] = ~a;
        f_deriv_uiR_evol_y[1] = ~a;
        f_deriv_uiR_evol_y[2] = ~a; // F'(U_{j, R+})
        f_deriv_upL_evol_y[0] = ~a;
        f_deriv_upL_evol_y[1] = ~a;
        f_deriv_upL_evol_y[2] = ~a; // F'(U_{j + 1, L+})

        // Left interface flux: F_{j - 1/2} = 0.5 * (F(U_{j - 1, R+}) + F(U_{j, L+})) - 0.5 * |aL_roe_y| * (U_{j, L+} - U_{j - 1, R+}).
        for (int k = 0; k < 3; k++) {
          aL_roe_y[k] = 0.5 * (f_deriv_umR_evol_y[k] + f_deriv_uiL_evol_y[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxL_y[k] = 0.5 * (f_umR_evol_y[k] + f_uiL_evol_y[k]) - 0.5 * fabs(aL_roe_y[k]) * (uiL_evol_y[k] - umR_evol_y[k]);
        }

        // Right interface flux: F_{j + 1/2} = 0.5 * (F(U_{j + 1, L+}) + F(U_{j, R+})) - 0.5 * |aR_roe_y| * (U_{j + 1, L+} - u_{j, R+}).
        for (int k = 0; k < 3; k++) {
          aR_roe_y[k] = 0.5 * (f_deriv_uiR_evol_y[k] + f_deriv_upL_evol_y[k]);
        }
        for (int k = 0; k < 3; k++) {
          fluxR_y[k] = 0.5 * (f_uiR_evol_y[k] + f_upL_evol_y[k]) - 0.5 * fabs(aR_roe_y[k]) * (upL_evol_y[k] - uiR_evol_y[k]);
        }

        // Update the conserved variable vector.
        for (int k = 0; k < 3; k++) {
          un[i][(j * 3) + k] = u[i][(j * 3) + k] - (dt / (2.0 * dy)) * (fluxR_y[k] - fluxL_y[k]);
        }
      }
    }
    
    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j <= ny + 3; j++) {
        for (int k = 0; k < 3; k++) {
          u[i][(j * 3) + k] = un[i][(j * 3) + k];
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 3; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[2][(j * 3) + k];
        u[1][(j * 3) + k] = u[2][(j * 3) + k];
        u[nx + 2][(j * 3) + k] = u[nx + 1][(j * 3) + k];
        u[nx + 3][(j * 3) + k] = u[nx + 1][(j * 3) + k];

        un[0][(j * 3) + k] = un[2][(j * 3) + k];
        un[1][(j * 3) + k] = un[2][(j * 3) + k];
        un[nx + 2][(j * 3) + k] = un[nx + 1][(j * 3) + k];
        un[nx + 3][(j * 3) + k] = un[nx + 1][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(2 * 3) + k];
        u[i][(1 * 3) + k] = u[i][(2 * 3) + k];
        u[i][((ny + 2) * 3) + k] = u[i][((ny + 1) * 3) + k];
        u[i][((ny + 3) * 3) + k] = u[i][((ny + 1) * 3) + k];

        un[i][(0 * 3) + k] = un[i][(2 * 3) + k];
        un[i][(1 * 3) + k] = un[i][(2 * 3) + k];
        un[i][((ny + 2) * 3) + k] = un[i][((ny + 1) * 3) + k];
        un[i][((ny + 3) * 3) + k] = un[i][((ny + 1) * 3) + k];
      }
    }

    // Output solution to disk.
    for (int k = 0; k < 3; k++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", k, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", k, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 2; i <= nx + 1; i++) {
          for (int j = 2; j <= ny + 1; j++) {
            double x = x0 + (i - 1.5) * dx;
            double y = y0 + (j - 1.5) * dy;
            fprintf(fptr, \"%f, %f, %f\\n\", x, y, u[i][(j * 3) + k]);
          }
        }

        fclose(fptr);
      }
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

  free(local_alpha_x);
  free(local_alpha_y);
  
  free(umL_x);
  free(umR_x);
  free(uiL_x);
  free(uiR_x);
  free(upL_x);
  free(upR_x);

  free(f_umL_x);
  free(f_umR_x);
  free(f_uiL_x);
  free(f_uiR_x);
  free(f_upL_x);
  free(f_upR_x);

  free(umR_evol_x);
  free(uiL_evol_x);
  free(uiR_evol_x);
  free(upL_evol_x);

  free(f_umR_evol_x);
  free(f_uiL_evol_x);
  free(f_uiR_evol_x);
  free(f_upL_evol_x);

  free(f_deriv_umR_evol_x);
  free(f_deriv_uiL_evol_x);
  free(f_deriv_uiR_evol_x);
  free(f_deriv_upL_evol_x);

  free(aL_roe_x);
  free(aR_roe_x);

  free(fluxL_x);
  free(fluxR_x);

  free(umL_y);
  free(umR_y);
  free(uiL_y);
  free(uiR_y);
  free(upL_y);
  free(upR_y);

  free(f_umL_y);
  free(f_umR_y);
  free(f_uiL_y);
  free(f_uiR_y);
  free(f_upL_y);
  free(f_upR_y);

  free(umR_evol_y);
  free(uiL_evol_y);
  free(uiR_evol_y);
  free(upL_evol_y);

  free(f_umR_evol_y);
  free(f_uiL_evol_y);
  free(f_uiR_evol_y);
  free(f_upL_evol_y);

  free(f_deriv_umR_evol_y);
  free(f_deriv_uiL_evol_y);
  free(f_deriv_uiR_evol_y);
  free(f_deriv_upL_evol_y);

  free(aL_roe_y);
  free(aR_roe_y);

  free(fluxL_y);
  free(fluxR_y);
  
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
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals-x 0)
           (list-ref max-speed-locals-x 1)
           (list-ref max-speed-locals-x 2)
           (list-ref max-speed-locals-y 0)
           (list-ref max-speed-locals-y 1)
           (list-ref max-speed-locals-y 2)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left/right negative flux vectors in y-direction F(U_{j - 1, L}), F(U_{j - 1, R}).
           (list-ref flux-umLs-y 0)
           (list-ref flux-umLs-y 1)
           (list-ref flux-umLs-y 2)
           (list-ref flux-umRs-y 0)
           (list-ref flux-umRs-y 1)
           (list-ref flux-umRs-y 2)
           ;; Left/right central flux vectors in y-direction F(U_{j, L}), F(U_{j, R}).
           (list-ref flux-uiLs-y 0)
           (list-ref flux-uiLs-y 1)
           (list-ref flux-uiLs-y 2)
           (list-ref flux-uiRs-y 0)
           (list-ref flux-uiRs-y 1)
           (list-ref flux-uiRs-y 2)
           ;; Left/right positive flux vectors in y-direction F(U_{j + 1, L}), F(U_{j + 1, R}).
           (list-ref flux-upLs-y 0)
           (list-ref flux-upLs-y 1)
           (list-ref flux-upLs-y 2)
           (list-ref flux-upRs-y 0)
           (list-ref flux-upRs-y 1)
           (list-ref flux-upRs-y 2)
           ;; Evolved right negative/left central flux vectors in y-direction F(U_{j - 1, R+}), F(U_{j, L+}).
           (list-ref flux-umR-evols-y 0)
           (list-ref flux-umR-evols-y 1)
           (list-ref flux-umR-evols-y 2)
           (list-ref flux-uiL-evols-y 0)
           (list-ref flux-uiL-evols-y 1)
           (list-ref flux-uiL-evols-y 2)
           ;; Evolved right central/left positive flux vectors in y-direction F(U_{j, R+}), F(U_{j + 1, L+}).
           (list-ref flux-uiR-evols-y 0)
           (list-ref flux-uiR-evols-y 1)
           (list-ref flux-uiR-evols-y 2)
           (list-ref flux-upL-evols-y 0)
           (list-ref flux-upL-evols-y 1)
           (list-ref flux-upL-evols-y 2)
           ;; Evolved right negative/left central flux Jacobian eigenvalues in y-direction F'(U_{j - 1, R+}), F'(U_{j, L+}).
           (list-ref flux-deriv-umR-evols-y 0)
           (list-ref flux-deriv-umR-evols-y 1)
           (list-ref flux-deriv-umR-evols-y 2)
           (list-ref flux-deriv-uiL-evols-y 0)
           (list-ref flux-deriv-uiL-evols-y 1)
           (list-ref flux-deriv-uiL-evols-y 2)
           ;; Evolved right central/left positive flux Jacobian eigenvalues in y-direction F'(U_{j, R+}), F'(U_{j + 1, L+}).
           (list-ref flux-deriv-uiR-evols-y 0)
           (list-ref flux-deriv-uiR-evols-y 1)
           (list-ref flux-deriv-uiR-evols-y 2)
           (list-ref flux-deriv-upL-evols-y 0)
           (list-ref flux-deriv-upL-evols-y 1)
           (list-ref flux-deriv-upL-evols-y 2)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left/right negative flux vectors in x-direction F(U_{i - 1, L}), F(U_{i - 1, R}).
           (list-ref flux-umLs-x 0)
           (list-ref flux-umLs-x 1)
           (list-ref flux-umLs-x 2)
           (list-ref flux-umRs-x 0)
           (list-ref flux-umRs-x 1)
           (list-ref flux-umRs-x 2)
           ;; Left/right central flux vectors in x-direction F(U_{i, L}), F(U_{i, R}).
           (list-ref flux-uiLs-x 0)
           (list-ref flux-uiLs-x 1)
           (list-ref flux-uiLs-x 2)
           (list-ref flux-uiRs-x 0)
           (list-ref flux-uiRs-x 1)
           (list-ref flux-uiRs-x 2)
           ;; Left/right positive flux vectors in x-direction F(U_{i + 1, L}), F(U_{i + 1, R}).
           (list-ref flux-upLs-x 0)
           (list-ref flux-upLs-x 1)
           (list-ref flux-upLs-x 2)
           (list-ref flux-upRs-x 0)
           (list-ref flux-upRs-x 1)
           (list-ref flux-upRs-x 2)
           ;; Evolved right negative/left central flux vectors in x-direction F(U_{i - 1, R+}), F(U_{i, L+}).
           (list-ref flux-umR-evols-x 0)
           (list-ref flux-umR-evols-x 1)
           (list-ref flux-umR-evols-x 2)
           (list-ref flux-uiL-evols-x 0)
           (list-ref flux-uiL-evols-x 1)
           (list-ref flux-uiL-evols-x 2)
           ;; Evolved right central/left positive flux vectors in x-direction F(U_{i, R+}), F(U_{i + 1, L+}).
           (list-ref flux-uiR-evols-x 0)
           (list-ref flux-uiR-evols-x 1)
           (list-ref flux-uiR-evols-x 2)
           (list-ref flux-upL-evols-x 0)
           (list-ref flux-upL-evols-x 1)
           (list-ref flux-upL-evols-x 2)
           ;; Evolved right negative/left central flux Jacobian eigenvalues in x-direction F'(U_{i - 1, R+}), F'(U_{i, L+}).
           (list-ref flux-deriv-umR-evols-x 0)
           (list-ref flux-deriv-umR-evols-x 1)
           (list-ref flux-deriv-umR-evols-x 2)
           (list-ref flux-deriv-uiL-evols-x 0)
           (list-ref flux-deriv-uiL-evols-x 1)
           (list-ref flux-deriv-uiL-evols-x 2)
           ;; Evolved right central/left positive flux Jacobian eigenvalues in x-direction F'(U_{i, R+}), F'(U_{i + 1, L+}).
           (list-ref flux-deriv-uiR-evols-x 0)
           (list-ref flux-deriv-uiR-evols-x 1)
           (list-ref flux-deriv-uiR-evols-x 2)
           (list-ref flux-deriv-upL-evols-x 0)
           (list-ref flux-deriv-upL-evols-x 1)
           (list-ref flux-deriv-upL-evols-x 2)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left/right negative flux vectors in y-direction F(U_{j - 1, L}), F(U_{j - 1, R}).
           (list-ref flux-umLs-y 0)
           (list-ref flux-umLs-y 1)
           (list-ref flux-umLs-y 2)
           (list-ref flux-umRs-y 0)
           (list-ref flux-umRs-y 1)
           (list-ref flux-umRs-y 2)
           ;; Left/right central flux vectors in y-direction F(U_{j, L}), F(U_{j, R}).
           (list-ref flux-uiLs-y 0)
           (list-ref flux-uiLs-y 1)
           (list-ref flux-uiLs-y 2)
           (list-ref flux-uiRs-y 0)
           (list-ref flux-uiRs-y 1)
           (list-ref flux-uiRs-y 2)
           ;; Left/right positive flux vectors in y-direction F(U_{j + 1, L}), F(U_{j + 1, R}).
           (list-ref flux-upLs-y 0)
           (list-ref flux-upLs-y 1)
           (list-ref flux-upLs-y 2)
           (list-ref flux-upRs-y 0)
           (list-ref flux-upRs-y 1)
           (list-ref flux-upRs-y 2)
           ;; Evolved right negative/left central flux vectors in y-direction F(U_{j - 1, R+}), F(U_{j, L+}).
           (list-ref flux-umR-evols-y 0)
           (list-ref flux-umR-evols-y 1)
           (list-ref flux-umR-evols-y 2)
           (list-ref flux-uiL-evols-y 0)
           (list-ref flux-uiL-evols-y 1)
           (list-ref flux-uiL-evols-y 2)
           ;; Evolved right central/left positive flux vectors in y-direction F(U_{j, R+}), F(U_{j + 1, L+}).
           (list-ref flux-uiR-evols-y 0)
           (list-ref flux-uiR-evols-y 1)
           (list-ref flux-uiR-evols-y 2)
           (list-ref flux-upL-evols-y 0)
           (list-ref flux-upL-evols-y 1)
           (list-ref flux-upL-evols-y 2)
           ;; Evolved right negative/left central flux Jacobian eigenvalues in y-direction F'(U_{j - 1, R+}), F'(U_{j, L+}).
           (list-ref flux-deriv-umR-evols-y 0)
           (list-ref flux-deriv-umR-evols-y 1)
           (list-ref flux-deriv-umR-evols-y 2)
           (list-ref flux-deriv-uiL-evols-y 0)
           (list-ref flux-deriv-uiL-evols-y 1)
           (list-ref flux-deriv-uiL-evols-y 2)
           ;; Evolved right central/left positive flux Jacobian eigenvalues in y-direction F'(U_{j, R+}), F'(U_{j + 1, L+}).
           (list-ref flux-deriv-uiR-evols-y 0)
           (list-ref flux-deriv-uiR-evols-y 1)
           (list-ref flux-deriv-uiR-evols-y 2)
           (list-ref flux-deriv-upL-evols-y 0)
           (list-ref flux-deriv-upL-evols-y 1)
           (list-ref flux-deriv-upL-evols-y 2)
           ;; PDE name for file output.
           name
           name
           ))
  code)