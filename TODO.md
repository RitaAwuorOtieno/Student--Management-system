# TODO: Fix Payments in Fees Page

## Step 1: Update FirestoreService for Fees and Discounts

- [x] Add fees collection reference
- [x] Add discounts collection reference
- [x] Implement CRUD methods for Fees (create, readAll, update, delete, getFees stream)
- [x] Implement CRUD methods for Discount (create, readAll, update, delete, getDiscounts stream)

## Step 2: Modify FeesPage to Use Firestore

- [ ] Replace hardcoded \_fees with Firestore stream
- [ ] Replace hardcoded \_discounts with Firestore stream
- [ ] Update UI to handle async data loading
- [ ] Add loading states and error handling

## Step 3: Enhance Payment Dialog

- [ ] Update \_showPaymentDialog to allow selecting payment method
- [ ] Add discount selection and calculation
- [ ] Implement payment confirmation logic to update fee status and save to Firestore

## Step 4: Implement Discount Management

- [ ] Complete \_showAddDiscountDialog with form fields
- [ ] Implement \_showEditDiscountDialog
- [ ] Implement \_confirmDeleteDiscount with actual deletion

## Step 5: Update Add Fees Dialog

- [ ] Make \_showAddFeesDialog save to Firestore instead of just closing

## Step 6: Testing and Verification

- [ ] Test adding fees
- [ ] Test making payments with and without discounts
- [ ] Test adding, editing, deleting discounts
- [ ] Ensure UI updates reflect Firestore changes
