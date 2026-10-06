#lang racket

(require "code_generator_core.rkt")
(require "code_generator_vector_2d.rkt")
(require "prover_core.rkt")
(require "prover_vector.rkt")
(provide (all-from-out "code_generator_core.rkt"))
(provide (all-from-out "code_generator_vector_2d.rkt"))

;; Construct /code and /proofs output directories if they do not already exist.
(cond
  [(not (directory-exists? "code")) (make-directory "code")])
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

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
                       `(abs (/ mom_x rho))
                       `(abs (+ (/ mom_x rho) vt)))            ; local wave-speeds (x-direction)
   'max-speed-exprs-y (list
                       `(abs (- (/ mom_y rho) vt))
                       `(abs (/ mom_y rho))
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

;; Synthesize the code for a Lax-Friedrichs solver for the 2D isothermal Euler equations.
(define code-isothermal-euler-lax-2d
  (generate-lax-friedrichs-vector3-2d pde-system-isothermal-euler-2d
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
(with-output-to-file "code/isothermal_euler_lax_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-lax-2d)))

(display "Lax-Friedrichs (finite-difference) properties: \n\n")

;; Attempt to prove hyperbolicity of the Lax-Friedrichs solver for the 2D isothermal Euler equations.
(define proof-isothermal-euler-lax-hyperbolicity-2d
  (call-with-output-file "proofs/proof_isothermal_euler_lax_hyperbolicity_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector3-2d-hyperbolicity pde-system-isothermal-euler-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_lax_hyperbolicity_2d.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-isothermal-euler-lax-hyperbolicity-2d)
(display "\n")

;; Attempt to prove strict hyperbolicity of the Lax-Friedrichs solver for the 2D isothermal Euler equations.
(define proof-isothermal-euler-lax-strict-hyperbolicity-2d
  (call-with-output-file "proofs/proof_isothermal_euler_lax_strict_hyperbolicity_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector3-2d-strict-hyperbolicity pde-system-isothermal-euler-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_lax_strict_hyperbolicity_2d.rkt")

;; Show whether strict hyperbolicity is preserved.
(display "Strict hyperbolicity preservation: ")
(display proof-isothermal-euler-lax-strict-hyperbolicity-2d)
(display "\n")

;; Attempt to prove CFL stability of the Lax-Friedrichs solver for the 2D isothermal Euler equations.
(define proof-isothermal-euler-lax-cfl-stability-2d
  (call-with-output-file "proofs/proof_isothermal_euler_lax_cfl_stability_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector3-2d-cfl-stability pde-system-isothermal-euler-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_lax_cfl_stability_2d.rkt")

;; Show whether CFL stability is satisfied.
(display "CFL stability: ")
(display proof-isothermal-euler-lax-cfl-stability-2d)
(display "\n")

;; Attempt to prove local Lipschitz continuity of the discrete flux function for the Lax-Friedrichs solver for the 2D isothermal Euler equations.
(define proof-isothermal-euler-lax-local-lipschitz-2d
  (call-with-output-file "proofs/proof_isothermal_euler_lax_local_lipschitz_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector3-2d-local-lipschitz pde-system-isothermal-euler-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_lax_local_lipschitz_2d.rkt")

;; Show whether the local Lipschitz continuity property of the discrete flux function is satisfied.
(display "Local Lipschitz continuity of discrete flux function: ")
(display proof-isothermal-euler-lax-local-lipschitz-2d)
(display "\n\n\n")

;; Synthesize the code for a Roe solver for the 2D isothermal Euler equations.
(define code-isothermal-euler-roe-2d
  (generate-roe-vector3-2d pde-system-isothermal-euler-2d
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
(with-output-to-file "code/isothermal_euler_roe_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-roe-2d)))

(display "Roe (finite-volume) properties: \n\n")

;; Attempt to prove hyperbolicity of the Roe solver for the 2D isothermal Euler equations.
(define proof-isothermal-euler-roe-hyperbolicity-2d
  (call-with-output-file "proofs/proof_isothermal_euler_roe_hyperbolicity_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector3-2d-hyperbolicity pde-system-isothermal-euler-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_roe_hyperbolicity_2d.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-isothermal-euler-roe-hyperbolicity-2d)
(display "\n")

;; Attempt to prove strict hyperbolicity of the Roe solver for the 2D isothermal Euler equations.
(define proof-isothermal-euler-roe-strict-hyperbolicity-2d
  (call-with-output-file "proofs/proof_isothermal_euler_roe_strict_hyperbolicity_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector3-2d-strict-hyperbolicity pde-system-isothermal-euler-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_roe_strict_hyperbolicity_2d.rkt")

;; Show whether strict hyperbolicity is preserved.
(display "Strict hyperbolicity preservation: ")
(display proof-isothermal-euler-roe-strict-hyperbolicity-2d)
(display "\n")

;; Attempt to prove flux conservation (jump continuity) of the Roe solver for the 2D isothermal Euler equations.
(define proof-isothermal-euler-roe-flux-conservation-2d
  (call-with-output-file "proofs/proof_isothermal_euler_roe_flux_conservation_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector3-2d-flux-conservation pde-system-isothermal-euler-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_roe_flux_conservation_2d.rkt")

;; Show whether flux conservation (jump continuity) is preserved.
(display "Flux conservation (jump continuity): ")
(display proof-isothermal-euler-roe-flux-conservation-2d)
(display "\n")

;; Define the minmod flux limiter.
(define limiter-minmod
  (hash
   'name "minmod"
   'limiter-expr `(max 0.0 (min 1.0 r))
   'limiter-ratio `r
   ))

;; Synthesize the code for a Lax-Friedrichs solver for the 2D isothermal Euler equations (with a second-order flux extrapolation using the minmod flux limiter).
(define code-isothermal-euler-lax-minmod-2d
  (generate-lax-friedrichs-vector3-2d-second-order pde-system-isothermal-euler-2d limiter-minmod
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
(with-output-to-file "code/isothermal_euler_lax_minmod_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-lax-minmod-2d)))

;; Synthesize the code for a Roe solver for the 2D isothermal Euler equations (with a second-order flux extrapolation using the minmod flux limiter).
(define code-isothermal-euler-roe-minmod-2d
  (generate-roe-vector3-2d-second-order pde-system-isothermal-euler-2d limiter-minmod
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
(with-output-to-file "code/isothermal_euler_roe_minmod_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-roe-minmod-2d)))