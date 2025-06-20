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

;; Reputation and Staking Mechanism
(define-map user-reputation
  { 
    user: principal 
  }
  {
    total-reputation: uint,
    claim-history: (list 10 bool),
    staked-amount: uint,
    last-activity-block: uint
  }
)

;; Emergency Stop Mechanism
(define-data-var emergency-stop-activated bool false)

;; Oracle Integration Placeholder
(define-map external-oracles 
  { 
    oracle-id: uint 
  }
  {
    oracle-address: principal,
    last-validation-block: uint,
    validation-success-rate: uint
  }
)

;; Emergency Stop Mechanism
(define-public (activate-emergency-stop)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set emergency-stop-activated true)
    (ok true)
  )
)

;; Utility Functions with Enhanced Logic
(define-private (calculate-premium 
  (coverage-amount uint) 
  (risk-category (string-ascii 50))
  (dynamic-params (list 10 uint))
  (additional-coverage-types (list 5 (string-ascii 30)))
)
  (let (
    (risk-pool (unwrap-panic (map-get? risk-pools { risk-category: risk-category })))
    (base-premium (* coverage-amount (/ (get risk-multiplier risk-pool) u100)))
    (dynamic-adjustment (fold + dynamic-params u0))
  )
  ;; Complex premium calculation
  (+ base-premium 
     (/ (* base-premium dynamic-adjustment) u1000)
     (* (len additional-coverage-types) u10)
  )
))


;; Advanced Reputation and Stake Management
(define-private (update-user-reputation 
  (user principal) 
  (premium uint)
)
  (let (
    (current-rep (unwrap-panic (map-get? user-reputation { user: user })))
    (new-reputation (+ (get total-reputation current-rep) (/ premium u100)))
  )
  (map-set user-reputation 
    { user: user }
    {
      total-reputation: new-reputation,
      claim-history: (unwrap-panic (as-max-len? (concat (get claim-history current-rep) (list true)) u10)),
      staked-amount: (+ (get staked-amount current-rep) (/ premium u10)),
      last-activity-block: stacks-block-height
    }
  )
))

;; Oracle Validation Mechanism
(define-private (validate-with-oracle 
  (oracle-id uint) 
  (claim-amount uint)
  (claim-evidence (optional (string-ascii 255)))
)
  (let (
    (oracle (unwrap-panic (map-get? external-oracles { oracle-id: oracle-id })))
  )
  (if (> claim-amount u1000)
    true  ;; Simplified validation logic
    false
  ))
)

;; Initialize contract with advanced configurations
(define-data-var next-policy-id uint u0)
(define-data-var next-claim-id uint u0)

;; Initial risk pool and oracle configurations
(map-set risk-pools 
  { risk-category: "low-risk" }
  { 
    total-pool-value: u0, 
    risk-multiplier: u10,
    liquidity-buffer: u1000,
    reinsurance-threshold: u5000 
  }
)

(map-set external-oracles
  { oracle-id: u1 }
  {
    oracle-address: CONTRACT_OWNER,
    last-validation-block: u0,
    validation-success-rate: u100
  }
)

(define-constant ERR_INVALID_PREMIUM_PAYMENT (err u11))
(define-constant ERR_POLICY_NOT_ACTIVE (err u12))
(define-constant ERR_ALREADY_VOTED (err u13))
(define-constant ERR_INVALID_PARAMETERS (err u14))
(define-constant ERR_INSUFFICIENT_REPUTATION (err u15))

;; Contract Management and Upgradability
(define-data-var contract-admin principal tx-sender)
(define-map authorized-admins
  {
    admin: principal
  }
  {
    role: (string-ascii 20),
    permissions: (list 5 (string-ascii 30)),
    active-since: uint
  }
)

;; Premium Payment Tracking
(define-map premium-payments
  {
    policy-id: uint,
    payment-id: uint
  }
  {
    amount: uint,
    timestamp: uint,
    status: (string-ascii 20),
    next-due-date: uint
  }
)

(define-map referrals
  {
    referrer: principal,
    referee: principal
  }
  {
    timestamp: uint,
    reward-amount: uint,
    status: (string-ascii 20)
  }
)


(define-map discount-tiers
  {
    tier-level: uint
  }
  {
    reputation-threshold: uint,
    discount-percentage: uint,
    special-benefits: (list 3 (string-ascii 30))
  }
)


(define-public (deactivate-emergency-stop)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set emergency-stop-activated false)
    (ok true)
  )
)

(define-data-var next-payment-id uint u0)
(define-data-var total-premiums-collected uint u0)
(define-data-var total-claims-paid uint u0)
(define-data-var contract-liquidity uint u0)


;; Initial risk pool and oracle configurations
(map-set risk-pools
  { risk-category: "low-risk" }
  {
    total-pool-value: u0,
    risk-multiplier: u10,
    liquidity-buffer: u1000,
    reinsurance-threshold: u5000
  }
)

(map-set external-oracles
  { oracle-id: u1 }
  {
    oracle-address: CONTRACT_OWNER,
    last-validation-block: u0,
    validation-success-rate: u100
  }
)

(define-private (calculate-claim-complexity (claim-amount uint) (policy-id uint))
  (let (
    (policy (unwrap-panic (map-get? policies { policy-id: policy-id, holder: tx-sender })))
    (coverage-ratio (/ (* claim-amount u100) (get coverage-amount policy)))
  )
    (if (> coverage-ratio u80)
      u3  ;; High complexity
      (if (> coverage-ratio u40)
        u2  ;; Medium complexity
        u1) ;; Low complexity
    )
  )
)


(define-private (update-risk-pool-value (risk-category (string-ascii 50)) (amount uint))
  (let (
    (pool (unwrap-panic (map-get? risk-pools { risk-category: risk-category })))
  )
    (map-set risk-pools
      { risk-category: risk-category }
      (merge pool { total-pool-value: (+ (get total-pool-value pool) amount) })
    )
  )
)



(define-private (process-claim-payment (policy-id uint) (claim-id uint))
  (let (
    (claim (unwrap-panic (map-get? claims { policy-id: policy-id, claim-id: claim-id })))
    (policy (unwrap-panic (map-get? policies { policy-id: policy-id, holder: tx-sender })))
  )
    ;; Ensure contract has sufficient funds
    (asserts! (>= (var-get contract-liquidity) (get claim-amount claim)) ERR_INSUFFICIENT_FUNDS)
   
   
    ;; Update risk pool
    (update-risk-pool-value (get risk-category policy) (- u0 (get claim-amount claim)))
   
    (ok true)
  )
)


;; Administrative Functions
(define-public (add-admin (new-admin principal) (role (string-ascii 20)) (permissions (list 5 (string-ascii 30))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set authorized-admins
      { admin: new-admin }
      {
        role: role,
        permissions: permissions,
        active-since: stacks-block-height
      }
    )
    (ok true)
  )
)

(define-public (stake-funds (amount uint))
  (begin
    (asserts! (not (var-get emergency-stop-activated)) ERR_EMERGENCY_STOP)
    (asserts! (>= (stx-get-balance tx-sender) amount) ERR_INSUFFICIENT_FUNDS)
   
    ;; Transfer STX to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
   
    ;; Update user reputation
    (let (
      (current-rep (default-to
                    {
                      total-reputation: u0,
                      claim-history: (list false),
                      staked-amount: u0,
                      last-activity-block: u0
                    }
                    (map-get? user-reputation { user: tx-sender })))
    )
      (map-set user-reputation
        { user: tx-sender }
        {
          total-reputation: (+ (get total-reputation current-rep) (/ amount u50)),
          claim-history: (get claim-history current-rep),
          staked-amount: (+ (get staked-amount current-rep) amount),
          last-activity-block: stacks-block-height
        }
      )
    )
   
    (var-set contract-liquidity (+ (var-get contract-liquidity) amount))
    (ok true)
  )
)

(define-private (calculate-discount (user principal) (base-premium uint))
  (let (
    (user-rep (default-to
              {
                total-reputation: u0,
                claim-history: (list false),
                staked-amount: u0,
                last-activity-block: u0
              }
              (map-get? user-reputation { user: user })))
    (tier-1 (unwrap-panic (map-get? discount-tiers { tier-level: u1 })))
    (tier-2 (unwrap-panic (map-get? discount-tiers { tier-level: u2 })))
  )
    (if (>= (get total-reputation user-rep) (get reputation-threshold tier-2))
      (- base-premium (/ (* base-premium (get discount-percentage tier-2)) u100))
      (if (>= (get total-reputation user-rep) (get reputation-threshold tier-1))
        (- base-premium (/ (* base-premium (get discount-percentage tier-1)) u100))
        base-premium
      )
    )
  )
)
