;;; -*- Mode: LISP; package:maxima; syntax:common-lisp; -*- 
(in-package :maxima)
(DSKSETQ |$varsC| '((MLIST SIMP) $X $Y)) 
(ADD2LNC '|$varsC| $VALUES) 
(DSKSETQ |$varsP| '((MLIST SIMP) $X $Y $VX)) 
(ADD2LNC '|$varsP| $VALUES) 
(DSKSETQ |$basisC|
         '((MLIST SIMP
            (10.
             #A((67.) BASE-CHAR
                . "/Users/junoravin/gkylcas/maxima/g0/basis-precalc/basis-pre-calc.mac")
             SRC |$writeBasisToFile| 7.))
           ((MLIST SIMP
             (33.
              #A((50.) BASE-CHAR
                 . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 31.))
            ((RAT SIMP) 1. 2.)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 2.) $X $Y))
           ((MLIST SIMP
             (33.
              #A((50.) BASE-CHAR
                 . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 31.))
            ((RAT SIMP) 1. 2.)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((RAT SIMP) 1. 2.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 2.) $X $Y)
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $X 2.)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $Y 2.)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.)
               $Y)))
            ((MTIMES SIMP) ((RAT SIMP) 3. 4.)
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
              ((MTIMES SIMP) $X
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))))
            ((MTIMES SIMP) ((RAT SIMP) 45. 8.)
             ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))))))) 
(ADD2LNC '|$basisC| $VALUES) 
(DSKSETQ |$basisP|
         '((MLIST SIMP
            (10.
             #A((67.) BASE-CHAR
                . "/Users/junoravin/gkylcas/maxima/g0/basis-precalc/basis-pre-calc.mac")
             SRC |$writeBasisToFile| 7.))
           ((MLIST SIMP
             (33.
              #A((50.) BASE-CHAR
                 . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 31.))
            ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VX)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $X $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $VX $X)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $VX $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $X $Y))
           ((MLIST SIMP
             (33.
              #A((50.) BASE-CHAR
                 . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
              SRC |$gsOrthoNorm| 31.))
            ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $X)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $Y)
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 1. 2.)) $VX)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $X $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $VX $X)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.)) $VX $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $X 2.)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $Y 2.)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $VX 2.)))
            ((MTIMES SIMP) ((MEXPT SIMP) 2. ((RAT SIMP) -3. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.)) $VX $X $Y)
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.)
               $Y)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
              ((MTIMES SIMP) $X
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.))))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $VX 2.)
               $X)))
            ((MTIMES SIMP) 3. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 15. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $VX 2.)
               $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $Y)
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.)
               $Y)))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX $X)
              ((MTIMES SIMP) $VX $X
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))))
            ((MTIMES SIMP) 9. ((MEXPT SIMP) 2. ((RAT SIMP) -5. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $VX 2.)
               $X $Y)))
            ((MTIMES SIMP) 45. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))))
            ((MTIMES SIMP) 45. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $VX 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $VX 2.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.))))
            ((MTIMES SIMP) 45. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $VX 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $VX 2.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $VX)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 2.))))
              ((MTIMES SIMP) $VX
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $VX)
                ((MTIMES SIMP) $VX
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $VX 2.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.)
               $Y)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $VX 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 2.)
                 $Y)))))
            ((MTIMES SIMP) 5. ((MEXPT SIMP) 2. ((RAT SIMP) -7. 2.))
             ((MEXPT SIMP) 3. ((RAT SIMP) 5. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 9.) $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $VX 2.)
                 $X)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $VX 2.)
               $X
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP) $X
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))))))
            ((MTIMES SIMP) 27. ((MEXPT SIMP) 2. ((RAT SIMP) -9. 2.))
             ((MEXPT SIMP) 5. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 27.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $VX 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $VX 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $X 2.)))
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 2.))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 9.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 2.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $VX 2.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 2.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $VX 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $Y 2.)))
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $VX 2.)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 9.)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $X 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $Y 2.)))
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 2.)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))))))))) 
(ADD2LNC '|$basisP| $VALUES) 