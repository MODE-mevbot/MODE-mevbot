;;; inferior-haskell-tests.el --- tests for collapse module  -*- lexical-binding: t -*-

;; Copyright © 2017 Vasantha Ganesh K. <vasanthaganesh.k@tuta.io>

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


(require 'ert)
(require 'inf-haskell)
(require 'haskell-string)

(ert-deftest test-run-haskell ()
  (run-haskell)
  (should (equal (inferior-haskell-get-result "1 + 1")
                 "2")))
