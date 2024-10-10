
;; title: magic-beans-lp
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
(define-fungible-token magic-beans-lp)

;; constants
(define-constant err-minter-only (err u101))

;; data vars
(define-data-var minter principal tx-sender)

;; data maps
;;

;; public functions
(define-public (set-minter (new-minter principal))
    (begin
        (asserts! (is-eq tx-sender (var-get minter)) err-minter-only)
        ;; #[allow(unchecked_data)]
        (var-set minter new-minter)
        (ok true)
    )
)

(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (var-get minter)) err-minter-only)
        ;; #[allow(unchecked_data)]
        (ft-mint? magic-beans-lp amount recipient)
    )
)

(define-public (burn (amount uint))
    (ft-burn? magic-beans-lp amount tx-sender)
)

;; read only functions
(define-read-only (get-total-supply)
    (let 
        (
            (decimals (pow u10 (unwrap-panic (get-decimals))))

        )
        (/ (ft-get-supply magic-beans-lp) decimals)
    )
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-symbol)
    (ok "MAGIC-LP")
)

;; private functions
;;

