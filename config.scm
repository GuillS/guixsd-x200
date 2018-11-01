;; This is an operating system configuration template
;; for a lenovo thinkpad x200 tablet setup with GNOME
;; based on the desktop template from the guixSD

(use-modules (gnu) 
             (gnu system nss)
             (gnu packages linux)
             (gnu packages wget)
             (gnu packages curl)
             (gnu packages admin)
             (gnu packages readline)
             (gnu packages file)
             (gnu packages emacs)
             (gnu packages guile)
             (gnu packages base)
             (gnu services xorg)
             (guix store))
(use-service-modules desktop)
(use-package-modules certs gnome xorg xdisorg)

;; Udev rule to enable pen and touch inputs
(define %wacom-udev-rule
  (udev-rule 
    "10-wacom.rules"
      (string-append "ACTION!=\"add|change\", "
                     "GOTO=\"wacom_end\"\n"
                     "ATTRS{id}==\"WACf*\" ENV{NAME}=\"Serial Wacom Tablet\", "
                     "ENV{ID_INPUT}=\"1\", "
                     "ENV{ID_INPUT_TABLET}=\"1\"\n"
                     "ATTRS{id}==\"FUJ*\" ENV{NAME}=\"Serial Wacom Tablet\", "
                     "ENV{ID_INPUT}=\"1\", "
                     "ENV{ID_INPUT_TABLET}=\"1\"\n"
                     "LABEL=\"wacom_end\"\n")))

(define %custom-services
  (modify-services %desktop-services
;; Installation of the udev rule
    (udev-service-type config =>
      (udev-configuration (inherit config)
        (rules (append (udev-configuration-rules config)
                       (list %wacom-udev-rule)))))
;; Hydra server is offline so i use berlin server for substitutes
    (guix-service-type config =>
      (guix-configuration
        (inherit config)
        (substitute-urls (cons "https://berlin.guixsd.org" %default-substitute-urls))))
;; Add wacom driver and configuration for the X server
    (slim-service-type config =>
      (slim-configuration
        (inherit config)
        (startx (xorg-start-command
                 #:modules (cons xf86-input-wacom %default-xorg-modules)
                 #:configuration-file
                   (xorg-configuration-file
                   #:modules (cons xf86-input-wacom %default-xorg-modules))))))))

(operating-system
  (host-name "tpx200t")
  (timezone "Europe/Paris")
  (locale "fr_FR.utf8")
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (target "/dev/sda")))

  (swap-devices '("/dev/sda2"))
 
  (file-systems (cons* (file-system
                         (device (file-system-label "guixsd"))
                         (mount-point "/")
                         (type "ext4"))
                       (file-system
                         (device (file-system-label "home"))
                         (mount-point "/home")
                         (type "ext4"))
                       %base-file-systems))

  (users (cons (user-account
                (name "one")
                (comment "")
                (group "users")
                (supplementary-groups '("wheel" "netdev"
                                        "audio" "video"
                                        "dialout"))
                (home-directory "/home/one"))
               %base-user-accounts))

  ;; This is where we specify system-wide packages.
  (packages (cons* nss-certs         ;for HTTPS access
                   gvfs              ;for user mounts
                   ;;X
                   xf86-input-evdev
                   libwacom 
                   xdpyinfo
                   xmodmap xev xrandr xkill xbindkeys 
                   ;;cli utils
                   wget curl htop readline file
                   ;;emacs
                   emacs emacs-guix emacs-magit-popup emacs-smart-mode-line
                   emacs-rainbow-delimiters emacs-rainbow-identifiers
                   emacs-flycheck emacs-magit
                   emacs-scheme-complete emacs-neotree emacs-ag
                   emacs-undo-tree emacs-fill-column-indicator
                   emacs-yasnippet emacs-yasnippet-snippets
                   emacs-danneskjold-theme
                   geiser guile-2.2 paredit emacs-debbugs
               
                   %base-packages))

  (services (cons*
              (gnome-desktop-service)
              %custom-services))

  ;; Allow resolution of '.local' host names with mDNS.
  (name-service-switch %mdns-host-lookup-nss))
