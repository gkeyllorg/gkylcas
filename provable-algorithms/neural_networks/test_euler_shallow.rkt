#lang racket

(require "code_generator_core_training.rkt")
(require "code_generator_matrix_training.rkt")
(require "code_generator_matrix_training_2d.rkt")
(require "code_generator_matrix_validation.rkt")
(require "prover_matrix.rkt")
(provide (all-from-out "code_generator_core_training.rkt"))
(provide (all-from-out "code_generator_matrix_training.rkt"))
(provide (all-from-out "code_generator_matrix_training_2d.rkt"))
(provide (all-from-out "code_generator_matrix_validation.rkt"))

;; Construct /code and /proofs output directories if they do not already exist.
(cond
  [(not (directory-exists? "code")) (make-directory "code")])
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

;; Define the 1D Euler equations (density, x-momentum, and total energy components).
(define pde-system-euler
  (hash
   'name "euler"
   'cons-exprs (list
                `rho
                `mom_x
                `energy)               ; conserved variables: density, x-momentum, total energy
   'flux-exprs (list
                `mom_x
                `(+ (/ (* mom_x mom_x) rho) (* (- gamma 1.0) (- energy (* 0.5 (/ (* mom_x mom_x) rho)))))
                `(* (+ energy (* (- gamma 1.0) (- energy (* 0.5 (/ (* mom_x mom_x) rho))))) (/ mom_x rho)))
                                       ; flux vector
   'max-speed-exprs (list
                     `(abs (- (/ mom_x rho) (sqrt (/ (* gamma (* (- gamma 1.0) (- energy (* 0.5 (/ (* mom_x mom_x) rho))))) rho))))
                     `(abs (/ mom_x rho))
                     `(abs (+ (/ mom_x rho) (sqrt (/ (* gamma (* (- gamma 1.0) (- energy (* 0.5 (/ (* mom_x mom_x) rho))))) rho)))))
                                       ; local wave-speeds
   'parameters (list
                `(define gamma 1.4))   ; adiabatic index: gamma = 1.4
   ))

;; Define simulation parameters.
(define nx 800)
(define x0 0.0)
(define x1 1.0)
(define t-final 0.1)
(define cfl 0.95)
(define init-funcs (list
                    `(cond
                       [(< x 0.5) 3.0]
                       [else 1.0])
                    `(cond
                       [(< x 0.5) 0.0]
                       [else 0.0])
                    `(cond
                       [(< x 0.5) 7.5]
                       [else 2.5])))

;; Define (shallow) neural network hyperparameters.
(define neural-net-shallow
  (hash
   'max-trains 10000    ; maximum number of training steps: 10000
   'width 64            ; number of neurons in each layer: 64
   'depth 6             ; total number of layers: 6
   'num-threads 12      ; number of threads to use in training: 12
   'mini-size 100       ; size of training mini-batch: 100
   ))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 1D Euler equations using a shallow neural network.
(define code-euler-lax-train
  (train-lax-friedrichs-vector3-1d pde-system-euler neural-net-shallow
                                   #:nx nx
                                   #:x0 x0
                                   #:x1 x1
                                   #:t-final t-final
                                   #:cfl cfl
                                   #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/euler_lax_train.c"
  #:exists 'replace
  (lambda ()
    (display code-euler-lax-train)))

;; Define the minmod flux limiter.
(define limiter-minmod
  (hash
   'name "minmod"
   'limiter-expr `(max 0.0 (min 1.0 r))
   'limiter-ratio `r
   ))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 1D Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-euler-lax-minmod-train
  (train-lax-friedrichs-vector3-1d-second-order pde-system-euler limiter-minmod neural-net-shallow
                                                #:nx nx
                                                #:x0 x0
                                                #:x1 x1
                                                #:t-final t-final
                                                #:cfl cfl
                                                #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/euler_lax_minmod_train.c"
  #:exists 'replace
  (lambda ()
    (display code-euler-lax-minmod-train)))

(display "1D compressible Euler properties: \n\n")

;; Attempt to prove error bounds on smooth solutions obtained from surrogate solvers for the 1D Euler equations.
(define proof-euler-smooth
  (call-with-output-file "proofs/proof_euler_smooth.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-vector3-1d-smooth pde-system-euler neural-net-shallow
                                 #:nx nx
                                 #:x0 x0
                                 #:x1 x1
                                 #:t-final t-final
                                 #:cfl cfl
                                 #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_euler_smooth.rkt")

;; Show the error bounds (if applicable) on smooth solutions.
(display "Error bound on rho (smooth solutions): ")
(display (max (list-ref proof-euler-smooth 0) (list-ref proof-euler-smooth 1) (list-ref proof-euler-smooth 2)))
(display "\n")

(display "Error bound on mom_x (smooth solutions): ")
(display (max (list-ref proof-euler-smooth 3) (list-ref proof-euler-smooth 4) (list-ref proof-euler-smooth 5)))
(display "\n")

(display "Error bound on energy (smooth solutions): ")
(display (max (list-ref proof-euler-smooth 6) (list-ref proof-euler-smooth 7) (list-ref proof-euler-smooth 8)))
(display "\n")

;; Attempt to prove error bounds on non-smooth solutions obtained from surrogate solvers for the 1D Euler equations.
(define proof-euler-non-smooth
  (call-with-output-file "proofs/proof_euler_non_smooth.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-vector3-1d-non-smooth pde-system-euler neural-net-shallow
                                     #:nx nx
                                     #:x0 x0
                                     #:x1 x1
                                     #:t-final t-final
                                     #:cfl cfl
                                     #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_euler_non_smooth.rkt")

;; Show the error bounds (if applicable) on non-smooth solutions.
(display "Error bound on rho (non-smooth solutions): ")
(display (max (list-ref proof-euler-non-smooth 0) (list-ref proof-euler-non-smooth 1) (list-ref proof-euler-non-smooth 2)))
(display "\n")

(display "Error bound on mom_x (non-smooth solutions): ")
(display (max (list-ref proof-euler-non-smooth 3) (list-ref proof-euler-non-smooth 4) (list-ref proof-euler-non-smooth 5)))
(display "\n")

(display "Error bound on energy (non-smooth solutions): ")
(display (max (list-ref proof-euler-non-smooth 6) (list-ref proof-euler-non-smooth 7) (list-ref proof-euler-non-smooth 8)))
(display "\n\n\n")

;; Synthesize the code to validate any first-order surrogate solver for the 1D Euler equations using a shallow neural network.
(define code-euler-validate
  (validate-vector3-1d pde-system-euler neural-net-shallow
                       #:nx nx
                       #:x0 x0
                       #:x1 x1
                       #:t-final t-final
                       #:cfl cfl
                       #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/euler_validate.c"
  #:exists 'replace
  (lambda ()
    (display code-euler-validate)))

;; Synthesize the code to validate any first-order surrogate solver for the 1D Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-euler-minmod-validate
  (validate-vector3-1d-second-order pde-system-euler limiter-minmod neural-net-shallow
                                    #:nx nx
                                    #:x0 x0
                                    #:x1 x1
                                    #:t-final t-final
                                    #:cfl cfl
                                    #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/euler_minmod_validate.c"
  #:exists 'replace
  (lambda ()
    (display code-euler-minmod-validate)))

;; Define the 2D Euler equations (density, x-momentum and y-momentum, and total energy components).
(define pde-system-euler-2d
  (hash
   'name "euler-2d"
   'cons-exprs (list
                `rho
                `mom_x
                `mom_y
                `energy)                                 ; conserved variables: density, x-momentum, y-momentum, total energy
   'flux-exprs-x (list
                  `mom_x
                  `(+ (/ (* mom_x mom_x) rho) (* (- gamma 1.0) (- energy (* 0.5 (+ (/ (* mom_x mom_x) rho) (/ (* mom_y mom_y) rho))))))
                  `(* mom_y (/ mom_x rho))
                  `(* (+ energy (* (- gamma 1.0) (- energy (* 0.5 (+ (/ (* mom_x mom_x) rho) (/ (* mom_y mom_y) rho)))))) (/ mom_x rho)))
                                                         ; flux vector (x-direction)
   'flux-exprs-y (list
                  `mom_y
                  `(* mom_x (/ mom_y rho))
                  `(+ (/ (* mom_y mom_y) rho) (* (- gamma 1.0) (- energy (* 0.5 (+ (/ (* mom_x mom_x) rho) (/ (* mom_y mom_y) rho))))))
                  `(* (+ energy (* (- gamma 1.0) (- energy (* 0.5 (+ (/ (* mom_x mom_x) rho) (/ (* mom_y mom_y) rho)))))) (/ mom_y rho)))
                                                         ; flux vector (y-direction)
   'max-speed-exprs-x (list
                       `(abs (- (/ mom_x rho) (sqrt (/ (* gamma (* (- gamma 1.0) (- energy (* 0.5 (+ (/ (* mom_x mom_x) rho) (/ (* mom_y mom_y) rho)))))) rho))))
                       `(abs (/ mom_x rho))
                       `(abs (/ mom_x rho))
                       `(abs (+ (/ mom_x rho) (sqrt (/ (* gamma (* (- gamma 1.0) (- energy (* 0.5 (+ (/ (* mom_x mom_x) rho) (/ (* mom_y mom_y) rho)))))) rho)))))
                                                         ; local wave-speeds (x-direction)
   'max-speed-exprs-y (list
                       `(abs (- (/ mom_y rho) (sqrt (/ (* gamma (* (- gamma 1.0) (- energy (* 0.5 (+ (/ (* mom_x mom_x) rho) (/ (* mom_y mom_y) rho)))))) rho))))
                       `(abs (/ mom_y rho))
                       `(abs (/ mom_y rho))
                       `(abs (+ (/ mom_y rho) (sqrt (/ (* gamma (* (- gamma 1.0) (- energy (* 0.5 (+ (/ (* mom_x mom_x) rho) (/ (* mom_y mom_y) rho)))))) rho)))))
                                                         ; local wave-speeds (y-direction)
   'parameters (list
                `(define gamma 1.4))                     ; adiabatic index: gamma = 1.4
   ))

;; Define 2D simulation parameters.
(define nx-2d 50)
(define ny-2d 50)
(define x0-2d 0.0)
(define x1-2d 1.0)
(define y0-2d 0.0)
(define y1-2d 1.0)
(define t-final-2d 0.8)
(define cfl-2d 0.95)
(define init-funcs-2d (list
                       `(cond
                          [(> y 0.8)
                           (cond
                             [(< x 0.8) 0.5323]
                             [else 1.5])]
                          [else
                           (cond
                             [(< x 0.8) 0.138]
                             [else 0.5323])])
                       `(cond
                          [(> y 0.8)
                           (cond
                             [(< x 0.8) 0.641954]
                             [else 0.0])]
                          [else
                           (cond
                             [(< x 0.8) 0.166428]
                             [else 0.0])])
                       `(cond
                          [(> y 0.8)
                           (cond
                             [(< x 0.8) 0.0]
                             [else 0.0])]
                          [else
                           (cond
                             [(< x 0.8) 0.166428]
                             [else 0.641954])])
                       `(cond
                          [(> y 0.8)
                           (cond
                             [(< x 0.8) 1.137098]
                             [else 3.75])]
                          [else
                           (cond
                             [(< x 0.8) 0.273212]
                             [else 1.137098])])))

;; Define (shallow) neural network hyperparameters for 2D.
(define neural-net-shallow-2d
  (hash
   'max-trains 10000    ; maximum number of training steps: 10000
   'width 64            ; number of neurons in each layer: 64
   'depth 6             ; total number of layers: 6
   'num-threads 12      ; number of threads to use in training: 12
   'mini-size 100       ; size of training mini-batch: 100
   ))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 2D Euler equations using a shallow neural network.
(define code-euler-lax-train-2d
  (train-lax-friedrichs-vector4-2d pde-system-euler-2d neural-net-shallow-2d
                                   #:nx nx-2d
                                   #:ny ny-2d
                                   #:x0 x0-2d
                                   #:x1 x1-2d
                                   #:y0 y0-2d
                                   #:y1 y1-2d
                                   #:t-final t-final-2d
                                   #:cfl cfl-2d
                                   #:init-funcs init-funcs-2d))

;; Output the code to a file.
(with-output-to-file "code/euler_lax_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-euler-lax-train-2d)))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 2D Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-euler-lax-minmod-train-2d
  (train-lax-friedrichs-vector4-2d-second-order pde-system-euler-2d limiter-minmod neural-net-shallow-2d
                                                #:nx nx-2d
                                                #:ny ny-2d
                                                #:x0 x0-2d
                                                #:x1 x1-2d
                                                #:y0 y0-2d
                                                #:y1 y1-2d
                                                #:t-final t-final-2d
                                                #:cfl cfl-2d
                                                #:init-funcs init-funcs-2d))

;; Output the code to a file.
(with-output-to-file "code/euler_lax_minmod_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-euler-lax-minmod-train-2d)))

(display "2D compressible Euler properties: \n\n")

;; Attempt to prove error bounds on smooth solutions obtained from surrogate solvers for the 2D Euler equations.
(define proof-euler-smooth-2d
  (call-with-output-file "proofs/proof_euler_smooth_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-vector4-2d-smooth pde-system-euler-2d neural-net-shallow-2d
                                 #:nx nx-2d
                                 #:ny ny-2d
                                 #:x0 x0-2d
                                 #:x1 x1-2d
                                 #:y0 y0-2d
                                 #:y1 y1-2d
                                 #:t-final t-final-2d
                                 #:cfl cfl-2d
                                 #:init-funcs init-funcs-2d)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_euler_smooth_2d.rkt")

;; Show the error bounds (if applicable) on smooth solutions.
(display "Error bound on rho (smooth solutions): ")
(display (max (list-ref proof-euler-smooth-2d 0) (list-ref proof-euler-smooth-2d 1) (list-ref proof-euler-smooth-2d 2) (list-ref proof-euler-smooth-2d 3)))
(display "\n")

(display "Error bound on mom_x (smooth solutions): ")
(display (max (list-ref proof-euler-smooth-2d 4) (list-ref proof-euler-smooth-2d 5) (list-ref proof-euler-smooth-2d 6) (list-ref proof-euler-smooth-2d 7)))
(display "\n")

(display "Error bound on mom_y (smooth solutions): ")
(display (max (list-ref proof-euler-smooth-2d 8) (list-ref proof-euler-smooth-2d 9) (list-ref proof-euler-smooth-2d 10) (list-ref proof-euler-smooth-2d 11)))
(display "\n")

(display "Error bound on energy (smooth solutions): ")
(display (max (list-ref proof-euler-smooth-2d 12) (list-ref proof-euler-smooth-2d 13) (list-ref proof-euler-smooth-2d 14) (list-ref proof-euler-smooth-2d 15)))
(display "\n")

;; Attempt to prove error bounds on non-smooth solutions obtained from surrogate solvers for the 2D Euler equations.
(define proof-euler-non-smooth-2d
  (call-with-output-file "proofs/proof_euler_non_smooth_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-vector4-2d-non-smooth pde-system-euler-2d neural-net-shallow-2d
                                     #:nx nx-2d
                                     #:ny ny-2d
                                     #:x0 x0-2d
                                     #:x1 x1-2d
                                     #:y0 y0-2d
                                     #:y1 y1-2d
                                     #:t-final t-final-2d
                                     #:cfl cfl-2d
                                     #:init-funcs init-funcs-2d)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_euler_non_smooth_2d.rkt")

;; Show the error bounds (if applicable) on non-smooth solutions.
(display "Error bound on rho (non-smooth solutions): ")
(display (max (list-ref proof-euler-non-smooth-2d 0) (list-ref proof-euler-non-smooth-2d 1) (list-ref proof-euler-non-smooth-2d 2) (list-ref proof-euler-non-smooth-2d 3)))
(display "\n")

(display "Error bound on mom_x (non-smooth solutions): ")
(display (max (list-ref proof-euler-non-smooth-2d 4) (list-ref proof-euler-non-smooth-2d 5) (list-ref proof-euler-non-smooth-2d 6) (list-ref proof-euler-non-smooth-2d 7)))
(display "\n")

(display "Error bound on mom_y (non-smooth solutions): ")
(display (max (list-ref proof-euler-non-smooth-2d 8) (list-ref proof-euler-non-smooth-2d 9) (list-ref proof-euler-non-smooth-2d 10) (list-ref proof-euler-non-smooth-2d 11)))
(display "\n")

(display "Error bound on energy (non-smooth solutions): ")
(display (max (list-ref proof-euler-non-smooth-2d 12) (list-ref proof-euler-non-smooth-2d 13) (list-ref proof-euler-non-smooth-2d 14) (list-ref proof-euler-non-smooth-2d 15)))
(display "\n")

;; Synthesize the code to validate any first-order surrogate solver for the 2D Euler equations using a shallow neural network.
(define code-euler-validate-2d
  (validate-vector4-2d pde-system-euler-2d neural-net-shallow-2d
                       #:nx nx-2d
                       #:ny ny-2d
                       #:x0 x0-2d
                       #:x1 x1-2d
                       #:y0 y0-2d
                       #:y1 y1-2d
                       #:t-final t-final-2d
                       #:cfl cfl-2d
                       #:init-funcs init-funcs-2d))

;; Output the code to a file.
(with-output-to-file "code/euler_validate_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-euler-validate-2d)))

;; Synthesize the code to validate any first-order surrogate solver for the 2D Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-euler-minmod-validate-2d
  (validate-vector4-2d-second-order pde-system-euler-2d limiter-minmod neural-net-shallow-2d
                                    #:nx nx-2d
                                    #:ny ny-2d
                                    #:x0 x0-2d
                                    #:x1 x1-2d
                                    #:y0 y0-2d
                                    #:y1 y1-2d
                                    #:t-final t-final-2d
                                    #:cfl cfl-2d
                                    #:init-funcs init-funcs-2d))

;; Output the code to a file.
(with-output-to-file "code/euler_minmod_validate_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-euler-minmod-validate-2d)))