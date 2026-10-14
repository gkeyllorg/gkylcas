;;; -*- Mode: LISP; package:maxima; syntax:common-lisp; -*- 
(in-package :maxima)
(DSKSETQ |$varsC| '((MLIST SIMP) $X)) 
(ADD2LNC '|$varsC| $VALUES) 
(DSKSETQ |$varsP| '((MLIST SIMP) $X $VX)) 
(ADD2LNC '|$varsP| $VALUES) 
(DSKSETQ |$basisC|
         '((MLIST SIMP
            (23.
             #A((94.) BASE-CHAR
                . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
             SRC |$writeHybBasisToFile| 16.))
           ((MLIST SIMP
             (32.
              #A((70.) BASE-CHAR
                 . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 30.))
            ((MEXPT SIMP) 2. ((RAT SIMP) -1. 2.))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -1. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)))) 
(ADD2LNC '|$basisC| $VALUES) 
(DSKSETQ |$basisP|
         '((MLIST SIMP
            (29.
             #A((94.) BASE-CHAR
                . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
             SRC |$writeHybBasisToFile| 16.))
           ((MLIST SIMP
             (32.
              #A((70.) BASE-CHAR
                 . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 30.))
            ((RAT SIMP) 1. 2.)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VX)
            ((MTIMES SIMP) ((RAT SIMP) 3. 2.) $VX $X)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (27.
                 #A((94.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                 SRC |$writeHybBasisToFile| 16.))
               $VX 2.)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (27.
                  #A((94.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                  SRC |$writeHybBasisToFile| 16.))
                $VX 2.)
               $X)))))) 
(ADD2LNC '|$basisP| $VALUES) 