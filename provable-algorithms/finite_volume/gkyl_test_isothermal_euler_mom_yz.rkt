#lang racket

(require "gkyl_code_generator_lax_vector.rkt")
(require "gkyl_code_generator_roe_vector.rkt")
(require "prover_core.rkt")
(require "prover_vector.rkt")
(provide (all-from-out "gkyl_code_generator_lax_vector.rkt"))
(provide (all-from-out "gkyl_code_generator_roe_vector.rkt"))

;; Construct /code and /proofs output directories if they do not already exist.
(cond
  [(not (directory-exists? "gkyl_code")) (make-directory "gkyl_code")])
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

;; Define the 1D isothermal Euler equations (y- and z-momentum components).
(define pde-system-isothermal-euler-mom-yz
  (hash
   'name "isothermal_euler_mom_yz"
   'cons-exprs (list
                `mom_y
                `mom_z)                ; conserved variables: y-momentum, z-momentum
   'flux-exprs (list
                `(* mom_y u)
                `(* mom_z u))          ; flux vector
   'max-speed-exprs (list
                     `(abs u)
                     `(abs u))         ; local wave-speeds
   'parameters (list      
                `(define u 0.0))       ; advection velocity: 0.0
   ))

;; Define simulation parameters.
(define nx 200)
(define x0 0.0)
(define x1 1.0)
(define t-final 0.1)
(define cfl 0.95)
(define init-funcs (list 0.0 0.0))

;; Synthesize the Gkeyll header code for a Lax-Friedrichs solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define code-isothermal-euler-mom-yz-lax-header
  (gkyl-generate-lax-friedrichs-vector2-1d-header pde-system-isothermal-euler-mom-yz
                                                  #:nx nx
                                                  #:x0 x0
                                                  #:x1 x1
                                                  #:t-final t-final
                                                  #:cfl cfl
                                                  #:init-funcs init-funcs))

;; Output the header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_isothermal_euler_mom_yz_lax.h"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-yz-lax-header)))

;; Synthesize the Gkeyll private header code for a Lax-Friedrichs solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define code-isothermal-euler-mom-yz-lax-priv-header
  (gkyl-generate-lax-friedrichs-vector2-1d-priv-header pde-system-isothermal-euler-mom-yz
                                                       #:nx nx
                                                       #:x0 x0
                                                       #:x1 x1
                                                       #:t-final t-final
                                                       #:cfl cfl
                                                       #:init-funcs init-funcs))

;; Output the private header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_isothermal_euler_mom_yz_lax_priv.h"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-yz-lax-priv-header)))

;; Synthesize the Gkeyll source code for a Lax-Friedrichs solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define code-isothermal-euler-mom-yz-lax-source
  (gkyl-generate-lax-friedrichs-vector2-1d-source pde-system-isothermal-euler-mom-yz
                                                  #:nx nx
                                                  #:x0 x0
                                                  #:x1 x1
                                                  #:t-final t-final
                                                  #:cfl cfl
                                                  #:init-funcs init-funcs))

;; Output the source code to a file.
(with-output-to-file "gkyl_code/wv_isothermal_euler_mom_yz_lax.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-yz-lax-source)))

;; Synthesize a Gkeyll C regression test for a Lax-Friedrichs solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define code-isothermal-euler-mom-yz-lax-regression
  (gkyl-generate-lax-friedrichs-vector2-1d-regression pde-system-isothermal-euler-mom-yz
                                                      #:nx nx
                                                      #:x0 x0
                                                      #:x1 x1
                                                      #:t-final t-final
                                                      #:cfl cfl
                                                      #:init-funcs init-funcs))

;; Output the regression test to a file.
(with-output-to-file "gkyl_code/rt_isothermal_euler_mom_yz_lax.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-yz-lax-regression)))

(display "Lax-Friedrichs (finite-difference) properties: \n\n")

;; Attempt to prove hyperbolicity of the Lax-Friedrichs solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define proof-isothermal-euler-mom-yz-lax-hyperbolicity
  (call-with-output-file "proofs/proof_isothermal_euler_mom_yz_lax_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-hyperbolicity pde-system-isothermal-euler-mom-yz
                                                       #:nx nx
                                                       #:x0 x0
                                                       #:x1 x1
                                                       #:t-final t-final
                                                       #:cfl cfl
                                                       #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_yz_lax_hyperbolicity.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-isothermal-euler-mom-yz-lax-hyperbolicity)
(display "\n")

;; Attempt to prove strict hyperbolicity of the Lax-Friedrichs solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define proof-isothermal-euler-mom-yz-lax-strict-hyperbolicity
  (call-with-output-file "proofs/proof_isothermal_euler_mom_yz_lax_strict_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-strict-hyperbolicity pde-system-isothermal-euler-mom-yz
                                                              #:nx nx
                                                              #:x0 x0
                                                              #:x1 x1
                                                              #:t-final t-final
                                                              #:cfl cfl
                                                              #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_yz_lax_strict_hyperbolicity.rkt")

;; Show whether strict hyperbolicity is preserved.
(display "Strict hyperbolicity preservation: ")
(display proof-isothermal-euler-mom-yz-lax-strict-hyperbolicity)
(display "\n")

;; Attempt to prove CFL stability of the Lax-Friedrichs solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define proof-isothermal-euler-mom-yz-lax-cfl-stability
  (call-with-output-file "proofs/proof_isothermal_euler_mom_yz_lax_cfl_stability.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-cfl-stability pde-system-isothermal-euler-mom-yz
                                                       #:nx nx
                                                       #:x0 x0
                                                       #:x1 x1
                                                       #:t-final t-final
                                                       #:cfl cfl
                                                       #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_yz_lax_cfl_stability.rkt")

;; Show whether CFL stability is satisfied.
(display "CFL stability: ")
(display proof-isothermal-euler-mom-yz-lax-cfl-stability)
(display "\n")

;; Attempt to prove local Lipschitz continuity of the discrete flux function for the Lax-Friedrichs solver for the 1D isothermal Euler equation (y- and z-momentum components).
(define proof-isothermal-euler-mom-yz-lax-local-lipschitz
  (call-with-output-file "proofs/proof_isothermal_euler_mom_yz_lax_local_lipschitz.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-local-lipschitz pde-system-isothermal-euler-mom-yz
                                                         #:nx nx
                                                         #:x0 x0
                                                         #:x1 x1
                                                         #:t-final t-final
                                                         #:cfl cfl
                                                         #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_yz_lax_local_lipschitz.rkt")

;; Show whether the local Lipschitz continuity property of the discrete flux function is satisfied.
(display "Local Lipschitz continuity of discrete flux function: ")
(display proof-isothermal-euler-mom-yz-lax-local-lipschitz)
(display "\n\n\n")

;; Synthesize the Gkeyll header code for a Roe solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define code-isothermal-euler-mom-yz-roe-header
  (gkyl-generate-roe-vector2-1d-header pde-system-isothermal-euler-mom-yz
                                       #:nx nx
                                       #:x0 x0
                                       #:x1 x1
                                       #:t-final t-final
                                       #:cfl cfl
                                       #:init-funcs init-funcs))

;; Output the header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_isothermal_euler_mom_yz_roe.h"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-yz-roe-header)))

;; Synthesize the Gkeyll private header code for a Roe solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define code-isothermal-euler-mom-yz-roe-priv-header
  (gkyl-generate-roe-vector2-1d-priv-header pde-system-isothermal-euler-mom-yz
                                            #:nx nx
                                            #:x0 x0
                                            #:x1 x1
                                            #:t-final t-final
                                            #:cfl cfl
                                            #:init-funcs init-funcs))

;; Output the private header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_isothermal_euler_mom_yz_roe_priv.h"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-yz-roe-priv-header)))

;; Synthesize the Gkeyll source code for a Roe solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define code-isothermal-euler-mom-yz-roe-source
  (gkyl-generate-roe-vector2-1d-source pde-system-isothermal-euler-mom-yz
                                       #:nx nx
                                       #:x0 x0
                                       #:x1 x1
                                       #:t-final t-final
                                       #:cfl cfl
                                       #:init-funcs init-funcs))

;; Output the source code to a file.
(with-output-to-file "gkyl_code/wv_isothermal_euler_mom_yz_roe.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-yz-roe-source)))

;; Synthesize a Gkeyll C regression test for a Roe solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define code-isothermal-euler-mom-yz-roe-regression
  (gkyl-generate-roe-vector2-1d-regression pde-system-isothermal-euler-mom-yz
                                           #:nx nx
                                           #:x0 x0
                                           #:x1 x1
                                           #:t-final t-final
                                           #:cfl cfl
                                           #:init-funcs init-funcs))

;; Output the regression test to a file.
(with-output-to-file "gkyl_code/rt_isothermal_euler_mom_yz_roe.c"
  #:exists 'replace
  (lambda ()
    (display code-isothermal-euler-mom-yz-roe-regression)))


(display "Roe (finite-volume) properties: \n\n")

;; Attempt to prove hyperbolicity of the Roe solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define proof-isothermal-euler-mom-yz-roe-hyperbolicity
  (call-with-output-file "proofs/proof_isothermal_euler_mom_yz_roe_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-hyperbolicity pde-system-isothermal-euler-mom-yz
                                            #:nx nx
                                            #:x0 x0
                                            #:x1 x1
                                            #:t-final t-final
                                            #:cfl cfl
                                            #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_yz_roe_hyperbolicity.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-isothermal-euler-mom-yz-roe-hyperbolicity)
(display "\n")

;; Attempt to prove strict hyperbolicity of the Roe solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define proof-isothermal-euler-mom-yz-roe-strict-hyperbolicity
  (call-with-output-file "proofs/proof_isothermal_euler_mom_yz_roe_strict_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-strict-hyperbolicity pde-system-isothermal-euler-mom-yz
                                                   #:nx nx
                                                   #:x0 x0
                                                   #:x1 x1
                                                   #:t-final t-final
                                                   #:cfl cfl
                                                   #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_yz_roe_strict_hyperbolicity.rkt")

;; Show whether strict hyperbolicity is preserved.
(display "Strict hyperbolicity preservation: ")
(display proof-isothermal-euler-mom-yz-roe-strict-hyperbolicity)
(display "\n")

;; Attempt to prove flux conservation (jump continuity) of the Roe solver for the 1D isothermal Euler equations (y- and z-momentum components).
(define proof-isothermal-euler-mom-yz-roe-flux-conservation
  (call-with-output-file "proofs/proof_isothermal_euler_mom_yz_roe_flux_conservation.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-flux-conservation pde-system-isothermal-euler-mom-yz
                                                #:nx nx
                                                #:x0 x0
                                                #:x1 x1
                                                #:t-final t-final
                                                #:cfl cfl
                                                #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_isothermal_euler_mom_yz_roe_flux_conservation.rkt")

;; Show whether flux conservation (jump continuity) is preserved.
(display "Flux conservation (jump continuity): ")
(display proof-isothermal-euler-mom-yz-roe-flux-conservation)
(display "\n")