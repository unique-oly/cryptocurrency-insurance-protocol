;; title: cryptocurrency-insurance-protocol
;; Expanded Constants and Error Codes
(define-constant CONTRACT_OWNER tx-sender)
(define-constant CONTRACT_VERSION u2)

;; Expanded Error Codes
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_INSUFFICIENT_FUNDS (err u2))
(define-constant ERR_INVALID_CLAIM (err u3))
(define-constant ERR_POLICY_EXISTS (err u4))
(define-constant ERR_POLICY_NOT_FOUND (err u5))
(define-constant ERR_CLAIM_PERIOD_EXPIRED (err u6))
(define-constant ERR_INSUFFICIENT_COVERAGE (err u7))
(define-constant ERR_LIQUIDATION_FAILED (err u8))
(define-constant ERR_EMERGENCY_STOP (err u9))
(define-constant ERR_ORACLE_VALIDATION_FAILED (err u10))

;; Advanced Storage Structures
(define-map policies 
  { 
    policy-id: uint,
    holder: principal 
  }
  {
    coverage-amount: uint,
    premium: uint,
    start-block: uint,
    expiration-block: uint,
    risk-category: (string-ascii 50),
    is-active: bool,
    dynamic-parameters: (list 10 uint),
    additional-coverage-types: (list 5 (string-ascii 30))
  }
)

(define-map claims
  {
    policy-id: uint,
    claim-id: uint
  }
  {
    claim-amount: uint,
    claim-status: (string-ascii 20),
    claim-timestamp: uint,
    claim-evidence: (optional (string-ascii 255)),
    oracle-validation-data: (optional (string-ascii 255)),
    claim-complexity-score: uint
  }
)

;; Enhanced Risk Pool Management
(define-map risk-pools
  { 
    risk-category: (string-ascii 50) 
  }
  {
    total-pool-value: uint,
    risk-multiplier: uint,
    liquidity-buffer: uint,
    reinsurance-threshold: uint
  }
)

;; Advanced Governance and Voting Mechanism
(define-map claim-votes
  {
    claim-id: uint,
    voter: principal
  }
  {
    vote: bool,
    voting-power: uint,
    voting-stake: uint,
    reputation-score: uint
  }
)