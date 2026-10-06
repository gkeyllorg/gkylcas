#lang racket

(require "code_generator_core_training.rkt")
(provide train-lax-friedrichs-vector3-1d
         train-lax-friedrichs-vector3-1d-second-order)

;; ----------------------------------------------------------------------------------------------------
;; Train a Lax–Friedrichs (Finite-Difference) Surrogate Solver for a 1D Coupled Vector System of 3 PDEs
;; ----------------------------------------------------------------------------------------------------
(define (train-lax-friedrichs-vector3-1d pde-system neural-net
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
                                                                      [(< x 0.5) 0.0]
                                                                      [else 0.0])
                                                                   `(cond
                                                                      [(< x 0.5) 7.5]
                                                                      [else 2.5]))])
  "Generate C code that trains a surrogate solver for the 1D coupled vector system of 3 PDEs specified by `pde-system` using the Lax-Friedrichs finite-difference method,
   with neural network architecture `neural-net`.
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

  (define max-trains (hash-ref neural-net 'max-trains))
  (define width (hash-ref neural-net 'width))
  (define depth (hash-ref neural-net 'depth))

  (define num-threads (hash-ref neural-net 'num-threads))
  (define mini-size (hash-ref neural-net 'mini-size))

  (define cons-codes (map (lambda (cons-expr)
                            (convert-expr cons-expr)) cons-exprs))
  (define flux-codes (map (lambda (flux-expr)
                            (convert-expr flux-expr)) flux-exprs))
  (define max-speed-codes (map (lambda (max-speed-expr)
                                 (convert-expr max-speed-expr)) max-speed-exprs))
  (define init-func-codes (map (lambda (init-func-expr)
                                 (convert-expr init-func-expr)) init-funcs))

  (define flux-ums (map (lambda (flux-code)
                          (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "um[0]")
                                                            (list-ref cons-codes 1) "um[1]") (list-ref cons-codes 2) "um[2]")) flux-codes))
  (define flux-uis (map (lambda (flux-code)
                          (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "ui[0]")
                                                            (list-ref cons-codes 1) "ui[1]") (list-ref cons-codes 2) "ui[2]")) flux-codes))
  (define flux-ups (map (lambda (flux-code)
                          (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "up[0]")
                                                            (list-ref cons-codes 1) "up[1]") (list-ref cons-codes 2) "up[2]")) flux-codes))

  (define max-speed-locals (map (lambda (max-speed-code)
                                  (flux-substitute (flux-substitute (flux-substitute max-speed-code (list-ref cons-codes 0) "u[(i * 3) + 0]")
                                                                    (list-ref cons-codes 1) "u[(i * 3) + 1]") (list-ref cons-codes 2) "u[(i * 3) + 2]")) max-speed-codes))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR TRAINING ON COUPLED VECTOR PDE SYSTEM: ~a
// Train a Lax–Friedrichs first-order finite-difference surrogate solver for a coupled vector system of 3 PDEs in 1D.

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

  // Neural network hyperparameters.
  const double num_trains = ~a;
  const int nn_width = ~a;
  const int nn_depth = ~a;

  const int num_threads = ~a;
  const int mini_size = ~a;

  // Arrays for storing solution.
  double *u = (double*) malloc((nx + 2) * 3 * sizeof(double));
  double *un = (double*) malloc((nx + 2) * 3 * sizeof(double));

  // Arrays for storing other intermediate values.
  double *local_alpha = (double*) malloc(3 * sizeof(double));

  double *um = (double*) malloc(3 * sizeof(double));
  double *ui = (double*) malloc(3 * sizeof(double));
  double *up = (double*) malloc(3 * sizeof(double));

  double *f_um = (double*) malloc(3 * sizeof(double));
  double *f_ui = (double*) malloc(3 * sizeof(double));
  double *f_up = (double*) malloc(3 * sizeof(double));

  double *fluxL = (double*) malloc(3 * sizeof(double));
  double *fluxR = (double*) malloc(3 * sizeof(double));

  // Arrays for storing training data.
  float ***input_data = (float***) malloc(3 * sizeof(float**));
  float ***output_data = (float***) malloc(3 * sizeof(float**));
  
  for (int i = 0; i < 3; i++) {
    input_data[i] = (float**) malloc(nx * num_trains * sizeof(float*));
    output_data[i] = (float**) malloc(nx * num_trains * sizeof(float*));
  }

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 1; i++) {
    double x = x0 + (i - 0.5) * dx;
    
    u[(i * 3) + 0] = ~a; // init-funcs[0] in C.
    u[(i * 3) + 1] = ~a; // init-funcs[1] in C.
    u[(i * 3) + 2] = ~a; // init-funcs[2] in C.
  }

  // Initialize neural network architecture.
  kad_node_t **t_net = (kad_node_t**) malloc(3 * sizeof(kad_node_t*));
  kann_t **ann = (kann_t**) malloc(3 * sizeof(kann_t*));

  for (int i = 0; i < 3; i++) {
    t_net[i] = kann_layer_input(2);
  
    for (int j = 0; j < nn_depth; j++) {
      t_net[i] = kann_layer_dense(t_net[i], nn_width);
      t_net[i] = kad_tanh(t_net[i]);
    }

    t_net[i] = kann_layer_cost(t_net[i], 1, KANN_C_MSE);
    ann[i] = kann_new(t_net[i], 0);
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
      local_alpha[2] = ~a; // max-speed-exprs[2] in C.
      
      for (int j = 0; j < 3; j++) {
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
      for (int j = 0; j < 3; j++) {
        um[j] = u[((i - 1) * 3) + j];
        ui[j] = u[(i * 3) + j];
        up[j] = u[((i + 1) * 3) + j];
      }

      // Evaluate flux vector for each value of the conserved variable vector.
      f_um[0] = ~a;
      f_um[1] = ~a;
      f_um[2] = ~a; // F(U_{i - 1}).
      
      f_ui[0] = ~a;
      f_ui[1] = ~a;
      f_ui[2] = ~a; // F(U_i).
      
      f_up[0] = ~a;
      f_up[1] = ~a;
      f_up[2] = ~a; // F(U_{i + 1}).

      // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1}) + F(U_i)) - 0.5 * alpha * (U_i - U_{i - 1}).
      for (int j = 0; j < 3; j++) {
        fluxL[j] = 0.5 * (f_um[j] + f_ui[j]) - 0.5 * alpha * (ui[j] - um[j]);
      }

      // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1}) + F(U_i)) - 0.5 * alpha * (U_{i + 1} - U_i).
      for (int j = 0; j < 3; j++) {
        fluxR[j] = 0.5 * (f_ui[j] + f_up[j]) - 0.5 * alpha * (up[j] - ui[j]);
      }

      // Update the conserved variable vector.
      for (int j = 0; j < 3; j++) {
        un[(i * 3) + j] = ui[j] - (dt / dx) * (fluxR[j] - fluxL[j]);
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 1; i++) {
      for (int j = 0; j < 3; j++) {
        u[(i * 3) + j] = un[(i * 3) + j];
      }
    }

    // Apply simple boundary conditions (transmissive).
    for (int j = 0; j < 3; j++) {
      u[(0 * 3) + j] = u[(1 * 3) + j];
      u[((nx + 1) * 3) + j] = u[(nx * 3) + j];
    }

    // Accumulate to training data.
    if (n < num_trains) {
      for (int i = 1; i <= nx; i++) {
        double x = x0 + (i - 0.5) * dx;

        for (int j = 0; j < 3; j++) {
          input_data[j][(n * nx) + (i - 1)] = (float*) malloc(2 * sizeof(float));
          output_data[j][(n * nx) + (i - 1)] = (float*) malloc(sizeof(float));
      
          input_data[j][(n * nx) + (i - 1)][0] = t;
          input_data[j][(n * nx) + (i - 1)][1] = x;
          output_data[j][(n * nx) + (i - 1)][0] = u[(i * 3) + j];
        }
      }
    }

    // Output solution to disk.
    for (int j = 0; j < 3; j++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", j, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", j, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 1; i <= nx; i++) {
          double x = x0 + (i - 0.5) * dx;
          fprintf(fptr, \"%f, %f\\n\", x, u[(i * 3) + j]);
        }

        fclose(fptr);
      }
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  // Train neural network.
  for (int i = 0; i < 3; i++) {
    kann_mt(ann[i], num_threads, mini_size);
    kann_train_fnn1(ann[i], 0.0001f, 64, 50, 10, 0.1f, n * nx, input_data[i], output_data[i]);
  }

  // Output neural network to disk.
  for (int i = 0; i < 3; i++) {
    const char *fmt = \"%s_%d_neural_net.dat\";
    int sz = snprintf(0, 0, fmt, \"~a\", i);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", i);
  
    kann_save(file_nm, ann[i]);
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

  for (int i = 0; i < 3; i++) {
    kann_delete(ann[i]);
  }
  free(ann);
  free(t_net);

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < nx * num_trains; j++) {
      free(input_data[i][j]);
      free(output_data[i][j]);
    }

    free(input_data[i]);
    free(output_data[i]);
  }

  free(input_data);
  free(output_data);
  
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
           ;; Maximum number of time-steps to train on.
           max-trains
           ;; Neural network width.
           width
           ;; Neural network depth.
           depth
           ;; Number of threads to use during training.
           num-threads
           ;; Mini-batch training size.
           mini-size
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals 0)
           (list-ref max-speed-locals 1)
           (list-ref max-speed-locals 2)
           ;; Left flux vector F(u_{i - 1}).
           (list-ref flux-ums 0)
           (list-ref flux-ums 1)
           (list-ref flux-ums 2)
           ;; Middle flux vector F(u_i).
           (list-ref flux-uis 0)
           (list-ref flux-uis 1)
           (list-ref flux-uis 2)
           ;; Right flux vector F(u_{i + 1}).
           (list-ref flux-ups 0)
           (list-ref flux-ups 1)
           (list-ref flux-ups 2)
           ;; PDE name for file output.
           name
           name
           ;; PDE name for neural network output.
           name
           name
           ))
  code)

;; -------------------------------------------------------------------------------------------------------------------------------------------
;; Train a Lax–Friedrichs (Finite-Difference) Surrogate Solver for a 1D Coupled Vector System of 3 PDEs with a Second-Order Flux Extrapolation
;; -------------------------------------------------------------------------------------------------------------------------------------------
(define (train-lax-friedrichs-vector3-1d-second-order pde-system limiter neural-net
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
                                                                                   [(< x 0.5) 0.0]
                                                                                   [else 0.0])
                                                                                `(cond
                                                                                   [(< x 0.5) 7.5]
                                                                                   [else 2.5]))])
  "Generate C code that trains a surrogate solver for the 1D coupled vector system of 3 PDEs specified by `pde-system` using the Lax-Friedrichs finite-difference method
   with a second-order flux extrapolation using the limiter `limiter`, with neural network architecture `neural-net`.
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

  (define max-trains (hash-ref neural-net 'max-trains))
  (define width (hash-ref neural-net 'width))
  (define depth (hash-ref neural-net 'depth))

  (define num-threads (hash-ref neural-net 'num-threads))
  (define mini-size (hash-ref neural-net 'mini-size))

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
                           (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umL[0]")
                                                             (list-ref cons-codes 1) "umL[1]") (list-ref cons-codes 2) "umL[2]")) flux-codes))
  (define flux-umRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umR[0]")
                                                             (list-ref cons-codes 1) "umR[1]") (list-ref cons-codes 2) "umR[2]")) flux-codes))
  (define flux-uiLs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiL[0]")
                                                             (list-ref cons-codes 1) "uiL[1]") (list-ref cons-codes 2) "uiL[2]")) flux-codes))
  (define flux-uiRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiR[0]")
                                                             (list-ref cons-codes 1) "uiR[1]") (list-ref cons-codes 2) "uiR[2]")) flux-codes))
  (define flux-upLs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upL[0]")
                                                             (list-ref cons-codes 1) "upL[1]") (list-ref cons-codes 2) "upL[2]")) flux-codes))
  (define flux-upRs (map (lambda (flux-code)
                           (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upR[0]")
                                                             (list-ref cons-codes 1) "upR[1]") (list-ref cons-codes 2) "upR[2]")) flux-codes))
  
  (define flux-umR-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "umR_evol[0]")
                                                                  (list-ref cons-codes 1) "umR_evol[1]") (list-ref cons-codes 2) "umR_evol[2]")) flux-codes))
  (define flux-uiL-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiL_evol[0]")
                                                                  (list-ref cons-codes 1) "uiL_evol[1]") (list-ref cons-codes 2) "uiL_evol[2]")) flux-codes))
  (define flux-uiR-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "uiR_evol[0]")
                                                                  (list-ref cons-codes 1) "uiR_evol[1]") (list-ref cons-codes 2) "uiR_evol[2]")) flux-codes))
  (define flux-upL-evols (map (lambda (flux-code)
                                (flux-substitute (flux-substitute (flux-substitute flux-code (list-ref cons-codes 0) "upL_evol[0]")
                                                                  (list-ref cons-codes 1) "upL_evol[1]") (list-ref cons-codes 2) "upL_evol[2]")) flux-codes))

  (define max-speed-locals (map (lambda (max-speed-code)
                                  (flux-substitute (flux-substitute (flux-substitute max-speed-code (list-ref cons-codes 0) "u[(i * 3) + 0]")
                                                                    (list-ref cons-codes 1) "u[(i * 3) + 1]") (list-ref cons-codes 2) "u[(i * 3) + 2]")) max-speed-codes))

  (define parameter-code (cond
                           [(not (empty? parameters)) (string-join (map (lambda (parameter)
                                                                          (string-append "double " (convert-expr parameter) ";")) parameters) "\n")]
                           [else ""]))

  (define code
    (format "
// AUTO-GENERATED CODE FOR TRAINING ON COUPLED VECTOR PDE SYSTEM: ~a
// FLUX LIMITER: ~a
// Train a Lax–Friedrichs first-order finite-difference surrogate solver for a coupled vector system of 3 PDEs in 1D, with a second-order flux extrapolation.

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

  // Neural network hyperparameters.
  const double num_trains = ~a;
  const int nn_width = ~a;
  const int nn_depth = ~a;

  const int num_threads = ~a;
  const int mini_size = ~a;

  // Array for storing slopes.
  double *slope = (double*) malloc((nx + 4) * 3 * sizeof(double));

  // Arrays for storing solution.
  double *u = (double*) malloc((nx + 4) * 3 * sizeof(double));
  double *un = (double*) malloc((nx + 4) * 3 * sizeof(double));

  // Arrays for storing other intermediate values.
  double *local_alpha = (double*) malloc(3 * sizeof(double));
  
  double *umL = (double*) malloc(3 * sizeof(double));
  double *umR = (double*) malloc(3 * sizeof(double));
  double *uiL = (double*) malloc(3 * sizeof(double));
  double *uiR = (double*) malloc(3 * sizeof(double));
  double *upL = (double*) malloc(3 * sizeof(double));
  double *upR = (double*) malloc(3 * sizeof(double));

  double *f_umL = (double*) malloc(3 * sizeof(double));
  double *f_umR = (double*) malloc(3 * sizeof(double));
  double *f_uiL = (double*) malloc(3 * sizeof(double));
  double *f_uiR = (double*) malloc(3 * sizeof(double));
  double *f_upL = (double*) malloc(3 * sizeof(double));
  double *f_upR = (double*) malloc(3 * sizeof(double));

  double *umR_evol = (double*) malloc(3 * sizeof(double));
  double *uiL_evol = (double*) malloc(3 * sizeof(double));
  double *uiR_evol = (double*) malloc(3 * sizeof(double));
  double *upL_evol = (double*) malloc(3 * sizeof(double));

  double *f_umR_evol = (double*) malloc(3 * sizeof(double));
  double *f_uiL_evol = (double*) malloc(3 * sizeof(double));
  double *f_uiR_evol = (double*) malloc(3 * sizeof(double));
  double *f_upL_evol = (double*) malloc(3 * sizeof(double));

  double *fluxL = (double*) malloc(3 * sizeof(double));
  double *fluxR = (double*) malloc(3 * sizeof(double));

  // Arrays for storing training data.
  float ***input_data = (float***) malloc(3 * sizeof(float**));
  float ***output_data = (float***) malloc(3 * sizeof(float**));
  
  for (int i = 0; i < 3; i++) {
    input_data[i] = (float**) malloc(nx * num_trains * sizeof(float*));
    output_data[i] = (float**) malloc(nx * num_trains * sizeof(float*));
  }

  // Initialize grid and set initial conditions.
  for (int i = 0; i <= nx + 3; i++) {
    double x = x0 + (i - 1.5) * dx;
    
    u[(i * 3) + 0] = ~a; // init-funcs[0] in C.
    u[(i * 3) + 1] = ~a; // init-funcs[1] in C.
    u[(i * 3) + 2] = ~a; // init-funcs[2] in C.
  }

  // Initialize neural network architecture.
  kad_node_t **t_net = (kad_node_t**) malloc(3 * sizeof(kad_node_t*));
  kann_t **ann = (kann_t**) malloc(3 * sizeof(kann_t*));

  for (int i = 0; i < 3; i++) {
    t_net[i] = kann_layer_input(2);
  
    for (int j = 0; j < nn_depth; j++) {
      t_net[i] = kann_layer_dense(t_net[i], nn_width);
      t_net[i] = kad_tanh(t_net[i]);
    }

    t_net[i] = kann_layer_cost(t_net[i], 1, KANN_C_MSE);
    ann[i] = kann_new(t_net[i], 0);
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
      local_alpha[2] = ~a; // max-speed-exprs[2] in C.
      
      for (int j = 0; j < 3; j++) {
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
      for (int j = 0; j < 3; j++) {
        double r = (u[(i * 3) + j] - u[((i - 1) * 3) + j]) / (u[((i + 1) * 3) + j] - u[(i * 3) + j]);
        double limiter = ~a; // limiter-r in C.

        slope[(i * 3) + j] = limiter * (0.5 * ((u[(i * 3) + j] - u[((i - 1) * 3) + j]) + (u[((i + 1) * 3) + j] - u[(i * 3) + j])));
      }
    }

    // Compute fluxes with Lax-Friedrichs approximation and update the conserved variable vector.
    for (int i = 2; i <= nx + 1; i++) {
      // Extrapolate boundary states.
      for (int j = 0; j < 3; j++) {
        umL[j] = u[((i - 1) * 3) + j] - (0.5 * slope[((i - 1) * 3) + j]);
        umR[j] = u[((i - 1) * 3) + j] + (0.5 * slope[((i - 1) * 3) + j]);

        uiL[j] = u[(i * 3) + j] - (0.5 * slope[(i * 3) + j]);
        uiR[j] = u[(i * 3) + j] + (0.5 * slope[(i * 3) + j]);

        upL[j] = u[((i + 1) * 3) + j] - (0.5 * slope[((i + 1) * 3) + j]);
        upR[j] = u[((i + 1) * 3) + j] + (0.5 * slope[((i + 1) * 3) + j]);
      }

      // Evaluate flux vector for each extrapolated boundary state.
      f_umL[0] = ~a;
      f_umL[1] = ~a;
      f_umL[2] = ~a;
      f_umR[0] = ~a;
      f_umR[1] = ~a;
      f_umR[2] = ~a;

      f_uiL[0] = ~a;
      f_uiL[1] = ~a;
      f_uiL[2] = ~a;
      f_uiR[0] = ~a;
      f_uiR[1] = ~a;
      f_uiR[2] = ~a;

      f_upL[0] = ~a;
      f_upL[1] = ~a;
      f_upL[2] = ~a;
      f_upR[0] = ~a;
      f_upR[1] = ~a;
      f_upR[2] = ~a;

      // Evolve each extrapolated boundary state.
      for (int j = 0; j < 3; j++) {
        umR_evol[j] = umR[j] + ((dt / (2.0 * dx)) * (f_umL[j] - f_umR[j]));

        uiL_evol[j] = uiL[j] + ((dt / (2.0 * dx)) * (f_uiL[j] - f_uiR[j]));
        uiR_evol[j] = uiR[j] + ((dt / (2.0 * dx)) * (f_uiL[j] - f_uiR[j]));

        upL_evol[j] = upL[j] + ((dt / (2.0 * dx)) * (f_upL[j] - f_upR[j]));
      }

      // Evaluate flux vector for each value of the (evolved) conserved variable vector.
      f_umR_evol[0] = ~a;
      f_umR_evol[1] = ~a;
      f_umR_evol[2] = ~a; // F(U_{i - 1, R+})
      f_uiL_evol[0] = ~a;
      f_uiL_evol[1] = ~a;
      f_uiL_evol[2] = ~a; // F(U_{i, L+})
      
      f_uiR_evol[0] = ~a;
      f_uiR_evol[1] = ~a;
      f_uiR_evol[2] = ~a; // F(U_{i, R+})
      f_upL_evol[0] = ~a;
      f_upL_evol[1] = ~a;
      f_upL_evol[2] = ~a; // F(U_{i + 1, L+})

      // Left interface flux: F_{i - 1/2} = 0.5 * (F(U_{i - 1, R+}) + F(U_{i, L+})) - 0.5 * alpha * (U_{i, L+} - U_{i - 1, R+}).
      for (int j = 0; j < 3; j++) {
        fluxL[j] = 0.5 * (f_umR_evol[j] + f_uiL_evol[j]) - 0.5 * alpha * (uiL_evol[j] - umR_evol[j]);
      }

      // Right interface flux: F_{i + 1/2} = 0.5 * (F(U_{i + 1, L+}) + F(U_{i, R+})) - 0.5 * alpha * (U_{i + 1, L+} - U_{i, R+}).
      for (int j = 0; j < 3; j++) {
        fluxR[j] = 0.5 * (f_uiR_evol[j] + f_upL_evol[j]) - 0.5 * alpha * (upL_evol[j] - uiR_evol[j]);
      }

      // Update the conserved variable vector.
      for (int j = 0; j < 3; j++) {
        un[(i * 3) + j] = u[(i * 3) + j] - (dt / dx) * (fluxR[j] - fluxL[j]);
      }
    }

    // Copy un -> u (updated conserved variable vector to new conserved variable vector).
    for (int i = 0; i <= nx + 3; i++) {
      for (int j = 0; j < 3; j++) {
        u[(i * 3) + j] = un[(i * 3) + j];
      }
    }

    // Apply simple boundary conditions (transmissive).
    for (int j = 0; j < 3; j++) {
      u[(0 * 3) + j] = u[(2 * 3) + j];
      u[(1 * 3) + j] = u[(2 * 3) + j];
      u[((nx + 2) * 3) + j] = u[((nx + 1) * 3) + j];
      u[((nx + 3) * 3) + j] = u[((nx + 1) * 3) + j];
    }


    // Accumulate to training data.
    if (n < num_trains) {
      for (int i = 2; i <= nx + 1; i++) {
        double x = x0 + (i - 1.5) * dx;

        for (int j = 0; j < 3; j++) {
          input_data[j][(n * nx) + (i - 2)] = (float*) malloc(2 * sizeof(float));
          output_data[j][(n * nx) + (i - 2)] = (float*) malloc(sizeof(float));
      
          input_data[j][(n * nx) + (i - 2)][0] = t;
          input_data[j][(n * nx) + (i - 2)][1] = x;
          output_data[j][(n * nx) + (i - 2)][0] = u[(i * 3) + j];
        }
      }
    }

    // Output solution to disk.
    for (int j = 0; j < 3; j++) {
      const char *fmt = \"%s_output_%d_%d.csv\";
      int sz = snprintf(0, 0, fmt, \"~a\", j, n);
      char file_nm[sz + 1];
      snprintf(file_nm, sizeof file_nm, fmt, \"~a\", j, n);
    
      FILE *fptr = fopen(file_nm, \"w\");
      if (fptr != NULL) {
        for (int i = 2; i <= nx + 1; i++) {
          double x = x0 + (i - 1.5) * dx;
          fprintf(fptr, \"%f, %f\\n\", x, u[(i * 3) + j]);
        }

        fclose(fptr);
      }
    }

    // Increment time.
    t += dt;
    n += 1;
  }

  // Train neural network.
  for (int i = 0; i < 3; i++) {
    kann_mt(ann[i], num_threads, mini_size);
    kann_train_fnn1(ann[i], 0.0001f, 64, 50, 10, 0.1f, n * nx, input_data[i], output_data[i]);
  }

  // Output neural network to disk.
  for (int i = 0; i < 3; i++) {
    const char *fmt = \"%s_%d_neural_net.dat\";
    int sz = snprintf(0, 0, fmt, \"~a\", i);
    char file_nm[sz + 1];
    snprintf(file_nm, sizeof file_nm, fmt, \"~a\", i);
  
    kann_save(file_nm, ann[i]);
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

  for (int i = 0; i < 2; i++) {
    kann_delete(ann[i]);
  }
  free(ann);
  free(t_net);

  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < nx * num_trains; j++) {
      free(input_data[i][j]);
      free(output_data[i][j]);
    }

    free(input_data[i]);
    free(output_data[i]);
  }

  free(input_data);
  free(output_data);
  
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
           ;; Maximum number of time-steps to train on.
           max-trains
           ;; Neural network width.
           width
           ;; Neural network depth.
           depth
           ;; Number of threads to use during training.
           num-threads
           ;; Mini-batch training size.
           mini-size
           ;; Initial condition expressions (e.g. (x < 1.0) ? 1.0 : 0.0)).
           (list-ref init-func-codes 0)
           (list-ref init-func-codes 1)
           (list-ref init-func-codes 2)
           ;; Expressions for local wave-speed estimates.
           (list-ref max-speed-locals 0)
           (list-ref max-speed-locals 1)
           (list-ref max-speed-locals 2)
           ;; Expression for flux limiter function.
           limiter-r
           ;; Left negative flux vector F(U_{i - 1, L}).
           (list-ref flux-umLs 0)
           (list-ref flux-umLs 1)
           (list-ref flux-umLs 2)
           ;; Right negative flux vector F(U_{i - 1, R}).
           (list-ref flux-umRs 0)
           (list-ref flux-umRs 1)
           (list-ref flux-umRs 2)
           ;; Left central flux vector F(U_{i, L}).
           (list-ref flux-uiLs 0)
           (list-ref flux-uiLs 1)
           (list-ref flux-uiLs 2)
           ;; Right central flux vector F(U_{i, R}).
           (list-ref flux-uiRs 0)
           (list-ref flux-uiRs 1)
           (list-ref flux-uiRs 2)
           ;; Left positive flux vector F(U_{i + 1, L}).
           (list-ref flux-upLs 0)
           (list-ref flux-upLs 1)
           (list-ref flux-upLs 2)
           ;; Right positive flux vector F(U_{i + 1, R}).
           (list-ref flux-upRs 0)
           (list-ref flux-upRs 1)
           (list-ref flux-upRs 2)
           ;; Evolved right negative flux vector F(U_{i - 1, R+}).
           (list-ref flux-umR-evols 0)
           (list-ref flux-umR-evols 1)
           (list-ref flux-umR-evols 2)
           ;; Evolved left central flux vector F(U_{i, L+}).
           (list-ref flux-uiL-evols 0)
           (list-ref flux-uiL-evols 1)
           (list-ref flux-uiL-evols 2)
           ;; Evolved right central flux vector F(U_{i, R+}).
           (list-ref flux-uiR-evols 0)
           (list-ref flux-uiR-evols 1)
           (list-ref flux-uiR-evols 2)
           ;; Evolved left positive flux vector F(U_{i + 1, L+}).
           (list-ref flux-upL-evols 0)
           (list-ref flux-upL-evols 1)
           (list-ref flux-upL-evols 2)
           ;; PDE name for file output.
           name
           name
           ;; PDE name for neural network output.
           name
           name
           ))
  code)