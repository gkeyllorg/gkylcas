#lang racket

(require "code_generator_core_training.rkt")
(require "code_generator_core_training_2d.rkt")
(require "code_generator_core_validation.rkt")
(require "prover_core.rkt")
(provide (all-from-out "code_generator_core_training.rkt"))
(provide (all-from-out "code_generator_core_training_2d.rkt"))
(provide (all-from-out "code_generator_core_validation.rkt"))

;; Construct /code and /proofs output directories if they do not already exist.
(cond
  [(not (directory-exists? "code")) (make-directory "code")])
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

;; Define the 1D inviscid Burgers' equation: du/dt + u du/dx = 0.
(define pde-inviscid-burgers
  (hash
   'name "burgers"
   'cons-expr `u             ; conserved variable: u
   'flux-expr `(* 0.5 u u)   ; flux function: f(u) = 0.5 * u^2
   'max-speed-expr `(abs u)  ; local wave-speed: alpha = |u|
   'parameters `()
   ))

;; Define simulation parameters.
(define nx 400)
(define x0 -3.0)
(define x1 3.0)
(define t-final 0.5)
(define cfl 0.95)
(define init-func `(cond
                     [(< (abs x) 1.0) 3.0]
                     [else -1.0]))

;; Define (shallow) neural network hyperparameters.
(define neural-net-shallow
  (hash
   'max-trains 10000    ; maximum number of training steps: 10000
   'width 64            ; number of neurons in each layer: 64
   'depth 6             ; total number of layers: 8
   'num-threads 12      ; number of threads to use in training: 12
   'mini-size 100       ; size of training mini-batch: 100
   ))
   

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 1D inviscid Burgers' equation using a shallow neural network.
(define code-inviscid-burgers-lax-train
  (train-lax-friedrichs-scalar-1d pde-inviscid-burgers neural-net-shallow
                                  #:nx nx
                                  #:x0 x0
                                  #:x1 x1
                                  #:t-final t-final
                                  #:cfl cfl
                                  #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_lax_train.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-lax-train)))

;; Synthesize the code to train a Roe surrogate solver for the 1D inviscid Burgers' equation using a shallow neural network.
(define code-inviscid-burgers-roe-train
  (train-roe-scalar-1d pde-inviscid-burgers neural-net-shallow
                       #:nx nx
                       #:x0 x0
                       #:x1 x1
                       #:t-final t-final
                       #:cfl cfl
                       #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_roe_train.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-roe-train)))

;; Define the minmod flux limiter.
(define limiter-minmod
  (hash
   'name "minmod"
   'limiter-expr `(max 0.0 (min 1.0 r))
   'limiter-ratio `r
   ))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 1D inviscid Burgers' equation (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-inviscid-burgers-lax-minmod-train
  (train-lax-friedrichs-scalar-1d-second-order pde-inviscid-burgers limiter-minmod neural-net-shallow
                                               #:nx nx
                                               #:x0 x0
                                               #:x1 x1
                                               #:t-final t-final
                                               #:cfl cfl
                                               #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_lax_minmod_train.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-lax-minmod-train)))

;; Synthesize the code to train a Roe surrogate solver for the 1D inviscid Burgers' equation (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-inviscid-burgers-roe-minmod-train
  (train-roe-scalar-1d-second-order pde-inviscid-burgers limiter-minmod neural-net-shallow
                                    #:nx nx
                                    #:x0 x0
                                    #:x1 x1
                                    #:t-final t-final
                                    #:cfl cfl
                                    #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_roe_minmod_train.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-roe-minmod-train)))

(display "1D inviscid Burgers' properties: \n\n")

;; Attempt to prove error bounds on smooth solutions obtained from surrogate solvers for the 1D inviscid Burgers' equation.
(define proof-inviscid-burgers-smooth
  (call-with-output-file "proofs/proof_inviscid_burgers_smooth.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-scalar-1d-smooth pde-inviscid-burgers neural-net-shallow
                                #:nx nx
                                #:x0 x0
                                #:x1 x1
                                #:t-final t-final
                                #:cfl cfl
                                #:init-func init-func)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_inviscid_burgers_smooth.rkt")

;; Show the error bound (if applicable) on smooth solutions.
(display "Error bound (smooth solutions): ")
(display proof-inviscid-burgers-smooth)
(display "\n")

;; Attempt to prove error bounds on non-smooth solutions obtained from surrogate solvers for the 1D inviscid Burgers' equation.
(define proof-inviscid-burgers-non-smooth
  (call-with-output-file "proofs/proof_inviscid_burgers_non_smooth.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-scalar-1d-non-smooth pde-inviscid-burgers neural-net-shallow
                                    #:nx nx
                                    #:x0 x0
                                    #:x1 x1
                                    #:t-final t-final
                                    #:cfl cfl
                                    #:init-func init-func)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_inviscid_burgers_non_smooth.rkt")

;; Show the error bound (if applicable) on non-smooth solutions.
(display "Error bound (non-smooth solutions): ")
(display proof-inviscid-burgers-non-smooth)
(display "\n\n\n")

;; Synthesize the code to validate any first-order surrogate solver for the 1D inviscid Burgers' equation using a shallow neural network.
(define code-inviscid-burgers-validate
  (validate-scalar-1d pde-inviscid-burgers neural-net-shallow
                      #:nx nx
                      #:x0 x0
                      #:x1 x1
                      #:t-final t-final
                      #:cfl cfl
                      #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_validate.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-validate)))

;; Synthesize the code to validate any first-order surrogate solver for the 1D inviscid Burgers' equation (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-inviscid-burgers-minmod-validate
  (validate-scalar-1d-second-order pde-inviscid-burgers limiter-minmod neural-net-shallow
                                   #:nx nx
                                   #:x0 x0
                                   #:x1 x1
                                   #:t-final t-final
                                   #:cfl cfl
                                   #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_minmod_validate.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-minmod-validate)))

;; Define the 2D inviscid Burgers' equation: du/dt + u du/dx + u du/dy = 0.
(define pde-inviscid-burgers-2d
  (hash
   'name "burgers-2d"
   'cons-expr `u                ; conserved variable: u
   'flux-expr-x `(* 0.5 u u)    ; x-flux function: f(u) = 0.5 * u^2
   'flux-expr-y `(* 0.5 u u)    ; y-flux function: f(u) = 0.5 * u^2
   'max-speed-expr-x `(abs u)   ; local wave-speed: alpha_x = |u|
   'max-speed-expr-y `(abs u)   ; local wave-speed: alpha_y = |u|
   'parameters `()
   ))

;; Define 2D simulation parameters.
(define nx-2d 100)
(define ny-2d 100)
(define x0-2d 0.0)
(define x1-2d 2.0)
(define y0-2d 0.0)
(define y1-2d 2.0)
(define t-final-2d 0.5)
(define cfl-2d 0.95)
(define init-func-2d `(cond
                        [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.25) 2.0]
                        [else 0.0]))

;; Define (shallow) neural network hyperparameters for 2D.
(define neural-net-shallow-2d
  (hash
   'max-trains 10000    ; maximum number of training steps: 10000
   'width 64            ; number of neurons in each layer: 64
   'depth 6            ; total number of layers: 6
   'num-threads 12      ; number of threads to use in training: 12
   'mini-size 100       ; size of training mini-batch: 100
   ))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 2D inviscid Burgers' equation using a shallow neural network.
(define code-inviscid-burgers-lax-train-2d
  (train-lax-friedrichs-scalar-2d pde-inviscid-burgers-2d neural-net-shallow-2d
                                  #:nx nx-2d
                                  #:ny ny-2d
                                  #:x0 x0-2d
                                  #:x1 x1-2d
                                  #:y0 y0-2d
                                  #:y1 y1-2d
                                  #:t-final t-final-2d
                                  #:cfl cfl-2d
                                  #:init-func init-func-2d))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_lax_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-lax-train-2d)))

;; Synthesize the code to train a Roe surrogate solver for the 2D inviscid Burgers' equation using a shallow neural network.
(define code-inviscid-burgers-roe-train-2d
  (train-roe-scalar-2d pde-inviscid-burgers-2d neural-net-shallow-2d
                       #:nx nx-2d
                       #:ny ny-2d
                       #:x0 x0-2d
                       #:x1 x1-2d
                       #:y0 y0-2d
                       #:y1 y1-2d
                       #:t-final t-final-2d
                       #:cfl cfl-2d
                       #:init-func init-func-2d))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_roe_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-roe-train-2d)))

;; Synthesize the code to train a Lax-Friedrichs surrogate solver for the 2D inviscid Burgers' equation (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-inviscid-burgers-lax-minmod-train-2d
  (train-lax-friedrichs-scalar-2d-second-order pde-inviscid-burgers-2d limiter-minmod neural-net-shallow-2d
                                               #:nx nx-2d
                                               #:ny ny-2d
                                               #:x0 x0-2d
                                               #:x1 x1-2d
                                               #:y0 y0-2d
                                               #:y1 y1-2d
                                               #:t-final t-final-2d
                                               #:cfl cfl-2d
                                               #:init-func init-func-2d))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_lax_minmod_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-lax-minmod-train-2d)))

;; Synthesize the code to train a Roe surrogate solver for the 2D inviscid Burgers' equation (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-inviscid-burgers-roe-minmod-train-2d
  (train-roe-scalar-2d-second-order pde-inviscid-burgers-2d limiter-minmod neural-net-shallow-2d
                                    #:nx nx-2d
                                    #:ny ny-2d
                                    #:x0 x0-2d
                                    #:x1 x1-2d
                                    #:y0 y0-2d
                                    #:y1 y1-2d
                                    #:t-final t-final-2d
                                    #:cfl cfl-2d
                                    #:init-func init-func-2d))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_roe_minmod_train_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-roe-minmod-train-2d)))

(display "2D inviscid Burgers' properties: \n\n")

;; Attempt to prove error bounds on smooth solutions obtained from surrogate solvers for the 2D inviscid Burgers' equation.
(define proof-inviscid-burgers-smooth-2d
  (call-with-output-file "proofs/proof_inviscid_burgers_smooth_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-scalar-2d-smooth pde-inviscid-burgers-2d neural-net-shallow-2d
                                #:nx nx-2d
                                #:ny ny-2d
                                #:x0 x0-2d
                                #:x1 x1-2d
                                #:y0 y0-2d
                                #:y1 y1-2d
                                #:t-final t-final-2d
                                #:cfl cfl-2d
                                #:init-func init-func-2d)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_inviscid_burgers_smooth_2d.rkt")

;; Show the error bound (if applicable) on smooth solutions.
(display "Error bound (smooth solutions): ")
(display proof-inviscid-burgers-smooth-2d)
(display "\n")

;; Attempt to prove error bounds on non-smooth solutions obtained from surrogate solvers for the 2D inviscid Burgers' equation.
(define proof-inviscid-burgers-non-smooth-2d
  (call-with-output-file "proofs/proof_inviscid_burgers_non_smooth_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover.rkt\")\n\n")
        (prove-scalar-2d-non-smooth pde-inviscid-burgers-2d neural-net-shallow-2d
                                    #:nx nx-2d
                                    #:ny ny-2d
                                    #:x0 x0-2d
                                    #:x1 x1-2d
                                    #:y0 y0-2d
                                    #:y1 y1-2d
                                    #:t-final t-final-2d
                                    #:cfl cfl-2d
                                    #:init-func init-func-2d)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_inviscid_burgers_non_smooth_2d.rkt")

;; Show the error bound (if applicable) on non-smooth solutions.
(display "Error bound (non-smooth solutions): ")
(display proof-inviscid-burgers-non-smooth-2d)
(display "\n")

;; Synthesize the code to validate any first-order surrogate solver for the 2D inviscid Burgers' equation using a shallow neural network.
(define code-inviscid-burgers-validate-2d
  (validate-scalar-2d pde-inviscid-burgers-2d neural-net-shallow-2d
                      #:nx nx-2d
                      #:ny ny-2d
                      #:x0 x0-2d
                      #:x1 x1-2d
                      #:y0 y0-2d
                      #:y1 y1-2d
                      #:t-final t-final-2d
                      #:cfl cfl-2d
                      #:init-func init-func-2d))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_validate_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-validate-2d)))

;; Synthesize the code to validate any first-order surrogate solver for the 2D inviscid Burgers' equation (with a second-order flux extrapolation using the minmod flux limiter)
;; using a shallow neural network.
(define code-inviscid-burgers-minmod-validate-2d
  (validate-scalar-2d-second-order pde-inviscid-burgers-2d limiter-minmod neural-net-shallow-2d
                                   #:nx nx-2d
                                   #:ny ny-2d
                                   #:x0 x0-2d
                                   #:x1 x1-2d
                                   #:y0 y0-2d
                                   #:y1 y1-2d
                                   #:t-final t-final-2d
                                   #:cfl cfl-2d
                                   #:init-func init-func-2d))

;; Output the code to a file.
(with-output-to-file "code/inviscid_burgers_minmod_validate_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-inviscid-burgers-minmod-validate-2d)))