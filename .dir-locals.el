;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((python-mode . ((python-interpreter . "nix develop --command python")
                 (python-shell-interpreter . "nix")
                 (python-shell-interpreter-args . "develop --command python -i")
                 (projectile-project-run-cmd . "nix develop .#preprocessPython --command python ./myapp.py")
                 )))
