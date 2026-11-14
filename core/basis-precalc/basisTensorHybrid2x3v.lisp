;;; -*- Mode: LISP; package:maxima; syntax:common-lisp; -*- 
(in-package :maxima)
(DSKSETQ |$varsC| '((MLIST SIMP) $X $Y)) 
(ADD2LNC '|$varsC| $VALUES) 
(DSKSETQ |$varsP| '((MLIST SIMP) $X $Y $VX $VY $VZ)) 
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
            ((RAT SIMP) 1. 2.)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 2.) $X $Y)))) 
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
            ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VX)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VY)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VZ)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $X $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VX $X)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VX $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VY $X)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VY $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VX $VY)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VZ $X)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VZ $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VX $VZ)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VY $VZ)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (73.
                 #A((70.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 73.))
               $VX 2.)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (73.
                 #A((70.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 73.))
               $VY 2.)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (73.
                 #A((70.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 73.))
               $VZ 2.)))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $X $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VY $X $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VY $X)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VY $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VZ $X $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VZ $X)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VZ $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VY $VZ $X)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VY $VZ $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VY $VZ)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
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
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
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
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $X)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $Y)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.))))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VZ)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY)
              ((MTIMES SIMP) $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VX $VY $X
             $Y)
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VX $VZ $X
             $Y)
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VY $VZ $X
             $Y)
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VX $VY $VZ
             $X)
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.)) $VX $VY $VZ
             $Y)
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
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
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $X $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VZ $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VZ $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $VZ)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY $VZ)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VZ)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X)
              ((MTIMES SIMP) $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $Y)
              ((MTIMES SIMP) $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VY)
              ((MTIMES SIMP) $VX $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))))
            ((MTIMES SIMP) 45. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VX 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VY 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.))))
            ((MTIMES SIMP) 45. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VX 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VZ 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))))
            ((MTIMES SIMP) 45. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VY 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VZ 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.)) $VX $VY $VZ $X $Y)
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY $X $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $X $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VZ $X $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $VZ $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY $VZ $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $VZ $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY $VZ $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $X $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VZ $X)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VZ $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X $Y)
              ((MTIMES SIMP) $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VY $X)
              ((MTIMES SIMP) $VX $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VY $Y)
              ((MTIMES SIMP) $VX $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $Y)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VZ)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $VZ)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $VZ)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $Y)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VY)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $VY)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY)
                ((MTIMES SIMP) $VY
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.))))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $Y)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VX)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.))))
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.))))))
            ((MTIMES SIMP) 27. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $VZ $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY $VZ $X $Y)))
            ((MTIMES SIMP) 27. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VZ $X $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $X $Y)))
            ((MTIMES SIMP) 27. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VY $X $Y)
              ((MTIMES SIMP) $VX $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X $Y)))))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VZ $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $VZ $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $VZ $X)))))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VZ $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $VZ $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $VZ $Y)))))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X $Y)))))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VY $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $VY $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X)
                ((MTIMES SIMP) $VY
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X)))))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VY $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $VY $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $Y)
                ((MTIMES SIMP) $VY
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $Y)))))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X $Y)))))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VX $X)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X)))))
            ((MTIMES SIMP) 135. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VX $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $Y)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $Y)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $Y)))))
            ((MTIMES SIMP) 27. ((MEXPT SIMP) 2. ((RAT SIMP) -11. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 27.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VX 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VY 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (73.
                     #A((70.) BASE-CHAR
                        . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 73.))
                   $VX 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (73.
                     #A((70.) BASE-CHAR
                        . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 73.))
                   $VY 2.)))
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (73.
                   #A((70.) BASE-CHAR
                      . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 73.))
                 $VZ 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (73.
                     #A((70.) BASE-CHAR
                        . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 73.))
                   $VX 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (73.
                     #A((70.) BASE-CHAR
                        . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 73.))
                   $VZ 2.)))
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (73.
                     #A((70.) BASE-CHAR
                        . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 73.))
                   $VY 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (73.
                     #A((70.) BASE-CHAR
                        . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 73.))
                   $VZ 2.)))
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.))))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 7. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VZ $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               $VZ $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $VZ $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VZ $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $VZ $X $Y)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 7. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VY $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $VY $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY $X $Y)
                ((MTIMES SIMP) $VY
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X $Y)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 7. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VX $X $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X $Y)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X $Y)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X $Y)))))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -11. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 27.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VX 2.)
                   $X)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VY 2.)
                   $X)))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VX 2.)
                   $X)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VZ 2.)
                   $X)))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VY 2.)
                   $X)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VZ 2.)
                   $X)))))))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -11. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 27.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $Y)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VX 2.)
                   $Y)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VY 2.)
                   $Y)))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $Y)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VX 2.)
                   $Y)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VZ 2.)
                   $Y)))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $Y)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VY 2.)
                   $Y)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VZ 2.)
                   $Y)))))))
            ((MTIMES SIMP) 81. ((MEXPT SIMP) 2. ((RAT SIMP) -11. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 27.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.)
               $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 $X $Y)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VX 2.)
                   $X $Y)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VY 2.)
                   $X $Y)))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X $Y)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VX 2.)
                   $X $Y)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VZ 2.)
                   $X $Y)))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VY 2.)
                 ((MEXPT SIMP
                   (73.
                    #A((70.) BASE-CHAR
                       . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 73.))
                  $VZ 2.)
                 $X $Y)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VY 2.)
                   $X $Y)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (73.
                      #A((70.) BASE-CHAR
                         . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 73.))
                    $VZ 2.)
                   $X $Y)))))))))) 
(ADD2LNC '|$basisP| $VALUES) 