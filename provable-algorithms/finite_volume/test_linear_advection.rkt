#lang racket

(require "code_generator_core.rkt")
(require "code_generator_core_2d.rkt")
(require "prover_core.rkt")
(provide (all-from-out "code_generator_core.rkt"))

;; Construct /code and /proofs output directories if they do not already exist.
(cond
  [(not (directory-exists? "code")) (make-directory "code")])
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

;; Define the 1D linear advection equation: du/dt + d(au)/dx = 0.
(define pde-linear-advection
  (hash
   'name "linear-advection"
   'cons-expr `u                 ; conserved variable: u
   'flux-expr `(* a u)           ; flux function: f(u) = a * u
   'max-speed-expr `(abs a)      ; local wave-speed: alpha = |a|
   'parameters (list
                `(define a 1.0)) ; advection speed: a = 1.0
   ))

;; Define simulation parameters.
(define nx 200)
(define x0 0.0)
(define x1 2.0)
(define t-final 0.5)
(define cfl 0.95)
(define init-func `(cond
                     [(< x 1.0) 1.0]
                     [else 0.0]))

;; Synthesize the code for a Lax-Friedrichs solver for the 1D linear advection equation.
(define code-linear-advection-lax
  (generate-lax-friedrichs-scalar-1d pde-linear-advection
                                     #:nx nx
                                     #:x0 x0
                                     #:x1 x1
                                     #:t-final t-final
                                     #:cfl cfl
                                     #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/linear_advection_lax.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-lax)))

(display "1D Lax-Friedrichs (finite-difference) properties: \n\n")

;; Attempt to prove hyperbolicity of the Lax-Friedrichs solver for the 1D linear advection equation.
(define proof-linear-advection-lax-hyperbolicity
  (call-with-output-file "proofs/proof_linear_advection_lax_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-lax-friedrichs-scalar-1d-hyperbolicity pde-linear-advection
                                                      #:nx nx
                                                      #:x0 x0
                                                      #:x1 x1
                                                      #:t-final t-final
                                                      #:cfl cfl
                                                      #:init-func init-func)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_lax_hyperbolicity.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-linear-advection-lax-hyperbolicity)
(display "\n")

;; Attempt to prove CFL stability of the Lax-Friedrichs solver for the 1D linear advection equation.
(define proof-linear-advection-lax-cfl-stability
  (call-with-output-file "proofs/proof_linear_advection_lax_cfl_stability.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-lax-friedrichs-scalar-1d-cfl-stability pde-linear-advection
                                                      #:nx nx
                                                      #:x0 x0
                                                      #:x1 x1
                                                      #:t-final t-final
                                                      #:cfl cfl
                                                      #:init-func init-func)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_lax_cfl_stability.rkt")

;; Show whether CFL stability is satisfied.
(display "CFL stability: ")
(display proof-linear-advection-lax-cfl-stability)
(display "\n")

;; Attempt to prove local Lipschitz continuity of the discrete flux function for the Lax-Friedrichs solver for the 1D linear advection equation.
(define proof-linear-advection-lax-local-lipschitz
  (call-with-output-file "proofs/proof_linear_advection_lax_local_lipschitz.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-lax-friedrichs-scalar-1d-local-lipschitz pde-linear-advection
                                                        #:nx nx
                                                        #:x0 x0
                                                        #:x1 x1
                                                        #:t-final t-final
                                                        #:cfl cfl
                                                        #:init-func init-func)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_lax_local_lipschitz.rkt")

;; Show whether the local Lipschitz continuity property of the discrete flux function is satisfied.
(display "Local Lipschitz continuity of discrete flux function: ")
(display proof-linear-advection-lax-local-lipschitz)
(display "\n\n\n")

;; Synthesize the code for a Roe solver for the 1D linear advection equation.
(define code-linear-advection-roe
  (generate-roe-scalar-1d pde-linear-advection
                          #:nx nx
                          #:x0 x0
                          #:x1 x1
                          #:t-final t-final
                          #:cfl cfl
                          #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/linear_advection_roe.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-roe)))

(display "1D Roe (finite-volume) properties: \n\n")

;; Attempt to prove hyperbolicity of the Roe solver for the 1D linear advection equation.
(define proof-linear-advection-roe-hyperbolicity
  (call-with-output-file "proofs/proof_linear_advection_roe_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-roe-scalar-1d-hyperbolicity pde-linear-advection
                                           #:nx nx
                                           #:x0 x0
                                           #:x1 x1
                                           #:t-final t-final
                                           #:cfl cfl
                                           #:init-func init-func)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_roe_hyperbolicity.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-linear-advection-roe-hyperbolicity)
(display "\n")

;; Attempt to prove flux conservation (jump continuity) of the Roe solver for the 1D linear advection equation.
(define proof-linear-advection-roe-flux-conservation
  (call-with-output-file "proofs/proof_linear_advection_roe_flux_conservation.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-roe-scalar-1d-flux-conservation pde-linear-advection
                                               #:nx nx
                                               #:x0 x0
                                               #:x1 x1
                                               #:t-final t-final
                                               #:cfl cfl
                                               #:init-func init-func)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_roe_flux_conservation.rkt")

;; Show whether flux conservation (jump continuity) is preserved.
(display "Flux conservation (jump continuity): ")
(display proof-linear-advection-roe-flux-conservation)
(display "\n\n\n")

;; Define the minmod flux limiter.
(define limiter-minmod
  (hash
   'name "minmod"
   'limiter-expr `(max 0.0 (min 1.0 r))
   'limiter-ratio `r
   ))

;; Synthesize the code for a Lax-Friedrichs solver for the 1D linear advection equation (with a second-order flux extrapolation using the minmod flux limiter).
(define code-linear-advection-lax-minmod
  (generate-lax-friedrichs-scalar-1d-second-order pde-linear-advection limiter-minmod
                                                  #:nx nx
                                                  #:x0 x0
                                                  #:x1 x1
                                                  #:t-final t-final
                                                  #:cfl cfl
                                                  #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/linear_advection_lax_minmod.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-lax-minmod)))

;; Synthesize the code for a Roe solver for the 1D linear advection equation (with a second-order flux extrapolation using the minmod flux limiter).
(define code-linear-advection-roe-minmod
  (generate-roe-scalar-1d-second-order pde-linear-advection limiter-minmod
                                       #:nx nx
                                       #:x0 x0
                                       #:x1 x1
                                       #:t-final t-final
                                       #:cfl cfl
                                       #:init-func init-func))

;; Output the code to a file.
(with-output-to-file "code/linear_advection_roe_minmod.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-roe-minmod)))

;; Define the 2D linear advection equation: du/dt + d(au)/dx + d(bu)/dy = 0.
(define pde-linear-advection-2d
  (hash
   'name "linear-advection-2d"
   'cons-expr `u                     ; conserved variable: u
   'flux-expr-x `(* a u)             ; x-flux function: f(u) = a * u
   'flux-expr-y `(* b u)             ; y-flux function: f(u) = b * u
   'max-speed-expr-x `(abs a)        ; local x wave-speed: alpha_x = |a|
   'max-speed-expr-y `(abs b)        ; local y wave-speed: alpha_y = |b|
   'parameters (list
                `(define a 1.0)
                `(define b 1.0))     ; advection speesd: a = 1.0, b = 1.0
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
                        [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.25) 1.0]
                        [else 0.0]))

;; Synthesize the code for a Lax-Friedrichs solver for the 2D linear advection equation.
(define code-linear-advection-lax-2d
  (generate-lax-friedrichs-scalar-2d pde-linear-advection-2d
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
(with-output-to-file "code/linear_advection_lax_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-lax-2d)))

(display "2D Lax-Friedrichs (finite-difference) properties: \n\n")

;; Attempt to prove hyperbolicity of the Lax-Friedrichs solver for the 2D linear advection equation.
(define proof-linear-advection-lax-hyperbolicity-2d
  (call-with-output-file "proofs/proof_linear_advection_lax_hyperbolicity_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-lax-friedrichs-scalar-2d-hyperbolicity pde-linear-advection-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_lax_hyperbolicity_2d.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-linear-advection-lax-hyperbolicity-2d)
(display "\n")

;; Attempt to prove CFL stability of the Lax-Friedrichs solver for the 2D linear advection equation.
(define proof-linear-advection-lax-cfl-stability-2d
  (call-with-output-file "proofs/proof_linear_advection_lax_cfl_stability_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-lax-friedrichs-scalar-2d-cfl-stability pde-linear-advection-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_lax_cfl_stability_2d.rkt")

;; Show whether CFL stability is satisfied.
(display "CFL stability: ")
(display proof-linear-advection-lax-cfl-stability-2d)
(display "\n")

;; Attempt to prove local Lipschitz continuity of the discrete flux function for the Lax-Friedrichs solver for the 2D linear advection equation.
(define proof-linear-advection-lax-local-lipschitz-2d
  (call-with-output-file "proofs/proof_linear_advection_lax_local_lipschitz_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-lax-friedrichs-scalar-2d-local-lipschitz pde-linear-advection-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_lax_local_lipschitz_2d.rkt")

;; Show whether the local Lipschitz continuity property of the discrete flux function is satisfied.
(display "Local Lipschitz continuity of discrete flux function: ")
(display proof-linear-advection-lax-local-lipschitz-2d)
(display "\n\n\n")

;; Synthesize the code for a Roe solver for the 2D linear advection equation.
(define code-linear-advection-roe-2d
  (generate-roe-scalar-2d pde-linear-advection-2d
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
(with-output-to-file "code/linear_advection_roe_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-roe-2d)))

(display "2D Roe (finite-volume) properties: \n\n")

;; Attempt to prove hyperbolicity of the Roe solver for the 2D linear advection equation.
(define proof-linear-advection-roe-hyperbolicity-2d
  (call-with-output-file "proofs/proof_linear_advection_roe_hyperbolicity_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-roe-scalar-2d-hyperbolicity pde-linear-advection-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_roe_hyperbolicity_2d.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-linear-advection-roe-hyperbolicity-2d)
(display "\n")

;; Attempt to prove flux conservation (jump continuity) of the Roe solver for the 2D linear advection equation.
(define proof-linear-advection-roe-flux-conservation-2d
  (call-with-output-file "proofs/proof_linear_advection_roe_flux_conservation_2d.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-roe-scalar-2d-flux-conservation pde-linear-advection-2d
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
(remove-bracketed-expressions-from-file "proofs/proof_linear_advection_roe_flux_conservation_2d.rkt")

;; Show whether flux conservation (jump continuity) is preserved.
(display "Flux conservation (jump continuity): ")
(display proof-linear-advection-roe-flux-conservation-2d)
(display "\n")

;; Synthesize the code for a Lax-Friedrichs solver for the 2D linear advection equation (with a second-order flux extrapolation using the minmod flux limiter).
(define code-linear-advection-lax-minmod-2d
  (generate-lax-friedrichs-scalar-2d-second-order pde-linear-advection-2d limiter-minmod
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
(with-output-to-file "code/linear_advection_lax_minmod_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-lax-minmod-2d)))

;; Synthesize the code for a Roe solver for the 2D linear advection equation (with a second-order flux extrapolation using the minmod flux limiter).
(define code-linear-advection-roe-minmod-2d
  (generate-roe-scalar-2d-second-order pde-linear-advection-2d limiter-minmod
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
(with-output-to-file "code/linear_advection_roe_minmod_2d.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-roe-minmod-2d)))