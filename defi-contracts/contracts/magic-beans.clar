
;; title: magic-beans
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
(define-fungible-token magic-beans)

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

;; data vars
;;

;; data maps
;;

;; public functions
(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; #[allow(unchecked_data)]
        (ft-mint? magic-beans amount recipient)
    )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
    ;; #[allow(unchecked_data)]
    (ft-transfer? magic-beans amount sender recipient)
)

;; read only functions

(define-read-only (get-balance (who principal))
    (ft-get-balance magic-beans who)
)

;; private functions
;;

