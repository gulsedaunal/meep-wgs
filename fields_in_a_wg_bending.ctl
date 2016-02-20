;15-16 dec 2015, bilkent university, gulsedaunal
;due to a localized CW incidence on a wg the field profile is observed

(reset-meep)
(use-output-directory) ;place all the results in a folder

;define parameters 
(define-param w 1) ; width of wg
(define-param sx 16) ;size of simulation cell in x-dir
(define-param sy 32) ;size of simulation cell in y-dir
(define-param pad 4) ;padding between wg and simulation cell
(define-param wg-xcen (* 0.5 (- sx w (* 2 pad)))) ;x center of vertical wg
(define-param wg-ycen (* -0.5 (- sy w (* 2 pad)))) ;y center of horizontal wg
(define-param pml-thick 1.0)

; define computational cell
(set! geometry-lattice (make lattice (size sx sy no-size)))
;geometry-lattice is a global variable of type constant int
;lattice is the class object
;set is a procedure that specifies the value of the variable geometry-lattice
;make construct an object of the class lattice
;size here is a property of the class lattice

; add the wg
(set! geometry 
	(if no-bend?
		(list (make block ;no bending single wg 
			(center 0 wg-ycen)
			(material (make dielectric (epsilon 12)))
			(size infinity w infinity)))
		(list ;bending occurs 2 wgs 
			(make block (center (* -0.5 pad) wg-ycen)  (material (make dielectric (epsilon 12)))  (size (- sx pad) w infinity))
			(make block (center wg-xcen (* 0.5 pad))  (material (make dielectric (epsilon 12)))  (size w (- sy pad) infinity)))
))



;geometry is a global variable of type list 
;geometry is a list of geometric-object superclass
;block is a subclass of geometric-object
;center and material are properties of class geometric-object and they dont have default values
;size is a property of subclass block with no default value
;material property; a material-type class has three alternatives dielectric,perfect metal,material function


;specify the sources
(set! sources
	(if no-bend?
	 	(list (make source 
			(src (make continuous-src (frequency 0.15)))
			(component Ez)
			(center (- (/ sx 2) pml-thick) wg-ycen)))
	 	(list (make source
                        (src (make continuous-src 
				(wavelength (* 2 (sqrt 12))) (width 20)))
                       	(component Ez)
			(size 0 1)
              		(center (+ (* -0.5 sx)  pml-thick) wg-ycen)))))

;sources is a global variable of type list from class source
;make constructs an object of class source and set sets that value to the variable sources
;src is a variable from src-time class
;src, component, center are properties of the cont-src (fixed freq sinusoid) source

;pml layers to the inside from the simulation boundary
(set! pml-layers (list (make pml (thickness pml-thick))))
;pml-layers is a list type variable of class pml
; thickness is a property of class pml

;discritization
(set! resolution 10)
;sets number of pixels per distance unit
;if wavelen is 6 then resolution is 60 px per wl

;run the simulation 
(run-until 200 ; time to run for
	(at-beginning output-epsilon)
	(at-end output-efield-z)
	(to-appended "ez" (at-every 0.6 output-efield-z))
	(at-every 0.6 (output-png Ez "-Zc bluered"))
	(to-appended "ez-slice"
		(at-every 0.6
			(in-volume (volume (center 0 -3.5) (size 16 0))
			output-efield-z)))
)

;run the simulation and specify the outputs
;only at the end and the beginning store the results
;at every 0.6 time interval save to single dataset ez
;instead of a huge dataset ez, you can save the png directly
;capture a specific area 

;eof

