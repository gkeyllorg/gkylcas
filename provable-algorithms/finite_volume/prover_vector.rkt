#lang racket

(require racket/trace)
(current-prefix-in " ")
(current-prefix-out " ")

(provide symbolic-jacobian
         symbolic-gradient
         symbolic-hessian
         symbolic-eigvals2
         symbolic-eigvals3
         is-non-zero
         are-distinct
         symbolic-roe-matrix
         prove-lax-friedrichs-vector2-1d-hyperbolicity
         prove-lax-friedrichs-vector2-1d-strict-hyperbolicity
         prove-lax-friedrichs-vector2-1d-cfl-stability
         prove-lax-friedrichs-vector2-1d-local-lipschitz
         prove-lax-friedrichs-vector3-2d-hyperbolicity
         prove-lax-friedrichs-vector3-2d-strict-hyperbolicity
         prove-lax-friedrichs-vector3-2d-cfl-stability
         prove-lax-friedrichs-vector3-2d-local-lipschitz
         prove-roe-vector2-1d-hyperbolicity
         prove-roe-vector2-1d-strict-hyperbolicity
         prove-roe-vector2-1d-flux-conservation
         prove-roe-vector3-2d-hyperbolicity
         prove-roe-vector3-2d-strict-hyperbolicity
         prove-roe-vector3-2d-flux-conservation)

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

;; Recursively replace conserved variable expressions within the flux derivative expression (for Roe functions).
(define (flux-deriv-replace flux-deriv-expr cons-expr new-cons-expr)
  (match flux-deriv-expr
    ;; If the flux derivative expression is just the conserved variable expression, then return the new conserved variable expression.
    [(? (lambda (arg)
          (equal? arg cons-expr))) new-cons-expr]

    ;; If the flux derivative expression consists of a sum, difference, product, or quotient, then recursively apply replacement to each term.
    [`(+ . ,terms)
     `(+ ,@(map (lambda (term) (flux-deriv-replace term cons-expr new-cons-expr)) terms))]
    [`(- . ,terms)
     `(- ,@(map (lambda (term) (flux-deriv-replace term cons-expr new-cons-expr)) terms))]
    [`(* . ,terms)
     `(* ,@(map (lambda (term) (flux-deriv-replace term cons-expr new-cons-expr)) terms))]
    [`(/ . ,terms)
     `(/ ,@(map (lambda (term) (flux-deriv-replace term cons-expr new-cons-expr)) terms))]

    ;; Otherwise, return the flux derivative expression.
    [else flux-deriv-expr]))

;; Compute symbolic Jacobian matrix by mapping symbolic differentiation over exprs with respect to vars.
(define (symbolic-jacobian exprs vars)
  (map (lambda (expr)
         (map (lambda (var)
                (symbolic-simp (symbolic-diff expr var)))
              vars))
       exprs))

;; Compute symbolic gradient vector by applying symbolic differentiation to expr, mapped over vars.
(define (symbolic-gradient expr vars)
  (map (lambda (var)
       (symbolic-simp (symbolic-diff expr var)))
  vars))

;; Compute symbolic Hessian matrix by computing the symbolic Jacobian matrix of the symbolic gradient vector of expr with respect to vars.
(define (symbolic-hessian expr vars)
  (symbolic-jacobian (symbolic-gradient expr vars) vars))

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

;; Determine whether an expression is non-zero.
(define (is-non-zero expr parameters)
  (match expr
    ;; A non-zero number is, trivially, non-zero.
    [(? (lambda (arg)
         (and (number? arg) (not (equal? arg 0)) (not (equal? arg 0.0))))) #t]

    ;; Simulation parameters that are non-zero are, trivially, non-zero.
    [(? (lambda (arg)
        (and (not (empty? parameters)) (ormap (lambda (parameter)
                                                 (and (equal? arg (list-ref parameter 1))
                                                      (or (not (equal? (list-ref parameter 2) 0))
                                                          (not (equal? (list-ref parameter 2) 0.0))))) parameters)))) #t]

    ;; The product of two non-zero numbers is always non-zero.
    [`(* ,x ,y) (and (is-non-zero x parameters) (is-non-zero y parameters))]
    
    ;; Otherwise, assume false.
    [else #f]))

;; Recursively determine whether two expressions are distinct.
(define (are-distinct expr parameters)
  (match expr
    ;; Two numbers that are unequal are, trivially, distinct.
    [(? (lambda (arg)
        (and (number? (list-ref arg 0)) (number? (list-ref arg 1)) (not (equal? (list-ref arg 0) (list-ref arg 1)))))) #t]

    ;; Expressions of the form (expr, -expr) or (-expr, expr) are distinct, so long as expr is non-zero.
    [`(,x (* -1 ,x)) (is-non-zero x parameters)]
    [`(,x (* -1.0 ,x)) (is-non-zero x parameters)]
    [`((* -1 ,x) ,x) (is-non-zero x parameters)]
    [`((* -1.0 ,x) ,x) (is-non-zero x parameters)]

    ;; Expressions of the form ((x + y), (x - y)) or ((x - y), (x + y)) are distinct, so long as y is non-zero.
    [`((+ ,x ,y) (- ,x ,y)) (is-non-zero y parameters)]
    [`((- ,x ,y) (+ ,x ,y)) (is-non-zero y parameters)]

    ;; Expressions of the form (x, (x - y)) or (x, (x + y)) are distinct, so long as y is non-zero.
    [`(,x (- ,x ,y)) (is-non-zero y parameters)]
    [`(,x (+ ,x ,y)) (is-non-zero y parameters)]

    ;; Expressions of the form ((x - y), x) or ((x + y), x) are distinct, so long as y is non-zero.
    [`((- ,x ,y) ,x) (is-non-zero y parameters)]
    [`((+ ,x ,y) ,x) (is-non-zero y parameters)]

    ;; Otherwise, assume false.
    [else #f]))

;; Compute the symbolic Roe matrix (averaged flux Jacobian).
(define (symbolic-roe-matrix flux-jacobian cons-exprs)
  (map (lambda (row)
         (map (lambda (column)
                (symbolic-simp `(+ (* 0.5 ,(flux-deriv-replace (flux-deriv-replace column (list-ref cons-exprs 0)
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                                               (list-ref cons-exprs 1)
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))))
                                   (* 0.5 ,(flux-deriv-replace (flux-deriv-replace column (list-ref cons-exprs 0)
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                                               (list-ref cons-exprs 1)
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))))))
              row))
       flux-jacobian))

;; Determine whether an expression is non-negative.
(define (is-non-negative expr parameters)
  (match expr
    ;; A non-negative number is, trivially, non-negative.
    [(? (lambda (arg)
          (and (number? arg) (or (>= arg 0) (>= arg 0.0))))) #t]

    ;; Simulation parameters that are non-negative are, trivially, non-negative.
    [(? (lambda (arg)
          (and (not (empty? parameters)) (ormap (lambda (parameter)
                                                  (and (equal? arg (list-ref parameter 1))
                                                       (or (>= (list-ref parameter 2) 0)
                                                           (>= (list-ref parameter 2) 0.0)))) parameters)))) #t]

    ;; The sum, product, or quotient of two non-negative numbers is always non-negative.
    [`(+ ,x ,y) (and (is-non-negative x parameters) (is-non-negative y parameters))]
    [`(* ,x ,y) (and (is-non-negative x parameters) (is-non-negative y parameters))]
    [`(/ ,x ,y) (and (is-non-negative x parameters) (is-non-negative y parameters))]

    ;; Otherwise, assume false.
    [else #f]))

;; -------------------------------------------------------------------------------------------------------------
;; Prove hyperbolicity of the Lax–Friedrichs (Finite-Difference) Solver for a 1D Coupled Vector System of 2 PDEs
;; -------------------------------------------------------------------------------------------------------------
(define (prove-lax-friedrichs-vector2-1d-hyperbolicity pde-system
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
   "Prove that the Lax-Friedrichs finite-difference method preserves hyperbolicity for the 1D coupled vector system of 2 PDEs specified by `pde-system`. 
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals2)

  (define flux-eigvals (symbolic-eigvals2 (symbolic-jacobian flux-exprs cons-exprs)))
  (define flux-eigvals-simp (list
                             (symbolic-simp (list-ref flux-eigvals 0))
                             (symbolic-simp (list-ref flux-eigvals 1))))

  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]
    
    ;; Check whether the eigenvalues of the flux Jacobian are all real (otherwise, return false).
    [(or (not (is-real (list-ref flux-eigvals-simp 0) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp 1) cons-exprs parameters))) #f]

    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals2)
  
  out)
(trace prove-lax-friedrichs-vector2-1d-hyperbolicity)

;; --------------------------------------------------------------------------------------------------------------------
;; Prove strict hyperbolicity of the Lax–Friedrichs (Finite-Difference) Solver for a 1D Coupled Vector System of 2 PDEs
;; --------------------------------------------------------------------------------------------------------------------
(define (prove-lax-friedrichs-vector2-1d-strict-hyperbolicity pde-system
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
   "Prove that the Lax-Friedrichs finite-difference method preserves strict hyperbolicity for the 1D coupled vector system of 2 PDEs specified by `pde-system`. 
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals2)
  (trace is-non-zero)
  (trace are-distinct)

  (define flux-eigvals (symbolic-eigvals2 (symbolic-jacobian flux-exprs cons-exprs)))
  (define flux-eigvals-simp (list
                             (symbolic-simp (list-ref flux-eigvals 0))
                             (symbolic-simp (list-ref flux-eigvals 1))))

  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]
    
    ;; Check whether the eigenvalues of the flux Jacobian are all real (otherwise, return false).
    [(or (not (is-real (list-ref flux-eigvals-simp 0) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp 1) cons-exprs parameters))) #f]

    ;; Check whether the eigenvalues of the flux Jacobian are all distinct (otherwise, return false).
    [(not (are-distinct flux-eigvals-simp parameters)) #f]
    
    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals2)
  (untrace is-non-zero)
  (untrace are-distinct)
  
  out)
(trace prove-lax-friedrichs-vector2-1d-strict-hyperbolicity)

;; -------------------------------------------------------------------------------------------------------------
;; Prove CFL stability of the Lax–Friedrichs (Finite-Difference) Solver for a 1D Coupled Vector System of 2 PDEs
;; -------------------------------------------------------------------------------------------------------------
(define (prove-lax-friedrichs-vector2-1d-cfl-stability pde-system
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
   "Prove that the Lax-Friedrichs finite-difference method is CFL stable for the 1D coupled vector system of 2 PDEs specified by `pde-system`. 
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define max-speed-exprs (hash-ref pde-system 'max-speed-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals2)

  (define flux-eigvals (symbolic-eigvals2 (symbolic-jacobian flux-exprs cons-exprs)))
  (define max-speed-exprs-simp (list
                                (symbolic-simp (list-ref max-speed-exprs 0))
                                (symbolic-simp (list-ref max-speed-exprs 1))))
  (define flux-eigvals-simp (list
                             (symbolic-simp `(abs ,(list-ref flux-eigvals 0)))
                             (symbolic-simp `(abs ,(list-ref flux-eigvals 1)))))

  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]
    
    ;; Check whether the absolute eigenvalues of the flux Jacobian are symbolically equivalent to the maximum wave-speed estimates (otherwise, return false).
    [(or (equal? (member (list-ref flux-eigvals-simp 0) max-speed-exprs-simp) #f)
         (equal? (member (list-ref flux-eigvals-simp 1) max-speed-exprs-simp) #f)) #f]

    ;; Otherwise, return true.
    [else #t]))
  
  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals2)

  out)
(trace prove-lax-friedrichs-vector2-1d-cfl-stability)

;; ---------------------------------------------------------------------------------------------------------------------------------------------------------
;; Prove local Lipschitz continuity of the discrete flux function for the Lax–Friedrichs (Finite-Difference) Solver for a 1D Coupled Vector System of 2 PDEs
;; ---------------------------------------------------------------------------------------------------------------------------------------------------------
(define (prove-lax-friedrichs-vector2-1d-local-lipschitz pde-system
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
   "Prove that the Lax-Friedrichs finite-difference method has a discrete flux function that satisfies local Lipschitz continuity for the 1D coupled vector system of 2 PDEs specified by `pde-system`. 
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals2)
  (trace symbolic-gradient)
  (trace symbolic-hessian)
  (trace is-non-negative)

  (define hessian-mats (list
                        (symbolic-hessian (list-ref flux-exprs 0) cons-exprs)
                        (symbolic-hessian (list-ref flux-exprs 1) cons-exprs)))
  (define hessian-eigvals (list
                           (symbolic-eigvals2 (list-ref hessian-mats 0))
                           (symbolic-eigvals2 (list-ref hessian-mats 1))))
  (define hessian-eigvals-simp (list
                                (symbolic-simp (list-ref (list-ref hessian-eigvals 0) 0))
                                (symbolic-simp (list-ref (list-ref hessian-eigvals 0) 1))
                                (symbolic-simp (list-ref (list-ref hessian-eigvals 1) 0))
                                (symbolic-simp (list-ref (list-ref hessian-eigvals 1) 1))))

  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]
    
    ;; Check whether the flux function is convex, i.e. that the Hessian matrix for each flux component is positive semidefinite (otherwise, return false).
    [(or (not (is-non-negative (list-ref hessian-eigvals-simp 0) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp 1) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp 2) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp 3) parameters))) #f]

    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals2)
  (untrace symbolic-gradient)
  (untrace symbolic-hessian)
  (untrace is-non-negative)
  
  out)
(trace prove-lax-friedrichs-vector2-1d-local-lipschitz)

;; -------------------------------------------------------------------------------------------------------------
;; Prove hyperbolicity of the Lax–Friedrichs (Finite-Difference) Solver for a 2D Coupled Vector System of 3 PDEs
;; -------------------------------------------------------------------------------------------------------------
(define (prove-lax-friedrichs-vector3-2d-hyperbolicity pde-system
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
   "Prove that the Lax-Friedrichs finite-difference method preserves hyperbolicity for the 2D coupled vector system of 3 PDEs specified by `pde-system`. 
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals3)

  (define flux-eigvals-x (symbolic-eigvals3 (symbolic-jacobian flux-exprs-x cons-exprs)))
  (define flux-eigvals-y (symbolic-eigvals3 (symbolic-jacobian flux-exprs-y cons-exprs)))
  (define flux-eigvals-simp-x (list
                               (symbolic-simp (list-ref flux-eigvals-x 0))
                               (symbolic-simp (list-ref flux-eigvals-x 1))
                               (symbolic-simp (list-ref flux-eigvals-x 2))))
  (define flux-eigvals-simp-y (list
                               (symbolic-simp (list-ref flux-eigvals-y 0))
                               (symbolic-simp (list-ref flux-eigvals-y 1))
                               (symbolic-simp (list-ref flux-eigvals-y 2))))

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
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]
    
    ;; Check whether the eigenvalues of the flux Jacobians are all real (otherwise, return false).
    [(or (not (is-real (list-ref flux-eigvals-simp-x 0) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp-x 1) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp-x 2) cons-exprs parameters))) #f]
    [(or (not (is-real (list-ref flux-eigvals-simp-y 0) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp-y 1) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp-y 2) cons-exprs parameters))) #f]

    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals3)
  
  out)
(trace prove-lax-friedrichs-vector3-2d-hyperbolicity)

;; --------------------------------------------------------------------------------------------------------------------
;; Prove strict hyperbolicity of the Lax–Friedrichs (Finite-Difference) Solver for a 2D Coupled Vector System of 3 PDEs
;; --------------------------------------------------------------------------------------------------------------------
(define (prove-lax-friedrichs-vector3-2d-strict-hyperbolicity pde-system
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
   "Prove that the Lax-Friedrichs finite-difference method preserves strict hyperbolicity for the 2D coupled vector system of 3 PDEs specified by `pde-system`. 
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."
  
  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals3)
  (trace is-non-zero)
  (trace are-distinct)

  (define flux-eigvals-x (symbolic-eigvals3 (symbolic-jacobian flux-exprs-x cons-exprs)))
  (define flux-eigvals-y (symbolic-eigvals3 (symbolic-jacobian flux-exprs-y cons-exprs)))
  (define flux-eigvals-simp-x (list
                               (symbolic-simp (list-ref flux-eigvals-x 0))
                               (symbolic-simp (list-ref flux-eigvals-x 1))
                               (symbolic-simp (list-ref flux-eigvals-x 2))))
  (define flux-eigvals-simp-y (list
                               (symbolic-simp (list-ref flux-eigvals-y 0))
                               (symbolic-simp (list-ref flux-eigvals-y 1))
                               (symbolic-simp (list-ref flux-eigvals-y 2))))

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
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]
    
    ;; Check whether the eigenvalues of the flux Jacobians are all real (otherwise, return false).
    [(or (not (is-real (list-ref flux-eigvals-simp-x 0) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp-x 1) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp-x 2) cons-exprs parameters))) #f]
    [(or (not (is-real (list-ref flux-eigvals-simp-y 0) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp-y 1) cons-exprs parameters))
         (not (is-real (list-ref flux-eigvals-simp-y 2) cons-exprs parameters))) #f]

    ;; Check whether the eigenvalues of the flux Jacobians are all distinct (otherwise, return false).
    [(not (are-distinct (list (list-ref flux-eigvals-simp-x 0) (list-ref flux-eigvals-simp-x 1)) parameters)) #f]
    [(not (are-distinct (list (list-ref flux-eigvals-simp-x 0) (list-ref flux-eigvals-simp-x 2)) parameters)) #f]
    [(not (are-distinct (list (list-ref flux-eigvals-simp-x 1) (list-ref flux-eigvals-simp-x 2)) parameters)) #f]
    [(not (are-distinct (list (list-ref flux-eigvals-simp-y 0) (list-ref flux-eigvals-simp-y 1)) parameters)) #f]
    [(not (are-distinct (list (list-ref flux-eigvals-simp-y 0) (list-ref flux-eigvals-simp-y 2)) parameters)) #f]
    [(not (are-distinct (list (list-ref flux-eigvals-simp-y 1) (list-ref flux-eigvals-simp-y 2)) parameters)) #f]
    
    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals3)
  (untrace is-non-zero)
  (untrace are-distinct)
  
  out)
(trace prove-lax-friedrichs-vector3-2d-strict-hyperbolicity)

;; -------------------------------------------------------------------------------------------------------------
;; Prove CFL stability of the Lax–Friedrichs (Finite-Difference) Solver for a 2D Coupled Vector System of 3 PDEs
;; -------------------------------------------------------------------------------------------------------------
(define (prove-lax-friedrichs-vector3-2d-cfl-stability pde-system
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
   "Prove that the Lax-Friedrichs finite-difference method is CFL stable for the 2D coupled vector system of 3 PDEs specified by `pde-system`. 
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define max-speed-exprs-x (hash-ref pde-system 'max-speed-exprs-x))
  (define max-speed-exprs-y (hash-ref pde-system 'max-speed-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals3)

  (define flux-eigvals-x (symbolic-eigvals3 (symbolic-jacobian flux-exprs-x cons-exprs)))
  (define flux-eigvals-y (symbolic-eigvals3 (symbolic-jacobian flux-exprs-y cons-exprs)))
  (define max-speed-exprs-simp-x (list
                                  (symbolic-simp (list-ref max-speed-exprs-x 0))
                                  (symbolic-simp (list-ref max-speed-exprs-x 1))
                                  (symbolic-simp (list-ref max-speed-exprs-x 2))))
  (define max-speed-exprs-simp-y (list
                                  (symbolic-simp (list-ref max-speed-exprs-y 0))
                                  (symbolic-simp (list-ref max-speed-exprs-y 1))
                                  (symbolic-simp (list-ref max-speed-exprs-y 2))))
  (define flux-eigvals-simp-x (list
                               (symbolic-simp `(abs ,(list-ref flux-eigvals-x 0)))
                               (symbolic-simp `(abs ,(list-ref flux-eigvals-x 1)))
                               (symbolic-simp `(abs ,(list-ref flux-eigvals-x 2)))))
  (define flux-eigvals-simp-y (list
                               (symbolic-simp `(abs ,(list-ref flux-eigvals-y 0)))
                               (symbolic-simp `(abs ,(list-ref flux-eigvals-y 1)))
                               (symbolic-simp `(abs ,(list-ref flux-eigvals-y 2)))))

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
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]
    
    ;; Check whether the absolute eigenvalues of the flux Jacobians are symbolically equivalent to the maximum wave-speed estimates (otherwise, return false).
    [(or (equal? (member (list-ref flux-eigvals-simp-x 0) max-speed-exprs-simp-x) #f)
         (equal? (member (list-ref flux-eigvals-simp-x 1) max-speed-exprs-simp-x) #f)
         (equal? (member (list-ref flux-eigvals-simp-x 2) max-speed-exprs-simp-x) #f)) #f]
    [(or (equal? (member (list-ref flux-eigvals-simp-y 0) max-speed-exprs-simp-y) #f)
         (equal? (member (list-ref flux-eigvals-simp-y 1) max-speed-exprs-simp-y) #f)
         (equal? (member (list-ref flux-eigvals-simp-y 2) max-speed-exprs-simp-y) #f)) #f]

    ;; Otherwise, return true.
    [else #t]))
  
  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals3)

  out)
(trace prove-lax-friedrichs-vector3-2d-cfl-stability)

;; ---------------------------------------------------------------------------------------------------------------------------------------------------------
;; Prove local Lipschitz continuity of the discrete flux function for the Lax–Friedrichs (Finite-Difference) Solver for a 2D Coupled Vector System of 3 PDEs
;; ---------------------------------------------------------------------------------------------------------------------------------------------------------
(define (prove-lax-friedrichs-vector3-2d-local-lipschitz pde-system
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
   "Prove that the Lax-Friedrichs finite-difference method has a discrete flux function that satisfies local Lipschitz continuity for the 2D coupled vector system of 3 PDEs specified by `pde-system`. 
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals3)
  (trace symbolic-gradient)
  (trace symbolic-hessian)
  (trace is-non-negative)

  (define hessian-mats-x (list
                          (symbolic-hessian (list-ref flux-exprs-x 0) cons-exprs)
                          (symbolic-hessian (list-ref flux-exprs-x 1) cons-exprs)
                          (symbolic-hessian (list-ref flux-exprs-x 2) cons-exprs)))
  (define hessian-mats-y (list
                          (symbolic-hessian (list-ref flux-exprs-y 0) cons-exprs)
                          (symbolic-hessian (list-ref flux-exprs-y 1) cons-exprs)
                          (symbolic-hessian (list-ref flux-exprs-y 2) cons-exprs)))
  (define hessian-eigvals-x (list
                             (symbolic-eigvals3 (list-ref hessian-mats-x 0))
                             (symbolic-eigvals3 (list-ref hessian-mats-x 1))
                             (symbolic-eigvals3 (list-ref hessian-mats-x 2))))
  (define hessian-eigvals-y (list
                             (symbolic-eigvals3 (list-ref hessian-mats-y 0))
                             (symbolic-eigvals3 (list-ref hessian-mats-y 1))
                             (symbolic-eigvals3 (list-ref hessian-mats-y 2))))
  (define hessian-eigvals-simp-x (list
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 0) 0))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 0) 1))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 0) 2))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 1) 0))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 1) 1))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 1) 2))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 2) 0))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 2) 1))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-x 2) 2))))
  (define hessian-eigvals-simp-y (list
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 0) 0))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 0) 1))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 0) 2))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 1) 0))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 1) 1))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 1) 2))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 2) 0))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 2) 1))
                                  (symbolic-simp (list-ref (list-ref hessian-eigvals-y 2) 2))))

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
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]
    
    ;; Check whether the flux functions are convex, i.e. that the Hessian matrices for each flux component are positive semidefinite (otherwise, return false).
    [(or (not (is-non-negative (list-ref hessian-eigvals-simp-x 0) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp-x 1) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp-x 2) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp-x 3) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp-x 4) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp-x 5) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp-x 6) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp-x 7) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp-x 8) parameters))) #f]
    [(or (not (is-non-negative (list-ref hessian-eigvals-simp-y 0) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp-y 1) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp-y 2) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp-y 3) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp-y 4) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp-y 5) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp-y 6) parameters)) (not (is-non-negative (list-ref hessian-eigvals-simp-y 7) parameters))
         (not (is-non-negative (list-ref hessian-eigvals-simp-y 8) parameters))) #f]

    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals3)
  (untrace symbolic-gradient)
  (untrace symbolic-hessian)
  (untrace is-non-negative)
  
  out)
(trace prove-lax-friedrichs-vector3-2d-local-lipschitz)

;; ----------------------------------------------------------------------------------------------
;; Prove hyperbolicity of the Roe (Finite-Volume) Solver for a 1D Coupled Vector System of 2 PDEs
;; ----------------------------------------------------------------------------------------------
(define (prove-roe-vector2-1d-hyperbolicity pde-system
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
   "Prove that the Roe finite-volume method preserves hyperbolicity for the 1D coupled vector system of 2 PDEs specified by `pde-system`. 
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals2)
  (trace symbolic-roe-matrix)
  (trace flux-deriv-replace)

  (define roe-matrix-eigvals (symbolic-eigvals2 (symbolic-roe-matrix (symbolic-jacobian flux-exprs cons-exprs) cons-exprs)))
  (define roe-matrix-eigvals-simp (list
                                   (symbolic-simp (list-ref roe-matrix-eigvals 0))
                                   (symbolic-simp (list-ref roe-matrix-eigvals 1))))
  
  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]
    
    ;; Check whether the eigenvalues of the Roe matrix are all real (otherwise, return false).
    [(or (not (is-real (list-ref roe-matrix-eigvals-simp 0) (list
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))) parameters))
         (not (is-real (list-ref roe-matrix-eigvals-simp 1) (list
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))) parameters))) #f]

    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals2)
  (untrace symbolic-roe-matrix)
  (untrace flux-deriv-replace)
  
  out)
(trace prove-roe-vector2-1d-hyperbolicity)

;; -----------------------------------------------------------------------------------------------------
;; Prove strict hyperbolicity of the Roe (Finite-Volume) Solver for a 1D Coupled Vector System of 2 PDEs
;; -----------------------------------------------------------------------------------------------------
(define (prove-roe-vector2-1d-strict-hyperbolicity pde-system
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
   "Prove that the Roe finite-volume method preserves strict hyperbolicity for the 1D coupled vector system of 2 PDEs specified by `pde-system`. 
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals2)
  (trace symbolic-roe-matrix)
  (trace flux-deriv-replace)
  (trace is-non-zero)
  (trace are-distinct)

  (define roe-matrix-eigvals (symbolic-eigvals2 (symbolic-roe-matrix (symbolic-jacobian flux-exprs cons-exprs) cons-exprs)))
  (define roe-matrix-eigvals-simp (list
                                   (symbolic-simp (list-ref roe-matrix-eigvals 0))
                                   (symbolic-simp (list-ref roe-matrix-eigvals 1))))

  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]
    
    ;; Check whether the eigenvalues of the Roe matrix are all real (otherwise, return false).
    [(or (not (is-real (list-ref roe-matrix-eigvals-simp 0) (list
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))) parameters))
         (not (is-real (list-ref roe-matrix-eigvals-simp 1) (list
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                             (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))) parameters))) #f]

    ;; Check whether the eigenvalues of the Roe matrix are all distinct (otherwise, return false).
    [(not (are-distinct roe-matrix-eigvals-simp parameters)) #f]
    
    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals2)
  (untrace symbolic-roe-matrix)
  (untrace flux-deriv-replace)
  (untrace is-non-zero)
  (untrace are-distinct)
  
  out)
(trace prove-roe-vector2-1d-strict-hyperbolicity)

;; --------------------------------------------------------------------------------------------------------------------
;; Prove flux conservation (jump continuity) of the Roe (Finite-Volume) Solver for a 1D Coupled Vector System of 2 PDEs
;; --------------------------------------------------------------------------------------------------------------------
(define (prove-roe-vector2-1d-flux-conservation pde-system
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
  "Prove that the Roe finite-volume method preserves flux conservation (jump continuity) for the 1D coupled vector system of 2 PDEs specified by `pde-system`. 
  - `nx` : Number of spatial cells.
  - `x0`, `x1` : Domain boundaries.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs (hash-ref pde-system 'flux-exprs))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-roe-matrix)
  (trace flux-deriv-replace)

  (define roe-matrix (symbolic-roe-matrix (symbolic-jacobian flux-exprs cons-exprs) cons-exprs))
  (define cons-jump (list (symbolic-simp `(- ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                             ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))))
                          (symbolic-simp `(- ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                             ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))))))
  
  (define roe-jump (list (symbolic-simp `(+ (* ,(list-ref (list-ref roe-matrix 0) 0) ,(list-ref cons-jump 0))
                                            (* ,(list-ref (list-ref roe-matrix 0) 1) ,(list-ref cons-jump 1))))
                         (symbolic-simp `(+ (* ,(list-ref (list-ref roe-matrix 1) 0) ,(list-ref cons-jump 0))
                                            (* ,(list-ref (list-ref roe-matrix 1) 1) ,(list-ref cons-jump 1))))))
  (define flux-jump (list (symbolic-simp `(- ,(flux-deriv-replace
                                               (flux-deriv-replace (list-ref flux-exprs 0) (list-ref cons-exprs 0)
                                                                   (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                               (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L")))
                                             ,(flux-deriv-replace
                                               (flux-deriv-replace (list-ref flux-exprs 0) (list-ref cons-exprs 0)
                                                                   (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                               (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))))
                          (symbolic-simp `(- ,(flux-deriv-replace
                                               (flux-deriv-replace (list-ref flux-exprs 1) (list-ref cons-exprs 0)
                                                                   (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                               (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L")))
                                             ,(flux-deriv-replace
                                               (flux-deriv-replace (list-ref flux-exprs 1) (list-ref cons-exprs 0)
                                                                   (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                               (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))))))

  (define out (cond
    ;; Check whether the CFL coefficient is greater than 0 and less than or equal to 1 (otherwise, return false).
    [(or (<= cfl 0) (> cfl 1)) #f]
    
    ;; Check whether the number of spatial cells is at least 1 and the right domain boundary is set to the right of the left boundary (otherwise, return false)
    [(or (< nx 1) (>= x0 x1)) #f]
    
    ;; Check whether the final simulation time is non-negative (otherwise, return false).
    [(< t-final 0) #f]

    ;; Check whether the simulation parameter(s) correspond to real numbers (otherwise, return false).
    [(not (or (empty? parameters) (andmap (lambda (parameter)
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))) #f]

    ;; Check whether the jump in the flux vector is equal to the product of the Roe matrix and the jump in the conserved variable vector (otherwise, return false).
    [(or (not (equal? (list-ref roe-jump 0) (list-ref flux-jump 0)))
         (not (equal? (list-ref roe-jump 1) (list-ref flux-jump 1)))) #f]
    
    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-roe-matrix)
  (untrace flux-deriv-replace)
  
  out)
(trace prove-roe-vector2-1d-flux-conservation)

;; ----------------------------------------------------------------------------------------------
;; Prove hyperbolicity of the Roe (Finite-Volume) Solver for a 2D Coupled Vector System of 3 PDEs
;; ----------------------------------------------------------------------------------------------
(define (prove-roe-vector3-2d-hyperbolicity pde-system
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
   "Prove that the Roe finite-volume method preserves hyperbolicity for the 2D coupled vector system of 3 PDEs specified by `pde-system`. 
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals3)
  (trace symbolic-roe-matrix)
  (trace flux-deriv-replace)

  (define roe-matrix-eigvals-x (symbolic-eigvals3 (symbolic-roe-matrix (symbolic-jacobian flux-exprs-x cons-exprs) cons-exprs)))
  (define roe-matrix-eigvals-y (symbolic-eigvals3 (symbolic-roe-matrix (symbolic-jacobian flux-exprs-y cons-exprs) cons-exprs)))
  (define roe-matrix-eigvals-simp-x (list
                                     (symbolic-simp (list-ref roe-matrix-eigvals-x 0))
                                     (symbolic-simp (list-ref roe-matrix-eigvals-x 1))
                                     (symbolic-simp (list-ref roe-matrix-eigvals-x 2))))
  (define roe-matrix-eigvals-simp-y (list
                                     (symbolic-simp (list-ref roe-matrix-eigvals-y 0))
                                     (symbolic-simp (list-ref roe-matrix-eigvals-y 1))
                                     (symbolic-simp (list-ref roe-matrix-eigvals-y 2))))
  
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
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]
    
    ;; Check whether the eigenvalues of the Roe matrices are all real (otherwise, return false).
    [(or (not (is-real (list-ref roe-matrix-eigvals-simp-x 0) (list
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))) parameters))
         (not (is-real (list-ref roe-matrix-eigvals-simp-x 1) (list
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))) parameters))) #f]
    [(or (not (is-real (list-ref roe-matrix-eigvals-simp-y 0) (list
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))) parameters))
         (not (is-real (list-ref roe-matrix-eigvals-simp-y 1) (list
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))) parameters))) #f]

    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals3)
  (untrace symbolic-roe-matrix)
  (untrace flux-deriv-replace)
  
  out)
(trace prove-roe-vector3-2d-hyperbolicity)

;; -----------------------------------------------------------------------------------------------------
;; Prove strict hyperbolicity of the Roe (Finite-Volume) Solver for a 2D Coupled Vector System of 3 PDEs
;; -----------------------------------------------------------------------------------------------------
(define (prove-roe-vector3-2d-strict-hyperbolicity pde-system
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
   "Prove that the Roe finite-volume method preserves strict hyperbolicity for the 2D coupled vector system of 3 PDEs specified by `pde-system`. 
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-eigvals3)
  (trace symbolic-roe-matrix)
  (trace flux-deriv-replace)
  (trace is-non-zero)
  (trace are-distinct)

  (define roe-matrix-eigvals-x (symbolic-eigvals3 (symbolic-roe-matrix (symbolic-jacobian flux-exprs-x cons-exprs) cons-exprs)))
  (define roe-matrix-eigvals-y (symbolic-eigvals3 (symbolic-roe-matrix (symbolic-jacobian flux-exprs-y cons-exprs) cons-exprs)))
  (define roe-matrix-eigvals-simp-x (list
                                     (symbolic-simp (list-ref roe-matrix-eigvals-x 0))
                                     (symbolic-simp (list-ref roe-matrix-eigvals-x 1))
                                     (symbolic-simp (list-ref roe-matrix-eigvals-x 2))))
  (define roe-matrix-eigvals-simp-y (list
                                     (symbolic-simp (list-ref roe-matrix-eigvals-y 0))
                                     (symbolic-simp (list-ref roe-matrix-eigvals-y 1))
                                     (symbolic-simp (list-ref roe-matrix-eigvals-y 2))))

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
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]
    
    ;; Check whether the eigenvalues of the Roe matrices are all real (otherwise, return false).
    [(or (not (is-real (list-ref roe-matrix-eigvals-simp-x 0) (list
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))) parameters))
         (not (is-real (list-ref roe-matrix-eigvals-simp-x 1) (list
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))) parameters))) #f]
    [(or (not (is-real (list-ref roe-matrix-eigvals-simp-y 0) (list
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))) parameters))
         (not (is-real (list-ref roe-matrix-eigvals-simp-y 1) (list
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                                               (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))) parameters))) #f]

    ;; Check whether the eigenvalues of the Roe matrices are all distinct (otherwise, return false).
    [(not (are-distinct (list (list-ref roe-matrix-eigvals-simp-x 0) (list-ref roe-matrix-eigvals-simp-x 1)) parameters)) #f]
    [(not (are-distinct (list (list-ref roe-matrix-eigvals-simp-x 0) (list-ref roe-matrix-eigvals-simp-x 2)) parameters)) #f]
    [(not (are-distinct (list (list-ref roe-matrix-eigvals-simp-x 1) (list-ref roe-matrix-eigvals-simp-x 2)) parameters)) #f]
    [(not (are-distinct (list (list-ref roe-matrix-eigvals-simp-y 0) (list-ref roe-matrix-eigvals-simp-y 1)) parameters)) #f]
    [(not (are-distinct (list (list-ref roe-matrix-eigvals-simp-y 0) (list-ref roe-matrix-eigvals-simp-y 2)) parameters)) #f]
    [(not (are-distinct (list (list-ref roe-matrix-eigvals-simp-y 1) (list-ref roe-matrix-eigvals-simp-y 2)) parameters)) #f]
    
    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-eigvals3)
  (untrace symbolic-roe-matrix)
  (untrace flux-deriv-replace)
  (untrace is-non-zero)
  (untrace are-distinct)
  
  out)
(trace prove-roe-vector3-2d-strict-hyperbolicity)

;; --------------------------------------------------------------------------------------------------------------------
;; Prove flux conservation (jump continuity) of the Roe (Finite-Volume) Solver for a 2D Coupled Vector System of 3 PDEs
;; --------------------------------------------------------------------------------------------------------------------
(define (prove-roe-vector3-2d-flux-conservation pde-system
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
  "Prove that the Roe finite-volume method preserves flux conservation (jump continuity) for the 2D coupled vector system of 3 PDEs specified by `pde-system`. 
  - `nx`, `ny` : Number of spatial cells in each coordinate direction.
  - `x0`, `x1`, `y0`, `y1` : Domain boundaries in each coordinate direction.
  - `t-final`: Final time.
  - `cfl`: CFL coefficient.
  - `init-funcs`: Racket expressions for the initial conditions, e.g. piecewise constant."

  (define cons-exprs (hash-ref pde-system 'cons-exprs))
  (define flux-exprs-x (hash-ref pde-system 'flux-exprs-x))
  (define flux-exprs-y (hash-ref pde-system 'flux-exprs-y))
  (define parameters (hash-ref pde-system 'parameters))

  (trace is-real)
  (trace symbolic-simp)
  (trace symbolic-simp-rule)
  (trace symbolic-diff)
  (trace symbolic-jacobian)
  (trace symbolic-roe-matrix)
  (trace flux-deriv-replace)

  (define roe-matrix-x (symbolic-roe-matrix (symbolic-jacobian flux-exprs-x cons-exprs) cons-exprs))
  (define roe-matrix-y (symbolic-roe-matrix (symbolic-jacobian flux-exprs-y cons-exprs) cons-exprs))
  (define cons-jump (list (symbolic-simp `(- ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L"))
                                             ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R"))))
                          (symbolic-simp `(- ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L"))
                                             ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R"))))
                          (symbolic-simp `(- ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L"))
                                             ,(string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R"))))))
  
  (define roe-jump-x (list (symbolic-simp `(+ (* ,(list-ref (list-ref roe-matrix-x 0) 0) ,(list-ref cons-jump 0))
                                              (* ,(list-ref (list-ref roe-matrix-x 0) 1) ,(list-ref cons-jump 1))
                                              (* ,(list-ref (list-ref roe-matrix-x 0) 2) ,(list-ref cons-jump 2))))
                           (symbolic-simp `(+ (* ,(list-ref (list-ref roe-matrix-x 1) 0) ,(list-ref cons-jump 0))
                                              (* ,(list-ref (list-ref roe-matrix-x 1) 1) ,(list-ref cons-jump 1))
                                              (* ,(list-ref (list-ref roe-matrix-x 1) 2) ,(list-ref cons-jump 1))))
                           (symbolic-simp `(+ (* ,(list-ref (list-ref roe-matrix-x 2) 0) ,(list-ref cons-jump 0))
                                              (* ,(list-ref (list-ref roe-matrix-x 2) 1) ,(list-ref cons-jump 1))
                                              (* ,(list-ref (list-ref roe-matrix-x 2) 2) ,(list-ref cons-jump 1))))))
  (define roe-jump-y (list (symbolic-simp `(+ (* ,(list-ref (list-ref roe-matrix-y 0) 0) ,(list-ref cons-jump 0))
                                              (* ,(list-ref (list-ref roe-matrix-y 0) 1) ,(list-ref cons-jump 1))
                                              (* ,(list-ref (list-ref roe-matrix-y 0) 2) ,(list-ref cons-jump 2))))
                           (symbolic-simp `(+ (* ,(list-ref (list-ref roe-matrix-y 1) 0) ,(list-ref cons-jump 0))
                                              (* ,(list-ref (list-ref roe-matrix-y 1) 1) ,(list-ref cons-jump 1))
                                              (* ,(list-ref (list-ref roe-matrix-y 1) 2) ,(list-ref cons-jump 1))))
                           (symbolic-simp `(+ (* ,(list-ref (list-ref roe-matrix-y 2) 0) ,(list-ref cons-jump 0))
                                              (* ,(list-ref (list-ref roe-matrix-y 2) 1) ,(list-ref cons-jump 1))
                                              (* ,(list-ref (list-ref roe-matrix-y 2) 2) ,(list-ref cons-jump 1))))))
  (define flux-jump-x (list (symbolic-simp `(- ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-x 0) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L")))
                                               ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-x 0) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R")))))
                            (symbolic-simp `(- ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-x 1) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L")))
                                               ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-x 1) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R")))))
                            (symbolic-simp `(- ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-x 2) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L")))
                                               ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-x 2) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R")))))))
  (define flux-jump-y (list (symbolic-simp `(- ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-y 0) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L")))
                                               ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-y 0) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R")))))
                            (symbolic-simp `(- ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-y 1) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L")))
                                               ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-y 1) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R")))))
                            (symbolic-simp `(- ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-y 2) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "L")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "L")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "L")))
                                               ,(flux-deriv-replace (flux-deriv-replace
                                                                     (flux-deriv-replace (list-ref flux-exprs-y 2) (list-ref cons-exprs 0)
                                                                                         (string->symbol (string-append (symbol->string (list-ref cons-exprs 0)) "R")))
                                                                     (list-ref cons-exprs 1) (string->symbol (string-append (symbol->string (list-ref cons-exprs 1)) "R")))
                                                                    (list-ref cons-exprs 2) (string->symbol (string-append (symbol->string (list-ref cons-exprs 2)) "R")))))))

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
                                            (is-real (list-ref parameter 2) cons-exprs parameters)) parameters))) #f]

    ;; Check whether the initial condition(s) correspond to real numbers (otherwise, return false).
    [(or (not (is-real (list-ref init-funcs 0) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 1) cons-exprs parameters))
         (not (is-real (list-ref init-funcs 2) cons-exprs parameters))) #f]

    ;; Check whether the jumps in the flux vectors are equal to the products of the Roe matrices and the jumps in the conserved variable vector (otherwise, return false).
    [(or (not (equal? (list-ref roe-jump-x 0) (list-ref flux-jump-x 0)))
         (not (equal? (list-ref roe-jump-x 1) (list-ref flux-jump-x 1)))
         (not (equal? (list-ref roe-jump-x 2) (list-ref flux-jump-x 2)))) #f]
    [(or (not (equal? (list-ref roe-jump-y 0) (list-ref flux-jump-y 0)))
         (not (equal? (list-ref roe-jump-y 1) (list-ref flux-jump-y 1)))
         (not (equal? (list-ref roe-jump-y 2) (list-ref flux-jump-y 2)))) #f]
    
    ;; Otherwise, return true.
    [else #t]))

  (untrace is-real)
  (untrace symbolic-simp)
  (untrace symbolic-simp-rule)
  (untrace symbolic-diff)
  (untrace symbolic-jacobian)
  (untrace symbolic-roe-matrix)
  (untrace flux-deriv-replace)
  
  out)
(trace prove-roe-vector3-2d-flux-conservation)