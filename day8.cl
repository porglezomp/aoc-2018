(defstruct meta-tree
  (children '() :type list)
  (meta '() :type list))

(defun read-tree (is)
  (let* ((num-children (read is))
         (num-meta (read is))
         (children (loop repeat num-children collect (read-tree is)))
         (meta (loop repeat num-meta collect (read is))))
     (make-meta-tree :children children :meta meta)))

(defun sum-tree (tree)
  (+ (loop for meta in (meta-tree-meta tree) sum meta)
     (loop for child in (meta-tree-children tree) sum (sum-tree child))))

(defun checksum (tree)
  (let ((children (meta-tree-children tree)))
    (if (null children)
      (sum-tree tree)
      (loop
        for meta in (meta-tree-meta tree)
        for child = (nth (- meta 1) children)
        when child sum (checksum child)))))

(let ((tree (read-tree *standard-input*)))
  (format t "~d~%" (sum-tree tree))
  (format t "~d~%" (checksum tree)))
