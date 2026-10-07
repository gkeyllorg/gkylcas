;;; -*- Mode: LISP; package:maxima; syntax:common-lisp; -*- 
(in-package :maxima)
(DSKSETQ |$varsV| '((MLIST SIMP) $VX)) 
(ADD2LNC '|$varsV| $VALUES) 
(DSKSETQ |$basisV|
         '((MLIST SIMP
            (47.
             #A((95.) BASE-CHAR
                . "/Users/mfrancis/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
             SRC |$writeGkHybVelBasisToFile| 45.))
           ((MLIST SIMP
             (33.
              #A((71.) BASE-CHAR
                 . "/Users/mfrancis/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 31.))
            ((MEXPT SIMP) 2. ((RAT SIMP) -1. 2.))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -1. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VX)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (48.
                 #A((95.) BASE-CHAR
                    . "/Users/mfrancis/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                 SRC |$writeGkHybVelBasisToFile| 45.))
               $VX 2.)))))) 
(ADD2LNC '|$basisV| $VALUES) 