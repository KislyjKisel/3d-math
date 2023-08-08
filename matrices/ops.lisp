#|
 This file is a part of 3d-math
 (c) 2023 Shirakumo http://shirakumo.org (shirakumo@tymoon.eu)
|#

(in-package #:org.shirakumo.fraf.math.matrices)

(defmacro with-fast-matref ((accessor mat) &body body)
  (let ((m (gensym "M"))
        (arr (gensym "ARRAY"))
        (w (gensym "WIDTH")) 
        (x (gensym "X"))
        (y (gensym "Y"))
        (v (gensym "V")))
    `(let ((,m ,mat))
       (etypecase ,m
         ,@(loop for type in (instances 'mat-type)
                 collect `(,(lisp-type type)
                           (let ((,arr ,(place-form type :arr m))
                                 (,w ,(attribute type :cols m)))
                             (declare (type dimension ,w))
                             (declare (type ,(lisp-type (slot type :arr))))
                             (flet ((,accessor (,y ,x)
                                      (declare (type index ,y ,x))
                                      (declare (optimize speed (safety 1)))
                                      (aref ,arr (+ ,x (* ,y ,w))))
                                    ((setf ,accessor) (,v ,y ,x)
                                      (declare (type index ,y ,x))
                                      (declare (optimize speed (safety 1)))
                                      (setf (aref ,arr (+ ,x (* ,y ,w))) (,(second (template-arguments type)) ,v))))
                               (declare (inline ,accessor (setf ,accessor)))
                               (declare (ignorable #',accessor #'(setf ,accessor)))
                               ,@body))))))))

(defmacro define-2mat-dispatch (op &optional (revop op))
  `(define-templated-dispatch ,(compose-name NIL '!2m op) (x a b)
     ((mat-type 0 #(0 1)) smatop ,op <t>)
     ((mat-type 0 real) smatop ,op real)
     ((mat-type #(0 1) 0) (smatop ,revop <t>) x b (,op a))
     ((mat-type real 0) (smatop ,revop real) x b (,op a))
     ((mat-type 0 0) 2matop ,op)))

(defmacro define-2mat-*-dispatch ()
  `(define-templated-dispatch !2m* (x a b)
     ((mat-type 0 #(0 1)) smatop * <t>)
     ((mat-type 0 real) smatop * real)
     ((mat-type #(0 1) 0) (smatop * <t>) x b a)
     ((mat-type real 0) (smatop * real) x b a)
     ((mat-type 0 0) m*m)
     ;; Extra handling for vectors.
     ,@(loop for instance in (instances 'mat-type)
             for (<s> <t>) = (template-arguments instance)
             append (loop for <vs> in '(2 3 4)
                          for vec-type = (type-instance 'vec-type <vs> <t>)
                          collect `((,(lisp-type vec-type) ,(lisp-type instance) 0)
                                    m*v ,<vs> ,<s> ,<t>)))))

(defmacro define-1mat-dispatch (name op &rest template-args)
  `(define-templated-dispatch ,name (x a)
     ((mat-type 0) ,op ,@template-args)))

(defmacro define-matcomp-dispatch (op &optional (comb 'and) (rop op))
  `(define-templated-dispatch ,(compose-name NIL '2m op) (a b)
     ((mat-type #(0 1)) smatreduce ,comb ,op <t>)
     ((mat-type real) smatreduce ,comb ,op real)
     ((real mat-type) (smatreduce ,comb ,rop real) b a)
     ((mat-type 0) 2matreduce ,comb ,op)))

(defmacro define-constructor (name initializer)
  `(define-type-dispatch ,name (x)
     ,@(loop for instance in (instances 'mat-type)
             collect (if (eql 'n (first (template-arguments instance)))
                         `((,(lisp-type instance)) ,(lisp-type instance) (,initializer (,(lisp-type instance) (mrows x) (mcols x))))
                         `((,(lisp-type instance)) ,(lisp-type instance) (,initializer (,(lisp-type instance))))))
     (((eql 2)) mat2 (,initializer (mat2)))
     (((eql 3)) mat3 (,initializer (mat3)))
     (((eql 4)) mat4 (,initializer (mat4)))
     (((and integer (not (member 2 3 4)))) matn (,initializer (matn x x)))))

(defmacro define-vec-return (name args)
  (let ((nname (compose-name NIL 'n name)))
    `(progn
       (define-templated-dispatch ,nname (x ,@(mapcar #'first args))
         ((#'(matching-vec 1) ,@(mapcar #'second args)) ,name))
       
       (define-templated-dispatch ,name ,(mapcar #'first args)
         (,(mapcar #'second args) (,name) (mvec ,(first (first args))) ,@(mapcar #'first args))))))

(define-dependent-dispatch-type lower-vec (types i ref)
  (handler-case (destructuring-bind (<s> <t>) (template-arguments (nth ref types))
                  (apply #'type-instance 'vec-type (1- <s>) <t>))
    (error () NIL)))

(define-dependent-dispatch-type matching-vec (types i ref)
  (handler-case (apply #'type-instance 'vec-type (template-arguments (nth ref types)))
    (error () NIL)))

(define-dependent-dispatch-type matching-array (types i ref)
  (destructuring-bind (<s> <t>) (template-arguments (nth ref types))
    (declare (ignore <s>))
    `(simple-array ,<t> (*))))

(define-dependent-dispatch-type matching-matrix (types i ref size)
  (destructuring-bind (<s> <t>) (template-arguments (nth ref types))
    (declare (ignore <s>))
    (type-instance 'mat-type size <t>)))

(define-2mat-dispatch +)
(define-2mat-dispatch - +)
(define-2mat-dispatch / *)
(define-2mat-dispatch min)
(define-2mat-dispatch max)

(define-2mat-*-dispatch)

(define-matcomp-dispatch =)
(define-matcomp-dispatch ~=)
(define-matcomp-dispatch /= or)
(define-matcomp-dispatch < and >)
(define-matcomp-dispatch <= and >=)
(define-matcomp-dispatch > and <)
(define-matcomp-dispatch >= and <=)

(define-templated-dispatch mvec (a)
  ((mat-type) mvec))

(define-templated-dispatch mcopy (a)
  ((mat-type) copy))

(define-1mat-dispatch m<- 1matop identity)

(define-1mat-dispatch !1m- 1matop -)
(define-1mat-dispatch !1m/ 1matop /)

(define-templated-dispatch !mapply (x m f)
  ((mat-type 0 function) mapply)
  ((mat-type 0 symbol) (mapply) x m (fdefinition f)))

(define-1mat-dispatch !mcof mcof)
(define-1mat-dispatch !minv minv)
(define-1mat-dispatch !minv-affine minv-affine)
(define-1mat-dispatch !mtranspose mtranspose)
(define-templated-dispatch !mswap-row (x m r1 r2)
  ((mat-type 0 index index) mswap-row))
(define-templated-dispatch !mswap-col (x m c1 c2)
  ((mat-type 0 index index) mswap-col))
(define-templated-dispatch !mrow (r m ri)
  ((#'(matching-array 1) mat-type index) mrow)
  ((#'(matching-vec 1) mat-type index) (mrow) (varr r) m ri)
  ((null mat-type index) (mrow) (make-array (mcols m) :element-type (array-element-type (marr m))) m ri))
(define-templated-dispatch !mcol (r m ci)
  ((#'(matching-array 1) mat-type index) mcol)
  ((#'(matching-vec 1) mat-type index) (mcol) (varr r) m ci)
  ((null mat-type index) (mcol) (make-array (mrows m) :element-type (array-element-type (marr m))) m ci))
(define-templated-dispatch !mdiag (r m)
  ((#'(matching-array 1) mat-type) mdiag)
  ((#'(matching-vec 1) mat-type) (mdiag) (varr r) m)
  ((null mat-type) (mdiag) (make-array (min (mcols m) (mrows m)) :element-type (array-element-type (marr m))) m))

(define-type-reductor !m+ v<- !2m+)
(define-type-reductor !m* v<- !2m*)
(define-type-reductor !m- v<- !2m- !1m-)
(define-type-reductor !m/ v<- !2m/ !1m/)
(define-type-reductor !mmin v<- !2mmin)
(define-type-reductor !mmax v<- !2mmax)

(define-templated-dispatch !mzero (x)
  ((mat-type) 0matop zero))
(define-templated-dispatch !meye (x)
  ((mat-type) 0matop eye))
(define-templated-dispatch !mrand (x)
  ((mat-type) 0matop rand))

(define-templated-dispatch !mtransfer (dst src w h dst-x dst-y src-x src-y)
  ((#'(matching-matrix 1 2) mat-type dimension 2 index 4 4 4) mtransfer)
  ((#'(matching-matrix 1 3) mat-type dimension 2 index 4 4 4) mtransfer)
  ((#'(matching-matrix 1 4) mat-type dimension 2 index 4 4 4) mtransfer)
  ((#'(matching-matrix 1 n) mat-type dimension 2 index 4 4 4) mtransfer)
  ((#'(matching-matrix 1 2) mat-type dimension 2 index 4 4 4) mtransfer 2)
  ((#'(matching-matrix 1 3) mat-type dimension 2 index 4 4 4) mtransfer 3)
  ((#'(matching-matrix 1 4) mat-type dimension 2 index 4 4 4) mtransfer 4)
  ((#'(matching-matrix 1 n) mat-type dimension 2 index 4 4 4) mtransfer n))

(define-value-reductor m= 2m= and T)
(define-value-reductor m~= 2m~= and T)
(define-value-reductor m/= 2m/= and T)
(define-value-reductor m< 2m< and T)
(define-value-reductor m<= 2m<= and T)
(define-value-reductor m> 2m> and T)
(define-value-reductor m>= 2m>= and T)

(define-pure-alias mapply (m f) mzero !mapply)
(define-modifying-alias nmapply (m f) !mapply)
(define-simple-alias mcof (m) mzero)
(define-simple-alias minv (m) mzero)
(define-simple-alias minv-affine (m) mzero)
(define-simple-alias mtranspose (m) mzero)
(define-simple-alias mswap-row (m r1 r2) mzero)
(define-simple-alias mswap-col (m c1 c2) mzero)
(define-alias mrow (m ri) `(!mrow NIL ,m ,ri))
(define-alias mcol (m ri) `(!mcol NIL ,m ,ri))
(define-alias mdiag (m) `(!mdiag NIL ,m))

(define-templated-dispatch mminor (m y x)
  ((mat-type index index) mminor))
(define-templated-dispatch mdet (m)
  ((mat-type) mdet))
(define-templated-dispatch mtrace (m)
  ((mat-type) mtrace))
(define-templated-dispatch m1norm (m)
  ((mat-type) m1norm))
(define-templated-dispatch minorm (m)
  ((mat-type) m1norm))
(define-templated-dispatch m2norm (m)
  ((mat-type) m2norm))

(define-rest-alias m+ (m &rest others) mzero)
(define-rest-alias m- (m &rest others) mzero)
(define-rest-alias m* (m &rest others) mzero)
(define-rest-alias m/ (m &rest others) mzero)
(define-rest-alias mmin (m &rest others) mzero)
(define-rest-alias mmax (m &rest others) mzero)

(defun n*m (&rest others)
  (apply #'!m* (car (last others)) others))

(define-compiler-macro n*m (&rest others)
  `(!m* ,(car (last others)) ,@others))

(define-templated-dispatch nmtranslate (x v)
  ((mat-type #'(lower-vec 0)) mtranslate))
(define-templated-dispatch nmscale (x v)
  ((mat-type #'(lower-vec 0)) mscale))
(define-templated-dispatch nmrotate (x v angle)
  ((mat-type #'(lower-vec 0) #(0 1)) mrotate))

(define-templated-dispatch nmtranslation (x v)
  ((mat-type #'(matching-vec 0)) mtranslation))
(define-templated-dispatch nmscaling (x v)
  ((mat-type #'(matching-vec 0)) mscaling))
(define-templated-dispatch nmrotation (x v angle)
  ((mat-type #'(matching-vec 0) #(0 1)) mrotation))
(define-templated-dispatch nmlookat (x eye target up)
  ((mat-type #'(matching-vec 0) 1 1) mlookat))
(define-templated-dispatch nmfrustum (x l r b u n f)
  ((mat-type #(0 1) 1 1 1 1 1) mfrustum))
(define-templated-dispatch nmortho (x l r b u n f)
  ((mat-type #(0 1) 1 1 1 1 1) mortho))
(define-templated-dispatch nmperspective (x fovy aspect near far)
  ((mat-type #(0 1) 1 1 1) mperspective))

(define-type-dispatch mtranslation (v)
  #-3d-math-no-f32 ((vec2) mat3 (mtranslation/3/f32 (mat3) v))
  #-3d-math-no-f64 ((dvec2) dmat3 (mtranslation/3/f64 (dmat3) v))
  #-3d-math-no-u32 ((uvec2) umat3 (mtranslation/3/u32 (umat3) v))
  #-3d-math-no-i32 ((ivec2) imat3 (mtranslation/3/i32 (imat3) v))
  #-3d-math-no-f32 ((vec3) mat4 (mtranslation/4/f32 (mat4) v))
  #-3d-math-no-f64 ((dvec3) dmat4 (mtranslation/4/f64 (dmat4) v))
  #-3d-math-no-u32 ((uvec3) umat4 (mtranslation/4/u32 (umat4) v))
  #-3d-math-no-i32 ((ivec3) imat4 (mtranslation/4/i32 (imat4) v)))

(define-type-dispatch mscaling (v)
  #-3d-math-no-f32 ((vec2) mat3 (mscaling/3/f32 (mat3) v))
  #-3d-math-no-f64 ((dvec2) dmat3 (mscaling/3/f64 (dmat3) v))
  #-3d-math-no-u32 ((uvec2) umat3 (mscaling/3/u32 (umat3) v))
  #-3d-math-no-i32 ((ivec2) imat3 (mscaling/3/i32 (imat3) v))
  #-3d-math-no-f32 ((vec3) mat4 (mscaling/4/f32 (mat4) v))
  #-3d-math-no-f64 ((dvec3) dmat4 (mscaling/4/f64 (dmat4) v))
  #-3d-math-no-u32 ((uvec3) umat4 (mscaling/4/u32 (umat4) v))
  #-3d-math-no-i32 ((ivec3) imat4 (mscaling/4/i32 (imat4) v)))

(define-type-dispatch mrotation (v angle)
  #-3d-math-no-f32 ((null f32) mat2 (mrotation/2/f32 (mat2) +vx+ angle))
  #-3d-math-no-f32 ((null real) mat2 (mrotation/2/f32 (mat2) +vx+ (f32 angle)))
  #-3d-math-no-f64 ((null f64) dmat2 (mrotation/2/f64 (dmat2) +vx+ angle))
  #-3d-math-no-f32 ((vec3 f32) mat4 (mrotation/4/f32 (mat4) v angle))
  #-3d-math-no-f32 ((vec3 real) mat4 (mrotation/4/f32 (mat4) v (f32 angle)))
  #-3d-math-no-f64 ((dvec3 f64) dmat4 (mrotation/4/f64 (dmat4) v angle)))

(define-type-dispatch mlookat (eye target up)
  #-3d-math-no-f32 ((vec3 vec3 vec3) mat4 (mlookat/4/f32 (mat4) eye target up))
  #-3d-math-no-f64 ((dvec3 dvec3 dvec3) dmat4 (mlookat/4/f64 (dmat4) eye target up)))

(define-type-dispatch mfrustum (l r b u n f)
  #-3d-math-no-f32 ((f32 f32 f32 f32 f32 f32) mat4 (mfrustum/4/f32 (mat4) l r b u n f))
  #-3d-math-no-f32 ((real real real real real real) mat4 (mfrustum/4/f32 (mat4) (f32 l) (f32 r) (f32 b) (f32 u) (f32 n) (f32 f)))
  #-3d-math-no-f64 ((f64 f64 f64 f64 f64 f64) dmat4 (mfrustum/4/f64 (dmat4) l r b u n f)))

(define-type-dispatch mperspective (fovy aspect n f)
  #-3d-math-no-f32 ((f32 f32 f32 f32) mat4 (mperspective/4/f32 (mat4) fovy aspect n f))
  #-3d-math-no-f32 ((real real real real) mat4 (mperspective/4/f32 (mat4) (f32 fovy) (f32 aspect) (f32 n) (f32 f)))
  #-3d-math-no-f64 ((f64 f64 f64 f64) dmat4 (mperspective/4/f64 (dmat4) fovy aspect n f)))

(define-type-dispatch mortho (l r b u n f)
  #-3d-math-no-f32 ((f32 f32 f32 f32 f32 f32) mat4 (mortho/4/f32 (mat4) l r b u n f))
  #-3d-math-no-f32 ((real real real real real real) mat4 (mortho/4/f32 (mat4) (f32 l) (f32 r) (f32 b) (f32 u) (f32 n) (f32 f)))
  #-3d-math-no-f64 ((f64 f64 f64 f64 f64 f64) dmat4 (mortho/4/f64 (dmat4) l r b u n f)))

(define-constructor meye !meye)
(define-constructor mrand !mrand)
(define-constructor mzero !mzero)

(declaim (ftype (function (*mat) (values *mat *mat dimension &optional)) mpivot))
(defun mpivot (m)
  (assert (= (mrows m) (mcols m)))
  (let* ((c (mrows m))
         (r (mcopy m))
         (ra (marr r))
         (p (meye c))
         (s 0))
    (declare (type index s))
    (macrolet ((e (y x) `(aref ra (+ ,x (* ,y c)))))
      (dotimes (i c (values r p s))
        (let ((index 0) (max 0))
          (loop for j from i below c
                for el = (abs (e j i))
                do (when (< max el)
                     ;; Make sure we don't accidentally introduce zeroes
                     ;; into the diagonal by swapping!
                     (when (/= 0 (e i j))
                       (setf max el)
                       (setf index j))))
          (when (= 0 max)
            (error "The matrix~%~a~%is singular in column ~a. A pivot cannot be constructed for it."
                   (write-matrix m NIL) i))
          ;; Non-diagonal means we swap. Record.
          (when (/= i index)
            (setf s (1+ s))
            (nmswap-row p i index)
            (nmswap-row r i index)))))))

(declaim (ftype (function (*mat &optional boolean) (values *mat *mat dimension &optional)) mlu))
(defun mlu (m &optional (pivot T))
  ;; We're using the Crout method for LU decomposition.
  ;; See https://en.wikipedia.org/wiki/Crout_matrix_decomposition
  (let* ((lu (mcopy m))
         (n (mcols m))
         (p (meye n))
         (s 0)
         (lua (marr lu))
         (scale (make-array n :element-type (array-element-type (marr m)))))
    (declare (type index s))
    (macrolet ((lu (y x) `(aref lua (+ ,x (* ,y n)))))
      ;; Discover the largest element and save the scaling.
      (loop for i from 0 below n
            for big = 0
            do (loop for j from 0 below n
                     for temp = (abs (lu i j))
                     do (if (< big temp) (setf big temp)))
               (when (= 0 big)
                 (error "The matrix is singular in ~a:~%~a" i
                        (write-matrix lu NIL)))
               (setf (aref scale i) big))
      ;; Time to Crout it up.
      (dotimes (j n (values lu p s))
        ;; Part A sans diag
        (loop for i from 0 below j
              for sum = (lu i j)
              do (loop for k from 0 below i
                       do (decf sum (* (lu i k) (lu k j))))
                 (setf (lu i j) sum))
        (let ((imax j))
          ;; Diag + pivot search
          (loop with big = 0
                for i from j below n
                for sum = (lu i j)
                do (loop for k from 0 below j
                         do (decf sum (* (lu i k) (lu k j))))
                   (setf (lu i j) sum)
                   (when pivot
                     (let ((temp (* (abs sum) (aref scale i))))
                       (when (<= big temp)
                         (setf big temp)
                         (setf imax i)))))
          ;; Pivot swap
          (unless (= j imax)
            (incf s)
            (nmswap-row lu imax j)
            (nmswap-row p  imax j)
            (setf (aref scale imax) (aref scale j)))
          ;; Division
          (when (< j (1- n))
            (let ((div (/ (lu j j))))
              (loop for i from (1+ j) below n
                    do (setf (lu i j) (* (lu i j) div))))))))))

(declaim (ftype (function (*mat) (values *mat *mat &optional)) mqr))
(defun mqr (mat)
  (let* ((m (mrows mat))
         (n (mcols mat))
         (Q (meye m))
         (R (mcopy mat))
         (G (meye m))
         (ra (marr r))
         (ga (marr g)))
    (with-fast-matref (g G)
      (with-fast-matref (r R)
        (dotimes (j n (values Q R))
          (loop for i downfrom (1- m) above j
                for a = (r (1- i) j)
                for b = (r     i  j)
                for c = 0
                for s = 0
                do (cond ((= 0 b) (setf c 1))
                         ((= 0 a) (setf s 1))
                         ((< (abs a) (abs b))
                          (let ((r (/ a b)))
                            (setf s (/ (sqrt (1+ (* r r)))))
                            (setf c (* s r))))
                         (T
                          (let ((r (/ b a)))
                            (setf c (/ (sqrt (1+ (* r r)))))
                            (setf s (* c r)))))
                   (setf (g (1- i) (1- i)) c
                         (g (1- i)     i)  (- s)
                         (g     i  (1- i)) s
                         (g     i      i)  c)
                   (n*m (mtranspose G) R)
                   (nm* Q G)
                   (setf (g (1- i) (1- i)) 1
                         (g (1- i)     i)  0
                         (g     i  (1- i)) 0
                         (g     i      i)  1)))))))

(declaim (ftype (function (*mat &optional (integer 0)) (values simple-array &optional)) meigen))
(defun meigen (m &optional (iterations 50))
  (multiple-value-bind (Q R) (mqr m)
    (loop repeat iterations
          do (multiple-value-bind (Qn Rn)
                 (mqr (nm* R Q))
               (setf Q Qn)
               (setf R Rn)))
    (mdiag (nm* R Q))))

(define-alias mcofactor (m y x)
  `(* (if (evenp (+ ,y ,x)) 1 -1)
      (mminor ,m ,y ,x)))

(define-alias !madj (r m)
  `(nmtranspose (!mcof ,r ,m)))

(define-alias madj (m)
  `(nmtranspose (mcof ,m)))

(define-alias mcref (m y x)
  `(aref (marr ,m) (+ ,x (* ,y (mcols ,m)))))

(define-alias (setf mcref) (value m y x)
  ;; FIXME: coerce value!
  `(setf (aref (marr ,m) (+ ,x (* ,y (mcols ,m)))) ,value))

(define-alias miref (m i)
  `(aref (marr ,m) ,i))

(define-alias (setf miref) (value m i)
  ;; FIXME: coerce value!
  `(setf (aref (marr ,m) ,i) ,value))

(define-alias mtransfer (x m &key (w (mcols x)) (h (mrows x)) (xx 0) (xy 0) (mx 0) (my 0))
  `(!mtransfer ,x ,m ,w ,h ,xx ,xy ,mx ,my))

(define-alias mblock (m x y w h)
  `(!mtransfer (mat ,w ,h) ,m ,w ,h 0 0 ,x ,y))

(define-templated-dispatch msetf (m &rest args)
  ((mat-type list) setf))
