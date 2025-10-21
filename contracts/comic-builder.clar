;; Comic Builder Contract
;; Story panels minted as NFTs, assembled into comics by the community

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-panel-owner (err u101))
(define-constant err-panel-not-found (err u102))
(define-constant err-comic-not-found (err u103))
(define-constant err-invalid-panel-count (err u104))
(define-constant err-already-voted (err u105))

;; Data Variables
(define-data-var last-panel-id uint u0)
(define-data-var last-comic-id uint u0)

;; Data Maps
;; Store panel NFT data
(define-map panels
    uint
    {
        creator: principal,
        title: (string-ascii 50),
        image-uri: (string-ascii 256),
        description: (string-ascii 500),
        created-at: uint
    }
)

;; Track panel ownership
(define-map panel-owners
    uint
    principal
)

;; Store assembled comics
(define-map comics
    uint
    {
        creator: principal,
        title: (string-ascii 100),
        panel-ids: (list 20 uint),
        created-at: uint,
        upvotes: uint
    }
)

;; Track user votes on comics
(define-map comic-votes
    { comic-id: uint, voter: principal }
    bool
)

;; Read-only functions

(define-read-only (get-panel (panel-id uint))
    (map-get? panels panel-id)
)

(define-read-only (get-panel-owner (panel-id uint))
    (map-get? panel-owners panel-id)
)

(define-read-only (get-comic (comic-id uint))
    (map-get? comics comic-id)
)

(define-read-only (get-last-panel-id)
    (var-get last-panel-id)
)

(define-read-only (get-last-comic-id)
    (var-get last-comic-id)
)

(define-read-only (has-voted (comic-id uint) (voter principal))
    (default-to false (map-get? comic-votes { comic-id: comic-id, voter: voter }))
)

;; Public functions

;; Mint a new story panel NFT
(define-public (mint-panel (title (string-ascii 50)) (image-uri (string-ascii 256)) (description (string-ascii 500)))
    (let
        (
            (panel-id (+ (var-get last-panel-id) u1))
        )
        ;; Store panel data
        (map-set panels panel-id
            {
                creator: tx-sender,
                title: title,
                image-uri: image-uri,
                description: description,
                created-at: block-height
            }
        )
        ;; Set ownership
        (map-set panel-owners panel-id tx-sender)
        ;; Update last panel id
        (var-set last-panel-id panel-id)
        (ok panel-id)
    )
)

;; Transfer panel ownership
(define-public (transfer-panel (panel-id uint) (recipient principal))
    (let
        (
            (current-owner (unwrap! (map-get? panel-owners panel-id) err-panel-not-found))
        )
        (asserts! (is-eq tx-sender current-owner) err-not-panel-owner)
        (map-set panel-owners panel-id recipient)
        (ok true)
    )
)

;; Create a comic by assembling panels
(define-public (create-comic (title (string-ascii 100)) (panel-ids (list 20 uint)))
    (let
        (
            (comic-id (+ (var-get last-comic-id) u1))
            (panel-count (len panel-ids))
        )
        ;; Validate panel count (1-20 panels)
        (asserts! (and (> panel-count u0) (<= panel-count u20)) err-invalid-panel-count)
        ;; Store comic
        (map-set comics comic-id
            {
                creator: tx-sender,
                title: title,
                panel-ids: panel-ids,
                created-at: block-height,
                upvotes: u0
            }
        )
        ;; Update last comic id
        (var-set last-comic-id comic-id)
        (ok comic-id)
    )
)

;; Upvote a comic
(define-public (upvote-comic (comic-id uint))
    (let
        (
            (comic (unwrap! (map-get? comics comic-id) err-comic-not-found))
            (already-voted (has-voted comic-id tx-sender))
        )
        ;; Check if user hasn't voted yet
        (asserts! (not already-voted) err-already-voted)
        ;; Record vote
        (map-set comic-votes { comic-id: comic-id, voter: tx-sender } true)
        ;; Increment upvote count
        (map-set comics comic-id
            (merge comic { upvotes: (+ (get upvotes comic) u1) })
        )
        (ok true)
    )
)

;; Remove upvote from a comic
(define-public (remove-upvote (comic-id uint))
    (let
        (
            (comic (unwrap! (map-get? comics comic-id) err-comic-not-found))
            (already-voted (has-voted comic-id tx-sender))
        )
        ;; Check if user has voted
        (asserts! already-voted err-panel-not-found)
        ;; Remove vote
        (map-delete comic-votes { comic-id: comic-id, voter: tx-sender })
        ;; Decrement upvote count
        (map-set comics comic-id
            (merge comic { upvotes: (- (get upvotes comic) u1) })
        )
        (ok true)
    )
)
