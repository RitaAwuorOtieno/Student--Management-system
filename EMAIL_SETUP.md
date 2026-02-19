# Email Verification Setup Guide

## Overview
Your Student Management System now has a complete email verification system using Gmail SMTP via your backend server.

## Step-by-Step Setup

### 1. Set Up Gmail App Password

Since Gmail doesn't allow using your regular password for SMTP connections (for security), you need to create an **App Password**:

#### A. Enable 2-Step Verification (if not already enabled)
1. Go to [myaccount.google.com](https://myaccount.google.com)
2. Click **"Security"** in the left sidebar
3. Find **"How you sign in to Google"** section
4. Click **"2-Step Verification"**
5. Follow the steps to enable it

#### B. Create an App Password
1. Go back to [myaccount.google.com/security](https://myaccount.google.com/security)
2. Click **"App passwords"** (appears only if 2-Step Verification is enabled)
3. Select:
   - **App**: Mail
   - **Device**: Windows Computer (or your OS)
4. Google will generate a 16-character password
5. **Copy this password** (you'll use it in the next step)

### 2. Configure Your Backend

#### A. Copy the .env File
```bash
cd mpesa-backend
cp .env.example .env
```

#### B. Edit `.env` file and add your Gmail credentials
```env
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-16-char-app-password
```

**Example:**
```env
EMAIL_USER=john.doe@gmail.com
EMAIL_PASSWORD=abcd efgh ijkl mnop
```

### 3. Install Backend Dependencies

```bash
cd mpesa-backend
npm install
```

This will install the required packages:
- `nodemailer` - For sending emails
- `firebase-admin` - For Firebase integration
- Other existing dependencies

### 4. Start Your Backend Server

```bash
npm start
```

You should see:
```
Server running on port 3000
✓ Email service ready
```

### 5. Update Your Flutter App

The app is already configured to use the backend email service. When users register:

1. ✅ User enters email and registers
2. ✅ Account created in Firebase
3. ✅ Backend sends real verification email from Gmail
4. ✅ User sees: "A verification email has been sent to your-email@gmail.com"
5. ✅ Email arrives in user's inbox
6. ✅ User clicks link to verify
7. ✅ Account fully activated

## How It Works

### Email Flow:
```
Flutter App
    ↓
Firebase Auth (creates user)
    ↓
Flutter calls Backend API
    ↓
Backend (email_service.js) sends email via Gmail SMTP
    ↓
Gmail server sends email to user
    ↓
User receives real email with verification link
```

### API Endpoints Available:

#### 1. Send Verification Email
```
POST /api/email/send-verification
Content-Type: application/json

{
  "email": "user@example.com",
  "verificationLink": "https://...",
  "fullName": "John Doe"
}
```

#### 2. Send Password Reset Email
```
POST /api/email/send-password-reset
Content-Type: application/json

{
  "email": "user@example.com",
  "resetLink": "https://...",
  "fullName": "John Doe"
}
```

#### 3. Send Welcome Email
```
POST /api/email/send-welcome
Content-Type: application/json

{
  "email": "user@example.com",
  "fullName": "John Doe",
  "role": "student"
}
```

## Troubleshooting

### Issue: "Email service not ready" error
**Solution:**
- Check your `.env` file has correct credentials
- Verify you created an App Password (not regular Gmail password)
- Make sure 2-Step Verification is enabled

### Issue: "Invalid login" error
**Solution:**
- Copy the entire 16-character App Password including spaces
- Make sure there are no extra spaces in `.env`
- Recreate the App Password in Google Account

### Issue: Emails not arriving
**Solution:**
- Check spam/promotions folder
- Verify email address is correct in registration form
- Check backend console for error messages
- Make sure backend is running on port 3000

### Issue: "Connection refused" error in Flutter app
**Solution:**
- For local development: Update `_backendUrl` in `email_service.dart` to your machine's IP
- For production: Use your deployed backend URL
- Make sure backend server is running

## For Production/Deployment

### Option 1: Use Your Own Email Domain (Recommended)
```env
EMAIL_SERVICE=gmail  # or another SMTP service
EMAIL_USER=noreply@yourdomain.com
EMAIL_PASSWORD=your-app-password
```

### Option 2: Update Backend URL
In `lib/services/email_service.dart`, change:
```dart
static const String _backendUrl = 'https://api.yourdomain.com';
```

### Option 3: Environment Variables
Instead of hardcoding, use Flutter environment variables or Firebase Remote Config

## Security Notes

⚠️ **Never commit `.env` file to git!**

The `.gitignore` file should include:
```
*.env
.env
.env.local
mpesa-backend/.env
```

✅ **Use GitHub Secrets** for CI/CD:
When deploying, use your hosting platform's secrets management (AWS Secrets Manager, GitHub Actions Secrets, etc.)

## Email Customization

Edit `mpesa-backend/email-service.js` to customize:
- Email subject lines
- HTML template and styling
- Email footer
- Company name/branding

## Files Modified/Created

### New Files:
- `mpesa-backend/email-service.js` - Email sending service
- `mpesa-backend/.env.example` - Configuration template

### Modified Files:
- `mpesa-backend/package.json` - Added nodemailer dependency
- `mpesa-backend/index.js` - Added email API endpoints
- `lib/services/email_service.dart` - Updated to use backend

## Next Steps

1. ✅ Set up Gmail App Password
2. ✅ Create `.env` file with credentials
3. ✅ Run `npm install` in backend
4. ✅ Start backend with `npm start`
5. ✅ Test registration and email sending
6. ✅ Customize email templates as needed

## Support

If you encounter issues:
1. Check the backend console for errors
2. Verify your Gmail credentials
3. Make sure 2-Step Verification is enabled
4. Check backend URL in Flutter is correct
5. Review `.env` file for typos
