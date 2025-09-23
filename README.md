# RepuChain Protocol

> Bitcoin-Native Reputation Infrastructure for the Stacks Ecosystem

[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-5546FF?style=for-the-badge&logo=stacks)](https://stacks.co/)
[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-FF6B35?style=for-the-badge)](https://clarity-lang.org/)
[![Bitcoin](https://img.shields.io/badge/Bitcoin-Secured-F7931E?style=for-the-badge&logo=bitcoin)](https://bitcoin.org/)

## Overview

RepuChain is a comprehensive reputation management system built on the Stacks blockchain that brings verifiable trust scoring to the Bitcoin ecosystem. By leveraging Bitcoin's immutable security model, RepuChain creates a decentralized reputation layer that serves DeFi protocols, Lightning Network operations, and cross-chain Bitcoin applications.

## Key Features

### 🔐 Bitcoin-Anchored Security

- **Immutable Audit Trails**: All reputation changes are anchored to Bitcoin blocks
- **Proof-of-Work Consensus**: Leverages Bitcoin's security for trust verification
- **Decentralized Architecture**: No single point of failure or control

### ⚡ Advanced Reputation Engine

- **Temporal Decay Mechanisms**: Reputation scores naturally decay over time to maintain relevance
- **Dynamic Trust Actions**: Configurable actions for ecosystem evolution
- **Score Ceiling & Floor**: Bounded reputation system (0-1000 points)
- **Batch Verification**: Efficient processing of multiple reputation events

### 🌐 Cross-Platform Integration

- **Lightning Network**: Reputation for channel management and routing
- **DeFi Protocols**: Trust scoring for Bitcoin DeFi participation
- **Smart Contracts**: Verification for contract deployment and auditing
- **Governance Systems**: Reputation-based voting and participation tracking

## Smart Contract Architecture

### Core Data Structures

#### Reputation Profiles

```clarity
{
  identifier: (string-ascii 64),     ;; Unique decentralized identifier
  score: uint,                       ;; Current reputation (0-1000)
  established: uint,                 ;; Creation block height
  last-activity: uint,               ;; Most recent update block
  last-decay-applied: uint,          ;; Last decay calculation block
  verified-actions: uint,            ;; Total completed trust actions
  status: bool                       ;; Account active/inactive
}
```

#### Reputation Actions

```clarity
{
  score-multiplier: uint,            ;; Points awarded for action
  description: (string-ascii 120),   ;; Human-readable explanation
  enabled: bool                      ;; Action availability
}
```

#### Platform Credentials

```clarity
{
  required-threshold: uint,          ;; Minimum reputation needed
  issued-at: uint,                   ;; Verification block height
  valid-until: uint,                 ;; Expiration block height
  active: bool                       ;; Credential validity
}
```

### Pre-configured Bitcoin Ecosystem Actions

| Action | Score Multiplier | Description |
|--------|------------------|-------------|
| `lightning-channel-management` | 12 | Successfully managing Lightning Network payment channels and routing |
| `bitcoin-defi-interaction` | 18 | Active participation in Bitcoin DeFi protocols on Stacks blockchain |
| `verified-contract-deployment` | 25 | Deployment and verification of Bitcoin smart contracts on Stacks |
| `ecosystem-governance-vote` | 8 | Participation in Bitcoin and Stacks ecosystem governance decisions |
| `cross-chain-bridge-usage` | 15 | Successful Bitcoin-Stacks bridge transactions and validations |
| `security-audit-contribution` | 30 | Security auditing and responsible vulnerability disclosure |

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Stacks CLI](https://github.com/hirosystems/stacks.js) (optional, for advanced interactions)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/akan-uduak/repuchain.git
   cd repuchain
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Check contract syntax**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Project Structure

```text
repuchain/
├── contracts/
│   └── repuchain.clar          # Main protocol contract
├── tests/
│   └── repuchain.test.ts       # Comprehensive test suite
├── settings/
│   ├── Devnet.toml            # Development network config
│   ├── Testnet.toml           # Testnet configuration
│   └── Mainnet.toml           # Mainnet configuration
├── Clarinet.toml              # Project configuration
├── package.json               # Node.js dependencies
├── tsconfig.json              # TypeScript configuration
└── vitest.config.js           # Test configuration
```

## Usage Examples

### Creating a Reputation Profile

```clarity
;; Create a new reputation profile with a unique identifier
(contract-call? .repuchain create-reputation-profile "bitcoin-builder-2024")
```

### Performing Reputation Actions

```clarity
;; Earn reputation by performing Lightning Network operations
(contract-call? .repuchain perform-reputation-action "lightning-channel-management")

;; Participate in Bitcoin DeFi
(contract-call? .repuchain perform-reputation-action "bitcoin-defi-interaction")
```

### Querying Reputation Data

```clarity
;; Get current reputation score
(contract-call? .repuchain get-reputation-score 'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)

;; Get complete profile information
(contract-call? .repuchain get-full-profile 'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)

;; Verify reputation threshold
(contract-call? .repuchain verify-reputation-threshold 
  'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE
  u100)
```

### Platform Integration

```clarity
;; Issue a platform credential for Lightning Network access
(contract-call? .repuchain issue-platform-credential 
  "lightning-network"
  u200    ;; Required reputation threshold
  u52560  ;; Valid for ~1 year
)
```

## Configuration Parameters

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `REPUTATION_CEILING` | 1000 | Maximum reputation score |
| `REPUTATION_FLOOR` | 0 | Minimum reputation score |
| `INITIAL_REPUTATION` | 75 | Starting score for new users (7.5%) |
| `STANDARD_DECAY_RATE` | 8 | Default decay rate (8% per period) |
| `MIN_IDENTIFIER_LENGTH` | 6 | Minimum identifier string length |
| `DECAY_INTERVAL_BLOCKS` | 8640 | Decay application interval (~6 days) |

## Administrative Functions

### Protocol Management

- `transfer-admin-rights`: Transfer protocol ownership
- `toggle-system-status`: Emergency protocol shutdown
- `update-decay-parameters`: Configure reputation decay mechanics

### Action Management

- `create-reputation-action`: Add new reputation-earning actions
- `update-reputation-action`: Modify existing action parameters

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `ERR_ACCESS_DENIED` | Unauthorized access attempt |
| 101 | `ERR_INVALID_INPUT` | Invalid input parameters |
| 102 | `ERR_ACCOUNT_EXISTS` | Account already exists |
| 103 | `ERR_ACCOUNT_NOT_FOUND` | Account not found |
| 104 | `ERR_REPUTATION_TOO_LOW` | Insufficient reputation |
| 105 | `ERR_REPUTATION_MAXED` | Reputation at maximum |
| 106 | `ERR_ACTION_DUPLICATE` | Action already exists |
| 107 | `ERR_ACTION_MISSING` | Action not found |
| 108 | `ERR_ADMIN_REQUIRED` | Admin privileges required |
| 109 | `ERR_SYSTEM_INACTIVE` | System is disabled |

## Security Considerations

### Reputation Decay

- **Temporal Relevance**: Scores decay over time to ensure current activity relevance
- **Configurable Parameters**: Decay rate and interval can be adjusted by protocol admin
- **Automatic Application**: Decay is applied automatically during reputation actions

### Access Control

- **Admin-Only Functions**: Critical protocol changes require admin privileges
- **User Ownership**: Users can only modify their own reputation profiles
- **System Disable**: Emergency shutdown capability for security incidents

### Bitcoin Anchoring

- **Block Height Tracking**: All changes are tracked against Bitcoin block heights
- **Immutable History**: Reputation ledger provides permanent audit trail
- **Cross-Chain Verification**: Enables verification across Bitcoin ecosystem

## Testing

The project includes comprehensive tests covering:

- **Profile Management**: Creation, updates, and status changes
- **Reputation Actions**: Performing actions and score calculations
- **Decay Mechanisms**: Temporal decay application and timing
- **Administrative Functions**: Access control and parameter updates
- **Platform Credentials**: Cross-platform verification systems
- **Error Handling**: All error conditions and edge cases

Run the test suite:

```bash
npm test
```

## Deployment

### Testnet Deployment

```bash
clarinet integrate
```

### Mainnet Deployment

1. Configure mainnet settings in `settings/Mainnet.toml`
2. Deploy using Clarinet or Stacks CLI
3. Initialize ecosystem actions via `initialize-bitcoin-ecosystem`

## Contributing

We welcome contributions to the RepuChain protocol! Please see our contributing guidelines:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow Clarity best practices and conventions
- Add comprehensive tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- **Documentation**: [RepuChain Docs](https://docs.repuchain.io)
- **API Reference**: [Contract API](https://api.repuchain.io)
- **Community**: [Discord](https://discord.gg/repuchain)
- **Twitter**: [@RepuChainBTC](https://twitter.com/RepuChainBTC)

## Acknowledgments

- **Stacks Foundation** for the robust Clarity smart contract platform
- **Bitcoin Community** for inspiring decentralized trust infrastructure
- **Lightning Network Developers** for pioneering Bitcoin layer-2 solutions
