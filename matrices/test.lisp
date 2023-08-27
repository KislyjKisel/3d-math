#|
 This file is a part of 3d-math
 (c) 2023 Shirakumo http://shirakumo.org (shirakumo@tymoon.eu)
|#

(in-package #:org.shirakumo.fraf.math.test)

(define-test matrices
  :parent 3d-math
  :depends-on (vectors))

(define-test matrix-struct
  :parent matrices)

(defun vector= (a b)
  (every #'= a b))

(defmacro define-matrix-struct-test (n)
  (let* ((matx (find-symbol (format NIL "~a~a" 'mat n)))
         (maty (find-symbol (format NIL "~a~a" 'mat (case n (2 3) (3 4) (4 2)))))
         (matx-p (find-symbol (format NIL "~a~a" matx '-p))))
    `(define-test ,matx
       :parent matrix-struct
       :compile-at :execute
       (of-type ,matx (,matx))
       (of-type ,matx (mcopy (,matx)))
       (true (,matx-p (,matx)))
       (false (,matx-p (,maty)))
       (is = 0 (miref (,matx) 0))
       (is = 0 (mcref (,matx) 0 0))
       (fail (miref (,matx) -1))
       (fail (miref (,matx) ,(* n n)))
       (fail (mcref (,matx) ,n 0))
       (of-type ,matx (mat ,@(loop repeat (* n n) collect 0)))
       (of-type ,matx (mcopy (,matx)))
       (true (mat-p (,matx)))
       (is = 0 (miref (,matx) 0))
       (is = 0 (mcref (,matx) 0 0))
       (fail (miref (,matx) -1))
       (fail (miref (,matx) ,(* n n)))
       (fail (mcref (,matx) ,n 0))
       (is = ,n (mcols (,matx)))
       (is = ,n (mrows (,matx))))))

(define-matrix-struct-test 2)
(define-matrix-struct-test 3)
(define-matrix-struct-test 4)

(define-test matn
  :parent matrix-struct
  :compile-at :execute
  (of-type mat2 (mat 2 2))
  (of-type mat3 (mat 3 3))
  (of-type mat4 (mat 4 4))
  (of-type matn (mat 1 2))
  (of-type matn (mcopy (mat 1 2)))
  (true (matn-p (mat 1 2)))
  (false (matn-p (mat2)))
  (is = 0 (miref (mat 1 2) 0))
  (is = 0 (mcref (mat 1 2) 0 0))
  (fail (miref (mat 1 2) -1))
  (fail (miref (mat 1 2) 2))
  (of-type matn (mcopy (matn 1 2)))
  (true (mat-p (mat 1 2)))
  (is = 0 (miref (mat 1 2) 0))
  (is = 0 (mcref (mat 1 2) 0 0))
  (fail (miref (mat 1 2) -1))
  (fail (miref (mat 1 2) 2))
  (is = 2 (mcols (mat 1 2)))
  (is = 1 (mrows (mat 1 2))))

(define-test matrix-comparison
  :parent matrices
  :depends-on (matrix-struct)
  (true (m= (mat2) 0))
  (true (m= 0 (mat2)))
  (false (m= (mat2) 1))
  (false (m= 1 (mat2)))
  (true (m= (mat2) (mat2)))
  (true (m= (matn 1 2) (matn 1 2)))
  (true (m= (mat 1 2 3 4) (mat 1 2 3 4)))
  (false (m= (mat 1 2 3 4) (mat 4 3 2 1)))
  (false (m= (mat 4 3 2 1) (mat 1 2 3 4)))
  (fail (m= (matn 1 2) (matn 2 1)))
  (fail (m= (mat2) (mat3)))
  (fail (m= (matn 2 3) (matn 3 2)))
  (true (m/= (mat2) 1))
  (false (m/= (mat2) 0))
  (true (m/= (mat 1 2 3 4) (mat 4 3 2 1)))
  (true (m/= (mat 1 1 1 1) (mat 1 1 1 0)))
  (false (m/= (mat2) (mat2)))
  (fail (m/= (mat2) (mat3)))
  (fail (m/= (matn 2 3) (matn 3 2)))
  (true (m< (mat2) 1))
  (false (m< 0 (mat2)))
  (true (m< (mat 1 2 3 4) (mat 2 3 4 5)))
  (false (m< (mat 1 2 3 4) (mat 1 2 3 4)))
  (false (m< (mat 0 0 0 0) (mat 0 1 1 1)))
  (fail (m< (mat2) (mat3)))
  (fail (m< (matn 2 3) (matn 3 2)))
  (true (m> (mat2) -1))
  (false (m> 0 (mat2)))
  (true (m> (mat 2 3 4 5) (mat 1 2 3 4)))
  (false (m> (mat 1 2 3 4) (mat 1 2 3 4)))
  (false (m> (mat 1 1 1 1) (mat 0 0 0 1)))
  (fail (m> (mat2) (mat3)))
  (fail (m> (matn 2 3) (matn 3 2)))
  (true (m<= (mat2) 0))
  (false (m<= 1 (mat2)))
  (true (m<= (mat 1 2 3 4) (mat 2 3 4 5)))
  (true (m<= (mat 1 2 3 4) (mat 1 2 3 4)))
  (true (m<= (mat 0 0 0 0) (mat 0 1 1 1)))
  (false (m<= (mat 1 1 1 1) (mat 0 0 0 0)))
  (fail (m<= (mat2) (mat3)))
  (fail (m<= (matn 2 3) (matn 3 2)))
  (true (m>= (mat2) 0))
  (false (m>= -1 (mat2)))
  (true (m>= (mat 2 3 4 5) (mat 1 2 3 4)))
  (true (m>= (mat 1 2 3 4) (mat 1 2 3 4)))
  (true (m>= (mat 1 1 1 1) (mat 0 0 0 1)))
  (false (m>= (mat 0 0 0 0) (mat 1 1 1 1)))
  (fail (m>= (mat2) (mat3)))
  (fail (m>= (matn 2 3) (matn 3 2))))

(define-test matrix-arithmetic
  :parent matrices
  :depends-on (matrix-comparison)
  (is m= (mat 1 1 1 1) (m+ (mat2 0) 1))
  (is m= (mat 1 2 3 4) (m+ (mat 0 1 2 3) 1))
  (is m= (mat 1 2 3 4) (m+ (mat 1 0 3 0) (mat 0 2 0 4)))
  (fail (m+ (mat2) (mat3)))
  (fail (m+ (matn 2 3) (matn 3 2)))
  (is m= (mat 0 0 0 0) (m- (mat2 1) 1))
  (is m= (mat 0 1 2 3) (m- (mat 1 2 3 4) 1))
  (is m= (mat 1 2 3 4) (m- (mat 2 2 4 4) (mat 1 0 1 0)))
  (fail (m- (mat2) (mat3)))
  (fail (m- (matn 2 3) (matn 3 2)))
  (is m= (mat 0 0 0 0) (m* (mat 0 0 0 0) 2))
  (is m= (mat 2 4 6 8) (m* (mat 1 2 3 4) 2))
  (is m= (mat 19 22 43 50) (m* (mat 1 2 3 4) (mat 5 6 7 8)))
  ;; (is m= (mat 3 4 6 8) (m* (matn 2 1 '(1 2)) (matn 1 2 '(3 4))))
  (is m= (mat 34 37 78 85) (m* (mat 1 2 3 4) (mat 10 11 12 13)))
  (is m= (matn 3 2 '(7 10 15 22 23 34)) (m* (matn 3 2 '(1 2 3 4 5 6)) (mat 1 2 3 4)))
  (fail (m* (mat 1 2 3 4) (matn 3 2 '(1 2 3 4 5 6))))
  (is m= (matn 2 3 '(9 12 15 19 26 33)) (m* (mat 1 2 3 4) (matn 2 3 '(1 2 3 4 5 6))))
  (is m= (matn 2 1 '(5 11)) (m* (mat 1 2 3 4) (matn 2 1 '(1 2))))
  (is m= (matn 2 6 '(15 18 21 24 27 30 31 38 45 52 59 66)) (m* (mat 1 2 3 4) (matn 2 6 (loop for x from 1 repeat 12 collect x))))
  (is m= (mat 84 90 96 201 216 231 318 342 366) (m* (mat 1 2 3 4 5 6 7 8 9) (mat 10 11 12 13 14 15 16 17 18)))
  (is m= (matn 4 3 '(30 36 42 66 81 96 102 126 150 138 171 204))
      (m* (matn 4 3 '(1 2 3 4 5 6 7 8 9 10 11 12)) (mat 1 2 3 4 5 6 7 8 9)))
  (fail (m* (mat 1 2 3 4 5 6 7 8 9) (matn 4 3 '(1 2 3 4 5 6 7 8 9 10 11 12))))
  (is m= (matn 3 4 '(38 44 50 56 83 98 113 128 128 152 176 200))
      (m* (mat 1 2 3 4 5 6 7 8 9) (matn 3 4 '(1 2 3 4 5 6 7 8 9 10 11 12))))
  (is m= (matn 3 6 '(54 60 66 72 78 84 117 132 147 162 177 192 180 204 228 252 276 300))
      (m* (mat 1 2 3 4 5 6 7 8 9) (matn 3 6 (loop for x from 1 repeat 18 collect x))))
  (is m= (mat 180 190 200 210 436 462 488 514 692 734 776 818 948 1006 1064 1122)
      (m* (mat 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16) (mat 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25)))
  (is m= (matn 5 4 '(90 100 110 120 202 228 254 280 314 356 398 440 426 484 542 600 538 612 686 760))
      (m* (matn 5 4 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)) (mat 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)))
  (fail (m* (mat 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16) (matn 5 4 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20))))
  (is m= (matn 4 5 '(110 120 130 140 150 246 272 298 324 350 382 424 466 508 550 518 576 634 692 750))
      (m* (mat 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16) (matn 4 5 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20))))
  (is m= (matn 4 6 '(130 140 150 160 170 180 290 316 342 368 394 420 450 492 534 576 618 660 610 668 726 784 842 900))
      (m* (mat 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16) (matn 4 6 (loop for x from 1 repeat 24 collect x))))
  (is m= (matn 5 5 '(350 365 380 395 410 850 890 930 970 1010 1350 1415 1480 1545 1610 1850 1940 2030 2120 2210 2350 2465 2580 2695 2810))
      (m* (matn 5 5 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25))
          (matn 5 5 '(10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34))))
  (is m= (matn 6 5 '(215 230 245 260 275 490 530 570 610 650 765 830 895 960 1025 1040 1130 1220 1310 1400 1315 1430 1545 1660 1775 1590 1730 1870 2010 2150))
      (m* (matn 6 5 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30))
          (matn 5 5 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25))))
  (fail (m* (matn 5 5 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25))
            (matn 6 5 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30))))
  (is m= (matn 5 6 '(255 270 285 300 315 330 580 620 660 700 740 780 905 970 1035 1100 1165 1230 1230 1320 1410 1500 1590 1680 1555 1670 1785 1900 2015 2130))
      (m* (matn 5 5 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25))
          (matn 5 6 '(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30))))
  (is m= (matn 5 5 '(40 43 46 49 52 90 97 104 111 118 140 151 162 173 184 190 205 220 235 250 240 259 278 297 316))
      (m* (matn 5 2 '(1 2 3 4 5 6 7 8 9 10))
          (matn 2 5 '(10 11 12 13 14 15 16 17 18 19))))
  (is v= (vec 17 39) (m* (mat 1 2 3 4) (vec 5 6)))
  (fail (m* (matn 2 1) (vec 0 0)))
  (fail (m* (matn 2 1) (mat4)))
  (fail (m* (matn 6 5) (matn 3 2)))
  (is m= (mat 1 1 1 1) (m/ (mat 2 2 2 2) 2))
  (skip-on (:arm64) "Division by zero may not generate a condition"
    (fail (m/ (mat2) (mat2)))
    (fail (m/ (matn 2 3) (matn 3 2))))
  (let ((mat (mat 1 2 3 4)))
    (is m= (mat 2 3 4 5) (nm+ mat 1))
    (is m= (mat 5 5 5 5) (nm+ mat (mat 3 2 1 0)))
    (is m= (mat 5 4 3 2) (nm- mat (mat 0 1 2 3)))
    (is m= (mat 4 3 2 1) (nm- mat 1))
    (is m= (mat 8 6 4 2) (nm* mat 2))
    (is m= (mat 4 3 2 1) (nm/ mat 2))
    (is m= (mat 13 20 5 8) (nm* mat (mat 1 2 3 4)))
    (is m= (mat 5 8 13 20) (n*m (mat 0 1 1 0) mat))))

(define-test matrix-construction
  :parent matrices
  :depends-on (matrix-comparison)
  (is m= (mat 1 0 0 1) (meye 2))
  (is vector= #(1.0 1.0 1.0 1.0 1.0) (mdiag (meye 5)))
  (true (every (lambda (a) (<= 0.0 a 1.0)) (marr (mrand 20)))))

(define-test matrix-sectioning
  :parent matrices
  :depends-on (matrix-comparison)
  (is vector= #(1 3) (mcol (mat 1 2 3 4) 0))
  (is vector= #(1 4 7) (mcol (mat 1 2 3 4 5 6 7 8 9) 0))
  (is vector= #(2 5 8) (mcol (mat 1 2 3 4 5 6 7 8 9) 1))
  (is vector= #(1 2) (mrow (mat 1 2 3 4) 0))
  (is vector= #(1 2 3) (mrow (mat 1 2 3 4 5 6 7 8 9) 0))
  (is vector= #(4 5 6) (mrow (mat 1 2 3 4 5 6 7 8 9) 1))
  (is vector= #(1.0 5.0 9.0) (mdiag (mat 1 2 3 4 5 6 7 8 9)))
  (is m= (mat 1 2 4 5) (mblock (mat 1 2 3 4 5 6 7 8 9) 0 0 2 2))
  (is m= (mat 5 6 8 9) (mblock (mat 1 2 3 4 5 6 7 8 9) 1 1 2 2))
  (let ((mat (mat 1 2 3 4 5 6 7 8 9)))
    (is m= (mat 7 8 9 4 5 6 1 2 3) (nmswap-row mat 0 2))
    (is m= (mat 8 7 9 5 4 6 2 1 3) (nmswap-col mat 0 1))))

(define-test matrix-math
  :parent matrices
  :depends-on (matrix-comparison)
  (is m= (mat 1 1 1 3 -1 -1 4 0 -1) (mlu (mat 1 1 1 3 2 2 4 4 3) NIL))
  (is m= (mat 4 4 3 0.75 -1 -0.25 0.25 0 0.25) (mlu (mat 1 1 1 3 2 2 4 4 3) T))
  (is ~= -2 (mdet (mat 1 2 3 4)))
  (is ~=  0 (mdet (mat 1 2 3 4 5 6 7 8 9)))
  (is ~=  0 (mdet (mat 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7)))
  (is ~= -1 (mdet (mat 1 1 1 1 3 2 2 2 4 4 3 3 5 5 5 4)))
  (is m= (mat -2 1 1.5 -0.5) (minv (mat 1 2 3 4)))
  (fail (minv (mat 1 2 3 4 5 6 7 8 9)))
  (fail (minv (mat 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7)))
  (is m= (mat -2 1 0 0 -1 -1 1 0 -1 0 -1 1 5 0 0 -1) (minv (mat 1 1 1 1 3 2 2 2 4 4 3 3 5 5 5 4)))
  (is m= (meye 5) (mtranspose (meye 5)))
  (is m= (mat4 1) (mtranspose (mat4 1)))
  (is m= (mat 1 4 7 2 5 8 3 6 9) (mtranspose (mat 1 2 3 4 5 6 7 8 9)))
  (is m= (matn 3 2 '(1 4 2 5 3 6)) (mtranspose (matn 2 3 '(1 2 3 4 5 6))))
  (is m= (matn 3 4 '(1 4 7 10 2 5 8 11 3 6 9 12)) (mtranspose (matn 4 3 '(1 2 3 4 5 6 7 8 9 10 11 12))))
  (is ~= 10 (mtrace (mat 1 1 1 1 3 2 2 2 4 4 3 3 5 5 5 4)))
  (is = (mdet (mat 1 2 4 5)) (mminor (mat 1 2 3 4 5 6 7 8 9) 0 0))
  (is = (mdet (mat 1 3 7 9)) (mminor (mat 1 2 3 4 5 6 7 8 9) 1 1))
  (is = (mdet (mat 1 3 7 9)) (mcofactor (mat 1 2 3 4 5 6 7 8 9) 1 1))
  (is m= (mat -3 6 -3 6 -12 6 -3 6 -3) (mcof (mat 1 2 3 4 5 6 7 8 9)))
  (is m= (mat 2 -1 0 0 1 1 -1 0 1 0 1 -1 -5 0 0 1) (madj (mat 1 1 1 1 3 2 2 2 4 4 3 3 5 5 5 4)))
  (is m= (mat 2 1 1 1) (mpivot (mat 2 1 1 1)))
  (is m= (mat 1 0 0 1) (nth-value 1 (mpivot (mat 2 1 1 1))))
  (is =  0 (nth-value 2 (mpivot (mat 2 1 1 1))))
  (is m= (mat 2 1 1 1) (mpivot (mat 1 1 2 1)))
  (is m= (mat 0 1 1 0) (nth-value 1 (mpivot (mat 1 1 2 1))))
  (is =  1 (nth-value 2 (mpivot (mat 1 1 2 1))))
  (is ~= 18 (m1norm (mat 1 2 3 4 5 6 7 8 9)))
  (is ~= 24 (minorm (mat 1 2 3 4 5 6 7 8 9)))
  (is ~= (sqrt 285) (m2norm (mat 1 2 3 4 5 6 7 8 9)))
  (multiple-value-bind (Q R) (finish (mqr (mat 1 1 1 3 2 2 4 4 3)))
    (is m~= (mat 0.19611613  0.14269547  0.9701426
                 0.58834845 -0.80860764  7.450581e-9
                 0.78446454  0.5707819  -0.24253567) Q)
    (is m~= (mat 5.0990195 4.510671  3.7262068
                 0.0       0.8086077 0.23782583
                 0.0       0.0       0.24253565) R))
  (let ((values (finish (meigen (mat 1 1 1 3 2 2 4 4 3) 50))))
    (is ~= 6.6264195 (aref values 0))
    (is ~= -0.39977652 (aref values 1))
    (is ~= -0.22664261 (aref values 2))))

(define-test matrix-transforms
  :parent matrices
  :depends-on (matrix-comparison)
  (is m= (mat 1 0 0 5 0 1 0 6 0 0 1 7 0 0 0 1) (mtranslation (vec 5 6 7)))
  (is m= (mat 5 0 0 0 0 6 0 0 0 0 7 0 0 0 0 1) (mscaling (vec 5 6 7)))
  (let ((c (cos 90))
        (s (sin 90)))
    (is m= (mat 1 0 0 0 0 c (- s) 0 0 s c 0 0 0 0 1) (mrotation (vec 1 0 0) 90))
    (is m= (mat c 0 s 0 0 1 0 0 (- s) 0 c 0 0 0 0 1) (mrotation (vec 0 1 0) 90))
    (is m= (mat c (- s) 0 0 s c 0 0 0 0 1 0 0 0 0 1) (mrotation (vec 0 0 1) 90)))
  (let ((mat (mat 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5)))
    (is m= (mat  0  1  2 11  4  5  6 39  8  9  0 27  2  3  4 25) (nmtranslate mat (vec 1 2 3)))
    (is m= (mat  0  1  0 11  8  5  0 39 16  9  0 27  4  3  0 25) (nmscale mat (vec 2 1 0)))
    (is m~= (mat 0.0 1.0 0.0 11.0 -3.584589 5.0 7.1519732 39.0 -7.169178 9.0 14.3039465 27.0
                 -1.7922945 3.0 3.5759866 25.0) (nmrotate mat (vec 0 1 0) 90))))
