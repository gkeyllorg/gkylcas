;;; -*- Mode: LISP; package:maxima; syntax:common-lisp; -*- 
(in-package :maxima)
(DSKSETQ |$varsC| '((MLIST SIMP) $X $Y $Z)) 
(ADD2LNC '|$varsC| $VALUES) 
(DSKSETQ |$varsP| '((MLIST SIMP) $X $Y $Z $VX)) 
(ADD2LNC '|$varsP| $VALUES) 
(DSKSETQ |$basisC|
         '((MLIST SIMP
            (102.
             #A((100.) BASE-CHAR
                . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-tensorhybrid.mac")
             SRC |$placeMonoBefore| 95.))
           ((MLIST SIMP
             (32.
              #A((70.) BASE-CHAR
                 . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 30.))
            ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Z)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $X $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $X $Z)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $Y $Z)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $X $Y $Z)))) 
(ADD2LNC '|$basisC| $VALUES) 
(DSKSETQ |$basisP|
         '((MLIST SIMP
            (103.
             #A((100.) BASE-CHAR
                . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/basis-precalc/basis-pre-calc-tensorhybrid.mac")
             SRC |$placeMonoBefore| 95.))
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
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Z)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VX)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $X $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $X $Z)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $Y $Z)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $X)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $Z)
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (73.
                 #A((70.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 73.))
               $VX 2.)))
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $X $Y $Z)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $X $Y)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $X $Z)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $Y $Z)
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $X)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $Y)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Z)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $Z)))
            ((MTIMES SIMP) ((RAT SIMP) 9. 4.) $VX $X $Y $Z)
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $X $Y)))
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Z)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $X $Z)))
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y $Z)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $Y $Z)))
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y $Z)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $X $Y $Z)))))) 
(ADD2LNC '|$basisP| $VALUES) 