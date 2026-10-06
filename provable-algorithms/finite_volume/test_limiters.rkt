#lang racket

(require "code_generator_core.rkt")
(require "prover_core.rkt")
(provide (all-from-out "code_generator_core.rkt"))

;; Construct /proofs output directory if it does not already exist.
(cond
  [(not (directory-exists? "proofs")) (make-directory "proofs")])

;; Define the minmod flux limiter.
(define limiter-minmod
  (hash
   'name "minmod"
   'limiter-expr `(max 0.0 (min 1.0 r))
   'limiter-ratio `r
   ))

(display "Minmod flux limiter properties: \n\n")

;; Attempt to prove symmetry (equivalent action on forward and backward gradients) of the minmod flux limiter.
(define proof-limiter-minmod-symmetry
  (call-with-output-file "proofs/proof_limiter_minmod_symmetry.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-flux-limiter-symmetry limiter-minmod)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_limiter_minmod_symmetry.rkt")

;; Show whether the symmetry (equivalent action on forward and backward gradients) property is satisfied.
(display "Symmetric (equivalent action on forward and backward gradients): ")
(display proof-limiter-minmod-symmetry)
(display "\n")

;; Attempt to prove second-order TVD (total variation diminishing) of the minmod flux limiter.
(define proof-limiter-minmod-tvd
  (call-with-output-file "proofs/proof_limiter_minmod_tvd.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-flux-limiter-tvd limiter-minmod)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_limiter_minmod_tvd.rkt")

;; Show whether the second-order TVD (total variation diminishing) property is satisfied.
(display "Second-order TVD (total variation diminishing): ")
(display proof-limiter-minmod-tvd)
(display "\n\n\n")

;; Define the superbee flux limiter.
(define limiter-superbee
  (hash
   'name "superbee"
   'limiter-expr `(max 0.0 (min (* 2.0 r) 1.0) (min r 2.0))
   'limiter-ratio `r
   ))

(display "Superbee flux limiter properties: \n\n")

;; Attempt to prove symmetry (equivalent action on forward and backward gradients) of the superbee flux limiter.
(define proof-limiter-superbee-symmetry
  (call-with-output-file "proofs/proof_limiter_superbee_symmetry.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-flux-limiter-symmetry limiter-superbee)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_limiter_superbee_symmetry.rkt")

;; Show whether the symmetry (equivalent action on forward and backward gradients) property is satisfied.
(display "Symmetric (equivalent action on forward and backward gradients): ")
(display proof-limiter-superbee-symmetry)
(display "\n")

;; Attempt to prove second-order TVD (total variation diminishing) of the superbee flux limiter.
(define proof-limiter-superbee-tvd
  (call-with-output-file "proofs/proof_limiter_superbee_tvd.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-flux-limiter-tvd limiter-superbee)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_limiter_superbee_tvd.rkt")

;; Show whether the second-order TVD (total variation diminishing) property is satisfied.
(display "Second-order TVD (total variation diminishing): ")
(display proof-limiter-superbee-tvd)
(display "\n\n\n")

;; Define the monotonized-centered flux limiter.
(define limiter-monotonized-centered
  (hash
   'name "monotonized-centered"
   'limiter-expr `(max 0.0 (min (* 2.0 r) (/ (+ 1.0 r) 2.0) 2.0))
   'limiter-ratio `r
   ))

(display "Monotonized-centered flux limiter properties: \n\n")

;; Attempt to prove symmetry (equivalent action on forward and backward gradients) of the monotonized-centered flux limiter.
(define proof-limiter-monotonized-centered-symmetry
  (call-with-output-file "proofs/proof_limiter_monotonized_centered_symmetry.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-flux-limiter-symmetry limiter-monotonized-centered)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_limiter_monotonized_centered_symmetry.rkt")

;; Show whether the symmetry (equivalent action on forward and backward gradients) property is satisfied.
(display "Symmetric (equivalent action on forward and backward gradients): ")
(display proof-limiter-monotonized-centered-symmetry)
(display "\n")

;; Attempt to prove second-order TVD (total variation diminishing) of the monotonized-centered flux limiter.
(define proof-limiter-monotonized-centered-tvd
  (call-with-output-file "proofs/proof_limiter_monotonized_centered_tvd.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-flux-limiter-tvd limiter-monotonized-centered)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_limiter_monotonized_centered_tvd.rkt")

;; Show whether the second-order TVD (total variation diminishing) property is satisfied.
(display "Second-order TVD (total variation diminishing): ")
(display proof-limiter-monotonized-centered-tvd)
(display "\n\n\n")

;; Define the van Leer flux limiter.
(define limiter-van-leer
  (hash
   'name "van-leer"
   'limiter-expr `(/ (+ r (abs r)) (+ 1.0 (abs r)))
   'limiter-ratio `r
   ))

(display "Van Leer flux limiter properties: \n\n")

;; Attempt to prove symmetry (equivalent action on forward and backward gradients) of the van Leer flux limiter.
(define proof-limiter-van-leer-symmetry
  (call-with-output-file "proofs/proof_limiter_van_leer_symmetry.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-flux-limiter-symmetry limiter-van-leer)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_limiter_van_leer_symmetry.rkt")

;; Show whether the symmetry (equivalent action on forward and backward gradients) property is satisfied.
(display "Symmetric (equivalent action on forward and backward gradients): ")
(display proof-limiter-van-leer-symmetry)
(display "\n")

;; Attempt to prove second-order TVD (total variation diminishing) of the van Leer flux limiter.
(define proof-limiter-van-leer-tvd
  (call-with-output-file "proofs/proof_limiter_van_leer_tvd.rkt"
    (lambda (out)
      (parameterize ([current-output-port out] [pretty-print-columns `infinity])
        (display "#lang racket\n\n")
        (display "(require \"../prover_core.rkt\")\n\n")
        (prove-flux-limiter-tvd limiter-van-leer)))
    #:exists `replace))
(remove-bracketed-expressions-from-file "proofs/proof_limiter_van_leer_tvd.rkt")

;; Show whether the second-order TVD (total variation diminishing) property is satisfied.
(display "Second-order TVD (total variation diminishing): ")
(display proof-limiter-van-leer-tvd)
(display "\n\n\n")