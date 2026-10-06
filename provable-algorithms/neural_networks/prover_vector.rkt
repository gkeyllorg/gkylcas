#lang racket

(require racket/trace)
(current-prefix-in " ")
(current-prefix-out " ")

(provide symbolic-diff
         symbolic-simp-rule
         symbolic-simp
         is-real
         symbolic-diff-order
         symbolic-jacobian-order
         symbolic-jacobian
         symbolic-eigvals2
         symbolic-eigvals3
         prove-vector2-1d-smooth
         prove-vector2-1d-non-smooth
         prove-vector3-2d-smooth
         prove-vector3-2d-non-smooth)

;; Lightweight symbolic differentiator (differentiates expr with respect to var).
(define (symbolic-diff expr var)
  (match expr
    ;; If expr is a symbol, then it either differentiates to 1 (if it's equal to var), or 0 otherwise.
    [(? symbol? symb) (cond
                        [(eq? symb var) 1.0]
                        [else 0.0])]

    ;; If expr is a numerical constant, then it differentiates to 0.
    [(? number?) 0.0]

    ;; If expr is a sum of the form (+ expr1 expr2 ...), then it differentiates to a sum of derivatives (+ expr1' expr2' ...), by linearity.
    [`(+ . ,terms)
     `(+ ,@(map (lambda (term) (symbolic-diff term var)) terms))]
    ;; Likewise for differences of the form (- expr1 expr2 ...), which differentiate to (- expr1' expr2' ...), by linearity.
    [`(- . ,terms)
     `(- ,@(map (lambda (term) (symbolic-diff term var)) terms))]

    ;; If expr is a product of the form (* expr1 expr2 ...), then it differentiates to (+ (* expr1' expr2 ...) (* expr1 expr2' ...) ...), by the product rule.
    [`(* . ,terms)
     (define n (length terms))
     (define (mult xs) (cons '* xs)) ; Multiplication helper function.

     ((lambda (sums) (cond
                      [(null? (cdr sums)) (car sums)]
                      [else (cons '+ sums)]))
      (let loop ([i 0])
        (cond
          [(= i n) `()]
          [else
           ;; Evaluate the derivative of the i-th term in the product.
           (let ([di (symbolic-diff (list-ref terms i) var)])
             (cons
              (mult (for/list ([j (in-range n)])
                      (cond
                        [(= j i) di]
                        [else (list-ref terms j)])))
              (loop (add1 i))))])))]

    ;; If expr is a quotient of the form (/ expr1 expr2), then it differentiates to (/ (- (* expr2 expr1') (expr1 expr2') (* expr2 expr2)), by the quotient rule.
    [`(/ ,x ,y)
     `(/ (- (* ,y ,(symbolic-diff x var)) (* ,x ,(symbolic-diff y var))) (* ,y ,y))]

    ;; If expr is an absolute value of the form (abs expr1), then it differentiates to (sgn expr1').
    [`(abs ,arg)
     `(* (sgn ,arg) ,(symbolic-diff arg var))]

    ;; If expr is a sign function of the form (sgn expr1), then it differentiates to 0.0.
    [`(sgn ,arg) 0.0]
    
    ;; Otherwise, return false.
    [else #f]))

;; Lightweight symbolic simplification rules (simplifies expr using only correctness-preserving algebraic transformations).
(define (symbolic-simp-rule expr)
  (match expr    
    ;; If expr is of the form (0 + x) or (0.0 + x), then simplify to x.
    [`(+ 0 ,x) `,x]
    [`(+ 0.0 ,x) `,x]
    [`(+ -0.0 ,x) `,x]

    ;; If expr is of the form (1 * x) or (1.0 * x), then simplify to x.
    [`(* 1 ,x) `,x]
    [`(* 1.0 ,x) `,x]

    ;; If expr is of the form (0 * x) or (0.0 * x), then simplify to 0 or 0.0.
    [`(* 0 ,x) 0]
    [`(* 0.0 ,x) 0.0]
    [`(* -0.0 ,x) 0.0]

    ;; If expr is of the form (x - 0) or (x - 0.0), then simplify to x.
    [`(- ,x 0) `,x]
    [`(- ,x 0.0) `,x]
    [`(- ,x -0.0) `,x]

    ;; If expr is of the form (0 - x) or (0.0 - x), then simplify to (-1 * x) or (-1.0 * x).
    [`(- 0 ,x) `(* -1 ,x)]
    [`(- 0.0 ,x) `(* -1.0 ,x)]
    [`(- -0.0 ,x) `(* -1.0 ,x)]

    ;; If expr is of the form (x / 1) or (x / 1.0), then simplify to x.
    [`(/ ,x 1) `,x]
    [`(/ ,x 1.0) `,x]

    ;; Enforce right associativity of addition: if expr is of the form ((x + y) + z) or (x + y + z), then simplify to (x + (y + z)).
    [`(+ (+ ,x ,y) ,z) `(+ ,x (+ ,y ,z))]
    [`(+ ,x ,y ,z) `(+ (+ ,x ,y) ,z)]

    ;; Enforce right associativity of multiplication: if expr is of the form ((x * y) * z) or (x * y * z), then simplify to (x * (y * z)).
    [`(* (* ,x ,y) ,z) `(* ,x (* ,y ,z))]
    [`(* ,x ,y ,z) `(* (* ,x ,y) ,z)]

    ;; If expr is of the form (x + y) for numeric x and y, then just evaluate the sum. Likewise for differences.
    [`(+ ,(and x (? number?)) ,(and y (? number?))) (+ x y)]
    [`(- ,(and x (? number?)) ,(and y (? number?))) (- x y)]

    ;; If expr is of the form (x * y) for numeric x and y, then just evaluate the product. Likewise for quotients
    [`(* ,(and x (? number?)) ,(and y (? number?))) (* x y)]
    [`(/ ,(and x (? number?)) ,(and y (? number?))) (/ x y)]

    ;; If expr is of the form (x * (y + z)) for numeric x, y and z, then just evaluate the product and sum.
    [`(* ,(and x (? number?)) (+ ,(and y (? number?)) ,(and z (? number?)))) (* x (+ y z))]

    ;; If expr is of the form ((x - y) * (x - y)), then simplify to (((x * x) + (y * y)) - (2 * (x * y))).
    [`(* (- ,x ,y) (- ,x ,y)) `(- (+ (* ,x ,x) (* ,y ,y)) (* 2.0 (* ,x ,y)))]

    ;; If expr is of the form ((a / b) * (c / d)), then simplify to ((a * c) / (b * d)).
    [`(* (/ ,a ,b) (/ ,c ,d)) `(/ (* ,a ,c) (* ,b ,d))]

    ;; If expr is of the form ((a * (b * c)) / (c * d)), then simplify to ((a * b) / d).
    [`(/ (* ,a (* ,b ,c)) (* ,c ,d)) `(/ (* ,a ,b) ,d)]

    ;; If expr is of the form ((a * b) + (c - (d * b))), then simplify to (((a - d) * b) + c).
    [`(+ (* ,a ,b) (- ,c (* ,d ,b))) `(+ (* (- ,a ,d) ,b) ,c)]

    ;; If expr is of the form ((a - b) * x) for symbolic x, then simplify to (x * (a - b)).
    [`(* (- ,a ,b) ,(and x (? symbol?))) `(* ,x (- ,a ,b))]

    ;; Enforce (reverse) distributive property: if expr is a sum of the form ((a * x) + (b * x)), then simplify to ((a + b) * x).
    [`(+ (* ,a, x) (* ,b ,x)) `(* (+ ,a ,b) ,x)]
    ;; Likewise for differences.
    [`(- (* ,a, x) (* ,b ,x)) `(* (- ,a ,b) ,x)]

    ;; If expr is of the form (x * (y * z)) for numeric numeric x and y, then evaluate the product of x and y.
    [`(* ,(and x (? number?)) (* ,(and y (? number?)) ,z)) `(* ,(* x y) ,z)]

    ;; Move numbers to the left: if expr is of the form (x + y) for non-numeric x but numeric y, then simplify to (y + x).
    [`(+ ,(and x (not (? number?))) ,(and y (? number?))) `(+ ,y ,x)]

    ;; Move numbers to the left: if expr is of the form (x * y) for non-numeric x but numeric y, then simplify to (y * x).
    [`(* ,(and x (not (? number?))) ,(and y (? number?))) `(* ,y ,x)]

    ;; If expr is of the form sqrt(x * x) or (sqrt(x) * sqrt(x)), then simplify to x.
    [`(sqrt (* ,x ,x)) `,x]
    [`(* (sqrt ,x) (sqrt ,x)) `,x]

    ;; If expr is of the form (sqrt(x) * (y * sqrt(x))), then simplify to (y * x).
    [`(* (sqrt,x) (* ,y (sqrt ,x))) `(* ,y ,x)]
    ;; Likewise, if expr is of the form (sqrt(x) * (sqrt(x) * y)), then simplify to (x * y).
    [`(* (sqrt,x) (* (sqrt ,x) ,y)) `(* ,x ,y)]

    ;; If expr is of the form sqrt(x * y), then simplify to (sqrt(x) * sqrt(y)).
    [`(sqrt (* ,x ,y)) `(* (sqrt ,x) (sqrt ,y))]

    ;; If expr if of the form sqrt(x) for numeric x, then just evaluate the square root.
    [`(sqrt ,(and x (? number?))) (sqrt x)]

    ;; If expr is of the form max(x, y) or min(x, y) for numeric x and y, then just evaluate the maximum/minimum.
    [`(max ,(and x (? number?)) ,(and y (? number?))) (max x y)]
    [`(min ,(and x (? number?)) ,(and y (? number?))) (min x y)]

    ;; If expr is of the form abs(x) for numeric x, then just evaluate the absolute value.,
    [`(abs ,(and x (? number?))) (abs x)]

    ;; If expr is of the form abs(-1 * x) or abs(-1.0 * x), then simplify to abs(x).
    [`(abs (* -1 ,x)) `(abs ,x)]
    [`(abs (* -1.0 ,x)) `(abs ,x)]

    ;; If expr is of the form (0 - (x * y)) or (0.0 - (x * y)), then simplify to ((0 - x) * y) or ((0.0 - x) * y).
    [`(- 0 (* ,x ,y)) `(* (- 0 ,x) ,y)]
    [`(- 0.0 (* ,x ,y)) `(* (- 0.0 ,x) ,y)]
    [`(- -0.0 (* ,x ,y)) `(* (- 0.0 ,x) ,y)]

    ;; If expr is of the form (x + x), thens implify to (2.0 * x).
    [`(+ ,x ,x) `(* 2.0 ,x)]

    ;; If expr is of the form ((x * y) / (x * z)), then simplify to (y / z).
    [`(/ (* ,x ,y) (* ,x ,z)) `(/ ,y ,z)]

    ;; If expr is of the form ((x / y) * (x / y)), then simplify to ((x * x) / (y * y)).
    [`(* (/ ,x ,y) (/ ,x ,y)) `(/ (* ,x ,x) (* ,y ,y))]

    ;; If expr is of the form (x * (y * z)) for numeric y and non-numeric x and z, then simplify to (y * (x * z)).
    [`(* ,(and x (not (? number?))) (* ,(and y (? number?)) ,(and z (not (? number?))))) `(* ,y (* ,x ,z))]

    ;; Enforce distributive property: if expr is of the form (x * (a + b)), then simplify to ((x * a) + (x * b)).
    [`(* ,x (+ ,a ,b)) `(+ (* ,x ,a) (* ,x ,b))]

    ;; If expr is of the form (x * (-y / z)), then simplify to (-x * (y / z)).
    [`(* ,x (/ (* -1 ,y) ,z)) `(* (* -1 ,x) (/ ,y ,z))]
    [`(* ,x (/ (* -1.0 ,y) ,z)) `(* (* -1.0 ,x ) (/ ,y ,z))]

    ;; If expr is of the form ((x * y) / z) for numeric x, then simplify to (x * (y / z)).
    [`(/ (* ,(and x (? number?)) ,y) ,z) `(* ,x (/ ,y ,z))]

    ;; If expr is of the form ((a * x) + (y + (b * x))) for numeric a and b, then simplify to (((a + b) * x) + y).
    [`(+ (* ,(and a (? number?)) ,x) (+ ,y (* ,(and b (? number?)) ,x))) `(+ (* (+ ,a ,b) ,x) ,y)]

    ;; If expr is of the form (a + (x / y)) or (-a + (x / y)) for symbolic a, then simplify to ((x / y) + a) or ((x / y) - a).
    [`(+ ,(and a (? symbol?)) (/ ,x ,y)) `(+ (/ ,x ,y) ,a)]
    [`(+ (* -1 ,(and a (? symbol?))) (/ ,x ,y)) `(- (/ ,x ,y) ,a)]
    [`(+ (* -1.0 ,(and a (? symbol?))) (/ ,x ,y)) `(- (/ ,x ,y) ,a)]

    ;; Enforce (reverse) distributive property: if expr is of the form ((a * x) - (a * y)), then simplify to (a * (x - y)).
    [`(- (* ,a ,x) (* ,a ,y)) `(* ,a (- ,x ,y))]

    ;; If expr is of the form (((a * x) + (a * y)) * (x - y)), then simplify to ((a * (x * x)) - (a * (y * y))).
    [`(* (+ (* ,a ,x) (* ,a ,y)) (- ,x ,y)) `(- (* ,a (* ,x ,x)) (* ,a (* ,y ,y)))]

    ;; If expr is of the form (0 / x) or (0.0 / x), then simplify to 0 or 0.0.
    [`(/ 0 ,x) 0]
    [`(/ 0.0 ,x) 0.0]
    [`(/ -0.0 ,x) 0.0]

    ;; If expr is of the form (x / x), then simplify to 1.0
    [`(/ ,x ,x) 1.0]

    ;; If expr is of the form (x * (y / z)) for numeric x and y, then evaluate the product to yield ((x * y) / z).
    [`(* ,(and x (? number?)) (/ ,(and y (? number?)) ,z)) `(/ ,(* x y) ,z)]
    ;; Likewise, if expr is of the form ((x / y) / z) for numeric x and z, then evaluate the quotient to yield ((x / z) / y).
    [`(/ (/ ,(and x (? number?)) ,y) ,(and z (? number?))) `(/ ,(/ x z) ,y)]

    ;; If expr is of the form ((x / y) / x), then simplify to (1.0 / y).
    [`(/ (/ ,x ,y) ,x) `(/ 1.0 ,y)]

    ;; If expr is of the form ((x / y) / (z + (x / y))), or ((x / y) / ((x / y) + z), then simplify to (x / ((z * y) + x)) or (x / (x + (z * y))).
    [`(/ (/ ,x ,y) (+ ,z (/ ,x ,y))) `(/ ,x (+ (* ,z ,y) ,x))]
    [`(/ (/ ,x ,y) (+ (/ ,x ,y) ,z)) `(/ ,x (+ ,x (* ,z ,y)))]

    ;; If expr is of the form ((x + y) / z) or ((x - y) / z), then simplify to ((x / z) + (y / z)) or ((x / z) - (y / z)).
    [`(/ (+ ,x ,y) ,z) `(+ (/ ,x ,z) (/ ,y ,z))]
    [`(/ (- ,x ,y) ,z) `(- (/ ,x ,z) (/ ,y ,z))]

    ;; If expr is a sum of the form (x + y + ...), then apply symbolic simplification to each term x, y, ... in the sum.
    [`(+ . ,terms)
     `(+ ,@(map (lambda (term) (symbolic-simp-rule term)) terms))]
    ;; Likewise for differences.
    [`(- . ,terms)
     `(- ,@(map (lambda (term) (symbolic-simp-rule term)) terms))]

    ;; If expr is a product of the form (x * y * ...), then apply symbolic simplification to each term x, y, ... in the product.
    [`(* . ,terms)
     `(* ,@(map (lambda (term) (symbolic-simp-rule term)) terms))]
    ;; Likewise for quotients.
    [`(/ . ,terms)
     `(/ ,@(map (lambda (term) (symbolic-simp-rule term)) terms))]

    ;; If expr is of the form sqrt(expr1), then apply symbolic simplification to the interior expr1.
    [`(sqrt ,arg)
     `(sqrt ,(symbolic-simp-rule arg))]

    ;; If expr is of the form abs(expr1), then apply symbolic simplification to the interior expr1.
    [`(abs ,arg)
     `(abs ,(symbolic-simp-rule arg))]

    ;; If expr is of the form max(x, y, z) or min(x, y, z), then simplify to max(max(x, y), z) or min(min(x, y), z).
    [`(max ,x ,y ,z) `(max (max ,x ,y) ,z)]
    [`(min ,x ,y ,z) `(min (min ,x ,y) ,z)]

    ;; If expr is of the form max(x, y), then simplify to ((0.5 * (x + y)) + (0.5 * abs(x - y))).
    [`(max ,x ,y) `(+ (* 0.5 (+ ,x ,y)) (* 0.5 (abs (- ,x ,y))))]

    ;; If expr is of the form min(x, y), then simplify to ((0.5 * (x + y)) - (0.5 * abs(x - y))).
    [`(min ,x ,y) `(- (* 0.5 (+ ,x ,y)) (* 0.5 (abs (- ,x ,y))))]

    ;; If expr is a complex number whose imaginary part is equal to 0.0 or -0.0, then simplify to Re(expr).
    [(? (lambda (arg)
         (and (number? arg) (not (real? arg )) (equal? (imag-part arg) 0.0)))) (real-part expr)]
    [(? (lambda (arg)
         (and (number? arg) (not (real? arg )) (equal? (imag-part arg) -0.0)))) (real-part expr)]

    ;; If expr is of the form expt(x, y) for numeric x and y, then just evaluate the exponential.
    [`(expt ,(and x (? number?)) ,(and y (? number?))) (expt x y)]
    ;; If expr is of the form expt(expr1, expr2), then apply symbolic simplification to the interior expr1 and expr2.
    [`(expt ,x ,y) `(expt ,(symbolic-simp-rule x) ,(symbolic-simp-rule y))]

    ;; If expr is of the form (x < y) for numeric x and y, then just evaluate the comparison operator.
    [`( < ,(and x (? number?)) ,(and y (? number?))) (< x y)]
    ;; If expr is of the form (expr1 < expr2), then apply symbolic simplification to the interior expr1 and expr2.
    [`(< ,x ,y) `(< ,(symbolic-simp-rule x) ,(symbolic-simp-rule y))]
    
    ;; Otherwise, return the expression.
    [else expr]))

;; Recursively apply the symbolic simplification rules until the expression stops changing (fixed point).
(define (symbolic-simp expr)
  (define simp-expr (symbolic-simp-rule expr))
  
  (cond
    [(equal? simp-expr expr) expr]
    [else (symbolic-simp simp-expr)]))

;; Recursively determine whether an expression corresponds to a real number.
(define (is-real expr cons-vars parameters)
  (match expr
    ;; Real numbers are trivially real.
    [(? real?) #t]

    ;; Conserved variables are assumed to be real (this is enforced elsewhere).
    [(? (lambda (arg)
          (not (equal? (member arg cons-vars) #f)))) #t]

    ;; Simulation parameters are assumed to be real (this is enforced elsewhere).
    [(? (lambda (arg)
          (and (not (empty? parameters)) (ormap (lambda (parameter)
                                                  (equal? arg (list-ref parameter 1))) parameters)))) #t]

    ;; The outcome of a conditional operation is real if both branches yield real numbers.
    [`(cond
        [,cond1 ,expr1]
        [else ,expr2])
     (and (is-real expr1 cons-vars parameters) (is-real expr2 cons-vars parameters))]

    ;; The sum, difference, product, or quotient of two real numbers is always real.
    [`(+ . ,terms)
     (andmap (lambda (term) (is-real term cons-vars parameters)) terms)]
    [`(- . ,terms)
     (andmap (lambda (term) (is-real term cons-vars parameters)) terms)]
    [`(* . ,terms)
     (andmap (lambda (term) (is-real term cons-vars parameters)) terms)]
    [`(/ . ,terms)
     (andmap (lambda (term) (is-real term cons-vars parameters)) terms)]

    ;; Otherwise, assume false.
    [else #f]))

;; Recursively differentiate expr with respect to var until the result is 0, and return the necessary order of differentiation.
(define (symbolic-diff-order expr var order)
  (define diff-expr (symbolic-simp (symbolic-diff expr var)))

  (cond
    [(or (equal? diff-expr 0.0) (equal? diff-expr 0)) (+ order 1)]
    [(> order 1) +inf.0]
    [else (symbolic-diff-order diff-expr var (+ order 1))]))

;; Recursively differentiate each component of exprs with respect to each component of vars until the results are 0, and return the necessary orders of differentiation.
(define (symbolic-jacobian-order exprs vars)
  (map (lambda (expr)
         (map (lambda (var)
                (symbolic-diff-order expr var 0))
              vars))
       exprs))

;; Compute symbolic Jacobian matrix by mapping symbolic differentiation over exprs with respect to vars.
(define (symbolic-jacobian exprs vars)
  (map (lambda (expr)
         (map (lambda (var)
                (symbolic-simp (symbolic-diff expr var)))
              vars))
       exprs))

;; Compute symbolic eigenvalues of a 2x2 symbolic matrix via explicit solution of the characteristic polynomial.
(define (symbolic-eigvals2 matrix)
  (let ([a (list-ref (list-ref matrix 0) 0)]
        [b (list-ref (list-ref matrix 0) 1)]
        [c (list-ref (list-ref matrix 1) 0)]
        [d (list-ref (list-ref matrix 1) 1)])
    (cond
      ;; Optimization to shorten certain proofs: if the matrix consists solely of zeroes, then just output a pair of zeroes.
      [(and (equal? a 0.0) (equal? b 0.0) (equal? c 0.0) (equal? d 0.0)) (list 0.0 0.0)]

      ;; Otherwise, calculate the eigenvalues explicitly.
      [else (list `(* 0.5 (+ (- ,a (sqrt (+ (* 4.0 ,b ,c) (* (- ,a ,d) (- ,a ,d))))) ,d))
                  `(* 0.5 (+ (+ ,a (sqrt (+ (* 4.0 ,b ,c) (* (- ,a ,d) (- ,a ,d))))) ,d)))])))

;; Compute symbolic eigenvalues of a 3x3 symbolic matrix (in restricted cases) via explicit solution of the characteristic polynomial.
(define (symbolic-eigvals3 matrix)
  (let ([a (list-ref (list-ref matrix 0) 0)]
        [b (list-ref (list-ref matrix 0) 1)]
        [c (list-ref (list-ref matrix 0) 2)]
        [d (list-ref (list-ref matrix 1) 0)]
        [e (list-ref (list-ref matrix 1) 1)]
        [f (list-ref (list-ref matrix 1) 2)]
        [g (list-ref (list-ref matrix 2) 0)]
        [h (list-ref (list-ref matrix 2) 1)]
        [i (list-ref (list-ref matrix 2) 2)])
    (cond
      ;; Optimization to shorten certain proofs: if the matrix consists solely of zeroes, then just output a triple of zeroes.
      [(and (equal? a 0.0) (equal? b 0.0) (equal? c 0.0) (equal? d 0.0) (equal? e 0.0) (equal? f 0.0) (equal? g 0.0) (equal? h 0.0) (equal? i 0.0)) (list 0.0 0.0 0.0)]

      ;; If the matrix is in a restricted (tractable) form, calculate the eigenvalues explicitly.
      [(and (equal? a 0.0) (equal? b 1.0) (equal? c 0.0) (equal? f 0.0))
       (list `(* 0.5 (- ,e (sqrt (+ (* 4.0 ,d) (* ,e ,e))))) `(* 0.5 (+ ,e (sqrt (+ (* 4.0 ,d) (* ,e ,e))))) i)]
      [(and (equal? a 0.0) (equal? b 0.0) (equal? c 1.0) (equal? h 0.0))
       (list e `(* 0.5 (- ,i (sqrt (+ (* 4.0 ,g) (* ,i ,i))))) `(* 0.5 (+ ,i (sqrt (+ (* 4.0 ,g) (* ,i ,i))))))]

      ;; Otherwise, return false(s).
      [else (list #f #f #f)])))

;; -----------------------------------------------------------------------------------------------------------------
;; Prove Error Bounds on Smooth Solutions for an Arbitrary Surrogate Solver for a 1D Coupled Vector System of 2 PDEs
;; -----------------------------------------------------------------------------------------------------------------
(define (prove-vector2-1d-smooth pde-system neural-net
                                 #:nx [nx 200]
                                 #:x0 [x0 0.0]
                                 #:x1 [x1 2.0]
                                 #:t-final [t-final 1.0]
                                 #:cfl [cfl 0.95]
                                 #:init-funcs [init-funcs (list
                                                           `(cond
                                                              [(< x 0.5) 3.0]
                                                              [else 1.0])
                                                           `(cond
                                                              [(< x 0.5) 1.5]
                                                              [else 0.0]))])
   "Attempt to prove an analytic error bound on smooth solutions for an arbitrary surrogate solver for the 1D coupled vector system of 2 PDEs specified by `pde-system`,
    with neural network architecture `neural-net`.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (define width (hash-ref neural-net 'width))
  (define depth (hash-ref neural-net 'depth))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-diff-order)
  (trace symbolic-jacobian-order)

  (define flux-jacobian-order (symbolic-jacobian-order flux-exprs cons-exprs))
  
  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) (list cons-exprs) parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]

    ;; Check whether the neural network depth is at least equal to 2 + the order of each component of the Jacobian of the flux function: if so, return the bounds;
    ;; otherwise, return false.
    [else (list (cond
                  [(not (equal? (symbolic-simp `(< ,depth (+ 2 ,(list-ref (list-ref flux-jacobian-order 0) 0)))) #f)) +inf.0]
                  [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 2 ,(list-ref (list-ref flux-jacobian-order 0) 0))))))])
                (cond
                  [(not (equal? (symbolic-simp `(< ,depth (+ 2 ,(list-ref (list-ref flux-jacobian-order 0) 1)))) #f)) +inf.0]
                  [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 2 ,(list-ref (list-ref flux-jacobian-order 0) 1))))))])
                (cond
                  [(not (equal? (symbolic-simp `(< ,depth (+ 2 ,(list-ref (list-ref flux-jacobian-order 1) 0)))) #f)) +inf.0]
                  [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 2 ,(list-ref (list-ref flux-jacobian-order 1) 0))))))])
                (cond
                  [(not (equal? (symbolic-simp `(< ,depth (+ 2 ,(list-ref (list-ref flux-jacobian-order 1) 1)))) #f)) +inf.0]
                  [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 2 ,(list-ref (list-ref flux-jacobian-order 1) 1))))))]))]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-diff-order)
  (untrace symbolic-jacobian-order)
  
  out)
(trace prove-vector2-1d-smooth)

;; ---------------------------------------------------------------------------------------------------------------------
;; Prove Error Bounds on Non-Smooth Solutions for an Arbitrary Surrogate Solver for a 1D Coupled Vector System of 2 PDEs
;; ---------------------------------------------------------------------------------------------------------------------
(define (prove-vector2-1d-non-smooth pde-system neural-net
                                     #:nx [nx 200]
                                     #:x0 [x0 0.0]
                                     #:x1 [x1 2.0]
                                     #:t-final [t-final 1.0]
                                     #:cfl [cfl 0.95]
                                     #:init-funcs [init-funcs (list
                                                               `(cond
                                                                  [(< x 0.5) 3.0]
                                                                  [else 1.0])
                                                               `(cond
                                                                  [(< x 0.5) 1.5]
                                                                  [else 0.0]))])
   "Attempt to prove an analytic error bound on non-smooth solutions for an arbitrary surrogate solver for the 1D coupled vector system of 2 PDEs specified by `pde-system`,
    with neural network architecture `neural-net`.
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (define width (hash-ref neural-net 'width))
  (define depth (hash-ref neural-net 'depth))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-diff-order)
  (trace symbolic-jacobian-order)

  (define flux-jacobian-order (symbolic-jacobian-order flux-exprs cons-exprs))
  
  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) (list cons-exprs) parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]

    ;; Check whether the neural network depth is at least equal to 2 * the order of each component of the Jacobian of the flux function: if so, return the bounds;
    ;; otherwise, return false.
    [else (list (cond
                  [(not (equal? (symbolic-simp `(< ,depth (* 2 ,(list-ref (list-ref flux-jacobian-order 0) 0)))) #f)) +inf.0]
                  [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 2 ,(list-ref (list-ref flux-jacobian-order 0) 0))))))])
                (cond
                  [(not (equal? (symbolic-simp `(< ,depth (* 2 ,(list-ref (list-ref flux-jacobian-order 0) 1)))) #f)) +inf.0]
                  [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 2 ,(list-ref (list-ref flux-jacobian-order 0) 1))))))])
                (cond
                  [(not (equal? (symbolic-simp `(< ,depth (* 2 ,(list-ref (list-ref flux-jacobian-order 1) 0)))) #f)) +inf.0]
                  [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 2 ,(list-ref (list-ref flux-jacobian-order 1) 0))))))])
                (cond
                  [(not (equal? (symbolic-simp `(< ,depth (* 2 ,(list-ref (list-ref flux-jacobian-order 1) 1)))) #f)) +inf.0]
                  [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 2 ,(list-ref (list-ref flux-jacobian-order 1) 1))))))]))]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-diff-order)
  (untrace symbolic-jacobian-order)
  
  out)
(trace prove-vector2-1d-non-smooth)

;; -----------------------------------------------------------------------------------------------------------------
;; Prove Error Bounds on Smooth Solutions for an Arbitrary Surrogate Solver for a 2D Coupled Vector System of 3 PDEs
;; -----------------------------------------------------------------------------------------------------------------
(define (prove-vector3-2d-smooth pde-system neural-net
                                 #:nx [nx 200]
                                 #:ny [ny 200]
                                 #:x0 [x0 0.0]
                                 #:x1 [x1 2.0]
                                 #:y0 [y0 0.0]
                                 #:y1 [y1 2.0]
                                 #:t-final [t-final 1.0]
                                 #:cfl [cfl 0.95]
                                 #:init-funcs [init-funcs (list
                                                           `(cond
                                                              [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.25) 5.0]
                                                              [else 1.0])
                                                           `0.0
                                                           `0.0)])
   "Attempt to prove an analytic error bound on smooth solutions for an arbitrary surrogate solver for the 2D coupled vector system of 3 PDEs specified by `pde-system`,
    with neural network architecture `neural-net`.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (define width (hash-ref neural-net 'width))
  (define depth (hash-ref neural-net 'depth))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-diff-order)
  (trace symbolic-jacobian-order)

  (define flux-jacobian-order-x (symbolic-jacobian-order flux-exprs-x cons-exprs))
  (define flux-jacobian-order-y (symbolic-jacobian-order flux-exprs-y cons-exprs))
  
  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right/bottom domain boundary is set to the right/below of the left/top boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    [(or (< ny 1) (>= y0 y1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) (list cons-exprs) parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]

    ;; Check whether the neural network depth is at least equal to 3 + the order of each component of the Jacobian of the flux function: if so, return the bounds;
    ;; otherwise, return false.
    [else (list (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 0))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 0))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 1))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 1))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 2))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 2))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 0))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 0))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 1))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 1))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 2))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 2))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 0))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 0))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 1))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 1))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 2))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (+ 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 2))))))])))]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-diff-order)
  (untrace symbolic-jacobian-order)
  
  out)
(trace prove-vector3-2d-smooth)

;; ---------------------------------------------------------------------------------------------------------------------
;; Prove Error Bounds on Non-Smooth Solutions for an Arbitrary Surrogate Solver for a 2D Coupled Vector System of 3 PDEs
;; ---------------------------------------------------------------------------------------------------------------------
(define (prove-vector3-2d-non-smooth pde-system neural-net
                                     #:nx [nx 200]
                                     #:ny [ny 200]
                                     #:x0 [x0 0.0]
                                     #:x1 [x1 2.0]
                                     #:y0 [y0 0.0]
                                     #:y1 [y1 2.0]
                                     #:t-final [t-final 1.0]
                                     #:cfl [cfl 0.95]
                                     #:init-funcs [init-funcs (list
                                                               `(cond
                                                                  [(< (+ (* (- x 1.0) (- x 1.0)) (* (- y 1.0) (- y 1.0))) 0.25) 5.0]
                                                                  [else 1.0])
                                                               `0.0
                                                               `0.0)])
   "Attempt to prove an analytic error bound on non-smooth solutions for an arbitrary surrogate solver for the 2D coupled vector system of 3 PDEs specified by `pde-system`,
    with neural network architecture `neural-net`.
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (define width (hash-ref neural-net 'width))
  (define depth (hash-ref neural-net 'depth))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-diff-order)
  (trace symbolic-jacobian-order)

  (define flux-jacobian-order-x (symbolic-jacobian-order flux-exprs-x cons-exprs))
  (define flux-jacobian-order-y (symbolic-jacobian-order flux-exprs-y cons-exprs))
  
  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right/bottom domain boundary is set to the right/below of the left/top boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    [(or (< ny 1) (>= y0 y1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) (list cons-exprs) parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]

    ;; Check whether the neural network depth is at least equal to 3 * the order of each component of the Jacobian of the flux function: if so, return the bounds;
    ;; otherwise, return false.
    [else (list (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 0))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 0))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 1))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 1))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 0) 2))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 0) 2))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 0))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 0))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 1))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 1))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 1) 2))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 1) 2))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 0))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 0)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 0))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 1))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 1)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 1))))))]))
                (max (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-x 2) 2))))))])
                     (cond
                       [(not (equal? (symbolic-simp `(< ,depth (* 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 2)))) #f)) +inf.0]
                       [else (symbolic-simp `(/ 1.0 (expt (* ,width ,depth) (/ 1.0 (* 3 ,(list-ref (list-ref flux-jacobian-order-y 2) 2))))))])))]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-diff-order)
  (untrace symbolic-jacobian-order)
  
  out)
(trace prove-vector3-2d-non-smooth)