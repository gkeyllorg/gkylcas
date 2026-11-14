;;; -*- Mode: LISP; package:maxima; syntax:common-lisp; -*- 
(in-package :maxima)
(DSKSETQ |$varsC| '((MLIST SIMP) $X $Y)) 
(ADD2LNC '|$varsC| $VALUES) 
(DSKSETQ |$basisC|
         '((MLIST SIMP
            (9.
             #A((72.) BASE-CHAR
                . "/Users/junoravin/gkylcas/maxima/g0/basis-precalc/basis-pre-cdim-calc.mac")
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
                $Y 2.)))))
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
            ((MTIMES SIMP) ((RAT SIMP) 5. 4.)
             ((MEXPT SIMP) 7. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $X 3.)))
            ((MTIMES SIMP) ((RAT SIMP) 5. 4.)
             ((MEXPT SIMP) 7. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $Y)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $Y 3.)))
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
                $Y 2.))))
            ((MTIMES SIMP) ((RAT SIMP) 5. 4.)
             ((MEXPT SIMP) 21. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 3.)
               $Y)))
            ((MTIMES SIMP) ((RAT SIMP) 5. 4.)
             ((MEXPT SIMP) 21. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X $Y)
              ((MTIMES SIMP) $X
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 3.))))
            ((MTIMES SIMP) ((RAT SIMP) 15. 8.)
             ((MEXPT SIMP) 35. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 3.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 3.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP) $X
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))))))
            ((MTIMES SIMP) ((RAT SIMP) 15. 8.)
             ((MEXPT SIMP) 35. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $Y)
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 2.)
                 $Y)))
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
                $Y 3.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $Y)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 3.)))))
            ((MTIMES SIMP) ((RAT SIMP) 175. 8.)
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -9. 25.) $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 3.)
                 $Y)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 3.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 3.))
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X $Y)
                ((MTIMES SIMP) $X
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 3.)))))))
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
            ((MTIMES SIMP) ((RAT SIMP) 5. 4.)
             ((MEXPT SIMP) 7. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $X 3.)))
            ((MTIMES SIMP) ((RAT SIMP) 5. 4.)
             ((MEXPT SIMP) 7. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $Y)
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $Y 3.)))
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
                $Y 2.))))
            ((MTIMES SIMP) ((RAT SIMP) 5. 4.)
             ((MEXPT SIMP) 21. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 3.)
               $Y)))
            ((MTIMES SIMP) ((RAT SIMP) 5. 4.)
             ((MEXPT SIMP) 21. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X $Y)
              ((MTIMES SIMP) $X
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 3.))))
            ((MTIMES SIMP) ((RAT SIMP) 105. 16.)
             ((MPLUS SIMP) ((RAT SIMP) -1. 5.)
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 2.)))
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $X 4.)))
            ((MTIMES SIMP) ((RAT SIMP) 105. 16.)
             ((MPLUS SIMP) ((RAT SIMP) -1. 5.)
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 2.)))
              ((MEXPT SIMP
                (74.
                 #A((50.) BASE-CHAR
                    . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                 SRC |$calcPowers| 74.))
               $Y 4.)))
            ((MTIMES SIMP) ((RAT SIMP) 15. 8.)
             ((MEXPT SIMP) 35. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 3.)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 3.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP) $X
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))))))
            ((MTIMES SIMP) ((RAT SIMP) 15. 8.)
             ((MEXPT SIMP) 35. ((RAT SIMP) 1. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $Y)
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 2.)
                 $Y)))
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
                $Y 3.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $Y)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 3.)))))
            ((MTIMES SIMP) ((RAT SIMP) 35. 16.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $Y)
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 4.)
               $Y)
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 2.)
                 $Y)))))
            ((MTIMES SIMP) ((RAT SIMP) 35. 16.)
             ((MEXPT SIMP) 3. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $X)
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP) $X
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))))
              ((MTIMES SIMP) $X
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 4.))))
            ((MTIMES SIMP) ((RAT SIMP) 175. 8.)
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -9. 25.) $X $Y)
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 3.)
                 $Y)))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 3.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 3.))
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X $Y)
                ((MTIMES SIMP) $X
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 3.))))))
            ((MTIMES SIMP) ((RAT SIMP) 63. 32.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 15.)
              ((MTIMES SIMP) ((RAT SIMP) -2. 7.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 5.)
                ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $X 2.)))
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 4.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 5.)
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
                $X 4.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 2.))
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
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
                  $Y 2.))))))
            ((MTIMES SIMP) ((RAT SIMP) 63. 32.)
             ((MEXPT SIMP) 5. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((RAT SIMP) -1. 15.)
              ((MTIMES SIMP) ((RAT SIMP) -1. 5.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -2. 7.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
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
                $Y 4.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 5.)
                ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $Y 2.)))
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 4.)))))
            ((MTIMES SIMP) ((RAT SIMP) 75. 32.)
             ((MEXPT SIMP) 7. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 25.) $Y)
              ((MTIMES SIMP) ((RAT SIMP) -18. 35.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 2.)
                 $Y)))
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $Y)
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 4.)
                 $Y)
                ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (74.
                      #A((50.) BASE-CHAR
                         . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 74.))
                    $X 2.)
                   $Y)))))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 4.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 3.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $Y)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 3.)))
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $Y)
                ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $Y)
                  ((MTIMES SIMP)
                   ((MEXPT SIMP
                     (74.
                      #A((50.) BASE-CHAR
                         . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 74.))
                    $X 2.)
                   $Y)))
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
                  $Y 3.))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $Y)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $Y 3.)))))))
            ((MTIMES SIMP) ((RAT SIMP) 75. 32.)
             ((MEXPT SIMP) 7. ((RAT SIMP) 3. 2.))
             ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 25.) $X)
              ((MTIMES SIMP) ((RAT SIMP) -1. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 3.)))
              ((MTIMES SIMP) ((RAT SIMP) -18. 35.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                ((MTIMES SIMP) $X
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))))
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $X)
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -3. 5.) $X)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $X 3.)))
                ((MTIMES SIMP)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $X 3.)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))
                ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                  ((MTIMES SIMP) $X
                   ((MEXPT SIMP
                     (74.
                      #A((50.) BASE-CHAR
                         . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 74.))
                    $Y 2.))))))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 3.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 4.))
              ((MTIMES SIMP) ((RAT SIMP) -3. 5.)
               ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 5.) $X)
                ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
                 ((MPLUS SIMP) ((MTIMES SIMP) ((RAT SIMP) -1. 3.) $X)
                  ((MTIMES SIMP) $X
                   ((MEXPT SIMP
                     (74.
                      #A((50.) BASE-CHAR
                         . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                      SRC |$calcPowers| 74.))
                    $Y 2.))))
                ((MTIMES SIMP) $X
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 4.))))))
            ((MTIMES SIMP) ((RAT SIMP) 11025. 128.)
             ((MPLUS SIMP) ((RAT SIMP) -1. 25.)
              ((MTIMES SIMP) ((RAT SIMP) -6. 35.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -1. 5.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 5.)
                ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $X 2.)))
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $X 4.)))
              ((MTIMES SIMP) ((RAT SIMP) -6. 35.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 2.)))
              ((MTIMES SIMP) ((RAT SIMP) -36. 49.)
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
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 15.)
                ((MTIMES SIMP) ((RAT SIMP) -2. 7.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $X 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 5.)
                  ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
                   ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                    ((MEXPT SIMP
                      (74.
                       #A((50.) BASE-CHAR
                          . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                       SRC |$calcPowers| 74.))
                     $X 2.)))
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $X 4.)))
                ((MTIMES SIMP) ((RAT SIMP) -1. 5.)
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
                  $X 4.)
                 ((MEXPT SIMP
                   (74.
                    #A((50.) BASE-CHAR
                       . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                    SRC |$calcPowers| 74.))
                  $Y 2.))
                ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
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
                    $Y 2.))))))
              ((MTIMES SIMP)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $X 4.)
               ((MEXPT SIMP
                 (74.
                  #A((50.) BASE-CHAR
                     . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                  SRC |$calcPowers| 74.))
                $Y 4.))
              ((MTIMES SIMP) ((RAT SIMP) -1. 5.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 5.)
                ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $Y 2.)))
                ((MEXPT SIMP
                  (74.
                   #A((50.) BASE-CHAR
                      . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                   SRC |$calcPowers| 74.))
                 $Y 4.)))
              ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
               ((MPLUS SIMP) ((RAT SIMP) -1. 15.)
                ((MTIMES SIMP) ((RAT SIMP) -1. 5.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $X 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -2. 7.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $Y 2.)))
                ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
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
                  $Y 4.))
                ((MTIMES SIMP) ((RAT SIMP) -1. 3.)
                 ((MPLUS SIMP) ((RAT SIMP) -1. 5.)
                  ((MTIMES SIMP) ((RAT SIMP) -6. 7.)
                   ((MPLUS SIMP) ((RAT SIMP) -1. 3.)
                    ((MEXPT SIMP
                      (74.
                       #A((50.) BASE-CHAR
                          . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                       SRC |$calcPowers| 74.))
                     $Y 2.)))
                  ((MEXPT SIMP
                    (74.
                     #A((50.) BASE-CHAR
                        . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
                     SRC |$calcPowers| 74.))
                   $Y 4.)))))))))) 
(ADD2LNC '|$basisC| $VALUES) 
(DSKSETQ |$basisConstant|
         '((MLIST SIMP
            (33.
             #A((50.) BASE-CHAR
                . "/Users/junoravin/gkylcas/maxima/g0/modal-basis.mac")
             SRC |$gsOrthoNorm| 31.))
           ((RAT SIMP) 1. 2.))) 
(ADD2LNC '|$basisConstant| $VALUES) 