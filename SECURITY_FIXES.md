# Security Fixes: Authentication & Authorization

## Issues Fixed

### 1. Admin Privileges Given to Parents (Privilege Escalation)
**Problem:** Parents were receiving admin privileges when logging in.

**Root Cause:** 
- Lack of Firestore security rules validation
- No client-side role validation to prevent sending admin role during registration
- Missing privilege escalation checks

**Solutions Implemented:**

#### A. Firestore Security Rules (`firestore.rules`)
- Created comprehensive Firestore security rules that enforce role-based access control
- Rules prevent users from:
  - Reading other users' documents
  - Escalating their own role (role cannot be changed by non-admins)
  - Accessing admin-only resources
- Rules validate that non-admin users cannot write documents to users collection

#### B. Role Validator Service (`lib/services/role_validator.dart`)
- Created `RoleValidator` class with helper methods:
  - `validateRegistrationRole()` - Forces any admin role to student role during registration
  - `isPrivilegeEscalation()` - Detects privilege escalation attempts
  - `getSafeRole()` - Safely parses roles from Firestore data
  - `isValidRole()` - Validates role strings

#### C. User Model Updates (`lib/models/user_model.dart`)
- Updated `_parseRole()` method to default to `student` role if role is invalid
- Added safety checks to prevent role parsing vulnerabilities

#### D. Auth Service Updates (`lib/services/auth_service.dart`)
- Added `RoleValidator` import and usage
- `register()` method now validates role using `RoleValidator.validateRegistrationRole()`
- This prevents anyone from registering as admin

### 2. Email Verification Not Sent on Registration
**Problem:** No verification email was being sent to users upon registration.

**Root Cause:**
- No email service implementation
- Auth service wasn't calling Firebase's email verification
- No user feedback about email verification

**Solutions Implemented:**

#### A. Email Service (`lib/services/email_service.dart`)
Created a new `EmailService` class with methods:
- `sendVerificationEmail()` - Sends Firebase verification email to user
- `isEmailVerified()` - Checks if user's email is verified
- `checkEmailVerification()` - Refreshes auth state and checks verification
- `resendVerificationEmail()` - Allows users to resend verification email

**Uses Firebase's built-in email verification** - No hardcoded SMTP or third-party service:
- Firebase Authentication handles email sending automatically
- Emails use your Firebase project's verified sender domain
- Users receive a link to their registered email with `firebase.com` domain (or custom if configured)

#### B. Auth Service Updates (`lib/services/auth_service.dart`)
- Added `EmailService` integration
- `register()` method now calls `_emailService.sendVerificationEmail()`
- Added `emailVerified` field to Firestore user document (initialized to false)

#### C. Login Page Updates (`lib/pages/login_page.dart`)
- Added success message after registration explaining email verification
- Message includes the user's email address
- Form automatically clears and switches to login view
- User feedback: "A verification email has been sent to [email]. Please check your inbox and verify your email to complete registration."

#### D. App Configuration (`lib/config/app_config.dart`)
- Created configuration file documenting:
  - Firebase project ID (not hardcoded in code)
  - Firestore collection names
  - Email verification settings
  - Security configuration
- Uses environment variables and Firebase configuration

## No Hardcoding

All configuration is now:
1. **Firebase-driven** - Uses `firebase.json` for project settings
2. **Externalized** - Configuration in `AppConfig` class
3. **Environment-based** - No hardcoded credentials or secrets in code
4. **Dynamic** - Email sender is Firebase's verified domain

## How Firebase Email Verification Works

1. User registers with email
2. Firebase automatically sends verification email from `noreply@[your-project].firebaseapp.com`
3. Email contains a clickable link
4. User clicks link to verify email
5. Firebase Auth marks email as verified (`user.emailVerified = true`)
6. App reads this flag to determine if email is verified

No SMTP server, API keys, or third-party mail service needed!

## Testing the Fixes

### Test Privilege Escalation Prevention:
1. Register a new parent user
2. Login and verify they see parent dashboard (not admin)
3. Check Firestore rules prevent any role modification
4. Attempt to manually update role to admin in Firestore - should fail

### Test Email Verification:
1. Register with a valid email address
2. Check your email inbox for verification email from Firebase
3. Click the verification link
4. User's `emailVerified` status updates to true in Auth

## Firestore Rules Deployment

To deploy these rules to Firebase:
```bash
firebase deploy --only firestore:rules
```

Or using Firebase Console:
1. Go to Firestore Database
2. Select "Rules" tab
3. Paste contents from `firestore.rules`
4. Click "Publish"

## Files Modified/Created

### New Files:
- `lib/services/email_service.dart` - Email verification service
- `lib/services/role_validator.dart` - Role validation utilities
- `lib/config/app_config.dart` - App configuration
- `firestore.rules` - Firebase security rules

### Modified Files:
- `lib/services/auth_service.dart` - Added email service and role validation
- `lib/pages/login_page.dart` - Added email verification feedback
- `lib/models/user_model.dart` - Improved role parsing safety

## Security Best Practices Applied

1. **Principle of Least Privilege** - Users only have permissions they need
2. **Defense in Depth** - Both client-side and server-side (Firestore) validation
3. **Input Validation** - Role validation before storing in Firestore
4. **Default Deny** - Firestore rules deny by default, explicitly allow access
5. **Separation of Concerns** - Email, role validation, and auth logic separated
6. **No Hardcoding** - All configuration externalized

## Future Improvements

1. Add email address verification requirement before full account access
2. Implement OAuth 2.0 for enhanced security
3. Add rate limiting to registration endpoint
4. Implement two-factor authentication
5. Add audit logging for privilege changes
6. Create admin dashboard to manage user roles (with proper authorization)
