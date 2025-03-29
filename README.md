# STX-MetaCollateral - Dynamic NFT-Backed Loan Smart Contract

## Overview
This smart contract facilitates loans backed by dynamic NFTs. The NFTs change their attributes based on the repayment status of the associated loan. This contract allows users to:
- Mint NFTs
- List NFTs as collateral for loans
- Offer and accept loans
- Track loan repayment status
- Update NFT attributes dynamically based on loan performance
- Handle loan closures, returning NFTs to borrowers upon full repayment or transferring them to lenders in case of default

## Features
- **Dynamic NFTs**: The NFTs have attributes such as rarity, power-level, and condition, which change based on repayment behavior.
- **Loan Listings**: NFT owners can list their assets as collateral for loans with customizable loan terms.
- **Lending Mechanism**: Lenders can offer loans to NFT owners based on predefined conditions.
- **Automated Loan Management**: The contract enforces repayment terms, updates NFT attributes, and manages loan closure.

## Constants
| Constant | Description |
|----------|-------------|
| CONTRACT_OWNER | Owner of the contract |
| ERR_NOT_AUTHORIZED | Error for unauthorized actions |
| ERR_NFT_NOT_FOUND | Error when NFT is not found |
| ERR_ALREADY_LISTED | Error when NFT is already listed for a loan |
| ERR_NOT_LISTED | Error when trying to interact with an unlisted NFT |
| ERR_INSUFFICIENT_VALUE | Error for insufficient loan offer |
| ERR_LOAN_NOT_FOUND | Error when loan is not found |
| ERR_LOAN_DEFAULTED | Error when loan is defaulted |
| ERR_LOAN_NOT_DUE | Error when loan is not yet due |
| ERR_LOAN_CLOSED | Error when loan is already closed |

## Data Structures
### NFT Attributes
```clojure
(define-map token-attributes
    { token-id: uint }
    {
        rarity: uint,
        power-level: uint,
        condition: uint,
        last-updated: uint
    }
)
```
Stores attributes of each NFT, which change dynamically based on loan status.

### Loan Details
```clojure
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
```
Tracks loan-specific details.

## Read-Only Functions
| Function | Description |
|----------|-------------|
| `get-token-attributes(token-id uint)` | Retrieves NFT attributes |
| `get-loan-details(loan-id uint)` | Retrieves loan details |
| `get-token-loan(token-id uint)` | Retrieves loan associated with a token |
| `get-loan-listing(token-id uint)` | Retrieves NFT listing details |

## Public Functions
### Mint NFT
```clojure
(define-public (mint-nft (recipient principal))
```
- Mints a new NFT with default attributes.
- Assigns NFT to the specified recipient.
- Increments the token ID.

### List NFT for Loan
```clojure
(define-public (list-nft-for-loan (token-id uint) (requested-amount uint) (min-duration uint) (max-interest uint))
```
- Lists an NFT as collateral for a loan.
- Ensures the sender owns the NFT and it's not already listed.

### Offer Loan
```clojure
(define-public (offer-loan (token-id uint) (amount uint) (interest-rate uint) (duration uint))
```
- Allows a lender to offer a loan to an NFT owner.
- Transfers STX to the borrower.
- Locks NFT within the contract until repayment is completed.

### Close Loan
```clojure
(define-public (close-loan (loan-id uint))
```
- Completes a loan by checking if the full repayment has been made.
- If repaid, returns the NFT to the borrower.
- If defaulted, transfers NFT to the lender.

## Private Functions
| Function | Description |
|----------|-------------|
| `calculate-payment(loan tuple)` | Computes repayment amount per block |
| `update-nft-attributes(loan-id uint, payment uint, payment-due uint)` | Updates NFT attributes based on loan repayment |
| `min-uint(a uint, b uint)` | Returns the smaller of two uint values |
| `max-uint(a uint, b uint)` | Returns the larger of two uint values |

## Loan Lifecycle
1. **NFT Minting**: Users mint NFTs with default attributes.
2. **Listing for Loan**: NFT owners list their NFTs as collateral.
3. **Loan Offering**: Lenders make loan offers, meeting the NFT owner's terms.
4. **Loan Acceptance**: The contract transfers STX to the borrower and holds the NFT.
5. **Repayment**: Borrowers make payments over time.
6. **Dynamic NFT Updates**: NFT attributes improve or degrade based on repayments.
7. **Loan Closure**:
   - If fully repaid, the NFT is returned to the borrower.
   - If defaulted, the lender takes ownership of the NFT.

## Security Considerations
- **Ownership Verification**: Ensures only NFT owners can list their NFTs.
- **Loan Agreement Enforcement**: Prevents unauthorized changes to loan terms.
- **Safe Transfers**: STX and NFTs are transferred securely to prevent loss.

## Future Enhancements
- **Auction System**: Enable competitive bidding for loan listings.
- **Multi-Collateral Loans**: Allow multiple NFTs to back a single loan.
- **Integration with DeFi Platforms**: Expand liquidity options for lenders.

## License
This project is open-source and can be used and modified freely under the MIT License.

---
