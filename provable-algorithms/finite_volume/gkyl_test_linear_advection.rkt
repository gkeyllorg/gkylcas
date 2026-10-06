#lang racket

(require "gkyl_code_generator_lax.rkt")
(require "gkyl_code_generator_roe.rkt")
(require "prover_core.rkt")
(provide (all-from-out "gkyl_code_generator_lax.rkt"))
(provide (all-from-out "gkyl_code_generator_roe.rkt"))

;; Construct /code and /proofs output directories if they do not already exist.
(cond
  [(not (directory-exists? "gkyl_code")) (make-directory "gkyl_code")])
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

;; Define the 1D linear advection equation: du/dt + d(au)/dx = 0.
(define pde-linear-advection
  (hash
   'name "advect"
   'cons-expr `u                  ; conserved variable: u
   'flux-expr `(* a u)            ; flux function: f(u) = a * u
   'max-speed-expr `(abs a)       ; local wave-speed: alpha = |a|
   'parameters (list
                `(define a 1.0))  ; advection speed: a = 1.0
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

;; Synthesize the Gkeyll header code for a Lax-Friedrichs solver for the 1D linear advection equation.
(define code-linear-advection-lax-header
  (gkyl-generate-lax-friedrichs-scalar-1d-header pde-linear-advection
                                                 #:nx nx
                                                 #:x0 x0
                                                 #:x1 x1
                                                 #:t-final t-final
                                                 #:cfl cfl
                                                 #:init-func init-func))

;; Output the header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_advect_lax.h"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-lax-header)))

;; Synthesize the Gkeyll private header code for a Lax-Friedrichs solver for the 1D linear advection equation.
(define code-linear-advection-lax-priv-header
  (gkyl-generate-lax-friedrichs-scalar-1d-priv-header pde-linear-advection
                                                      #:nx nx
                                                      #:x0 x0
                                                      #:x1 x1
                                                      #:t-final t-final
                                                      #:cfl cfl
                                                      #:init-func init-func))

;; Output the private header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_advect_lax_priv.h"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-lax-priv-header)))

;; Synthesize the Gkeyll source code for a Lax-Friedrichs solver for the 1D linear advection equation.
(define code-linear-advection-lax-source
  (gkyl-generate-lax-friedrichs-scalar-1d-source pde-linear-advection
                                                 #:nx nx
                                                 #:x0 x0
                                                 #:x1 x1
                                                 #:t-final t-final
                                                 #:cfl cfl
                                                 #:init-func init-func))

;; Output the source code to a file.
(with-output-to-file "gkyl_code/wv_advect_lax.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-lax-source)))

;; Synthesize a Gkeyll C regression test for a Lax-Friedrichs solver for the 1D linear advection equation.
(define code-linear-advection-lax-regression
  (gkyl-generate-lax-friedrichs-scalar-1d-regression pde-linear-advection
                                                     #:nx nx
                                                     #:x0 x0
                                                     #:x1 x1
                                                     #:t-final t-final
                                                     #:cfl cfl
                                                     #:init-func init-func))

;; Output the regression test to a file.
(with-output-to-file "gkyl_code/rt_advect_lax.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-lax-regression)))

(display "Lax-Friedrichs (finite-difference) properties: \n\n")

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

;; Synthesize the Gkeyll header code for a Roe solver for the 1D linear advection equation.
(define code-linear-advection-roe-header
  (gkyl-generate-roe-scalar-1d-header pde-linear-advection
                                      #:nx nx
                                      #:x0 x0
                                      #:x1 x1
                                      #:t-final t-final
                                      #:cfl cfl
                                      #:init-func init-func))

;; Output the header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_advect_roe.h"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-roe-header)))

;; Synthesize the Gkeyll private header code for a Roe solver for the 1D linear advection equation.
(define code-linear-advection-roe-priv-header
  (gkyl-generate-roe-scalar-1d-priv-header pde-linear-advection
                                           #:nx nx
                                           #:x0 x0
                                           #:x1 x1
                                           #:t-final t-final
                                           #:cfl cfl
                                           #:init-func init-func))

;; Output the private header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_advect_roe_priv.h"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-roe-priv-header)))

;; Synthesize the Gkeyll source code for a Roe solver for the 1D linear advection equation.
(define code-linear-advection-roe-source
  (gkyl-generate-roe-scalar-1d-source pde-linear-advection
                                      #:nx nx
                                      #:x0 x0
                                      #:x1 x1
                                      #:t-final t-final
                                      #:cfl cfl
                                      #:init-func init-func))

;; Output the source code to a file.
(with-output-to-file "gkyl_code/wv_advect_roe.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-roe-source)))

;; Synthesize a Gkeyll C regression test for a Roe solver for the 1D linear advection equation.
(define code-linear-advection-roe-regression
  (gkyl-generate-roe-scalar-1d-regression pde-linear-advection
                                          #:nx nx
                                          #:x0 x0
                                          #:x1 x1
                                          #:t-final t-final
                                          #:cfl cfl
                                          #:init-func init-func))

;; Output the regression test to a file.
(with-output-to-file "gkyl_code/rt_advect_roe.c"
  #:exists 'replace
  (lambda ()
    (display code-linear-advection-roe-regression)))

(display "Roe (finite-volume) properties: \n\n")

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
(display "\n")