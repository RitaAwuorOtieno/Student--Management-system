# TODO: Update Fees Page

## Task: Make payment dialogue in fees page to match the one in the parent dashboard and remove mock data

### Steps:
- [ ] 1. Update `_showPayFeesDialog` method to match parent dashboard pattern
  - [ ] Add phone number input field
  - [ ] Use MpesaService.initiateSTKPush() for payment
  - [ ] Show loading state during payment
  - [ ] Show appropriate success/error messages
- [ ] 2. Remove mock data from fees_page.dart
  - [ ] Replace _students with empty list
  - [ ] Replace _feeStructures with empty list
  - [ ] Replace _payments with empty list
  - [ ] Replace _discounts with empty list
  - [ ] Add empty state UI messages where needed
