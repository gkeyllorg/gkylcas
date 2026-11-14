#lang racket

(require "code_generator_core_training.rkt")
(require "code_generator_vector_training.rkt")
(require "code_generator_vector_training_2d.rkt")
(require "code_generator_vector_validation.rkt")
(require "prover_vector.rkt")
(provide (all-from-out "code_generator_core_training.rkt"))
(provide (all-from-out "code_generator_vector_training.rkt"))
(provide (all-from-out "code_generator_vector_training_2d.rkt"))
(provide (all-from-out "code_generator_vector_validation.rkt"))

;; Construct /code and /proofs output directories if they do not already exist.
(cond
  [(not (directory-exists? "code")) (make-directory "code")])
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

;; Define the 1D isothermal Euler equations (density and x-momentum components).
(define pde-system-isothermal-euler
  (hash
   'name "isothermal-euler"
   'cons-exprs (list
                `rho
                `mom_x)                                      ; conserved variables: density, x-momentum
   'flux-exprs (list
                `mom_x
                `(+ (/ (* mom_x mom_x) rho) (* rho vt vt)))  ; flux vector
   'max-speed-exprs (list
                     `(abs (- (/ mom_x rho) vt))
                     `(abs (+ (/ mom_x rho) vt)))            ; local wave-speeds
   'parameters (list
                `(define vt 1.0))                            ; thermal velocity: vt = 1.0
   ))

;; Define simulation parameters.
(define nx 400)
(define x0 0.0)
(define x1 1.0)
(define t-final 0.1)
(define cfl 0.95)
(define init-funcs (list
                    `(cond
                       [(< x 0.5) 3.0]
                       [else 1.0])
                    `(cond
                       [(< x 0.5) 1.5]
                       [else 0.0])))

;; Define (shallow) neural network hyperparameters.
(define neural-net-shallow
  (hash
   'max-trains 10000    ; maximum number of training steps: 10000
   'width 64            ; number of neurons in each layer: 64
   'depth 6             ; total number of layers: 6
   'num-threads 12      ; number of threads to use in training: 12
   'mini-size 100       ; size of training mini-batch: 100
   ))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 1D isothermal Euler equations using a shallow neural network.
(define code-isothermal-euler-lax-train
  (train-lax-friedrichs-vector2-1d pde-system-isothermal-euler neural-net-shallow
                                   #:nx nx
                                   #:x0 x0
                                   #:x1 x1
                                   #:t-final t-final
                                   #:cfl cfl
                                   #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_lax_train.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-lax-train)))

;; Synthesize the code to train a Roe surrogate solver for the 1D isothermal Euler equations using a shallow neural network.
(define code-isothermal-euler-roe-train
  (train-roe-vector2-1d pde-system-isothermal-euler neural-net-shallow
                        #:nx nx
                        #:x0 x0
                        #:x1 x1
                        #:t-final t-final
                        #:cfl cfl
                        #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_roe_train.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-roe-train)))

;; Define the minmod flux limiter.
(define limiter-minmod
  (hash
   'name "minmod"
   'limiter-expr `(max 0.0 (min 1.0 r))
   'limiter-ratio `r
   ))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 1D isothermal Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-isothermal-euler-lax-minmod-train
  (train-lax-friedrichs-vector2-1d-second-order pde-system-isothermal-euler limiter-minmod neural-net-shallow
                                                #:nx nx
                                                #:x0 x0
                                                #:x1 x1
                                                #:t-final t-final
                                                #:cfl cfl
                                                #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_lax_minmod_train.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-lax-minmod-train)))

;; Synthesize the code to train a Roe surrogate solver for the 1D isothermal Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-isothermal-euler-roe-minmod-train
  (train-roe-vector2-1d-second-order pde-system-isothermal-euler limiter-minmod neural-net-shallow
                                     #:nx nx
                                     #:x0 x0
                                     #:x1 x1
                                     #:t-final t-final
                                     #:cfl cfl
                                     #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_roe_minmod_train.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-roe-minmod-train)))

(display "1D isothermal Euler properties: \n\n")

;; Attempt to prove error bounds on smooth solutions obtained from surrogate solvers for the 1D isothermal Euler equations.
(define proof-isothermal-euler-smooth
  (call-with-output-file "proofs/proof_isothermal_euler_smooth.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-vector2-1d-smooth pde-system-isothermal-euler neural-net-shallow
                                 #:nx nx
                                 #:x0 x0
                                 #:x1 x1
                                 #:t-final t-final
                                 #:cfl cfl
                                 #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_smooth.rkt")

;; Show the error bounds (if applicable) on smooth solutions.
(display "Error bound on rho (smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-smooth 0) (list-ref proof-isothermal-euler-smooth 1)))
(display "\n")

(display "Error bound on mom_x (smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-smooth 2) (list-ref proof-isothermal-euler-smooth 3)))
(display "\n")

;; Attempt to prove error bounds on non-smooth solutions obtained from surrogate solvers for the 1D isothermal Euler equations.
(define proof-isothermal-euler-non-smooth
  (call-with-output-file "proofs/proof_isothermal_euler_non_smooth.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-vector2-1d-non-smooth pde-system-isothermal-euler neural-net-shallow
                                     #:nx nx
                                     #:x0 x0
                                     #:x1 x1
                                     #:t-final t-final
                                     #:cfl cfl
                                     #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_non_smooth.rkt")

;; Show the error bounds (if applicable) on non-smooth solutions.
(display "Error bound on rho (non-smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-non-smooth 0) (list-ref proof-isothermal-euler-non-smooth 1)))
(display "\n")

(display "Error bound on mom_x (non-smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-non-smooth 2) (list-ref proof-isothermal-euler-non-smooth 3)))
(display "\n\n\n")

;; Synthesize the code to validate any first-order surrogate solver for the 1D isothermal Euler equations using a shallow neural network.
(define code-isothermal-euler-validate
  (validate-vector2-1d pde-system-isothermal-euler neural-net-shallow
                       #:nx nx
                       #:x0 x0
                       #:x1 x1
                       #:t-final t-final
                       #:cfl cfl
                       #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_validate.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-validate)))

;; Synthesize the code to validate any first-order surrogate solver for the 1D isothermal Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-isothermal-euler-minmod-validate
  (validate-vector2-1d-second-order pde-system-isothermal-euler limiter-minmod neural-net-shallow
                                    #:nx nx
                                    #:x0 x0
                                    #:x1 x1
                                    #:t-final t-final
                                    #:cfl cfl
                                    #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_minmod_validate.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-minmod-validate)))

;; Define the 2D isothermal Euler equations (density, x-momentum and y-momentum components).
(define pde-system-isothermal-euler-2d
  (hash
   'name "isothermal-euler-2d"
   'cons-exprs (list
                `rho
                `mom_x
                `mom_y)                                        ; conserved variables: density, x-momentum, y-momentum
   'flux-exprs-x (list
                  `mom_x
                  `(+ (/ (* mom_x mom_x) rho) (* rho vt vt))
                  `(* mom_y (/ mom_x rho)))                    ; x-flux vector
   'flux-exprs-y (list
                  `mom_y
                  `(* mom_x (/ mom_y rho))
                  `(+ (/ (* mom_y mom_y) rho) (* rho vt vt)))  ; y-flux vector
   'max-speed-exprs-x (list
                       `(abs (- (/ mom_x rho) vt))
                       `(/ mom_x rho)
                       `(abs (+ (/ mom_x rho) vt)))            ; local wave-speeds (x-direction)
   'max-speed-exprs-y (list
                       `(abs (- (/ mom_y rho) vt))
                       `(/ mom_y rho)
                       `(abs (+ (/ mom_y rho) vt)))            ; local wave-speeds (y-direction)
   'parameters (list
                `(define vt 1.0))                              ; thermal velocity: vt = 1.0
   ))

;; Define 2D simulation parameters.
(define nx-2d 50)
(define ny-2d 50)
(define x0-2d 0.0)
(define x1-2d 2.0)
(define y0-2d 0.0)
(define y1-2d 2.0)
(define t-final-2d 0.2)
(define cfl-2d 0.9)
(define init-funcs-2d (list
                       `(cond
                          [(> y 1.0)
                           (cond
                             [(< x 1.0) 0.5323]
                             [else 1.5])]
                          [else
                           (cond
                             [(< x 1.0) 0.138]
                             [else 0.5323])])
                       `(cond
                          [(> y 1.0)
                           (cond
                             [(< x 1.0) 1.206]
                             [else 0.0])]
                          [else
                           (cond
                             [(< x 1.0) 1.206]
                             [else 0.0])])
                       `(cond
                          [(> y 1.0)
                           (cond
                             [(< x 1.0) 0.0]
                             [else 0.0])]
                          [else
                           (cond
                             [(< x 1.0) 1.206]
                             [else 1.206])])))

;; Define (shallow) neural network hyperparameters for 2D.
(define neural-net-shallow-2d
  (hash
   'max-trains 10000    ; maximum number of training steps: 10000
   'width 64            ; number of neurons in each layer: 64
   'depth 6             ; total number of layers: 6
   'num-threads 12      ; number of threads to use in training: 12
   'mini-size 100       ; size of training mini-batch: 100
   ))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 2D isothermal Euler equations using a shallow neural network.
(define code-isothermal-euler-lax-train-2d
  (train-lax-friedrichs-vector3-2d pde-system-isothermal-euler-2d neural-net-shallow-2d
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
(with-output-to-file "code/isothermal_euler_lax_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-lax-train-2d)))

;; Synthesize the code to train a Roe surrogate solver for the 2D isothermal Euler equations using a shallow neural network.
(define code-isothermal-euler-roe-train-2d
  (train-roe-vector3-2d pde-system-isothermal-euler-2d neural-net-shallow-2d
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
(with-output-to-file "code/isothermal_euler_roe_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-roe-train-2d)))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 2D isothermal Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-isothermal-euler-lax-minmod-train-2d
  (train-lax-friedrichs-vector3-2d-second-order pde-system-isothermal-euler-2d limiter-minmod neural-net-shallow-2d
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
(with-output-to-file "code/isothermal_euler_lax_minmod_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-lax-minmod-train-2d)))

;; Synthesize the code to train a Roe surrogate solver for the 2D isothermal Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-isothermal-euler-roe-minmod-train-2d
  (train-roe-vector3-2d-second-order pde-system-isothermal-euler-2d limiter-minmod neural-net-shallow-2d
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
(with-output-to-file "code/isothermal_euler_roe_minmod_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-roe-minmod-train-2d)))

(display "2D isothermal Euler properties: \n\n")

;; Attempt to prove error bounds on smooth solutions obtained from surrogate solvers for the 2D isothermal Euler equations.
(define proof-isothermal-euler-smooth-2d
  (call-with-output-file "proofs/proof_isothermal_euler_smooth_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-vector3-2d-smooth pde-system-isothermal-euler-2d neural-net-shallow-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_smooth_2d.rkt")

;; Show the error bounds (if applicable) on smooth solutions.
(display "Error bound on rho (smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-smooth-2d 0) (list-ref proof-isothermal-euler-smooth-2d 1) (list-ref proof-isothermal-euler-smooth-2d 2)))
(display "\n")

(display "Error bound on mom_x (smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-smooth-2d 3) (list-ref proof-isothermal-euler-smooth-2d 4) (list-ref proof-isothermal-euler-smooth-2d 5)))
(display "\n")

(display "Error bound on mom_y (smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-smooth-2d 6) (list-ref proof-isothermal-euler-smooth-2d 7) (list-ref proof-isothermal-euler-smooth-2d 8)))
(display "\n")

;; Attempt to prove error bounds on non-smooth solutions obtained from surrogate solvers for the 2D isothermal Euler equations.
(define proof-isothermal-euler-non-smooth-2d
  (call-with-output-file "proofs/proof_isothermal_euler_non_smooth_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-vector3-2d-non-smooth pde-system-isothermal-euler-2d neural-net-shallow-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_non_smooth_2d.rkt")

;; Show the error bounds (if applicable) on non-smooth solutions.
(display "Error bound on rho (non-smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-non-smooth-2d 0) (list-ref proof-isothermal-euler-non-smooth-2d 1) (list-ref proof-isothermal-euler-non-smooth-2d 2)))
(display "\n")

(display "Error bound on mom_x (non-smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-non-smooth-2d 3) (list-ref proof-isothermal-euler-non-smooth-2d 4) (list-ref proof-isothermal-euler-non-smooth-2d 5)))
(display "\n")

(display "Error bound on mom_y (non-smooth solutions): ")
(display (max (list-ref proof-isothermal-euler-non-smooth-2d 6) (list-ref proof-isothermal-euler-non-smooth-2d 7) (list-ref proof-isothermal-euler-non-smooth-2d 8)))
(display "\n")

;; Synthesize the code to validate any first-order surrogate solver for the 2D isothermal Euler equations using a shallow neural network.
(define code-isothermal-euler-validate-2d
  (validate-vector3-2d pde-system-isothermal-euler-2d neural-net-shallow-2d
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
(with-output-to-file "code/isothermal_euler_validate_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-validate-2d)))

;; Synthesize the code to validate any first-order surrogate solver for the 2D isothermal Euler equations (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-isothermal-euler-minmod-validate-2d
  (validate-vector3-2d-second-order pde-system-isothermal-euler-2d limiter-minmod neural-net-shallow-2d
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
(with-output-to-file "code/isothermal_euler_minmod_validate_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-minmod-validate-2d)))