;;; -*- Mode: LISP; package:maxima; syntax:common-lisp; -*- 
(in-package :maxima)
(DSKSETQ |$varsC| '((MLIST SIMP) $X)) 
(ADD2LNC '|$varsC| $VALUES) 
(DSKSETQ |$varsP| '((MLIST SIMP) $X $VX $VY $VZ)) 
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
            ((MEXPT SIMP) 2. ((RAT SIMP) -1. 2.))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -1. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)))) 
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
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VX)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VY)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VZ)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $X)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VY $X)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $VY)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VZ $X)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VX $VZ)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.) $VY $VZ)
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (73.
                 #A((70.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 73.))
               $VX 2.)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (73.
                 #A((70.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 73.))
               $VY 2.)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (73.
                 #A((70.) BASE-CHAR
                    . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 73.))
               $VZ 2.)))
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VY $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VZ $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VY $VZ $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 4.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $VY $VZ)
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
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VX 2.)
               $VY)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VY 2.))))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))))
            ((MTIMES SIMP) ((RAT SIMP) 3. 8.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VY)
              ((MTIMES SIMP) $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))))
            ((MTIMES SIMP) ((RAT SIMP) 9. 4.) $VX $VY $VZ $X)
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $VY)
              ((MTIMES SIMP) $VX $VY
               ((MEXPT SIMP
                 (73.
                  #A((70.) BASE-CHAR
                     . "/Users/manaure/Documents/gkeyll/code/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 73.))
                $VZ 2.))))
            ((MTIMES SIMP) ((RAT SIMP) 45. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 45. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 45. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 8.)
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
            ((MTIMES SIMP) ((RAT SIMP) 5. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 5. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 5. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 5. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 5. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 5. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 135. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 135. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 135. 16.)
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
            ((MTIMES SIMP) ((RAT SIMP) 27. 32.)
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
            ((MTIMES SIMP) ((RAT SIMP) 9. 32.)
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
                   $X)))))))))) 
(ADD2LNC '|$basisP| $VALUES) 