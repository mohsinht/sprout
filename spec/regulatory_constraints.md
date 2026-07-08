# Regulatory Constraints

## Purpose

This document defines the product boundary Sprout must stay inside unless the company intentionally enters regulated payments or stored-value territory.

This is not legal advice. It is a product and architecture constraint based on the current Pakistan research.

## Safe Product Boundary

Sprout v0 is a read-only personal finance and budgeting product.

Allowed:

- User-entered manual transactions.
- User-permissioned email parsing.
- User-uploaded statement imports.
- Optional Android financial SMS parsing where store policy permits.
- Read-only insights, budgets, goals, reminders, score explanations, tax/market education, and suggested next steps.
- Instructions that the user performs outside Sprout, such as "Move PKR 5,000 to savings."

Not allowed in v0:

- Moving funds in-app.
- Holding stored value.
- Issuing wallet balances.
- Initiating payments.
- Switching payments.
- Merchant acceptance.
- Disbursements.
- Account opening or KYC journeys embedded as if Sprout is the regulated provider.

## Hard Boundary

If Sprout moves money, holds value, enables merchant acceptance, or initiates regulated payment flows, the product likely enters SBP EMI, PSO, PSP, branchless banking, or partner-regulated territory.

No feature may cross this boundary without:

- Legal review.
- Security review.
- Partner/regulatory operating model.
- Updated data retention and audit requirements.
- Updated incident response process.
- Updated user consent and terms.

## Safe Copy Pattern

Allowed:

- "Move PKR 5,000 to your Emergency Fund."
- "Set aside PKR 10,000 after salary."
- "Review this bill before it is due."

Not allowed unless Sprout becomes regulated or acts through a compliant partner:

- "Transfer now."
- "Pay this bill in Sprout."
- "Top up your Al Meezan account here."
- "Accept customer payments."

## Privacy Posture

Pakistan does not currently provide the same mature enacted private-sector data-protection baseline as some other markets. Treat that as a reason to raise Sprout's standard, not lower it.

Minimum posture:

- Explicit consent before reading email, SMS, or statement files.
- OAuth or user-uploaded files only; no stored bank passwords.
- No screen scraping as a core path.
- Least-privilege scopes.
- Clear disconnect and delete controls.
- Statement files discarded after parsing by default.
- Refresh tokens encrypted at rest.
- Sensitive data encrypted in transit and at rest.
- Audit logs for access, parsing, deletion, and export.
- Incident response process before handling real user financial data.

## Hosting Boundary

The research did not find a general rule forcing a non-regulated budgeting app to host all personal finance data inside Pakistan.

However, if Sprout partners with an SBP-regulated institution, that partner's cloud outsourcing, technology governance, audit, and contractual requirements may flow down to Sprout. Treat bank partnership architecture as a separate phase.

## PECA / Unauthorized Access Boundary

Sprout must not normalize credential capture, bank portal automation, or inbox access without explicit consent. PECA risk makes unauthorized access and interference a live product risk.

Acceptable access:

- Delegated OAuth.
- User-approved finance senders.
- User-uploaded files.
- User-initiated exports.

Rejected access:

- Asking for bank passwords.
- Screen scraping bank portals.
- Browser automation that logs into financial accounts.
- Parsing data sources the user did not explicitly approve.

## Acceptance

- No v0 feature moves money or holds value.
- Every money-movement recommendation is an instruction, not an in-app transfer.
- Every sensitive source has explicit consent, disconnect, and delete.
- Bank/API partnerships are documented separately before implementation.
- Legal/security review is required before any regulated boundary changes.
