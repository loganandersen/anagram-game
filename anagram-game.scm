#! /usr/bin/env -S guile -e main -s
!#

;; anagram-game.scm, asks user to unshuffle shuffled words from directory
;; Copyright (C) 2026 Logan Andersen

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at

;;     http://www.apache.org/licenses/LICENSE-2.0

;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.


(use-modules (ice-9 rdelim)
	     (srfi srfi-26) ;; cut operator
	     (srfi srfi-43) ;; vector operations
	     )

;; initialize random
(set! *random-state* (random-state-from-platform))

;; read newline delimited word file into a vector
(define (read-dictionary filename)
  ;; sort list after we took it from the file, and then convert to
  ;; vector.
  (list->vector
   ;; remove any whitespace
   (map string-trim-both
    ;; sort words in file as strings (I realized that I don't actually
    ;; need this)
    ((cut sort <> string<?) 
     (with-input-from-file filename
       (lambda ()
	 ;; go through each line and add it to the list
	 (let loop ((items '()))
	   (let* ((line (read-line (current-input-port) 'split ))
		  (text (car line))
		  (delimiter (cdr line)))
	     ;; if string is last one
	     (if (eof-object? delimiter)
		 ;; add last string to list
		 (if (eof-object? text)
		     items
		     (cons text items))
		 ;; recursive case (if it is not last one)
		 (loop (cons text items)))))))))))

(define (shuffle-string string)
  (list->string
   ;; return a list of the new characters
   (let loop ((newstring-li '())
	      (indexes (iota (string-length string))))
     (if (null? indexes)
	 ;; return the shiffled chars list
	 newstring-li
	 ;; grab a random index from the list of indexes left
	 ;; insert the index into the newstring
	 (let* ((index (list-ref indexes (random (length indexes))))
		(ch (string-ref string index)))
	   (loop (cons ch newstring-li) (delete index indexes)))))))

(define (delete1-ch ch li)
  (let loop ((accum '() )
	     (li li))
    (if (null? li)
	#f
	(let* ((head (car li))
	       (tail (cdr li)))
	  (if (char=? head ch)
	      (append (reverse accum ) tail)
	      (loop (cons head accum) tail))))))

;; checks if anagram is an anagram of base word
(define (check-anagram anagram base-word)
  (let loop ((anagram-list (string->list anagram))
	     (base-word-list (string->list base-word)))
    (if (or (null? base-word-list) (null? anagram-list))
	(and (null? base-word-list) (null? anagram-list))
	(let ((cmp-char
	       (car anagram-list)))
	  (if (member cmp-char base-word-list)
	      (loop (cdr anagram-list)
		    (delete1-ch cmp-char base-word-list))
	      #f)))))

(define (pick-word dictionary)
  (vector-ref dictionary (random (vector-length dictionary))))

(define (get-anagram-question dictionary)
  (let ((word (pick-word dictionary)))
    (cons word (shuffle-string word))))

(define (strncmp string1 string2)
  (let ((comparison (cut <> string1 string2)))
    (cond ((comparison string<?) -1)
	  ((comparison string= ) 0)
	  ((comparison string>?) 1))))

;; checks if anagram is in dictionary and an anagram of the question.
(define (check-anagram-answer answer question dictionary)
  ;; word in dictionary, and the answer is an anagram of question
  (and (vector-binary-search dictionary answer strncmp)
       (check-anagram answer question)))

(define (question-loop dictionary)
  (let* ((aq (get-anagram-question dictionary))
	 (question (cdr aq))
	 (answer (car aq)))
    (display question) (newline)
    (let ((user-answer (read-line)))
      (unless (eof-object? user-answer)
	(if (check-anagram-answer user-answer question dictionary)
	    (display "correct, ")
	    (display "incorrect, "))
	(display "(answer was: ")
	(display answer)
	(display ")")
	(newline)
	(question-loop dictionary)))))

(define (main argv) 
  (if (= 2 (length argv))
      (let* ((filename (cadr argv))
	     (dictionary (read-dictionary filename)))
	;; check if file exists [[info:guile#File
	;; System][guile#File System]]
	(if (access? (cadr argv) R_OK)
	    (question-loop  dictionary)
	    (display "Cannot access files\n")))
      (display "Invalid number of arguments\n")))


