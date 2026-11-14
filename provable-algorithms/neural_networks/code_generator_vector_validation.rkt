#lang racket

(require "code_generator_core_training.rkt")
(require "code_generator_core_validation.rkt")
(provide validate-vector2-1d
         validate-vector2-1d-second-order
         validate-vector3-2d
         validate-vector3-2d-second-order)

;; ---------------------------------------------------------------------------------------------
;; Validate an Arbitrary (First-Order) Surrogate Solver for a 1D Coupled Vector System of 2 PDEs
;; ---------------------------------------------------------------------------------------------
(define (validate-vector2-1d pde-system neural-net
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
  "Generate C code that validates a surrogate solver for the 1D coupled vector system of 2 PDEs specified by `pde` using any first-order method,
   with neural network architecture `neural-net`.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define max-speed-exprs (hash-ref pde-system 'max-speed-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define max-speed-codes (map (lambda (max-speed-expr)
                                 (convert-expr max-speed-expr)) max-speed-exprs))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))
  
  (define max-speed-locals (map (lambda (max-speed-code)
                                  (flux-substitute (flux-substitute max-speed-code (list-ref cons-codes 0) "u[(i * 2) + 0]")
                                                   (list-ref cons-codes 1) "u[(i * 2) + 1]")) max-speed-codes))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR VALIDATING ON COUPLED VECTOR PDE SYSTEM: ~a
// Validate any first-order surrogate solver for a coupled vector system of 2 PDEs in 1D.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include \"kann.h\"

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

  // Arrays for storing other intermediate values.
  double *local_alpha = (double*) malloc(2 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    double x = x0 + (i - 0.5) * dx;
    
    u[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    u[(i * 2) + 1] = ~a; // init-funcs[1] in C.
  }

  // Load neural network architecture.
  kann_t **ann = (kann_t**) malloc(2 * sizeof(kann_t*));

  for (int i = 0; i < 2; i++) { 
    const char *fmt = \"%s_%d_neural_net.dat\";
    int sz = snprintf(0, 0, fmt, \"~a\", i);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", i);

    FILE *fptr;
    fptr = fopen(file_nm, \"r\");
    if (fptr != NULL) {
      ann[i] = kann_load(file_nm);
    
      fclose(fptr);
    }
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

    for (int i = 1; i <= nx; i++) {
      for (int j = 0; j < 2; j++) {
        double x = x0 + (i - 0.5) * dx;
      
        float *input_data = (float*) malloc(2 * sizeof(float));
        const float *output_data;

        input_data[0] = t;
        input_data[1] = x;
      
        output_data = kann_apply1(ann[j], input_data);

        u[(i * 2) + j] = output_data[0];

        free(input_data);
      }
    }

    // Apply simple boundary conditions (transmissive).
    for (int j = 0; j < 2; j++) {
      u[(0 * 2) + j] = u[(1 * 2) + j];
      u[((nx + 1) * 2) + j] = u[(nx * 2) + j];
    }

    // Output solution to disk.
    for (int j = 0; j < 2; j++) {
      const char *fmt = \"%s_validation_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", j, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", j, n);
    
      FILE *fptr;
      fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 1; i <= nx; i++) {
          double x = x0 + (i - 0.5) * dx;
          fprintf(fptr, \"%f, %f\\n\", x, u[(i * 2) + j]);
        }
      }
      
      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(local_alpha);
  
  for (int i = 0; i < 2; i++) {
    kann_delete(ann[i]);
  }
  free(ann);
  
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
           ;; PDE name for neural network input.
           name
           name
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals 0)
           (list-ref max-speed-locals 1)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ----------------------------------------------------------------------------------------------
;; Validate an Arbitrary (Second-Order) Surrogate Solver for a 1D Coupled Vector System of 2 PDEs
;; ----------------------------------------------------------------------------------------------
(define (validate-vector2-1d-second-order pde-system limiter neural-net
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
  "Generate C code that validates a surrogate solver for the 1D coupled vector system of 2 PDEs specified by `pde` using any first-order method
   with any second-order flux extrapolation using flux limiter `limiter`, with neural network architecture `neural-net`.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define max-speed-exprs (hash-ref pde-system 'max-speed-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (define limiter-name (hash-ref limiter 'name))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define max-speed-codes (map (lambda (max-speed-expr)
                                 (convert-expr max-speed-expr)) max-speed-exprs))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))
  
  (define max-speed-locals (map (lambda (max-speed-code)
                                  (flux-substitute (flux-substitute max-speed-code (list-ref cons-codes 0) "u[(i * 2) + 0]")
                                                   (list-ref cons-codes 1) "u[(i * 2) + 1]")) max-speed-codes))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR VALIDATING ON COUPLED VECTOR PDE SYSTEM: ~a
// FLUX LIMITER: ~a
// Validate any first-order surrogate solver for a coupled vector system of 2 PDEs in 1D, with a second-order flux extrapolation.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include \"kann.h\"

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
  double *u = (double*) malloc((nx + 4) * 2 * sizeof(double));

  // Arrays for storing other intermediate values.
  double *local_alpha = (double*) malloc(2 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    double x = x0 + (i - 1.5) * dx;
    
    u[(i * 2) + 0] = ~a; // init-funcs[0] in C.
    u[(i * 2) + 1] = ~a; // init-funcs[1] in C.
  }

  // Load neural network architecture.
  kann_t **ann = (kann_t**) malloc(2 * sizeof(kann_t*));

  for (int i = 0; i < 2; i++) { 
    const char *fmt = \"%s_%d_neural_net.dat\";
    int sz = snprintf(0, 0, fmt, \"~a\", i);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", i);

    FILE *fptr;
    fptr = fopen(file_nm, \"r\");
    if (fptr != NULL) {
      ann[i] = kann_load(file_nm);
    
      fclose(fptr);
    }
  }

  double t = 0.0;
  int n = 0;
  while (t < t_final) {
    // Determine global maximum wave-speed alpha (for stable dt).
    // Simplistic approach: we compute the local alpha for each cell and take the maximum over the entire domain.
    double alpha = 0.0;
    
    for (int i = 1; i <= nx + 2; i++) {
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

    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 0; j < 2; j++) {
        double x = x0 + (i - 1.5) * dx;
      
        float *input_data = (float*) malloc(2 * sizeof(float));
        const float *output_data;

        input_data[0] = t;
        input_data[1] = x;
      
        output_data = kann_apply1(ann[j], input_data);

        u[(i * 2) + j] = output_data[0];

        free(input_data);
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
      const char *fmt = \"%s_validation_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", j, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", j, n);
    
      FILE *fptr;
      fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 2; i <= nx + 1; i++) {
          double x = x0 + (i - 1.5) * dx;
          fprintf(fptr, \"%f, %f\\n\", x, u[(i * 2) + j]);
        }
      }
      
      fclose(fptr);
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  free(u);
  free(local_alpha);
  
  for (int i = 0; i < 2; i++) {
    kann_delete(ann[i]);
  }
  free(ann);
  
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
           ;; PDE name for neural network input.
           name
           name
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals 0)
           (list-ref max-speed-locals 1)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ---------------------------------------------------------------------------------------------
;; Validate an Arbitrary (First-Order) Surrogate Solver for a 2D Coupled Vector System of 3 PDEs
;; ---------------------------------------------------------------------------------------------
(define (validate-vector3-2d pde-system neural-net
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
  "Generate C code that validates a surrogate solver for the 2D coupled vector system of 3 PDEs specified by `pde` using any first-order method,
   with neural network architecture `neural-net`.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define max-speed-exprs-x (hash-ref pde-system 'max-speed-exprs-x))
  (define max-speed-exprs-y (hash-ref pde-system 'max-speed-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define max-speed-codes-x (map (lambda (max-speed-expr-x)
                                   (convert-expr max-speed-expr-x)) max-speed-exprs-x))
  (define max-speed-codes-y (map (lambda (max-speed-expr-x)
                                   (convert-expr max-speed-expr-x)) max-speed-exprs-y))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))
  
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
// AUTO-GENERATED CODE FOR VALIDATING ON COUPLED VECTOR PDE SYSTEM: ~a
// Validate any first-order surrogate solver for a coupled vector system of 3 PDEs in 2D.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include \"kann.h\"

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
  for (int i = 0; i <= nx + 1; i++) {
    u[i] = (double*) malloc((ny + 2) * 3 * sizeof(double));
  }

  // Arrays for storing other intermediate values.
  double *local_alpha_x = (double*) malloc(3 * sizeof(double));
  double *local_alpha_y = (double*) malloc(3 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    for (int j = 0; j <= ny + 1; j++) {
      double x = x0 + (i - 0.5) * dx;
      double y = y0 + (j - 0.5) * dy;
    
      u[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      u[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      u[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.
    }
  }

  // Load neural network architecture.
  kann_t **ann = (kann_t**) malloc(3 * sizeof(kann_t*));

  for (int i = 0; i < 3; i++) { 
    const char *fmt = \"%s_%d_neural_net.dat\";
    int sz = snprintf(0, 0, fmt, \"~a\", i);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", i);

    FILE *fptr;
    fptr = fopen(file_nm, \"r\");
    if (fptr != NULL) {
      ann[i] = kann_load(file_nm);
    
      fclose(fptr);
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

    for (int i = 1; i <= nx; i++) {
      for (int j = 1; j <= ny; j++) {
        for (int k = 0; k < 3; k++) {
          double x = x0 + (i - 0.5) * dx;
          double y = y0 + (j - -.5) * dy;
      
          float *input_data = (float*) malloc(3 * sizeof(float));
          const float *output_data;

          input_data[0] = t;
          input_data[1] = x;
          input_data[2] = y;
      
          output_data = kann_apply1(ann[k], input_data);

          u[i][(j * 3) + k] = output_data[0];

          free(input_data);
        }
      }
    }

    // Apply simple boundary conditions in the x-direction (transmissive).
    for (int j = 0; j <= ny + 1; j++) {
      for (int k = 0; k < 3; k++) {
        u[0][(j * 3) + k] = u[1][(j * 3) + k];
        u[nx + 1][(j * 3) + k] = u[nx][(j * 3) + k];
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 1; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(1 * 3) + k];
        u[i][((ny + 1) * 3) + k] = u[i][(ny * 3) + k];
      }
    }

    // Output solution to disk.
    for (int k = 0; k < 3; k++) {
      const char *fmt = \"%s_validation_%d_%d.csv\";
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
  }
  free(u);

  free(local_alpha_x);
  free(local_alpha_y);
  
  for (int i = 0; i < 3; i++) {
    kann_delete(ann[i]);
  }
  free(ann);
  
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
           ;; PDE name for neural network input.
           name
           name
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals-x 0)
           (list-ref max-speed-locals-x 1)
           (list-ref max-speed-locals-x 2)
           (list-ref max-speed-locals-y 0)
           (list-ref max-speed-locals-y 1)
           (list-ref max-speed-locals-y 2)
           ;; PDE name for file output.
           name
           name
           ))
  code)

;; ----------------------------------------------------------------------------------------------
;; Validate an Arbitrary (Second-Order) Surrogate Solver for a 2D Coupled Vector System of 3 PDEs
;; ----------------------------------------------------------------------------------------------
(define (validate-vector3-2d-second-order pde-system limiter neural-net
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
  "Generate C code that validates a surrogate solver for the 2D coupled vector system of 3 PDEs specified by `pde` using any first-order method
   with any second-order flux extrapolation using flux limiter `limiter`, with neural network architecture `neural-net`.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define name (hash-ref pde-system 'name))
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define max-speed-exprs-x (hash-ref pde-system 'max-speed-exprs-x))
  (define max-speed-exprs-y (hash-ref pde-system 'max-speed-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (define limiter-name (hash-ref limiter 'name))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define max-speed-codes-x (map (lambda (max-speed-expr-x)
                                   (convert-expr max-speed-expr-x)) max-speed-exprs-x))
  (define max-speed-codes-y (map (lambda (max-speed-expr-y)
                                   (convert-expr max-speed-expr-y)) max-speed-exprs-y))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))
  
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
// AUTO-GENERATED CODE FOR VALIDATING ON COUPLED VECTOR PDE SYSTEM: ~a
// FLUX LIMITER: ~a
// Validate any first-order surrogate solver for a coupled vector system of 3 PDEs in 2D, with a second-order flux extrapolation.

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include \"kann.h\"

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
  double **u = (double**) malloc((nx + 4) * sizeof(double*));
  for (int i = 0; i <= nx + 3; i++) {
    u[i] = (double*) malloc((ny + 4) * 3 * sizeof(double));
  }

  // Arrays for storing other intermediate values.
  double *local_alpha_x = (double*) malloc(3 * sizeof(double));
  double *local_alpha_y = (double*) malloc(3 * sizeof(double));

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    for (int j = 0; j <= ny + 3; j++) {
      double x = x0 + (i - 1.5) * dx;
      double y = y0 + (j - 1.5) * dy;
    
      u[i][(j * 3) + 0] = ~a; // init-funcs[0] in C.
      u[i][(j * 3) + 1] = ~a; // init-funcs[1] in C.
      u[i][(j * 3) + 2] = ~a; // init-funcs[2] in C.
    }
  }

  // Load neural network architecture.
  kann_t **ann = (kann_t**) malloc(3 * sizeof(kann_t*));

  for (int i = 0; i < 3; i++) { 
    const char *fmt = \"%s_%d_neural_net.dat\";
    int sz = snprintf(0, 0, fmt, \"~a\", i);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", i);

    FILE *fptr;
    fptr = fopen(file_nm, \"r\");
    if (fptr != NULL) {
      ann[i] = kann_load(file_nm);
    
      fclose(fptr);
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

    for (int i = 2; i <= nx + 1; i++) {
      for (int j = 2; j <= ny + 1; j++) {
        for (int k = 0; k < 3; k++) {
          double x = x0 + (i - 1.5) * dx;
          double y = y0 + (j - 1.5) * dy;
      
          float *input_data = (float*) malloc(3 * sizeof(float));
          const float *output_data;

          input_data[0] = t;
          input_data[1] = x;
          input_data[2] = y;
      
          output_data = kann_apply1(ann[k], input_data);

          u[i][(j * 3) + k] = output_data[0];

          free(input_data);
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
      }
    }

    // Apply simple boundary conditions in the y-direction (transmissive).
    for (int i = 0; i <= nx + 3; i++) {
      for (int k = 0; k < 3; k++) {
        u[i][(0 * 3) + k] = u[i][(2 * 3) + k];
        u[i][(1 * 3) + k] = u[i][(2 * 3) + k];
        u[i][((ny + 2) * 3) + k] = u[i][((ny + 1) * 3) + k];
        u[i][((ny + 3) * 3) + k] = u[i][((ny + 1) * 3) + k];
      }
    }

    // Output solution to disk.
    for (int k = 0; k < 3; k++) {
      const char *fmt = \"%s_validation_%d_%d.csv\";
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
  }
  free(u);

  free(local_alpha_x);
  free(local_alpha_y);
  
  for (int i = 0; i < 3; i++) {
    kann_delete(ann[i]);
  }
  free(ann);
  
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
           ;; PDE name for neural network input.
           name
           name
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals-x 0)
           (list-ref max-speed-locals-x 1)
           (list-ref max-speed-locals-x 2)
           (list-ref max-speed-locals-y 0)
           (list-ref max-speed-locals-y 1)
           (list-ref max-speed-locals-y 2)
           ;; PDE name for file output.
           name
           name
           ))
  code)