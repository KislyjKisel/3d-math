#|
 This file is a part of 3d-math
 (c) 2023 Shirakumo http://shirakumo.org (shirakumo@tymoon.eu)
|#

(in-package #:org.shirakumo.fraf.math.quaternions)

(define-template random <t> (x)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x)
               (return-type ,(lisp-type type))
               inline)
      (let* ((u (random (,<t> 1.0)))
             (v (random (,<t> 1.0)))
             (w (random (,<t> 1.0)))
             (sqr1-u (sqrt (- 1 u)))
             (sqr-u (sqrt u))
             (2piv (* 2 (,<t> PI) v))
             (2piw (* 2 (,<t> PI) w)))
        (psetf ,(place-form type 0 'x) (* sqr1-u (sin 2piv))
               ,(place-form type 1 'x) (* sqr1-u (cos 2piv))
               ,(place-form type 2 'x) (* sqr-u (sin 2piw))
               ,(place-form type 3 'x) (* sqr-u (cos 2piw))))
      x)))

(define-template zero <t> (x)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x)
               (return-type ,(lisp-type type))
               inline)
      (psetf ,(place-form type 0 'x) (,<t> 0)
             ,(place-form type 1 'x) (,<t> 0)
             ,(place-form type 2 'x) (,<t> 0)
             ,(place-form type 3 'x) (,<t> 1))
      x)))

(define-template conjugate <t> (x a)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x a)
               (return-type ,(lisp-type type))
               (dynamic-extent a)
               inline)
      (psetf ,(place-form type 0 'x) (- ,(place-form type 0 'a))
             ,(place-form type 1 'x) (- ,(place-form type 1 'a))
             ,(place-form type 2 'x) (- ,(place-form type 2 'a))
             ,(place-form type 3 'x) ,(place-form type 3 'a))
      x)))

(define-template inverses <t> (x a)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x a)
               (return-type ,(lisp-type type))
               (dynamic-extent a)
               inline)
      (let* ((len (,(compose-name #\/ '1quatreduce '+ 'sqr <t>) a))
             (div (if (~= 0 len) (,<t> 1) (/ (,<t> -1) len))))
        (psetf ,(place-form type 0 'x) (* ,(place-form type 0 'a) div)
               ,(place-form type 1 'x) (* ,(place-form type 1 'a) div)
               ,(place-form type 2 'x) (* ,(place-form type 2 'a) div)
               ,(place-form type 3 'x) (* ,(place-form type 3 'a) (- div))))
      x)))

(define-template qfrom-angle <t> (x axis angle)
  (let ((type (type-instance 'quat-type <t>))
        (vtype (type-instance 'vec-type 3 <t>)))
    `((declare (type ,(lisp-type type) x)
               (type ,(lisp-type vtype) axis)
               (type ,<t> angle)
               (return-type ,(lisp-type type))
               (dynamic-extent axis)
               inline)
      (let ((s (sin (* (,<t> 0.5) angle))))
        (psetf ,(place-form type 0 'x) (* s ,(place-form vtype 0 'axis))
               ,(place-form type 1 'x) (* s ,(place-form vtype 1 'axis))
               ,(place-form type 2 'x) (* s ,(place-form vtype 2 'axis))
               ,(place-form type 3 'x) (cos (* (,<t> 0.5) angle)))
        x))))

(define-template qtowards <t> (x from to)
  (let ((type (type-instance 'quat-type <t>))
        (vtype (type-instance 'vec-type 3 <t>)))
    `((declare (type ,(lisp-type type) x)
               (type ,(lisp-type vtype) from to)
               (return-type ,(lisp-type type))
               (dynamic-extent from to)
               inline)
      (let ((ff (vcopy from))
            (tt (vcopy to)))
        (declare (dynamic-extent ff tt))
        (cond ((v= ff tt)
               (,(compose-name #\/ 'zero <t>) x))
              ((and (= ,(place-form vtype 0 'ff) (- ,(place-form vtype 0 'tt)))
                    (= ,(place-form vtype 1 'ff) (- ,(place-form vtype 1 'tt)))
                    (= ,(place-form vtype 2 'ff) (- ,(place-form vtype 2 'tt))))
               (let ((ortho (cond ((< (abs ,(place-form vtype :y 'ff)) (abs ,(place-form vtype :x 'ff)))
                                   (load-time-value (,(lisp-type vtype) 0 1 0)))
                                  ((and (< (abs ,(place-form vtype :z 'ff)) (abs ,(place-form vtype :y 'ff)))
                                        (< (abs ,(place-form vtype :z 'ff)) (abs ,(place-form vtype :x 'ff))))
                                   (load-time-value (,(lisp-type vtype) 0 0 1)))
                                  (T
                                   (load-time-value (,(lisp-type vtype) 1 0 0))))))
                 (nvunit (!vc x from ortho))
                 (setf ,(place-form type 3 'x) (,<t> 0))))
              (T
               (let ((half (nvunit (v+ ff tt))))
                 (declare (dynamic-extent half))
                 (!vc x ff tt)
                 (setf ,(place-form type 3 'x) (v. from half)))))
        x))))

(define-template qangle <t> (q)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) q)
               (return-type ,<t>)
               (dynamic-extent q)
               inline)
      (let ((length (vlength q)))
        (if (= 0 length)
            (,<t> 0)
            (* (,<t> 2) (atan length ,(place-form type 3 'q))))))))

(define-template set-qangle <t> (angle x)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x)
               (type ,<t> angle)
               (return-type ,<t>)
               inline)
      (setf ,(place-form type 3 'x) (cos (* (,<t> 0.5) angle)))
      angle)))

(define-template 2quatop <op> <t> (x a b)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x a b)
               (return-type ,(lisp-type type))
               (dynamic-extent a b)
               inline)
      (psetf ,@(loop for i from 0 below 4
                     collect (place-form type i 'x)
                     collect `(,<op> ,(place-form type i 'a)
                                     ,(place-form type i 'b))))
      x)))

(define-template squatop <op> <st> <t> (x a s)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x a)
               (type ,(case <st> (<t> <t>) (T <st>)) s)
               (return-type ,(lisp-type type))
               (dynamic-extent a)
               inline)
      (let ((s (,<t> s)))
        (psetf ,@(loop for i from 0 below 4
                       collect (place-form type i 'x)
                       collect `(,<op> ,(place-form type i 'a) s))))
      x)))

(define-template 1quatop <op> <t> (x a)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x a)
               (return-type ,(lisp-type type))
               (dynamic-extent a)
               inline)
      (psetf ,@(loop for i from 0 below 4
                     collect (place-form type i 'x)
                     collect `(,<op> ,(place-form type i 'a))))
      x)))

(define-template 2quatreduce <red> <comb> rtype <t> (a b)
  (let ((type (type-instance 'quat-type <t>))
        (rtype (case rtype
                 (<t> <t>)
                 (float (case <t> (f64 'f64) (T 'f32)))
                 (T rtype))))
    `((declare (type ,(lisp-type type) a b)
               (return-type ,rtype)
               (dynamic-extent a b)
               inline)
      (,(if (member rtype '(f32 f64 i32 u32)) rtype 'progn)
       (,<red> ,@(loop for i from 0 below 4
                       collect `(,<comb> ,(place-form type i 'a)
                                         ,(place-form type i 'b))))))))

(define-template 1quatreduce <red> <comb> rtype <t> (a)
  (let ((type (type-instance 'quat-type <t>))
        (rtype (case rtype
                 (<t> <t>)
                 (float (case <t> (f64 'f64) (T 'f32)))
                 (T rtype))))
    `((declare (type ,(lisp-type type) a)
               (return-type ,rtype)
               (dynamic-extent a)
               inline)
      (,(if (member rtype '(f32 f64 i32 u32)) rtype 'progn)
       (,<red> ,@(loop for i from 0 below 4
                       collect `(,<comb> ,(place-form type i 'a))))))))

(define-template squatreduce <red> <comb> <st> rtype <t> (a s)
  (let ((type (type-instance 'quat-type <t>))
        (rtype (case rtype
                 (<t> <t>)
                 (float (case <t> (f64 'f64) (T 'f32)))
                 (T rtype))))
    `((declare (type ,(lisp-type type) a)
               (type ,(case <st> (<t> <t>) (T <st>)) s)
               (return-type ,rtype)
               (dynamic-extent a)
               inline)
      (let ((s (,<t> s)))
        (,(if (member rtype '(f32 f64 i32 u32)) rtype 'progn)
         (,<red> ,@(loop for i from 0 below 4
                         collect `(,<comb> ,(place-form type i 'a) s))))))))

(define-template q*q <t> (x a b)
  (let* ((type (type-instance 'quat-type <t>))
         (xa (place-form type :x 'a)) (xb (place-form type :x 'b))
         (ya (place-form type :y 'a)) (yb (place-form type :y 'b))
         (za (place-form type :z 'a)) (zb (place-form type :z 'b))
         (wa (place-form type :w 'a)) (wb (place-form type :w 'b)))
    `((declare (type ,(lisp-type type) x a b)
               (return-type ,(lisp-type type))
               (dynamic-extent a b)
               inline)
      (psetf ,(place-form type :x 'x) (+ (+ (* ,xb ,wa)) (+ (* ,yb ,za)) (- (* ,zb ,ya)) (+ (* ,wb ,xa)))
             ,(place-form type :y 'x) (+ (- (* ,xb ,za)) (+ (* ,yb ,wa)) (+ (* ,zb ,xa)) (+ (* ,wb ,ya)))
             ,(place-form type :z 'x) (+ (+ (* ,xb ,ya)) (- (* ,yb ,xa)) (+ (* ,zb ,wa)) (+ (* ,wb ,za)))
             ,(place-form type :w 'x) (+ (- (* ,xb ,xa)) (- (* ,yb ,ya)) (- (* ,zb ,za)) (+ (* ,wb ,wa))))
      x)))

(define-template q*v <t> (x q v)
  (let ((type (type-instance 'quat-type <t>))
        (vtype (type-instance 'vec-type 3 <t>)))
    `((declare (type ,(lisp-type type) q)
               (type ,(lisp-type vtype) x v)
               (return-type ,(lisp-type vtype))
               (dynamic-extent q v)
               inline)
      (let* ((qx ,(place-form type :x 'q)) (vx ,(place-form vtype :x 'v))
             (qy ,(place-form type :y 'q)) (vy ,(place-form vtype :y 'v))
             (qz ,(place-form type :z 'q)) (vz ,(place-form vtype :z 'v))

             (qw2 (* (qw q) (qw q)))
             (2qw (* 2.0 (qw q)))
             (q.q (- qw2 (v. q q)))
             (2q.v (* 2.0 (v. q v))))
        (setf ,(place-form vtype :x 'x) (+ (* qx 2q.v) (* vx q.q) (* (- (* qy vz) (* qz vy)) 2qw))
              ,(place-form vtype :y 'x) (+ (* qy 2q.v) (* vy q.q) (* (- (* qz vx) (* qx vz)) 2qw))
              ,(place-form vtype :z 'x) (+ (* qz 2q.v) (* vz q.q) (* (- (* qx vy) (* qy vx)) 2qw)))
        x))))

(define-template q+* <t> (x a b s)
  (let ((type (type-instance 'quat-type <t>))
        (vtype (type-instance 'vec-type 3 <t>)))
    `((declare (type ,(lisp-type type) x a)
               (type ,(lisp-type vtype) b)
               (type ,<t> s)
               (return-type ,(lisp-type type))
               (dynamic-extent a b))
      (let* ((tmp (,(lisp-type type)
                    (* s ,(place-form vtype :x 'b))
                    (* s ,(place-form vtype :y 'b))
                    (* s ,(place-form vtype :z 'b))
                    (,<t> 0))))
        (declare (dynamic-extent tmp))
        (,(compose-name #\/ '1quatop 'identity <t>) x a)
        (,(compose-name #\/ 'q*q <t>) x x tmp)
        (,(compose-name #\/ 'squatop '* '<t> <t>) x x (,<t> 0.5))
        (,(compose-name #\/ '2quatop '+ <t>) x x a)))))

(define-template qunit <t> (x q)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x q)
               (return-type ,(lisp-type type))
               (dynamic-extent q)
               inline)
      (let ((len (/ (the ,<t> (sqrt (,(compose-name #\/ '1quatreduce '+ 'sqr <t>) q))))))
        (setf ,@(loop for i from 0 below 4
                      collect (place-form type i 'x)
                      collect `(* len ,(place-form type i 'x))))
        x))))

(define-template qunit* <t> (x q)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x q)
               (return-type ,(lisp-type type))
               (dynamic-extent q)
               inline)
      (let ((len (the ,<t> (sqrt (,(compose-name #\/ '1quatreduce '+ 'sqr <t>) q)))))
        (cond ((= 0 len)
               (setf ,@(loop for i from 0 below 4
                             collect (place-form type i 'x)
                             collect `(,<t> 0))))
              (T
               (setf len (/ len))
               (setf ,@(loop for i from 0 below 4
                             collect (place-form type i 'x)
                             collect `(* len ,(place-form type i 'x))))))
        x))))

(define-template qexpt <t> (x q e)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x q)
               (return-type ,(lisp-type type))
               (type ,<t> e)
               (dynamic-extent q)
               inline)
      (let* ((f (* e (acos (the (,<t> -1.0 +1.0) ,(place-form type :w 'q)))))
             (axis (,(lisp-type type)))
             (cos/2 (cos f))
             (sin/2 (sin f)))
        (declare (dynamic-extent axis))
        (,(compose-name #\/ 'qunit <t>) axis q)
        (setf ,(place-form type :x 'x) (* ,(place-form type :x 'axis) sin/2)
              ,(place-form type :y 'x) (* ,(place-form type :y 'axis) sin/2)
              ,(place-form type :z 'x) (* ,(place-form type :z 'axis) sin/2)
              ,(place-form type :w 'x) cos/2))
      x)))

(define-template qlookat <t> (x dir up)
  (let ((type (type-instance 'quat-type <t>))
        (vtype (type-instance 'vec-type 3 <t>)))
    `((declare (type ,(lisp-type type) x)
               (type ,(lisp-type vtype) dir up)
               (return-type ,(lisp-type type))
               (dynamic-extent dir up)
               inline)
      (let* ((f (vunit* dir))
             (u (vunit* up))
             (r (vc u f))
             (object-up (,(lisp-type type))))
        (declare (dynamic-extent f u r object-up))
        (!vc u f r)
        (,(compose-name #\/ 'qtowards <t>) x (load-time-value (,(lisp-type vtype) 0 0 1)) f)
        (,(compose-name #\/ 'q*v <t>) object-up x (load-time-value (,(lisp-type vtype) 0 1 0)))
        (,(compose-name #\/ 'qtowards <t>) object-up object-up u)
        (,(compose-name #\/ 'q*q <t>) x x object-up)
        (,(compose-name #\/ 'qunit <t>) x x)))))

(define-template qmat <s> <t> (x q)
  (let ((type (type-instance 'quat-type <t>))
        (mtype (type-instance 'mat-type <s> <t>)))
    `((declare (type ,(lisp-type type) q)
               (type ,(lisp-type mtype) x)
               (return-type ,(lisp-type mtype))
               (dynamic-extent q))
      (let* ((xa ,(place-form mtype :arr 'x))
             (x ,(place-form type :x 'q))
             (y ,(place-form type :y 'q))
             (z ,(place-form type :z 'q))
             (w ,(place-form type :w 'q))
             (tx (* (,<t> 2) x)) (ty (* (,<t> 2) y)) (tz (* (,<t> 2) z))
             (twx (* tx w)) (twy (* ty w)) (twz (* tz w))
             (txx (* tx x)) (txy (* tx y)) (txz (* tz x))
             (tyy (* ty y)) (tyz (* tz y)) (tzz (* tz z)))
        (macrolet ((f (&rest args)
                     `(progn
                        ,@(loop for arg in args
                                for i from 0 for x = (mod i 4) for y = (floor i 4)
                                when (and (< x ,<s>) (< y ,<s>))
                                collect `(setf (aref xa ,(+ x (* y ,<s>))) ,arg)))))
          (f (- 1 (+ tyy tzz)) (- txy twz) (+ txz twy) (,<t> 0)
             (+ txy twz) (- 1 (+ txx tzz)) (- tyz twx) (,<t> 0)
             (- txz twy) (+ tyz twx) (- 1 (+ txx tyy)) (,<t> 0)
             (,<t> 0) (,<t> 0) (,<t> 0) (,<t> 1))))
      x)))

(define-template qfrom-mat <s> <t> (x m)
  (let ((type (type-instance 'quat-type <t>))
        (mtype (type-instance 'mat-type <s> <t>)))
    `((declare (type ,(lisp-type type) x)
               (type ,(lisp-type mtype) m)
               (return-type ,(lisp-type type))
               (dynamic-extent m))
      (let ((marr ,(place-form mtype :arr 'm)))
        (macrolet ((m (y x)
                     `(aref marr (+ ,x (* ,',<s> ,y)))))
          (let ((s (sqrt (+ (* (m 0 0) (m 0 0)) (* (m 1 0) (m 1 0)) (* (m 2 0) (m 2 0))))))
            (declare (type ,<t> s))
            (if (< (m 2 2) 0)
                (if (< (m 1 1) (m 0 0))
                    (let* ((tt (+ s (m 0 0) (- (m 1 1)) (- (m 2 2))))
                           (s (/ (,<t> 0.5) (the ,<t> (sqrt (* s tt))))))
                      (declare (type ,<t> s))
                      (setf ,(place-form type :x 'x) (* s tt)
                            ,(place-form type :y 'x) (* s (+ (m 0 1) (m 1 0)))
                            ,(place-form type :z 'x) (* s (+ (m 2 0) (m 0 2)))
                            ,(place-form type :w 'x) (* s (- (m 2 1) (m 1 2)))))
                    (let* ((tt (+ s (- (m 0 0)) (m 1 1) (- (m 2 2))))
                           (s (/ (,<t> 0.5) (the ,<t> (sqrt (* s tt))))))
                      (setf ,(place-form type :x 'x) (* s (+ (m 0 1) (m 1 0)))
                            ,(place-form type :y 'x) (* s tt)
                            ,(place-form type :z 'x) (* s (+ (m 1 2) (m 2 1)))
                            ,(place-form type :w 'x) (* s (- (m 0 2) (m 2 0))))))
                (if (< (m 0 0) (- (m 1 1)))
                    (let* ((tt (+ s (- (m 0 0)) (- (m 1 1)) (+ (m 2 2))))
                           (s (/ (,<t> 0.5) (the ,<t> (sqrt (* s tt))))))
                      (setf ,(place-form type :x 'x) (* s (+ (m 2 0) (m 0 2)))
                            ,(place-form type :y 'x) (* s (+ (m 1 2) (m 2 1)))
                            ,(place-form type :z 'x) (* s tt)
                            ,(place-form type :w 'x) (* s (- (m 1 0) (m 0 1)))))
                    (let* ((tt (+ s (+ (m 0 0)) (+ (m 1 1)) (+ (m 2 2))))
                           (s (/ (,<t> 0.5) (the ,<t> (sqrt (* s tt))))))
                      (setf ,(place-form type :x 'x) (* s (- (m 2 1) (m 1 2)))
                            ,(place-form type :y 'x) (* s (- (m 0 2) (m 2 0)))
                            ,(place-form type :z 'x) (* s (- (m 1 0) (m 0 1)))
                            ,(place-form type :w 'x) (* s tt)))))
            x))))))

(define-template qmix <t> (x a b t-t)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x a b)
               (type ,<t> t-t)
               (return-type ,(lisp-type type))
               (dynamic-extent a b)
               inline)
      (let ((1-t (- 1 t-t)))
        (psetf ,@(loop for i from 0 below 4
                       collect (place-form type i 'x)
                       collect `(+ (* 1-t ,(place-form type i 'a))
                                   (* t-t ,(place-form type i 'b))))))
      x)))

(define-template qnlerp <t> (x a b t-t)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x a b)
               (type ,<t> t-t)
               (return-type ,(lisp-type type))
               (dynamic-extent a b)
               inline)
      (psetf ,@(loop for i from 0 below 4
                     collect (place-form type i 'x)
                     collect `(+ ,(place-form type i 'a)
                                 (* t-t (- ,(place-form type i 'b) ,(place-form type i 'a))))))
      (,(compose-name #\/ 'qunit* <t>) x x))))

(define-template qslerp <t> (x a b t-t)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) x a b)
               (type ,<t> t-t)
               (return-type ,(lisp-type type))
               (dynamic-extent a b)
               inline)
      (cond ((~= 1 (,(compose-name #\/ '2quatreduce  '* '+ <t>) a b))
             (,(compose-name #\/ 'qnlerp <t>) x a b t-t))
            (T
             (let ((tmp (,(lisp-type type) a)))
               (declare (dynamic-extent tmp))
               (,(compose-name #\/ 'inverses <t>) tmp a)
               (,(compose-name #\/ 'q*q <t>) tmp tmp b)
               (,(compose-name #\/ 'qexpt <t>) tmp tmp t-t)
               (,(compose-name #\/ 'q*q <t>) tmp tmp a)
               (,(compose-name #\/ 'qunit* <t>) x tmp)))))))

(define-template setf <t> (a x y z w)
  (let ((type (type-instance 'quat-type <t>)))
    `((declare (type ,(lisp-type type) a)
               (return-type ,(lisp-type type))
               inline)
      (setf ,@(loop for i from 0
                    for s in '(x y z w)
                    collect (place-form type i 'a)
                    collect `(,<t> ,s)))
      a)))

(declaim (inline equal=))
(defun equal= (a b &optional (eps 1.0e-6))
  (or (<= (abs (+ a b)) eps)
      (<= (abs (- a b)) eps)))

(do-type-combinations quat-type define-random)
(do-type-combinations quat-type define-zero)
(do-type-combinations quat-type define-conjugate)
(do-type-combinations quat-type define-inverses)
(do-type-combinations quat-type define-qfrom-angle)
(do-type-combinations quat-type define-qtowards)
(do-type-combinations quat-type define-qangle)
(do-type-combinations quat-type define-set-qangle)
(do-type-combinations quat-type define-2quatop (+ - * / min max))
(do-type-combinations quat-type define-squatop (+ - * / min max) (<t> real))
(do-type-combinations quat-type define-1quatop (- / abs identity))
(do-type-combinations quat-type define-2quatreduce (and) (= ~= equal= < <= >= >) boolean)
(do-type-combinations quat-type define-squatreduce (and) (= ~= equal= < <= >= >) (<t> real) boolean)
(do-type-combinations quat-type define-2quatreduce (or) (/=) boolean)
(do-type-combinations quat-type define-squatreduce (or) (/=) (<t> real) boolean)
(do-type-combinations quat-type define-2quatreduce (+) (*) (<t>)) ; dot
(do-type-combinations quat-type define-1quatreduce (+) (sqr) <t>) ; sqrlen
(do-type-combinations quat-type define-q*q)
(do-type-combinations quat-type define-q*v)
(do-type-combinations quat-type define-q+*)
(do-type-combinations quat-type define-qunit)
(do-type-combinations quat-type define-qunit*)
(do-type-combinations quat-type define-qexpt)
(do-type-combinations quat-type define-qlookat)
(do-type-combinations quat-type define-qmat (3 4))
(do-type-combinations quat-type define-qfrom-mat (3 4))
(do-type-combinations quat-type define-qmix)
(do-type-combinations quat-type define-qnlerp)
(do-type-combinations quat-type define-qslerp)
(do-type-combinations quat-type define-setf)
