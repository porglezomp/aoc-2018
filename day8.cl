(defstruct meta-tree
  (children '() :type list)
  (meta '() :type list))

(defun read-tree (is)
  (let* ((num-children (read is))
         (num-meta (read is))
         (children (loop for i from 1 to num-children collect (read-tree is)))
         (meta (loop for i from 1 to num-meta collect (read is))))
     (make-meta-tree :children children :meta meta)))

(defun sum-tree (tree)
  (+ (loop for meta in (meta-tree-meta tree) summing meta)
     (loop for child in (meta-tree-children tree) summing (sum-tree child))))

(format t "~d~%" (sum-tree (read-tree *standard-input*)))
