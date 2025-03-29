;; Dynamic NFT-Backed Loan Smart Contract
;; Manages loans backed by NFTs that change attributes based on repayment status

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_NFT_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_LISTED (err u102))
(define-constant ERR_NOT_LISTED (err u103))
(define-constant ERR_INSUFFICIENT_VALUE (err u104))
(define-constant ERR_LOAN_NOT_FOUND (err u105))
(define-constant ERR_LOAN_DEFAULTED (err u106))
(define-constant ERR_LOAN_NOT_DUE (err u107))
(define-constant ERR_LOAN_CLOSED (err u108))

;; NFT Definition
(define-non-fungible-token dynamic-nft uint)

;; Data Maps
(define-map token-attributes
    { token-id: uint }
    {
        rarity: uint,
        power-level: uint,
        condition: uint,
        last-updated: uint
    }
)

(define-map loan-details
    { loan-id: uint }
    {
        borrower: principal,
        lender: principal,
        token-id: uint,
        amount: uint,
        interest-rate: uint,
        duration: uint,
        start-block: uint,
        status: (string-utf8 20),
        missed-payments: uint,
        total-repaid: uint
    }
)

(define-map token-loans 
    { token-id: uint }
    { loan-id: uint }
)

(define-map loan-listings
    { token-id: uint }
    {
        owner: principal,
        requested-amount: uint,
        min-duration: uint,
        max-interest: uint
    }
)

;; Variables
(define-data-var next-token-id uint u1)
(define-data-var next-loan-id uint u1)

;; Read-only functions
(define-read-only (get-token-attributes (token-id uint))
    (map-get? token-attributes { token-id: token-id })
)

(define-read-only (get-loan-details (loan-id uint))
    (map-get? loan-details { loan-id: loan-id })
)

(define-read-only (get-token-loan (token-id uint))
    (map-get? token-loans { token-id: token-id })
)

(define-read-only (get-loan-listing (token-id uint))
    (map-get? loan-listings { token-id: token-id })
)

;; Mint new NFT
(define-public (mint-nft (recipient principal))
    (let 
        ((token-id (var-get next-token-id)))

        ;; Mint NFT
        (try! (nft-mint? dynamic-nft token-id recipient))

        ;; Set initial attributes
        (map-set token-attributes
            { token-id: token-id }
            {
                rarity: u100,
                power-level: u100,
                condition: u100,
                last-updated: stacks-block-height
            }
        )

        ;; Increment token ID
        (var-set next-token-id (+ token-id u1))
        (ok token-id)
    )
)

;; List NFT for loan
(define-public (list-nft-for-loan 
    (token-id uint) 
    (requested-amount uint)
    (min-duration uint)
    (max-interest uint))

    (let ((owner (unwrap! (nft-get-owner? dynamic-nft token-id) ERR_NFT_NOT_FOUND)))
        ;; Checks
        (asserts! (is-eq tx-sender owner) ERR_NOT_AUTHORIZED)
        (asserts! (is-none (get-loan-listing token-id)) ERR_ALREADY_LISTED)

        ;; Create listing
        (map-set loan-listings
            { token-id: token-id }
            {
                owner: tx-sender,
                requested-amount: requested-amount,
                min-duration: min-duration,
                max-interest: max-interest
            }
        )
        (ok true)
    )
)
