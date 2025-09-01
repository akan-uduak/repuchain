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