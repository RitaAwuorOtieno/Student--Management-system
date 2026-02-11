# TODO: Fix Payments in Fees Page

## Step 1: Update FirestoreService for Fees and Discounts

- [x] Add fees collection reference
- [x] Add discounts collection reference
- [x] Implement CRUD methods for Fees (create, readAll, update, delete, getFees stream)
- [x] Implement CRUD methods for Discount (create, readAll, update, delete, getDiscounts stream)

## Step 2: Modify FeesPage to Use Firestore

- [x] Replace hardcoded \_fees with Firestore stream
- [x] Replace hardcoded \_discounts with Firestore stream
- [x] Update UI to handle async data loading
- [x] Add loading states and error handling

## Step 3: Enhance Payment Dialog

- [x] Update \_showPaymentDialog to allow selecting payment method
- [x] Add discount selection and calculation
- [x] Implement payment confirmation logic to update fee status and save to Firestore

## Step 4: Implement Discount Management

- [x] Complete \_showAddDiscountDialog with form fields
- [x] Implement \_showEditDiscountDialog
- [x] Implement \_confirmDeleteDiscount with actual deletion

## Step 5: Update Add Fees Dialog

- [x] Make \_showAddFeesDialog save to Firestore instead of just closing

## Step 6: Add Fees Management (Edit/Delete)

- [x] Add delete button to fee items
- [x] Implement \_confirmDeleteFee method
- [x] Add edit button to fee items
- [x] Implement \_showEditFeeDialog method

## Step 7: Testing and Verification

- [x] Code compiles successfully (flutter analyze)
- [ ] Test adding fees
- [ ] Test making payments with and without discounts
- [ ] Test adding, editing, deleting discounts
- [ ] Test deleting fees
- [ ] Test editing fees
- [ ] Ensure UI updates reflect Firestore changes

---

## Summary

All core functionality has been implemented:

- ✅ Fees CRUD (Create, Read, Update, Delete)
- ✅ Discounts CRUD (Create, Read, Update, Delete)
- ✅ Payment processing with M-Pesa integration
- ✅ Discount application on payments
- ✅ Firestore real-time updates

The app is ready for testing in a real environment.
