;;;; gfx.lisp

;; example:
;; 
;; (defun render (w h)
;;   (gfx:clear)
;;   ;; draw stuff with gl:blah
;;   (gfx:flush))
;; 
;; (gfx:window 'render :width 800 :height 600)

(in-package #:gfx)

(require :sdl2)
(require :cl-opengl)

(defparameter *win* nil)

(defun window (render-fn &key (width 640) (height 480) (title "untitled"))
  "Creates a window for drawing."
  (sdl2:with-init (:everything)
    (sdl2:with-window (win :title title :w width :h height :flags '(:shown :opengl))
      (sdl2:with-gl-context (gl-context win)
        (sdl2:gl-make-current win gl-context)
        (gl:viewport 0 0 width height)
        (gl:matrix-mode :projection)
        (gl:ortho 0 width 0 height -2 2)
        (gl:matrix-mode :modelview)
        (gl:load-identity)
        (gl:clear-color 0.0 0.0 0.0 1.0)
        (setf *win* win)
        (sdl2:with-event-loop (:method :poll)
          (:keydown (:keysym keysym)
                    (when (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
                      (sdl2:push-event :quit)))
          (:idle ()
                 (funcall render-fn width height))
          (:quit () t))))))

;; TODO: support an optional clear color
(defun clear ()
  (gl:clear :color-buffer))

(defun flush ()
  (gl:flush)
  (sdl2:gl-swap-window *win*))

;;=============================================================================

(quote
 (defun render (w h)
   (let ((hw (/ w 2))
         (hh (/ h 2)))
     (setq *rot* (+ *rot* 0.3))
     (gl:clear :color-buffer)

     ;; Transform
     (gl:load-identity)
     (gl:translate hw hh 0)
     (gl:rotate *rot* 0 0 1)

     ;; Draw a demo triangle
     (gl:begin :triangles)
     (gl:color 1.0 0.3 0.6)
     (gl:vertex 0.0 200.0)
     (gl:color 1.0 1.0 0.0)
     (gl:vertex -200.0 -100.0)
     (gl:color 0.3 1.0 1.0)
     (gl:vertex 200.0 -100.0)
     (gl:end)
     (gfx::flush))))
