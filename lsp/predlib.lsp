;; Copyright (C) 1994 M. Hagiya, W. Schelter, T. Yuasa

;; This file is part of GNU Common Lisp, herein referred to as GCL
;;
;; GCL is free software; you can redistribute it and/or modify it under
;;  the terms of the GNU LIBRARY GENERAL PUBLIC LICENSE as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; 
;; GCL is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public 
;; License for more details.
;; 
;; You should have received a copy of the GNU Library General Public License 
;; along with GCL; see the file COPYING.  If not, write to the Free Software
;; Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.


;;;;    predlib.lsp
;;;;
;;;;                              predicate routines


(in-package 'system)

(export '(lisp::deftype lisp::typep lisp::subtypep lisp::coerce) 'lisp)

(eval-when (compile)
(proclaim '(optimize (safety 2) (space 3)))
)

;;; DEFTYPE macro.
(defmacro deftype (name lambda-list &rest body)
  ;; Replace undefaultized optional parameter X by (X '*).
  (do ((l lambda-list (cdr l))
       (m nil (cons (car l) m)))
      ((null l))
    (when (member (car l) lambda-list-keywords)
	  (unless (eq (car l) '&optional) (return nil))
	  (setq m (cons '&optional m))
	  (setq l (cdr l))
	  (do ()
	      ((or (null l) (member (car l) lambda-list-keywords)))
	    (if (symbolp (car l))
		(setq m (cons (list (car l) ''*) m))
		(setq m (cons (car l) m)))
	    (setq l (cdr l)))
	  (setq lambda-list (nreconc m l))
	  (return nil)))
  `(eval-when (compile eval load)
	      (si:putprop ',name
			  '(deftype ,name ,lambda-list ,@body)
			  'deftype-form)
	      (si:putprop ',name
			  #'(lambda ,lambda-list ,@body)
			  'deftype-definition)
	      (si:putprop ',name
			  ,(find-documentation body)
			  'type-documentation)
	      ',name))


;;; Some DEFTYPE definitions.
(deftype fixnum ()
  `(integer ,most-negative-fixnum ,most-positive-fixnum))
(deftype bit () '(integer 0 1))
(deftype mod (n)
  `(integer 0 ,(1- n)))
(deftype signed-byte (&optional s)
  (if (eq s '*)
      `(integer * *)
      `(integer ,(- (expt 2 (1- s))) ,(1- (expt 2 (1- s))))))
(deftype unsigned-byte (&optional s)
  (if (eq s '*)
      `(integer 0 *)
      `(integer 0 ,(1- (expt 2 s)))))
(deftype signed-char ()`(signed-byte ,char-size))
(deftype unsigned-char ()`(unsigned-byte ,char-size))
(deftype signed-short ()`(signed-byte ,short-size))
(deftype unsigned-short ()`(unsigned-byte ,short-size))



(deftype vector (&optional element-type size)
  `(array ,element-type (,size)))
(deftype string (&optional size)
  `(vector string-char ,size))
(deftype bit-vector (&optional size)
  `(vector bit ,size))

(deftype simple-vector (&optional size)
  `(simple-array t (,size)))
(deftype simple-string (&optional size)
  `(simple-array string-char (,size)))
(deftype simple-bit-vector (&optional size)
  `(simple-array bit (,size)))



(defun simple-array-p (x)
  (and (arrayp x)
       (not (adjustable-array-p x))
       (not (array-has-fill-pointer-p x))
       (not (si:displaced-array-p x))))


(do ((l '((null . null)
          (symbol . symbolp)
          (keyword . keywordp)
          (atom . atom)
          (cons . consp)
          (list . listp)
          (number . numberp)
          (character . characterp)
          (package . packagep)
          (stream . streamp)
          (pathname . pathnamep)
          (readtable . readtablep)
          (hash-table . hash-table-p)
          (random-state . random-state-p)
          (structure . si:structurep)
          (function . functionp)
          (compiled-function . compiled-function-p)
          (common . commonp)
          )
        (cdr l)))
    ((endp l))
  (si:putprop (caar l) (cdar l) 'type-predicate))


;;; TYPEP predicate.
(defun typep (object type &aux tp i tem)
  (if (atom type)
      (setq tp type i nil)
      (setq tp (car type) i (cdr type)))
  (let ((f (get tp 'type-predicate)))
    (when f (return-from typep (funcall f object))))
  (case tp
    (member (member object i))
    (not (not (typep object (car i))))
    (or
     (do ((l i (cdr l)))
         ((null l) nil)
      (when (typep object (car l)) (return t))))
    (and
     (do ((l i (cdr l)))
         ((null l) t)
       (unless (typep object (car l)) (return nil))))
    (satisfies (funcall (car i) object))
    ((t) t)
    ((nil) nil)
    (fixnum (eq (type-of object) 'fixnum))
    (bignum (eq (type-of object) 'bignum))
    (ratio (eq (type-of object) 'ratio))
    (standard-char
     (and (characterp object) (standard-char-p object)))
    (string-char
     (and (characterp object) (string-char-p object)))
    (integer
     (and (integerp object) (in-interval-p object i)))
    (rational
     (and (rationalp object) (in-interval-p object i)))
    (float
     (and (floatp object) (in-interval-p object i)))
    ((short-float)
     (and (eq (type-of object) 'short-float) (in-interval-p object i)))
    ((single-float double-float long-float)
     (and (eq (type-of object) 'long-float) (in-interval-p object i)))
    (complex
     (and (complexp object)
(or (null i)
       (and   (typep (realpart object) (car i))
            ;;wfs--should only have to check one.
            ;;Illegal to mix real and imaginary types!
              (typep (imagpart object) (car i))))
     ))
    (sequence (or (listp object) (vectorp object)))
    (string
     (and (stringp object)
          (or (null i) (match-dimensions (array-dimensions object) i))))
    (bit-vector
     (and (bit-vector-p object)
          (or (null i) (match-dimensions (array-dimensions object) i))))
    (simple-string
     (and (simple-string-p object)
          (or (null i) (match-dimensions (array-dimensions object) i))))
    (simple-bit-vector
     (and (simple-bit-vector-p object)
          (or (null i) (match-dimensions (array-dimensions object) i))))
    (simple-vector
     (and (simple-vector-p object)
          (or (null i) (match-dimensions (array-dimensions object) i))))
    (simple-array
     (and (simple-array-p object)
          (or (endp i) (eq (car i) '*)
              (equal (array-element-type object)(best-array-element-type (car i))))
          (or (endp (cdr i)) (eq (cadr i) '*)
              (match-dimensions (array-dimensions object) (cadr i)))))
    (array
     (and (arrayp object)
          (or (endp i) (eq (car i) '*)
              ;; Or the element type of object should be EQUAL to (car i).
              ;; Is this too strict?
              (equal (array-element-type object) (best-array-element-type (car i))))
          (or (endp (cdr i)) (eq (cadr i) '*)
              (match-dimensions (array-dimensions object) (cadr i)))))
    (t
     (cond ((setq tem (get tp 'si::s-data))
	    (structure-subtype-p object tem))
           ((get tp 'deftype-definition)
            (typep object
                   (apply (get tp 'deftype-definition) i)))))))


;;; NORMALIZE-TYPE normalizes the type using the DEFTYPE definitions.
;;; The result is always a list.
(defun normalize-type (type &aux tp i )
  ;; Loops until the car of type has no DEFTYPE definition.
  (loop
    (if (atom type)
        (setq tp type i nil)
        (setq tp (car type) i (cdr type)))
    (if (get tp 'deftype-definition)
        (setq type (apply (get tp 'deftype-definition) i))
        (return-from normalize-type (if (atom type) (list type) type)))))


;;; KNOWN-TYPE-P answers if the given type is a known base type.
;;; The type may not be normalized.
(defun known-type-p (type)
  (when (consp type) (setq type (car type)))
  (if (or (member type
                  '(t nil null symbol keyword atom cons list sequence
		      signed-char unsigned-char signed-short unsigned-short
                    number integer bignum rational ratio float
                    short-float single-float double-float long-float complex
                    character standard-char string-char
                    package stream pathname readtable hash-table random-state
                    structure array simple-array function compiled-function))
          (get type 's-data))
      t
      nil))


;;; SUBTYPEP predicate.
(defun subtypep (type1 type2 &aux t1 t2 i1 i2 ntp1 ntp2 tem)
  (setq type1 (normalize-type type1))
  (setq type2 (normalize-type type2))  
  (when (equal type1 type2)
    (return-from subtypep (values t t)))
  (setq t1 (car type1) t2 (car type2))
  (setq i1 (cdr type1) i2 (cdr type2))
  (cond ((eq t1 'member)
         (dolist (e i1)
           (unless (typep e type2) (return-from subtypep (values nil t))))
         (return-from subtypep (values t t)))
        ((eq t1 'or)
         (dolist (tt i1)
           (multiple-value-bind (tv flag) (subtypep tt type2)
             (unless tv (return-from subtypep (values tv flag)))))
         (return-from subtypep (values t t)))
        ((eq t1 'and)
         (dolist (tt i1)
           (let ((tv (subtypep tt type2)))
             (when tv (return-from subtypep (values t t)))))
         (return-from subtypep (values nil nil)))
        ((eq t1 'not)
	 ;;
	 (return-from subtypep
		      (if (eq t2 'not)
			  (subtypep (car i2) (car i1))
			(subtypep t `(or ,type2 ,(car i1)))))))
  (cond ((eq t2 'member)
         (return-from subtypep (values nil nil)))
        ((eq t2 'or)
         (dolist (tt i2)
           (let ((tv (subtypep type1 tt)))
             (when tv (return-from subtypep (values t t)))))
         (return-from subtypep (values nil nil)))
        ((eq t2 'and)
         (dolist (tt i2)
           (multiple-value-bind (tv flag) (subtypep type1 tt)
             (unless tv (return-from subtypep (values tv flag)))))
         (return-from subtypep (values t t)))
        ((eq t2 'not)
	 (return-from subtypep (subtypep `(and ,type1 ,(car i2)) nil))))
	
  (setq ntp1 (known-type-p type1) ntp2 (known-type-p type2))
  (cond	((or (eq t1 'nil) (eq t2 't) (eq t2 'common)) (values t t))
       	((eq t2 'nil) (values nil ntp1))
       	((eq t1 't) (values nil ntp2))
       	((eq t1 'common) (values nil ntp2))
       	((eq t2 'list)
       	 (cond ((member t1 '(null cons list)) (values t t))
       	       (t (values nil ntp1))))
       	((eq t2 'sequence)
       	 (cond ((member t1 '(null cons list sequence)) (values t t))
       	       ((eq t1 'array)
       	        (if (and (cdr i1) (consp (cadr i1)) (null (cdadr i1)))
       	            (values t t)
       	            (values nil t)))
       	       (t (values nil ntp1))))
       	((eq t1 'list) (values nil ntp2))
       	((eq t1 'sequence) (values nil ntp2))
       	((eq t2 'atom)
       	 (cond ((member t1 '(cons list)) (values nil t))
       	       (ntp1 (values t t))
       	       (t (values nil nil))))
       	((eq t1 'atom) (values nil ntp2))
       	((eq t2 'symbol)
       	 (if (member t1 '(symbol keyword null))
       	     (values t t)
       	     (values nil ntp1)))
       	((eq t2 'keyword)
       	 (if (eq t1 'keyword) (values t t) (values nil ntp1)))
       	((eq t2 'null)
       	 (if (eq t1 'null) (values t t) (values nil ntp1)))
       	((eq t2 'number)
	 (cond ((member t1 '(bignum integer ratio rational float
	                     short-float single-float double-float long-float
	                     complex number))
	        (values t t))
	       (t (values nil ntp1))))
       	((eq t1 'number) (values nil ntp2))
       	((eq t2 'structure)
       	 (if (or (eq t1 'structure) (get t1 'si::s-data))
       	     (values t t)
       	     (values nil ntp1)))
       	((eq t1 'structure) (values nil ntp2))
       	((setq tem (get t1 'si::s-data))
	 (let ((tem2 (get t2 'si::s-data)))
	   (cond (tem2
		   (do ((tp1 tem (s-data-includes tp1)) (tp2 tem2))
		       ((null tp1)(values nil t))
		       (when (eq tp1 tp2) (return (values t t)))))
		 (t (values nil ntp2)))))
       	((get t2 'si::s-data) (values nil ntp1))
       	(t
       	 (case t1
       	   (bignum
       	    (case t2
       	      (bignum (values t t))
       	      ((integer rational)
       	       (if (sub-interval-p '(* *) i2)
       	           (values t t)
       	           (values nil t)))
       	      (t (values nil ntp2))))
       	   (ratio
       	    (case t2
       	      (ratio (values t t))
       	      (rational
       	       (if (sub-interval-p '(* *) i2) (values t t) (values nil t)))
       	      (t (values nil ntp2))))
       	   (standard-char
	    (if (member t2 '(standard-char string-char character))
	        (values t t)
	        (values nil ntp2)))
	   (string-char
	    (if (member t2 '(string-char character))
	        (values t t)
	        (values nil ntp2)))
	   (integer
	    (if (member t2 '(integer rational))
		(values (sub-interval-p i1 i2) t)
		(values nil ntp2)))
	   (rational
	    (if (eq t2 'rational)
		(values (sub-interval-p i1 i2) t)
		(values nil ntp2)))
	   (float
	    (if (eq t2 'float)
		(values (sub-interval-p i1 i2) t)
		(values nil ntp2)))
	   ((short-float)
	    (if (member t2 '(short-float float))
		(values (sub-interval-p i1 i2) t)
		(values nil ntp2)))
	   ((single-float double-float long-float)
	    (if (member t2 '(single-float double-float long-float float))
		(values (sub-interval-p i1 i2) t)
		(values nil ntp2)))
	   (complex
	    (if (eq t2 'complex)
		(subtypep (or (car i1) t) (or (car i2) t))
	        (values nil ntp2)))
	   (simple-array
	    (cond ((or (eq t2 'simple-array) (eq t2 'array))
	           (if (or (endp i1) (eq (car i1) '*))
	               (unless (or (endp i2) (eq (car i2) '*))
	                       (return-from subtypep (values nil t)))
	               (unless (or (endp i2) (eq (car i2) '*))
	                       (unless (equal (car i1) (car i2))
	                               ;; Unless the element type matches,
	                               ;;  return NIL T.
	                               ;; Is this too strict?
	                               (return-from subtypep
	                                            (values nil t)))))
	           (when (or (endp (cdr i1)) (eq (cadr i1) '*))
		         (if (or (endp (cdr i2)) (eq (cadr i2) '*))
		             (return-from subtypep (values t t))
		             (return-from subtypep (values nil t))))
		   (when (or (endp (cdr i2)) (eq (cadr i2) '*))
		         (return-from subtypep (values t t)))
		   (values (match-dimensions (cadr i1) (cadr i2)) t))
	          (t (values nil ntp2))))
	   (array
	    (cond ((eq t2 'array)
	           (if (or (endp i1) (eq (car i1) '*))
	               (unless (or (endp i2) (eq (car i2) '*))
	                       (return-from subtypep (values nil t)))
	               (unless (or (endp i2) (eq (car i2) '*))
	                       (unless (equal (car i1) (car i2))
	                               (return-from subtypep
	                                            (values nil t)))))
	           (when (or (endp (cdr i1)) (eq (cadr i1) '*))
		         (if (or (endp (cdr i2)) (eq (cadr i2) '*))
		             (return-from subtypep (values t t))
		             (return-from subtypep (values nil t))))
		   (when (or (endp (cdr i2)) (eq (cadr i2) '*))
		         (return-from subtypep (values t t)))
		   (values (match-dimensions (cadr i1) (cadr i2)) t))
	          (t (values nil ntp2))))
	   (t (if ntp1 (values (eq t1 t2) t) (values nil nil)))))))


(defun sub-interval-p (i1 i2)
  (let (low1 high1 low2 high2)
    (if (endp i1)
        (setq low1 '* high1 '*)
        (if (endp (cdr i1))
            (setq low1 (car i1) high1 '*)
            (setq low1 (car i1) high1 (cadr i1))))
    (if (endp i2)
        (setq low2 '* high2 '*)
        (if (endp (cdr i2))
            (setq low2 (car i2) high2 '*)
            (setq low2 (car i2) high2 (cadr i2))))
    (cond ((eq low1 '*)
	   (unless (eq low2 '*)
	           (return-from sub-interval-p nil)))
          ((eq low2 '*))
	  ((consp low1)
	   (if (consp low2)
	       (when (< (car low1) (car low2))
		     (return-from sub-interval-p nil))
	       (when (< (car low1) low2)
		     (return-from sub-interval-p nil))))
	  ((if (consp low2)
	       (when (<= low1 (car low2))
		     (return-from sub-interval-p nil))
	       (when (< low1 low2)
		     (return-from sub-interval-p nil)))))
    (cond ((eq high1 '*)
	   (unless (eq high2 '*)
	           (return-from sub-interval-p nil)))
          ((eq high2 '*))
	  ((consp high1)
	   (if (consp high2)
	       (when (> (car high1) (car high2))
		     (return-from sub-interval-p nil))
	       (when (> (car high1) high2)
		     (return-from sub-interval-p nil))))
	  ((if (consp high2)
	       (when (>= high1 (car high2))
		     (return-from sub-interval-p nil))
	       (when (> high1 high2)
		     (return-from sub-interval-p nil)))))
    (return-from sub-interval-p t)))

(defun in-interval-p (x interval)
  (let (low high)
    (if (endp interval)
        (setq low '* high '*)
        (if (endp (cdr interval))
            (setq low (car interval) high '*)
            (setq low (car interval) high (cadr interval))))
    (cond ((eq low '*))
          ((consp low)
           (when (<= x (car low)) (return-from in-interval-p nil)))
          ((when (< x low) (return-from in-interval-p nil))))
    (cond ((eq high '*))
          ((consp high)
           (when (>= x (car high)) (return-from in-interval-p nil)))
          ((when (> x high) (return-from in-interval-p nil))))
    (return-from in-interval-p t)))

(defun match-dimensions (dim pat)
  (if (null dim)
      (null pat)
      (and (or (eq (car pat) '*)
	       (eq (car dim) (car pat)))
	   (match-dimensions (cdr dim) (cdr pat)))))



;;; COERCE function.
(defun coerce (object type)
  (when (typep object type)
        ;; Just return as it is.
        (return-from coerce object))
  (setq type (normalize-type type))
  (case (car type)
    (list
     (do ((l nil (cons (elt object i) l))
          (i (1- (length object)) (1- i)))
         ((< i 0) l)))
    ((array simple-array)
     (unless (or (endp (cdr type))
                 (endp (cddr type))
                 (eq (caddr type) '*)
                 (endp (cdr (caddr type))))
             (error "Cannot coerce to an multi-dimensional array."))
     (do ((seq (make-sequence type (length object)))
          (i 0 (1+ i))
          (l (length object)))
         ((>= i l) seq)
       (setf (elt seq i) (elt object i))))
    (character (character object))
    (float (float object))
    ((short-float) (float object 0.0S0))
    ((single-float double-float long-float) (float object 0.0L0))
    (complex
     (if (or (null (cdr type)) (null (cadr type)) (eq (cadr type) '*))
         (complex (realpart object) (imagpart object))
         (complex (coerce (realpart object) (cadr type))
                  (coerce (imagpart object) (cadr type)))))
    (t (error "Cannot coerce ~S to ~S." object type))))

;; set by unixport/init_kcl.lsp
;; warn if a file was comopiled in another version
(defvar *gcl-version* nil)

(defun warn-version (x)
  (and *gcl-version*
       (not (eql x *gcl-version*))
       *load-verbose*
       (format t "[compiled in GCL 1-~a] " x)))



