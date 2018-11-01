(use-modules (guix packages)
             (guix download)
	     (guix utils)
             (guix build-system gnu)
             (guix licenses))

(define-public inputattach
  (package
    (name "inputattach")
    (version "1.6.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://prdownloads.sourceforge.net/linuxconsole/linuxconsoletools-"
				  version
				  ".tar.bz2/download"))
              (sha256
               (base32
                "0il1m8pgw8f6b8qid035ixamv0w5fgh9pinx5vw4ayxn03nyzlnf"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:make-flags (list "inputattach"
			  (string-append "prefix=" (assoc-ref %outputs "out"))
			  "CC=gcc")
       #:phases
       (modify-phases %standard-phases
		      (delete 'configure)
		      (add-before 'build 'that
				 (lambda _
				 (chdir "utils")
				 #t))
		      (replace 'install
			       (lambda*
				 (#:key outputs #:allow-other-keys)
				 (let ((out (assoc-ref outputs "out")))
				   (install-file "inputattach"
						 (string-append out "/bin"))
				   (chdir "../docs")
				   (install-file "inputattach.1"
						 (string-append out "/share/man/man1")))
				 #t))
    )))
    (synopsis "inputattach is an utility for serial devices from the linuxconsole tools")
    (description
     "This project maintains the Linux Console tools, which include utilities to test and configure joysticks, connect legacy devices to the kernel's input subsystem (providing support for serial mice, touchscreens etc.), and test the input event layer.")
    (home-page "https://sourceforge.net/projects/linuxconsole/")
    (license gpl2)))

inputattach
