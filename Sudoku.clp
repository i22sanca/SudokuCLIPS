;;; IC: Sesión práctica
;;; Resolución deductiva de un Sudoku
;;; Dpto. de C. de la Computación e I.A. (Univ. de Sevilla)
;;;============================================================================


;;;============================================================================
;;; Introducción
;;;============================================================================

;;;   Sudoku es un pasatiempo que se popularizó en Japón en 1986, y se dió a
;;; conocer en el ámbito internacional en 2005. El objetivo es rellenar una
;;; cuadrícula de 9 x 9 celdas (81 casillas) dividida en subcuadrículas de
;;; 3 x 3 (llamadas "cajas") con las cifras del 1 al 9 partiendo de algunos
;;; números ya dispuestos en algunas de las celdas. La única restricción es que
;;; no se debe repetir ninguna cifra en una misma fila, columna o caja.

;;;   Un ejemplo de Sudoku es el siguiente:

;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  | |7| | |8|5| | | | | |
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  | |3| | | | | | |5| |7|
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  | | | | | | |7| | |6| |
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  |4| | | | | | | | | |1|
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  |2|9|3| | | | | | | |4|
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  | | | | |7| |6| | |9| |
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  | | |2| |1|3|9| | | | |
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  | | | | | | | | |1| | |
;;;                  +-+-+-+ +-+-+-+ +-+-+-+
;;;                  |1| | | |2| | | | | | |
;;;                  +-+-+-+ +-+-+-+ +-+-+-+

;;;============================================================================
;;; Representación del sudoku
;;;============================================================================

;;;   Utilizaremos la siguiente plantilla para representar las celdas del
;;; sudoku. Cada celda tiene los siguientes campos:
;;; - fila: Número de fila en la que se encuentra la celda
;;; - columna: Número de columna en la que se encuentra la celda
;;; - caja: Número de caja en el que se encuentra la celda
;;; - rango: Rango de valores que se pueden colocar en la celda. Inicialmente
;;;   el rango son todos los valores numéricos de 1 a 9.

(deftemplate celda
  (slot fila)
  (slot columna)
  (slot caja)
  (multislot rango
             (default (create$ 1 2 3 4 5 6 7 8 9))))

;;;   De esta forma, una celda tendrá un valor asignado si y solo si dicho
;;; valor es el único elemento del rango.

;;;   Consideraremos el sudoku anterior representado por el siguiente conjunto
;;; de hechos, uno para cada celda del tablero:

(deffacts ejemplo
  (celda (fila 1) (columna 1) (caja 1))
  (celda (fila 1) (columna 2) (caja 1) (rango 7))
  (celda (fila 1) (columna 3) (caja 1))
  (celda (fila 1) (columna 4) (caja 2) (rango 8))
  (celda (fila 1) (columna 5) (caja 2) (rango 5))
  (celda (fila 1) (columna 6) (caja 2))
  (celda (fila 1) (columna 7) (caja 3))
  (celda (fila 1) (columna 8) (caja 3))
  (celda (fila 1) (columna 9) (caja 3))

  (celda (fila 2) (columna 1) (caja 1))
  (celda (fila 2) (columna 2) (caja 1) (rango 3))
  (celda (fila 2) (columna 3) (caja 1))
  (celda (fila 2) (columna 4) (caja 2))
  (celda (fila 2) (columna 5) (caja 2))
  (celda (fila 2) (columna 6) (caja 2))
  (celda (fila 2) (columna 7) (caja 3) (rango 5))
  (celda (fila 2) (columna 8) (caja 3))
  (celda (fila 2) (columna 9) (caja 3) (rango 7))

  (celda (fila 3) (columna 1) (caja 1))
  (celda (fila 3) (columna 2) (caja 1))
  (celda (fila 3) (columna 3) (caja 1))
  (celda (fila 3) (columna 4) (caja 2))
  (celda (fila 3) (columna 5) (caja 2))
  (celda (fila 3) (columna 6) (caja 2) (rango 7))
  (celda (fila 3) (columna 7) (caja 3))
  (celda (fila 3) (columna 8) (caja 3) (rango 6))
  (celda (fila 3) (columna 9) (caja 3))

  (celda (fila 4) (columna 1) (caja 4) (rango 4))
  (celda (fila 4) (columna 2) (caja 4))
  (celda (fila 4) (columna 3) (caja 4))
  (celda (fila 4) (columna 4) (caja 5))
  (celda (fila 4) (columna 5) (caja 5))
  (celda (fila 4) (columna 6) (caja 5))
  (celda (fila 4) (columna 7) (caja 6))
  (celda (fila 4) (columna 8) (caja 6))
  (celda (fila 4) (columna 9) (caja 6) (rango 1))

  (celda (fila 5) (columna 1) (caja 4) (rango 2))
  (celda (fila 5) (columna 2) (caja 4) (rango 9))
  (celda (fila 5) (columna 3) (caja 4) (rango 3))
  (celda (fila 5) (columna 4) (caja 5))
  (celda (fila 5) (columna 5) (caja 5))
  (celda (fila 5) (columna 6) (caja 5))
  (celda (fila 5) (columna 7) (caja 6))
  (celda (fila 5) (columna 8) (caja 6))
  (celda (fila 5) (columna 9) (caja 6) (rango 4))

  (celda (fila 6) (columna 1) (caja 4))
  (celda (fila 6) (columna 2) (caja 4))
  (celda (fila 6) (columna 3) (caja 4))
  (celda (fila 6) (columna 4) (caja 5) (rango 7))
  (celda (fila 6) (columna 5) (caja 5))
  (celda (fila 6) (columna 6) (caja 5) (rango 6))
  (celda (fila 6) (columna 7) (caja 6))
  (celda (fila 6) (columna 8) (caja 6) (rango 9))
  (celda (fila 6) (columna 9) (caja 6))

  (celda (fila 7) (columna 1) (caja 7))
  (celda (fila 7) (columna 2) (caja 7))
  (celda (fila 7) (columna 3) (caja 7) (rango 2))
  (celda (fila 7) (columna 4) (caja 8) (rango 1))
  (celda (fila 7) (columna 5) (caja 8) (rango 3))
  (celda (fila 7) (columna 6) (caja 8) (rango 9))
  (celda (fila 7) (columna 7) (caja 9))
  (celda (fila 7) (columna 8) (caja 9))
  (celda (fila 7) (columna 9) (caja 9))

  (celda (fila 8) (columna 1) (caja 7))
  (celda (fila 8) (columna 2) (caja 7))
  (celda (fila 8) (columna 3) (caja 7))
  (celda (fila 8) (columna 4) (caja 8))
  (celda (fila 8) (columna 5) (caja 8))
  (celda (fila 8) (columna 6) (caja 8))
  (celda (fila 8) (columna 7) (caja 9) (rango 1))
  (celda (fila 8) (columna 8) (caja 9))
  (celda (fila 8) (columna 9) (caja 9))

  (celda (fila 9) (columna 1) (caja 7) (rango 1))
  (celda (fila 9) (columna 2) (caja 7))
  (celda (fila 9) (columna 3) (caja 7))
  (celda (fila 9) (columna 4) (caja 8) (rango 2))
  (celda (fila 9) (columna 5) (caja 8))
  (celda (fila 9) (columna 6) (caja 8))
  (celda (fila 9) (columna 7) (caja 9))
  (celda (fila 9) (columna 8) (caja 9))
  (celda (fila 9) (columna 9) (caja 9))
  )

;;;============================================================================
;;; Estrategias de resolución
;;;============================================================================

;;;----------------------------------------------------------------------------
;;; 1) Estrategia del valor asignado
;;;----------------------------------------------------------------------------

;;;   Si una celda tiene un único valor en su rango entonces dicho valor se
;;; puede eliminar del rango de cualquier otra celda distinta que esté situada
;;; en la misma fila, columna o caja.

;;;   Implementa la estrategia del valor asignado con tres reglas: una por
;;; filas (valor-asignado-fila), otra por columnas (valor-asignado-columna) y
;;; una última por cajas (valor-asignado-caja).

(defrule valor-asignado-fila
  ?h1 <- (celda (fila ?f) (rango ?v))
  ?h2 <- (celda (fila ?f) (rango $?ini ?v $?fin))
  (test (neq ?h1 ?h2))
  =>
  (modify ?h2
	  (rango $?ini $?fin)))

(defrule valor-asignado-columna
  ?h1 <- (celda (columna ?c) (rango ?v))
  ?h2 <- (celda (columna ?c) (rango $?ini ?v $?fin))
  (test (neq ?h1 ?h2))
  =>
  (modify ?h2
	  (rango $?ini $?fin)))

(defrule valor-asignado-caja
  ?h1 <- (celda (caja ?b) (rango ?v))
  ?h2 <- (celda (caja ?b) (rango $?ini ?v $?fin))
  (test (neq ?h1 ?h2))
  =>
  (modify ?h2
	  (rango $?ini $?fin)))

;;;----------------------------------------------------------------------------
;;; 2) Estrategia de los pares asignados
;;;----------------------------------------------------------------------------

;;;   Si dos celdas de la misma unidad (fila, columna o caja) tiene dos únicos
;;; valores en su rango entonces dichos valores se pueden eliminar del rango de
;;; cualquier otra celda distinta que esté situada en la misma unidad.

;;;   Implementa la estrategia de los pares asignados con tres reglas: una por
;;; filas (par-asignado-fila), otra por columnas (par-asignado-columna) y
;;; una última por cajas (par-asignado-caja).

; (defrule par-asignado-fila
;   ?h1 <- (celda (fila ?f) (rango ?v1 ?v2))
;   ?h2 <- (celda (fila ?f) (rango ?v1 ?v2))
;   (test (neq ?h1 ?h2))
;   ?h3 <- (celda (fila ?f) (rango $?ini ?v&?v1|?v2 $?fin))
;   (test (and (neq ?h1 ?h3) (neq ?h2 ?h3)))
;   =>
;   (modify ?h3
; 	  (rango $?ini $?fin)))

; (defrule par-asignado-columna
;   ?h1 <- (celda (columna ?c) (rango ?v1 ?v2))
;   ?h2 <- (celda (columna ?c) (rango ?v1 ?v2))
;   (test (neq ?h1 ?h2))
;   ?h3 <- (celda (columna ?c) (rango $?ini ?v&?v1|?v2 $?fin))
;   (test (and (neq ?h1 ?h3) (neq ?h2 ?h3)))
;   =>
;   (modify ?h3
; 	  (rango $?ini $?fin)))

; (defrule par-asignado-caja
;   ?h1 <- (celda (caja ?b) (rango ?v1 ?v2))
;   ?h2 <- (celda (caja ?b) (rango ?v1 ?v2))
;   (test (neq ?h1 ?h2))
;   ?h3 <- (celda (caja ?b) (rango $?ini ?v&?v1|?v2 $?fin))
;   (test (and (neq ?h1 ?h3) (neq ?h2 ?h3)))
;   =>
;   (modify ?h3
; 	  (rango $?ini $?fin)))

;;;----------------------------------------------------------------------------
;;; 3) Estrategia del valor oculto
;;;----------------------------------------------------------------------------

;;;   Si una celda tiene un posible valor en su rango, el rango tiene más de un
;;; valor, y no hay ninguna otra celda distinta en la misma fila, columna o
;;; caja que tenga dicho valor en su rango, entonces se puede asignar dicho
;;; valor a la celda inicial.

;;;   Implementa la estrategia del valor oculto con tres reglas: una por filas
;;; (valor-oculto-fila), otra por columnas (valor-oculto-columna) y una última
;;; por cajas (valor-oculto-caja).

(defrule valor-oculto-fila
  ?h <- (celda (fila ?f) (columna ?c1) (rango $? ?v $?))
  (celda (fila ?f) (columna ?c1) (rango ? ? $?))
; (not (celda (fila ?f) (columna ?c1) (rango ?v)))
  (not (celda (fila ?f) (columna ?c2&~?c1) (rango $? ?v $?)))
  =>
  (modify ?h
	  (rango ?v)))

(defrule valor-oculto-columna
  ?h <- (celda (fila ?f1) (columna ?c) (rango $? ?v $?))
  (celda (fila ?f1) (columna ?c) (rango ? ? $?))
; (not (celda (fila ?f1) (columna ?c) (rango ?v)))
  (not (celda (fila ?f2&~?f1) (columna ?c) (rango $? ?v $?)))
  =>
  (modify ?h
	  (rango ?v)))

(defrule valor-oculto-caja
  ?h <- (celda (fila ?f1) (columna ?c1)
	       (caja ?b) (rango $? ?v $?))
  (celda (fila ?f1) (columna ?c1) (rango ? ? $?))
; (not (celda (fila ?f1) (columna ?c1) (rango ?v)))
  (not (celda (fila ?f2)
	      (columna ?c2&:(or (!= ?f1 ?f2) (!= ?c1 ?c2)))
	      (caja ?b) (rango $? ?v $?)))
  =>
  (modify ?h
	  (rango ?v)))

;;;----------------------------------------------------------------------------
;;; 4) Estrategia de los pares ocultos
;;;----------------------------------------------------------------------------

;;;   Si dos celdas C1 y C2 de la misma unidad (fila, columna o caja) tienen
;;; dos posibles valores en su rango, el rango tiene más elementos, y no hay
;;; ninguna otra celda distinta en la misma unidad con dichos valores en su
;;; rango, entonces se puede eliminar cualquier otro valor del rango de las
;;; celdas C1 y C2.

;;;   Implementa la estrategia de los pares ocultos con tres reglas: una por
;;; filas (par-oculto-fila), otra por columnas (par-oculto-columna) y una
;;; última por cajas (par-oculto-caja).

(defrule par-oculto-fila
  ?h <- (celda (fila ?f) (columna ?c1) (rango $? ?v $?))
  ?h1 <- (celda (fila ?f) (columna ?c2) (rango $? ?v $?))
  (test (neq ?h ?h1))
  (celda (fila ?f) (columna ?c1) (rango $? ?v1&~?v $?))
  (celda (fila ?f) (columna ?c2&~c1) (rango $? ?v1 $?))
;;;Comprobar que haya valores que eliminar
  (celda (fila ?f) (columna ?c1) (rango ? ? ? $?))
  (celda (fila ?f) (columna ?c2) (rango ? ? ? $?))
  (not (celda (fila ?f) (columna ?c3&:(and (neq ?c3 ?c1) (neq ?c3 ?c2))) (rango $? ?v|?v1 $?)))
  =>
  (modify ?h (rango ?v ?v1))
  (modify ?h1 (rango ?v ?v1)))

(defrule par-oculto-columna
  ?h <- (celda (fila ?f1) (columna ?c) (rango $? ?v $?))
  ?h1 <- (celda (fila ?f2&~?f1) (columna ?c) (rango $? ?v $?))
  (celda (fila ?f1) (columna ?c) (rango $? ?v1&~?v $?))
  (celda (fila ?f2&~?f1) (columna ?c) (rango $? ?v1 $?))
;;;Comprobar que haya valores que eliminar
  (celda (fila ?f1) (columna ?c) (rango ? ? ? $?))
  (celda (fila ?f2) (columna ?c) (rango ? ? ? $?))
  (not (celda (fila ?f3&:(and (neq ?f3 ?f1) (neq ?f3 ?f2))) (columna ?c) (rango $? ?v|?v1 $?)))
  =>
  (modify ?h (rango ?v ?v1))
  (modify ?h1 (rango ?v ?v1)))

(defrule par-oculto-caja
  ?h <- (celda (fila ?f1) (columna ?c1) (caja ?b) (rango $? ?v $?))
  ?h1 <- (celda (fila ?f2) (columna ?c2&:(or (!= ?f1 ?f2) (!= ?c1 ?c2))) (caja ?b) (rango $? ?v $?))
  (celda (fila ?f1) (columna ?c1) (rango $? ?v1&~?v $?))
  (celda (fila ?f2) (columna ?c2&:(or (!= ?f1 ?f2) (!= ?c1 ?c2))) (caja ?b) (rango $? ?v1 $?))
;;;Comprobar que haya valores que eliminar
  (celda (fila ?f1) (columna ?c1) (rango ? ? ? $?))
  (celda (fila ?f2) (columna ?c2) (rango ? ? ? $?))
  (not (celda (fila ?f3) (columna ?c3&:(and
					(or (!= ?f1 ?f3) (!= ?c1 ?c3))
					(or (!= ?f2 ?f3) (!= ?c2 ?c3)))) (rango $? ?v|?v1 $?)))
  =>
  (modify ?h (rango ?v ?v1))
  (modify ?h1 (rango ?v ?v1)))

;;;----------------------------------------------------------------------------
;;; 5) Estrategia de la intersección
;;;----------------------------------------------------------------------------

;;;   Consideremos una unidad U1 (fila o columna) y una caja U2 con tres celdas
;;; en común, C1, C2 y C3. Si un valor no aparece en el rango de ninguna celda
;;; de la unidad U1 (respectivamente U2) distinta de C1, C2 y C3, entonces
;;; dicho valor se puede eliminar del rango de cualquier celda de la unidad U2
;;; (respectivamente U1) distinta de C1, C2 y C3.

;;;   Implementa la estrategia de la intersección con cuatro reglas, una para
;;; cada combinación posible: interseccion-fila-caja, interseccion-caja-fila,
;;; interseccion-columna-caja e interseccion-caja-columna.

;;;Regla para eliminar de la caja
(defrule interseccion-fila-caja
  ?h <- (celda (fila ?f) (caja ?b) (rango $? ?v $?))
  (not (celda (fila ?f) (caja ?b1&~?b) (rango $? ?v $?)))
  ?h1 <- (celda (fila ?f2&~?f) (caja ?b) (rango $?inicio ?v $?fin))
  =>
  (modify ?h1 (rango $?inicio $?fin)))

;;;Regla para eliminar de la fila
(defrule interseccion-caja-fila
  ?h <- (celda (fila ?f) (caja ?b) (rango $? ?v $?))
  (not (celda (fila ?f1&~?f) (caja ?b) (rango $? ?v $?)))
  ?h1 <- (celda (fila ?f) (caja ?b1&~?b) (rango $?inicio ?v $?fin))
  =>
  (modify ?h1 (rango $?inicio $?fin)))


;;;Regla para eliminar de la caja
(defrule interseccion-columna-caja
  ?h <- (celda (columna ?c) (caja ?b) (rango $? ?v $?))
  (not (celda (columna ?c) (caja ?b1&~?b) (rango $? ?v $?)))
  ?h1 <- (celda (columna ?c2&~?c) (caja ?b) (rango $?inicio ?v $?fin))
  =>
  (modify ?h1 (rango $?inicio $?fin)))

;;;Regla para eliminar de la columna
(defrule interseccion-caja-columna
  ?h <- (celda (columna ?c) (caja ?b) (rango $? ?v $?))
  (not (celda (columna ?c1&~?c) (caja ?b) (rango $? ?v $?)))
  ?h1 <- (celda (columna ?c) (caja ?b1&~?b) (rango $?inicio ?v $?fin))
  =>
  (modify ?h1 (rango $?inicio $?fin)))

;;;----------------------------------------------------------------------------
;;; 6) Estrategia de la cruz
;;;----------------------------------------------------------------------------

;;;   Dadas cuatro celdas C1, C2, C3 y C4 tales que C1 y C2 están en la unidad
;;; U12 (por ejemplo fila), C3 y C4 están en una unidad U34 del mismo tipo que
;;; el anterior pero distinta, C1 y C3 están una unidad de otro tipo U13 (por
;;; ejemplo columna) y C2 y C4 están en una unidad U24 del mismo tipo que el
;;; anterior pero distinta. Si en el rango de las cuatro celdas hay un mismo
;;; valor que no aparece en ninguna otra celda de las unidades U12 ni U34
;;; (respectivamente U13 ni U24), entonces dicho valor se puede eliminar del
;;; rango de cualquier celda de las unidades U13 y U24 (respectivamente U12 y
;;; U34) distinta de C1, C2, C3 y C4.

;;;   En http://www.sudoku.org.uk/SolvingTechniques/X-WingFamily.asp se puede
;;; encontrar una descripción más detallada de esta situación y ejemplos de la
;;; misma.

;;;   Implementa la estrategia de la cruz con las reglas que sean necesarias
;;; para tener en cuenta todos los casos posibles: cruz-fila-columna,
;;; cruz-fila-caja, cruz-columna-fila, cruz-columna-caja, cruz-caja-fila y
;;; cruz-caja-columna.

(defrule cruz-fila-columna
  (celda (fila ?f1) (columna ?c1) (rango $? ?v $?))
  (celda (fila ?f1) (columna ?c2&~?c1) (rango $? ?v $?))
  (celda (fila ?f2&~?f1) (columna ?c1) (rango $? ?v $?))
  (celda (fila ?f2) (columna ?c2) (rango $? ?v $?))
  (not (celda (fila ?f3&~?f1&~?f2) (columna ?c1) (rango $? ?v $?)))
  (not (celda (fila ?f3&~?f1&~?f2) (columna ?c2) (rango $? ?v $?)))
  ?h <- (celda (fila ?f1|?f2) (columna ?c3&~?c1&~?c2) (rango $?inicio ?v $?fin))
  =>
  (modify ?h (rango $?inicio $?fin)))

(defrule cruz-fila-caja
  (celda (fila ?f1) (caja ?b1) (rango $? ?v $?))
  (celda (fila ?f1) (caja ?b2&~?b1) (rango $? ?v $?))
  (celda (fila ?f2&~?f1) (caja ?b1) (rango $? ?v $?))
  (celda (fila ?f2) (caja ?b2) (rango $? ?v $?))
  (not (celda (fila ?f3&~?f1&~?f2) (caja ?b1) (rango $? ?v $?)))
  (not (celda (fila ?f3&~?f1&~?f2) (caja ?b2) (rango $? ?v $?)))
  ?h <- (celda (fila ?f1|?f2) (caja ?b3&~?b1&~?b2) (rango $?inicio ?v $?fin))
  =>
  (modify ?h (rango $?inicio $?fin)))

(defrule cruz-columna-caja
  (celda (columna ?c1) (caja ?b1) (rango $? ?v $?))
  (celda (columna ?c1) (caja ?b2&~?b1) (rango $? ?v $?))
  (celda (columna ?c2&~?c1) (caja ?b1) (rango $? ?v $?))
  (celda (columna ?c2) (caja ?b2) (rango $? ?v $?))
  (not (celda (columna ?c3&~?c1&~?c2) (caja ?b1) (rango $? ?v $?)))
  (not (celda (columna ?c3&~?c1&~?c2) (caja ?b2) (rango $? ?v $?)))
  ?h <- (celda (columna ?c1|?c2) (caja ?b3&~?b1&~?b2) (rango $?inicio ?v $?fin))
  =>
  (modify ?h (rango $?inicio $?fin)))

(defrule cruz-columna-fila
  (celda (fila ?f1) (columna ?c1) (rango $? ?v $?))
  (celda (fila ?f1) (columna ?c2&~?c1) (rango $? ?v $?))
  (celda (fila ?f2&~?f1) (columna ?c1) (rango $? ?v $?))
  (celda (fila ?f2) (columna ?c2) (rango $? ?v $?))
  (not (celda (fila ?f1) (columna ?c3&~?c1&~?c2) (rango $? ?v $?)))
  (not (celda (fila ?f2) (columna ?c3&~?c1&~?c2) (rango $? ?v $?)))
  ?h <- (celda (fila ?f3&~?f1&~?f2) (columna ?c1|?c2) (rango $?inicio ?v $?fin))
  =>
  (modify ?h (rango $?inicio $?fin)))

(defrule cruz-caja-fila
  (celda (fila ?f1) (caja ?b1) (rango $? ?v $?))
  (celda (fila ?f1) (caja ?b2&~?b1) (rango $? ?v $?))
  (celda (fila ?f2&~?f1) (caja ?b1) (rango $? ?v $?))
  (celda (fila ?f2) (caja ?b2) (rango $? ?v $?))
  (not (celda (fila ?f1) (caja ?b3&~?b1&~?b2) (rango $? ?v $?)))
  (not (celda (fila ?f2) (caja ?b3&~?b1&~?b2) (rango $? ?v $?)))
  ?h <- (celda (fila ?f3&~?f1&~?f2) (caja ?b1|?b2) (rango $?inicio ?v $?fin))
  =>
  (modify ?h (rango $?inicio $?fin)))

(defrule cruz-caja-columna
  (celda (columna ?c1) (caja ?b1) (rango $? ?v $?))
  (celda (columna ?c1) (caja ?b2&~?b1) (rango $? ?v $?))
  (celda (columna ?c2&~?c1) (caja ?b1) (rango $? ?v $?))
  (celda (columna ?c2) (caja ?b2) (rango $? ?v $?))
  (not (celda (columna ?c1) (caja ?b3&~?b1&~?b2) (rango $? ?v $?)))
  (not (celda (columna ?c2) (caja ?b3&~?b1&~?b2) (rango $? ?v $?)))
  ?h <- (celda (columna ?c3&~?c1&~?c2) (caja ?b1|?b2) (rango $?inicio ?v $?fin))
  =>
  (modify ?h (rango $?inicio $?fin)))


;;;============================================================================
;;; Reglas para imprimir el resultado
;;;============================================================================

;;;   Las siguientes reglas permiten visualizar el estado del sudoku, una vez
;;; aplicadas todas las reglas que implementan las estrategias de resolución:

(defrule imprime-solucion
  (declare (salience -10))
  =>
  (printout t "+---+---+---+" crlf "|")
  (assert (imprime 1 1)))

(defrule imprime-celda
  (declare (salience -10))
  ?h <- (imprime ?i ?j)
  (celda (fila ?i) (columna ?j) (rango $?v))
  =>
  (retract ?h)
  (if (= (length$ $?v) 1)
      then (printout t (nth$ 1 $?v))
    else (printout t " "))
  (if (= (mod ?j 3) 0)
      then (printout t "|"))
  (if (= (mod ?j 9) 0)
      then (printout t crlf))
  (if (and (= (mod ?i 3) 0) (= (mod ?j 9) 0))
      then (printout t "+---+---+---+" crlf))
  (if (and (= (mod ?j 9) 0) (not (= ?i 9)))
      then (printout t "|")
    (assert (imprime (+ ?i 1) 1))
    else (assert (imprime ?i (+ ?j 1)))))

;;;============================================================================
