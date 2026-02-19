# Quick Start: Email Verification

## TL;DR - 5 Minute Setup

### 1. Get Gmail App Password
- Go to [myaccount.google.com/security](https://myaccount.google.com/security)
- Enable 2-Step Verification (if needed)
- Click "App passwords" → Select Mail + Windows Computer
- Copy the 16-character password

### 2. Create `.env` File
```bash
cd mpesa-backend
```

Create file: `mpesa-backend/.env`
```
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=xxx xxxx xxxx xxxx
```

### 3. Install & Run Backend
```bash
npm install
npm start
```

You should see: `✓ Email service ready`

### 4. Test It!
- Register in your Flutter app with a real email
- Check your inbox (check spam too!)
- Click the verification link

## Default Backend URL

The app is configured to use: `http://localhost:3000`

**For production**, update `lib/services/email_service.dart`:
```dart
static const String _backendUrl = 'https://your-backend-url.com';
```

## Email Templates

Edit `mpesa-backend/email-service.js` to customize:
- Verification email HTML/styling
- Password reset email
- Welcome email

## What Gets Sent

✅ **Verification Email** - Link to verify email address
✅ **Password Reset Email** - Link to reset password  
✅ **Welcome Email** - After email verification

All emails use professional HTML templates with your branding.

## Files Changed
- ✅ `mpesa-backend/package.json` - Added nodemailer
- ✅ `mpesa-backend/index.js` - Added 3 email endpoints
- ✅ `mpesa-backend/email-service.js` - New file with email logic
- ✅ `mpesa-backend/.env.example` - Configuration template
- ✅ `lib/services/email_service.dart` - Updated to call backend
