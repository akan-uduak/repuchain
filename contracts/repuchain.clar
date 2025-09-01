;; REPUCHAIN PROTOCOL - Bitcoin-Native Reputation Infrastructure
;;
;; A comprehensive reputation management system built on Stacks that brings 
;; verifiable trust scoring to the Bitcoin ecosystem. RepuChain leverages Bitcoin's
;; immutable security model to create a decentralized reputation layer for DeFi,
;; Lightning Network operations, and cross-chain Bitcoin applications.
;;
;; Core Features:
;; - Bitcoin-anchored reputation scores with temporal decay mechanisms
;; - Cross-platform verification for Lightning, DeFi, and NFT ecosystems  
;; - Immutable audit trails secured by Bitcoin's proof-of-work consensus
;; - Dynamic trust actions configurable for ecosystem evolution
;; - Advanced analytics and batch verification capabilities

;; ERROR HANDLING FRAMEWORK

(define-constant ERR_ACCESS_DENIED (err u100))
(define-constant ERR_INVALID_INPUT (err u101))
(define-constant ERR_ACCOUNT_EXISTS (err u102))
(define-constant ERR_ACCOUNT_NOT_FOUND (err u103))
(define-constant ERR_REPUTATION_TOO_LOW (err u104))
(define-constant ERR_REPUTATION_MAXED (err u105))
(define-constant ERR_ACTION_DUPLICATE (err u106))
(define-constant ERR_ACTION_MISSING (err u107))
(define-constant ERR_ADMIN_REQUIRED (err u108))
(define-constant ERR_SYSTEM_INACTIVE (err u109))

;; PROTOCOL CONFIGURATION CONSTANTS

(define-constant REPUTATION_CEILING u1000) ;; Maximum reputation score (100%)
(define-constant REPUTATION_FLOOR u0) ;; Minimum reputation score
(define-constant INITIAL_REPUTATION u75) ;; New user starting score (7.5%)
(define-constant STANDARD_DECAY_RATE u8) ;; Default decay rate (8% per period)
(define-constant MIN_IDENTIFIER_LENGTH u6) ;; Minimum DID string length
(define-constant PROTOCOL_VERSION u210) ;; Current protocol version

;; GLOBAL PROTOCOL STATE

(define-data-var protocol-admin principal tx-sender)
(define-data-var system-enabled bool true)
(define-data-var decay-percentage uint STANDARD_DECAY_RATE)
(define-data-var decay-interval-blocks uint u8640) ;; ~6 days in blocks
(define-data-var new-user-reputation uint INITIAL_REPUTATION)
(define-data-var registered-accounts uint u0)

;; CORE DATA STRUCTURES

;; Primary reputation registry mapping Bitcoin addresses to trust profiles
(define-map reputation-profiles
  { account: principal }
  {
    identifier: (string-ascii 64), ;; Unique decentralized identifier
    score: uint, ;; Current reputation (0-1000)
    established: uint, ;; Creation block height
    last-activity: uint, ;; Most recent update block
    last-decay-applied: uint, ;; Last decay calculation block
    verified-actions: uint, ;; Total completed trust actions
    status: bool, ;; Account active/inactive
  }
)

;; Configurable reputation actions with scoring multipliers
(define-map reputation-actions
  { action-name: (string-ascii 48) }
  {
    score-multiplier: uint, ;; Points awarded for action
    description: (string-ascii 120), ;; Human-readable explanation
    enabled: bool, ;; Action availability
  }
)

;; Immutable reputation change history for transparency and auditing
(define-map reputation-ledger
  {
    account: principal,
    entry-id: uint,
  }
  {
    action-performed: (string-ascii 48),
    score-before: uint,
    score-after: uint,
    bitcoin-block: uint, ;; Bitcoin block for immutability
    stacks-block: uint, ;; Stacks block for ordering
  }
)

;; Cross-platform verification registry for external integrations
(define-map platform-credentials
  {
    platform: (string-ascii 32),
    account: principal,
  }
  {
    required-threshold: uint, ;; Minimum reputation needed
    issued-at: uint, ;; Verification block height
    valid-until: uint, ;; Expiration block height
    active: bool, ;; Credential validity
  }
)

;; ADMINISTRATIVE FUNCTIONS

;; Transfer protocol ownership to a new Bitcoin address
(define-public (transfer-admin-rights (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-admin)) ERR_ADMIN_REQUIRED)
    (asserts! (not (is-eq new-admin (var-get protocol-admin))) ERR_INVALID_INPUT)

    (var-set protocol-admin new-admin)
    (print {
      event: "admin-transferred",
      previous: tx-sender,
      new: new-admin,
      block: stacks-block-height,
    })
    (ok true)
  )
)

;; Emergency protocol shutdown for critical security events
(define-public (toggle-system-status (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-admin)) ERR_ADMIN_REQUIRED)

    (var-set system-enabled enabled)
    (print {
      event: "system-status-changed",
      enabled: enabled,
      admin: tx-sender,
      block: stacks-block-height,
    })
    (ok true)
  )
)

;; Configure reputation decay mechanics for long-term sustainability
(define-public (update-decay-parameters
    (rate uint)
    (interval uint)
  )
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-admin)) ERR_ADMIN_REQUIRED)
    (asserts! (and (<= rate u50) (> rate u0)) ERR_INVALID_INPUT)
    (asserts! (> interval u1000) ERR_INVALID_INPUT)

    (var-set decay-percentage rate)
    (var-set decay-interval-blocks interval)
    (print {
      event: "decay-updated",
      rate: rate,
      interval: interval,
      effective: stacks-block-height,
    })
    (ok true)
  )
)

;; REPUTATION ACTION MANAGEMENT

;; Create new reputation-earning action for the Bitcoin ecosystem
(define-public (create-reputation-action
    (action-name (string-ascii 48))
    (multiplier uint)
    (description (string-ascii 120))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-admin)) ERR_ADMIN_REQUIRED)
    (asserts! (> (len action-name) u0) ERR_INVALID_INPUT)
    (asserts! (> (len description) u0) ERR_INVALID_INPUT)
    (asserts!
      (is-none (map-get? reputation-actions { action-name: action-name }))
      ERR_ACTION_DUPLICATE
    )
    (asserts! (and (> multiplier u0) (<= multiplier u200)) ERR_INVALID_INPUT)

    (map-set reputation-actions { action-name: action-name } {
      score-multiplier: multiplier,
      description: description,
      enabled: true,
    })
    (print {
      event: "action-created",
      name: action-name,
      multiplier: multiplier,
    })
    (ok true)
  )
)

;; Update existing reputation action parameters
(define-public (update-reputation-action
    (action-name (string-ascii 48))
    (multiplier uint)
    (description (string-ascii 120))
    (enabled bool)
  )
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-admin)) ERR_ADMIN_REQUIRED)
    (asserts! (> (len action-name) u0) ERR_INVALID_INPUT)
    (asserts! (> (len description) u0) ERR_INVALID_INPUT)
    (asserts!
      (is-some (map-get? reputation-actions { action-name: action-name }))
      ERR_ACTION_MISSING
    )
    (asserts! (and (> multiplier u0) (<= multiplier u200)) ERR_INVALID_INPUT)

    (map-set reputation-actions { action-name: action-name } {
      score-multiplier: multiplier,
      description: description,
      enabled: enabled,
    })
    (print {
      event: "action-updated",
      name: action-name,
      enabled: enabled,
    })
    (ok true)
  )
)

;; INTERNAL UTILITY FUNCTIONS

;; Validate account ownership and existence
(define-private (validate-account-access (account principal))
  (and
    (is-some (map-get? reputation-profiles { account: account }))
    (is-eq account tx-sender)
  )
)

;; Record reputation changes in the immutable audit ledger
(define-private (log-reputation-change
    (account principal)
    (action-name (string-ascii 48))
    (old-score uint)
    (new-score uint)
  )
  (let ((entry-id stacks-block-height))
    (map-set reputation-ledger {
      account: account,
      entry-id: entry-id,
    } {
      action-performed: action-name,
      score-before: old-score,
      score-after: new-score,
      bitcoin-block: burn-block-height,
      stacks-block: entry-id,
    })
    (print {
      event: "reputation-logged",
      account: account,
      action: action-name,
      delta: (if (>= new-score old-score)
        (- new-score old-score)
        (- old-score new-score)
      ),
      total: new-score,
    })
  )
)

;; Get action multiplier with safe fallback
(define-private (get-action-multiplier (action-name (string-ascii 48)))
  (default-to u0
    (get score-multiplier
      (map-get? reputation-actions { action-name: action-name })
    ))
)

;; Check if reputation action is currently enabled
(define-private (is-action-enabled (action-name (string-ascii 48)))
  (default-to false
    (get enabled (map-get? reputation-actions { action-name: action-name }))
  )
)

;; Determine if decay should be applied based on time elapsed
(define-private (needs-decay-application (last-decay uint))
  (>= (- stacks-block-height last-decay) (var-get decay-interval-blocks))
)

;; REPUTATION PROFILE MANAGEMENT

;; Create new Bitcoin-secured reputation profile
(define-public (create-reputation-profile (identifier (string-ascii 64)))
  (let (
      (user tx-sender)
      (current-block stacks-block-height)
      (starting-score (var-get new-user-reputation))
    )
    (begin
      (asserts! (var-get system-enabled) ERR_SYSTEM_INACTIVE)
      (asserts! (is-none (map-get? reputation-profiles { account: user }))
        ERR_ACCOUNT_EXISTS
      )
      (asserts! (>= (len identifier) MIN_IDENTIFIER_LENGTH) ERR_INVALID_INPUT)

      (map-set reputation-profiles { account: user } {
        identifier: identifier,
        score: starting-score,
        established: current-block,
        last-activity: current-block,
        last-decay-applied: current-block,
        verified-actions: u0,
        status: true,
      })

      (var-set registered-accounts (+ (var-get registered-accounts) u1))

      (print {
        event: "profile-created",
        account: user,
        identifier: identifier,
        initial-score: starting-score,
        bitcoin-anchor: burn-block-height,
      })

      (ok identifier)
    )
  )
)

;; Update profile status (activate/deactivate)
(define-public (update-profile-status (active bool))
  (let (
      (user tx-sender)
      (current-profile (unwrap! (map-get? reputation-profiles { account: user })
        ERR_ACCOUNT_NOT_FOUND
      ))
    )
    (begin
      (map-set reputation-profiles { account: user }
        (merge current-profile {
          status: active,
          last-activity: stacks-block-height,
        })
      )

      (print {
        event: "profile-status-updated",
        account: user,
        active: active,
      })

      (ok true)
    )
  )
)

;; REPUTATION SCORING ENGINE

;; Execute reputation-earning action and update score
(define-public (perform-reputation-action (action-name (string-ascii 48)))
  (let (
      (user tx-sender)
      (profile (unwrap! (map-get? reputation-profiles { account: user })
        ERR_ACCOUNT_NOT_FOUND
      ))
      (current-score (get score profile))
      (multiplier (get-action-multiplier action-name))
      (action-count (+ (get verified-actions profile) u1))
    )
    (begin
      (asserts! (var-get system-enabled) ERR_SYSTEM_INACTIVE)
      (asserts! (get status profile) ERR_ACCESS_DENIED)
      (asserts!
        (is-some (map-get? reputation-actions { action-name: action-name }))
        ERR_INVALID_INPUT
      )
      (asserts! (is-action-enabled action-name) ERR_INVALID_INPUT)

      ;; Apply decay if needed before calculating new score
      (if (needs-decay-application (get last-decay-applied profile))
        (apply-reputation-decay-internal user)
        true
      )

      ;; Calculate new reputation score
      (let (
          (updated-profile (unwrap! (map-get? reputation-profiles { account: user })
            ERR_ACCOUNT_NOT_FOUND
          ))
          (decayed-score (get score updated-profile))
          (new-score (if (< (+ decayed-score multiplier) REPUTATION_CEILING)
            (+ decayed-score multiplier)
            REPUTATION_CEILING
          ))
        )
        (begin
          (map-set reputation-profiles { account: user }
            (merge updated-profile {
              score: new-score,
              last-activity: stacks-block-height,
              verified-actions: action-count,
            })
          )

          (log-reputation-change user action-name decayed-score new-score)

          (ok new-score)
        )
      )
    )
  )
)

;; Internal decay application function
(define-private (apply-reputation-decay-internal (account principal))
  (let (
      (profile (default-to {
        identifier: "",
        score: u0,
        established: u0,
        last-activity: u0,
        last-decay-applied: u0,
        verified-actions: u0,
        status: false,
      }
        (map-get? reputation-profiles { account: account })
      ))
      (current-score (get score profile))
      (decay-amount (/ (* current-score (var-get decay-percentage)) u100))
      (new-score (if (> current-score decay-amount)
        (- current-score decay-amount)
        REPUTATION_FLOOR
      ))
    )
    (begin
      (map-set reputation-profiles { account: account }
        (merge profile {
          score: new-score,
          last-activity: stacks-block-height,
          last-decay-applied: stacks-block-height,
        })
      )

      (log-reputation-change account "reputation-decay" current-score new-score)

      true
    )
  )
)

;; Public decay application function
(define-public (apply-reputation-decay)
  (let (
      (user tx-sender)
      (profile (unwrap! (map-get? reputation-profiles { account: user })
        ERR_ACCOUNT_NOT_FOUND
      ))
    )
    (begin
      (asserts! (var-get system-enabled) ERR_SYSTEM_INACTIVE)
      (asserts! (get status profile) ERR_ACCESS_DENIED)
      (asserts! (needs-decay-application (get last-decay-applied profile))
        ERR_INVALID_INPUT
      )

      (apply-reputation-decay-internal user)

      (let (
          (updated-profile (unwrap! (map-get? reputation-profiles { account: user })
            ERR_ACCOUNT_NOT_FOUND
          ))
          (final-score (get score updated-profile))
        )
        (ok final-score)
      )
    )
  )
)