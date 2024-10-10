
;; title: beanstalk-exchange
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
(define-constant err-zero-stx (err u101))
(define-constant err-zero-tokens (err u102))
(define-constant fee-basis-points u30)

;; data vars
;;

;; data maps
;;

;; public functions
(define-public (provide-liquidity (stx-amount uint) (max-token-amount uint))
    (begin
        (asserts! (> stx-amount u0) err-zero-stx)
        (asserts! (> max-token-amount u0) err-zero-tokens)

        (if (is-eq (get-stx-balance) u0)
            (provide-initial-liquidity stx-amount max-token-amount tx-sender)
            (provide-additional-liquidity stx-amount)
        )
    )
)

(define-public (stx-to-token-swap (stx-amount uint))
    (begin
        (asserts! (> stx-amount u0) err-zero-stx)

        (let
            (
                (contract-address (as-contract tx-sender))
                (stx-balance (get-stx-balance))
                (token-balance (get-token-balance))
                (product (* stx-balance token-balance))
                (new-stx-balance (+ stx-balance stx-amount))
                (fee (/ (* fee-basis-points stx-amount) u10000))
                (new-stx-balance-minus-fees (- new-stx-balance fee))
                (new-token-balance (/ product new-stx-balance-minus-fees))
                (tokens-to-transfer (- token-balance new-token-balance))
            )
            (try! (stx-transfer? stx-amount tx-sender contract-address))
            (contract-call? .magic-beans transfer tokens-to-transfer contract-address tx-sender)
        )
    )
)

(define-public (token-to-stx-swap (token-amount uint))
    (begin
        (asserts! (> token-amount u0) err-zero-tokens)

        (let
            (
                (contract-address (as-contract tx-sender))
                (stx-balance (get-stx-balance))
                (token-balance (get-token-balance))
                (product (* stx-balance token-balance))
                (fee (/ (* fee-basis-points token-amount) u10000))
                (new-token-balance (+ token-balance token-amount))
                (new-token-balance-minus-fees (- new-token-balance fee))
                (new-stx-balance (/ product new-token-balance-minus-fees))
                (stx-to-transfer (- stx-balance new-stx-balance))
                (sender-address tx-sender)

            )
            (try! (contract-call? .magic-beans transfer token-amount tx-sender contract-address))
            (as-contract (stx-transfer? stx-to-transfer tx-sender sender-address))
        )
    )
)

(define-public (remove-liquidity (liquidity-burnt uint))
    (begin
        (asserts! (> liquidity-burnt u0) err-zero-tokens)
        (let
            (
                (stx-balance (get-stx-balance))
                (token-balance (get-token-balance))
                (lp-token-supply (get-lp-token-supply))
                (stx-to-transfer (/ (* stx-balance liquidity-burnt) lp-token-supply))
                (tokens-to-transfer (/ (* token-balance liquidity-burnt) lp-token-supply))
                (contract-address (as-contract tx-sender))
                (recipient tx-sender)
            )
            (try! (contract-call? .magic-beans-lp burn liquidity-burnt))
            (print contract-address)
            (print stx-balance)
            (print token-balance)
            (print liquidity-burnt)
            (print lp-token-supply)
            (print tokens-to-transfer)
            (try! (as-contract (stx-transfer? stx-to-transfer contract-address recipient)))
            (as-contract (contract-call? .magic-beans transfer tokens-to-transfer contract-address recipient))
        )
    )
)

;; read only functions
(define-read-only (get-stx-balance)
    (stx-get-balance (as-contract tx-sender))
)

(define-read-only (get-token-balance)
    (contract-call? .magic-beans get-balance (as-contract tx-sender))
)

(define-read-only (get-lp-token-supply)
    (contract-call? .magic-beans-lp get-total-supply)
)

;; private functions
(define-private (provide-initial-liquidity (stx-amount uint) (max-token-amount uint) (provider principal))
    (begin
        (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
        (try! (contract-call? .magic-beans transfer max-token-amount tx-sender (as-contract tx-sender)))
        (as-contract (contract-call? .magic-beans-lp mint stx-amount provider))
    )
)

(define-private (provide-additional-liquidity (stx-amount uint))
    (let
        (
            (contract-address (as-contract tx-sender))
            (token-balance (get-token-balance))
            (lp-token-supply (get-lp-token-supply))
            (stx-balance (get-stx-balance))
            (tokens-to-transfer (/ (* stx-amount token-balance) stx-balance))
            (lps-to-mint (/ (* stx-amount lp-token-supply) stx-balance))
            (provider tx-sender)
        )
        (begin
            (try! (stx-transfer? stx-amount tx-sender contract-address))
            (try! (contract-call? .magic-beans transfer tokens-to-transfer tx-sender contract-address))
            (as-contract (contract-call? .magic-beans-lp mint lps-to-mint provider))
        )
    )
)
