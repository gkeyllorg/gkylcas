#lang racket

(require "code_generator_core.rkt")
(require "code_generator_vector.rkt")
(require "prover_core.rkt")
(require "prover_vector.rkt")
(provide (all-from-out "code_generator_core.rkt"))
(provide (all-from-out "code_generator_vector.rkt"))

;; Construct /code and /proofs output directories if they do not already exist.
(cond
  [(not (directory-exists? "code")) (make-directory "code")])
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

;; Define the 1D isothermal Euler equations (density and x-momentum components).
(define pde-system-isothermal-euler-mom-x
  (hash
   'name "isothermal-euler-mom-x"
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
(define nx 200)
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

;; Synthesize the code for a Lax-Friedrichs solver for the 1D isothermal Euler equations (density and x-momentum components).
(define code-isothermal-euler-mom-x-lax
  (generate-lax-friedrichs-vector2-1d pde-system-isothermal-euler-mom-x
                                      #:nx nx
                                      #:x0 x0
                                      #:x1 x1
                                      #:t-final t-final
                                      #:cfl cfl
                                      #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_mom_x_lax.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-x-lax)))

(display "Lax-Friedrichs (finite-difference) properties: \n\n")

;; Attempt to prove hyperbolicity of the Lax-Friedrichs solver for the 1D isothermal Euler equations (density and x-momentum components).
(define proof-isothermal-euler-mom-x-lax-hyperbolicity
  (call-with-output-file "proofs/proof_isothermal_euler_mom_x_lax_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-hyperbolicity pde-system-isothermal-euler-mom-x
                                                       #:nx nx
                                                       #:x0 x0
                                                       #:x1 x1
                                                       #:t-final t-final
                                                       #:cfl cfl
                                                       #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_x_lax_hyperbolicity.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-isothermal-euler-mom-x-lax-hyperbolicity)
(display "\n")

;; Attempt to prove strict hyperbolicity of the Lax-Friedrichs solver for the 1D isothermal Euler equations (density and x-momentum components).
(define proof-isothermal-euler-mom-x-lax-strict-hyperbolicity
  (call-with-output-file "proofs/proof_isothermal_euler_mom_x_lax_strict_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-strict-hyperbolicity pde-system-isothermal-euler-mom-x
                                                              #:nx nx
                                                              #:x0 x0
                                                              #:x1 x1
                                                              #:t-final t-final
                                                              #:cfl cfl
                                                              #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_x_lax_strict_hyperbolicity.rkt")

;; Show whether strict hyperbolicity is preserved.
(display "Strict hyperbolicity preservation: ")
(display proof-isothermal-euler-mom-x-lax-strict-hyperbolicity)
(display "\n")

;; Attempt to prove CFL stability of the Lax-Friedrichs solver for the 1D isothermal Euler equations (density and x-momentum components).
(define proof-isothermal-euler-mom-x-lax-cfl-stability
  (call-with-output-file "proofs/proof_isothermal_euler_mom_x_lax_cfl_stability.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-cfl-stability pde-system-isothermal-euler-mom-x
                                                       #:nx nx
                                                       #:x0 x0
                                                       #:x1 x1
                                                       #:t-final t-final
                                                       #:cfl cfl
                                                       #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_x_lax_cfl_stability.rkt")

;; Show whether CFL stability is satisfied.
(display "CFL stability: ")
(display proof-isothermal-euler-mom-x-lax-cfl-stability)
(display "\n")

;; Attempt to prove local Lipschitz continuity of the discrete flux function for the Lax-Friedrichs solver for the 1D isothermal Euler equations (density and x-momentum components).
(define proof-isothermal-euler-mom-x-lax-local-lipschitz
  (call-with-output-file "proofs/proof_isothermal_euler_mom_x_lax_local_lipschitz.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-local-lipschitz pde-system-isothermal-euler-mom-x
                                                         #:nx nx
                                                         #:x0 x0
                                                         #:x1 x1
                                                         #:t-final t-final
                                                         #:cfl cfl
                                                         #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_x_lax_local_lipschitz.rkt")

;; Show whether the local Lipschitz continuity property of the discrete flux function is satisfied.
(display "Local Lipschitz continuity of discrete flux function: ")
(display proof-isothermal-euler-mom-x-lax-local-lipschitz)
(display "\n\n\n")

;; Synthesize the code for a Roe solver for the 1D isothermal Euler equations (density and x-momentum components).
(define code-isothermal-euler-mom-x-roe
  (generate-roe-vector2-1d pde-system-isothermal-euler-mom-x
                           #:nx nx
                           #:x0 x0
                           #:x1 x1
                           #:t-final t-final
                           #:cfl cfl
                           #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_mom_x_roe.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-x-roe)))

(display "Roe (finite-volume) properties: \n\n")

;; Attempt to prove hyperbolicity of the Roe solver for the 1D isothermal Euler equations (density and x-momentum components).
(define proof-isothermal-euler-mom-x-roe-hyperbolicity
  (call-with-output-file "proofs/proof_isothermal_euler_mom_x_roe_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-hyperbolicity pde-system-isothermal-euler-mom-x
                                            #:nx nx
                                            #:x0 x0
                                            #:x1 x1
                                            #:t-final t-final
                                            #:cfl cfl
                                            #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_x_roe_hyperbolicity.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-isothermal-euler-mom-x-roe-hyperbolicity)
(display "\n")

;; Attempt to prove strict hyperbolicity of the Roe solver for the 1D isothermal Euler equations (density and x-momentum components).
(define proof-isothermal-euler-mom-x-roe-strict-hyperbolicity
  (call-with-output-file "proofs/proof_isothermal_euler_mom_x_roe_strict_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-strict-hyperbolicity pde-system-isothermal-euler-mom-x
                                                   #:nx nx
                                                   #:x0 x0
                                                   #:x1 x1
                                                   #:t-final t-final
                                                   #:cfl cfl
                                                   #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_x_roe_strict_hyperbolicity.rkt")

;; Show whether strict hyperbolicity is preserved.
(display "Strict hyperbolicity preservation: ")
(display proof-isothermal-euler-mom-x-roe-strict-hyperbolicity)
(display "\n")

;; Attempt to prove flux conservation (jump continuity) of the Roe solver for the 1D isothermal Euler equations (density and x-momentum components).
(define proof-isothermal-euler-mom-x-roe-flux-conservation
  (call-with-output-file "proofs/proof_isothermal_euler_mom_x_roe_flux_conservation.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-flux-conservation pde-system-isothermal-euler-mom-x
                                                #:nx nx
                                                #:x0 x0
                                                #:x1 x1
                                                #:t-final t-final
                                                #:cfl cfl
                                                #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_x_roe_flux_conservation.rkt")

;; Show whether flux conservation (jump continuity) is preserved.
(display "Flux conservation (jump continuity): ")
(display proof-isothermal-euler-mom-x-roe-flux-conservation)
(display "\n")

;; Define the minmod flux limiter.
(define limiter-minmod
  (hash
   'name "minmod"
   'limiter-expr `(max 0.0 (min 1.0 r))
   'limiter-ratio `r
   ))

;; Synthesize the code for a Lax-Friedrichs solver for the 1D isothermal Euler equations (density and x-momentum components, with a second-order flux extrapolation using the minmod flux limiter).
(define code-isothermal-euler-mom-x-lax-minmod
  (generate-lax-friedrichs-vector2-1d-second-order pde-system-isothermal-euler-mom-x limiter-minmod
                                                   #:nx nx
                                                   #:x0 x0
                                                   #:x1 x1
                                                   #:t-final t-final
                                                   #:cfl cfl
                                                   #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_mom_x_lax_minmod.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-x-lax-minmod)))

;; Synthesize the code for a Roe solver for the 1D isothermal Euler equations (density and x-momentum components, with a second-order flux extrapolation using the minmod flux limiter).
(define code-isothermal-euler-mom-x-roe-minmod
  (generate-roe-vector2-1d-second-order pde-system-isothermal-euler-mom-x limiter-minmod
                                        #:nx nx
                                        #:x0 x0
                                        #:x1 x1
                                        #:t-final t-final
                                        #:cfl cfl
                                        #:init-funcs init-funcs))

;; Output the code to a file.
(with-output-to-file "code/isothermal_euler_mom_x_roe_minmod.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-x-roe-minmod)))