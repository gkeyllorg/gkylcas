;;; -*- Mode: LISP; package:maxima; syntax:common-lisp; -*- 
(in-package :maxima)
(DSKSETQ |$varsC| '((MLIST SIMP) $X $Y)) 
(ADD2LNC '|$varsC| $VALUES) 
(DSKSETQ |$varsP| '((MLIST SIMP) $X $Y $VX $VY)) 
(ADD2LNC '|$varsP| $VALUES) 
(DSKSETQ |$basisC|
         '((MLIST SIMP
            (37.
             #A((94.) BASE-CHAR
                . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
             SRC |$writeGkHybBasisToFile| 34.))
           ((MLIST SIMP
             (32.
              #A((70.) BASE-CHAR
                 . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 30.))
            ((RAT SIMP) 1. 2.)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 2.) $X $Y)))) 
(ADD2LNC '|$basisC| $VALUES) 
(DSKSETQ |$basisP|
         '((MLIST SIMP
            (38.
             #A((94.) BASE-CHAR
                . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
             SRC |$writeGkHybBasisToFile| 34.))
           ((MLIST SIMP
             (32.
              #A((70.) BASE-CHAR
                 . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 30.))
            ((RAT SIMP) 1. 4.)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VX)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VY)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $X $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $X)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VY $X)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VY $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $VY)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $X $Y)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VY $X $Y)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VY $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VY $Y)
            ((MTIMES SIMP) ((RAT SIMP) 9. 4.) $VX $VY $X $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (39.
                 #A((94.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                 SRC |$writeGkHybBasisToFile| 34.))
               $VX 2.)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (39.
                  #A((94.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                  SRC |$writeGkHybBasisToFile| 34.))
                $VX 2.)
               $X)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (39.
                  #A((94.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                  SRC |$writeGkHybBasisToFile| 34.))
                $VX 2.)
               $Y)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (39.
                  #A((94.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                  SRC |$writeGkHybBasisToFile| 34.))
                $VX 2.)
               $VY)))
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (39.
                  #A((94.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                  SRC |$writeGkHybBasisToFile| 34.))
                $VX 2.)
               $X $Y)))
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (39.
                  #A((94.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                  SRC |$writeGkHybBasisToFile| 34.))
                $VX 2.)
               $VY $X)))
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (39.
                  #A((94.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                  SRC |$writeGkHybBasisToFile| 34.))
                $VX 2.)
               $VY $Y)))
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (39.
                  #A((94.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-hybrid.mac")
                  SRC |$writeGkHybBasisToFile| 34.))
                $VX 2.)
               $VY $X $Y)))))) 
(ADD2LNC '|$basisP| $VALUES) 