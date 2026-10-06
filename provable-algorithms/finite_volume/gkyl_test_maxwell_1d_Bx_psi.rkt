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

;; Define the 1D Maxwell equations (Bx and psi components).
(define pde-system-maxwell-1d-Bx-psi
  (hash
    'name "maxwell_Bxpsi"
    'cons-exprs (list
                 `Bx
                 `psi)                        ; conserved variables: magnetic field (x-component), magnetic field correction potential (psi).
    'flux-exprs (list
                 `(* b_fact psi)
                 `(* b_fact (* (* c c) Bx)))  ; flux vector
    'max-speed-exprs (list
                      `(abs (* b_fact c))
                      `(abs (* b_fact c)))    ; local wave-speeds
    'parameters (list
                 `(define c 1.0)              ; speed of light: c = 1.0
                 `(define e_fact 1.0)         ; electric field divergence error propagation: e_fact = 1.0
                 `(define b_fact 1.0))        ; magnetic field divergence error propagation: b_fact = 1.0
    ))

;; Define simulation parameters.
(define nx 200)
(define x0 -1.5)
(define x1 1.5)
(define t-final 1.0)
(define cfl 0.95)
(define init-funcs (list
                    0.0
                    `(cond
                       [(< x 0.0) 0.5]
                       [else -0.5])))

;; Synthesize the Gkeyll header code for a Lax-Friedrichs solver for the 1D Maxwell equations (Bx and psi components).
(define code-maxwell-1d-Bx-psi-lax-header
  (gkyl-generate-lax-friedrichs-vector2-1d-header pde-system-maxwell-1d-Bx-psi
                                                  #:nx nx
                                                  #:x0 x0
                                                  #:x1 x1
                                                  #:t-final t-final
                                                  #:cfl cfl
                                                  #:init-funcs init-funcs))

;; Output the header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_maxwell_Bxpsi_lax.h"
  #:exists 'replace
  (lambda ()
    (display code-maxwell-1d-Bx-psi-lax-header)))

;; Synthesize the Gkeyll private header code for a Lax-Friedrichs solver for the 1D Maxwell equations (Bx and psi components).
(define code-maxwell-1d-Bx-psi-lax-priv-header
  (gkyl-generate-lax-friedrichs-vector2-1d-priv-header pde-system-maxwell-1d-Bx-psi
                                                       #:nx nx
                                                       #:x0 x0
                                                       #:x1 x1
                                                       #:t-final t-final
                                                       #:cfl cfl
                                                       #:init-funcs init-funcs))

;; Output the private header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_maxwell_Bxpsi_lax_priv.h"
  #:exists 'replace
  (lambda ()
    (display code-maxwell-1d-Bx-psi-lax-priv-header)))

;; Synthesize the Gkeyll source code for a Lax-Friedrichs solver for the 1D Maxwell equations (Bx and psi components).
(define code-maxwell-1d-Bx-psi-lax-source
  (gkyl-generate-lax-friedrichs-vector2-1d-source pde-system-maxwell-1d-Bx-psi
                                                  #:nx nx
                                                  #:x0 x0
                                                  #:x1 x1
                                                  #:t-final t-final
                                                  #:cfl cfl
                                                  #:init-funcs init-funcs))

;; Output the source code to a file.
(with-output-to-file "gkyl_code/wv_maxwell_Bxpsi_lax.c"
  #:exists 'replace
  (lambda ()
    (display code-maxwell-1d-Bx-psi-lax-source)))

;; Synthesize a Gkeyll C regression test for a Lax-Friedrichs solver for the 1D Maxwell equations (Bx and psi components).
(define code-maxwell-1d-Bx-psi-lax-regression
  (gkyl-generate-lax-friedrichs-vector2-1d-regression pde-system-maxwell-1d-Bx-psi
                                                      #:nx nx
                                                      #:x0 x0
                                                      #:x1 x1
                                                      #:t-final t-final
                                                      #:cfl cfl
                                                      #:init-funcs init-funcs))

;; Output the regression test to a file.
(with-output-to-file "gkyl_code/rt_maxwell_Bxpsi_lax.c"
  #:exists 'replace
  (lambda ()
    (display code-maxwell-1d-Bx-psi-lax-regression)))

(display "Lax-Friedrichs (finite-difference) properties: \n\n")

;; Attempt to prove hyperbolicity of the Lax-Friedrichs solver for the 1D Maxwell equations (Bx and psi components).
(define proof-maxwell-1d-Bx-psi-lax-hyperbolicity
  (call-with-output-file "proofs/proof_maxwell_1d_Bx_psi_lax_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-hyperbolicity pde-system-maxwell-1d-Bx-psi
                                                       #:nx nx
                                                       #:x0 x0
                                                       #:x1 x1
                                                       #:t-final t-final
                                                       #:cfl cfl
                                                       #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_maxwell_1d_Bx_psi_lax_hyperbolicity.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-maxwell-1d-Bx-psi-lax-hyperbolicity)
(display "\n")

;; Attempt to prove strict hyperbolicity of the Lax-Friedrichs solver for the 1D Maxwell equations (Bx and psi components).
(define proof-maxwell-1d-Bx-psi-lax-strict-hyperbolicity
  (call-with-output-file "proofs/proof_maxwell_1d_Bx_psi_lax_strict_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-strict-hyperbolicity pde-system-maxwell-1d-Bx-psi
                                                              #:nx nx
                                                              #:x0 x0
                                                              #:x1 x1
                                                              #:t-final t-final
                                                              #:cfl cfl
                                                              #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_maxwell_1d_Bx_psi_lax_strict_hyperbolicity.rkt")

;; Show whether strict hyperbolicity is preserved.
(display "Strict hyperbolicity preservation: ")
(display proof-maxwell-1d-Bx-psi-lax-strict-hyperbolicity)
(display "\n")

;; Attempt to prove CFL stability of the Lax-Friedrichs solver for the 1D Maxwell equations (Bx and psi components).
(define proof-maxwell-1d-Bx-psi-lax-cfl-stability
  (call-with-output-file "proofs/proof_maxwell_1d_Bx_psi_lax_cfl_stability.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-cfl-stability pde-system-maxwell-1d-Bx-psi
                                                       #:nx nx
                                                       #:x0 x0
                                                       #:x1 x1
                                                       #:t-final t-final
                                                       #:cfl cfl
                                                       #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_maxwell_1d_Bx_psi_lax_cfl_stability.rkt")

;; Show whether CFL stability is satisfied.
(display "CFL stability: ")
(display proof-maxwell-1d-Bx-psi-lax-cfl-stability)
(display "\n")

;; Attempt to prove local Lipschitz continuity of the discrete flux function for the Lax-Friedrichs solver for the 1D Maxwell equations (Bx and psi components)
(define proof-maxwell-1d-Bx-psi-lax-local-lipschitz
  (call-with-output-file "proofs/proof_maxwell_1d_Bx_psi_lax_local_lipschitz.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-lax-friedrichs-vector2-1d-local-lipschitz pde-system-maxwell-1d-Bx-psi
                                                         #:nx nx
                                                         #:x0 x0
                                                         #:x1 x1
                                                         #:t-final t-final
                                                         #:cfl cfl
                                                         #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_maxwell_1d_Bx_psi_lax_local_lipschitz.rkt")

;; Show whether the local Lipschitz continuity property of the discrete flux function is satisfied.
(display "Local Lipschitz continuity of discrete flux function: ")
(display proof-maxwell-1d-Bx-psi-lax-local-lipschitz)
(display "\n\n\n")

;; Synthesize the Gkeyll header code for a Roe solver for the 1D Maxwell equations (Bx and psi components).
(define code-maxwell-1d-Bx-psi-roe-header
  (gkyl-generate-roe-vector2-1d-header pde-system-maxwell-1d-Bx-psi
                                       #:nx nx
                                       #:x0 x0
                                       #:x1 x1
                                       #:t-final t-final
                                       #:cfl cfl
                                       #:init-funcs init-funcs))

;; Output the header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_maxwell_Bxpsi_roe.h"
  #:exists 'replace
  (lambda ()
    (display code-maxwell-1d-Bx-psi-roe-header)))

;; Synthesize the Gkeyll private header code for a Roe solver for the 1D Maxwell equations (Bx and psi components).
(define code-maxwell-1d-Bx-psi-roe-priv-header
  (gkyl-generate-roe-vector2-1d-priv-header pde-system-maxwell-1d-Bx-psi
                                            #:nx nx
                                            #:x0 x0
                                            #:x1 x1
                                            #:t-final t-final
                                            #:cfl cfl
                                            #:init-funcs init-funcs))

;; Output the private header code to a file.
(with-output-to-file "gkyl_code/gkyl_wv_maxwell_Bxpsi_roe_priv.h"
  #:exists 'replace
  (lambda ()
    (display code-maxwell-1d-Bx-psi-roe-priv-header)))

;; Synthesize the Gkeyll source code for a Roe solver for the 1D Maxwell equations (Bx and psi components).
(define code-maxwell-1d-Bx-psi-roe-source
  (gkyl-generate-roe-vector2-1d-source pde-system-maxwell-1d-Bx-psi
                                       #:nx nx
                                       #:x0 x0
                                       #:x1 x1
                                       #:t-final t-final
                                       #:cfl cfl
                                       #:init-funcs init-funcs))

;; Output the source code to a file.
(with-output-to-file "gkyl_code/wv_maxwell_Bxpsi_roe.c"
  #:exists 'replace
  (lambda ()
    (display code-maxwell-1d-Bx-psi-roe-source)))

;; Synthesize a Gkeyll C regression test for a Roe solver for the 1D Maxwell equations (Bx and psi components).
(define code-maxwell-1d-Bx-psi-roe-regression
  (gkyl-generate-roe-vector2-1d-regression pde-system-maxwell-1d-Bx-psi
                                           #:nx nx
                                           #:x0 x0
                                           #:x1 x1
                                           #:t-final t-final
                                           #:cfl cfl
                                           #:init-funcs init-funcs))

;; Output the regression test to a file.
(with-output-to-file "gkyl_code/rt_maxwell_Bxpsi_roe.c"
  #:exists 'replace
  (lambda ()
    (display code-maxwell-1d-Bx-psi-roe-regression)))


(display "Roe (finite-volume) properties: \n\n")

;; Attempt to prove hyperbolicity of the Roe solver for the 1D Maxwell equations (Bx and psi components).
(define proof-maxwell-1d-Bx-psi-roe-hyperbolicity
  (call-with-output-file "proofs/proof_maxwell_1d_Bx_psi_roe_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-hyperbolicity pde-system-maxwell-1d-Bx-psi
                                            #:nx nx
                                            #:x0 x0
                                            #:x1 x1
                                            #:t-final t-final
                                            #:cfl cfl
                                            #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_maxwell_1d_Bx_psi_roe_hyperbolicity.rkt")

;; Show whether hyperbolicity is preserved.
(display "Hyperbolicity preservation: ")
(display proof-maxwell-1d-Bx-psi-roe-hyperbolicity)
(display "\n")

;; Attempt to prove strict hyperbolicity of the Roe solver for the 1D Maxwell equations (Bx and psi components).
(define proof-maxwell-1d-Bx-psi-roe-strict-hyperbolicity
  (call-with-output-file "proofs/proof_maxwell_1d_Bx_psi_roe_strict_hyperbolicity.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-strict-hyperbolicity pde-system-maxwell-1d-Bx-psi
                                                   #:nx nx
                                                   #:x0 x0
                                                   #:x1 x1
                                                   #:t-final t-final
                                                   #:cfl cfl
                                                   #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_maxwell_1d_Bx_psi_roe_strict_hyperbolicity.rkt")

;; Show whether strict hyperbolicity is preserved.
(display "Strict hyperbolicity preservation: ")
(display proof-maxwell-1d-Bx-psi-roe-strict-hyperbolicity)
(display "\n")

;; Attempt to prove flux conservation (jump continuity) of the Roe solver for the 1D Maxwell equations (Bx and psi components).
(define proof-maxwell-1d-Bx-psi-roe-flux-conservation
  (call-with-output-file "proofs/proof_maxwell_1d_Bx_psi_roe_flux_conservation.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n")
        (display "(require \"../prover_vector.rkt\")\n\n")
        (prove-roe-vector2-1d-flux-conservation pde-system-maxwell-1d-Bx-psi
                                                #:nx nx
                                                #:x0 x0
                                                #:x1 x1
                                                #:t-final t-final
                                                #:cfl cfl
                                                #:init-funcs init-funcs)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_maxwell_1d_Bx_psi_roe_flux_conservation.rkt")

;; Show whether flux conservation (jump continuity) is preserved.
(display "Flux conservation (jump continuity): ")
(display proof-maxwell-1d-Bx-psi-roe-flux-conservation)
(display "\n")