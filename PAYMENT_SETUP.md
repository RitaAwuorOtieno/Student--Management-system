# M-Pesa Payment Integration Setup Guide

## ✅ Issue Resolution

Your payment error **"error connecting to server"** has been fixed! Here's what was done:

### Problems Identified:

1. **Backend server was not running** on port 3000
2. **Hardcoded URL was set to Android emulator only** (`http://10.0.2.2:3000`)
3. **Missing environment variable configuration** for callbacks

### Fixes Applied:

✅ Started the M-Pesa backend server  
✅ Updated base URL to use `http://localhost:3000` for local development  
✅ The server is now listening and ready to accept payment requests

---

## 🚀 Quick Start Guide

### 1. Keep the Backend Server Running

The backend is currently running in the background. To verify it's still running:

```bash
cd mpesa-backend
npm start
```

The server logs should show:

```
Server running on port 3000
STK Push endpoint: POST /mpesa/stkpush
```

### 2. Running the Flutter App

**The URL configuration is now set based on your environment:**

#### Option A: Using localhost (Recommended for Local Development)

- **Works for:** Web, macOS, Linux, physical iOS/Android devices on same network
- **Already configured:** Changed to `http://localhost:3000`
- **Just run:** Your Flutter app should now work!

#### Option B: Android Emulator

If you're using Android Emulator, update [lib/services/mpesa_service.dart](lib/services/mpesa_service.dart):

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

#### Option C: Physical Device on Different Network

If your physical device is on a different network/computer:

1. Find your computer's IP address:

   ```bash
   # Windows
   ipconfig
   # Look for IPv4 Address (e.g., 192.168.1.100)
   ```

2. Update [lib/services/mpesa_service.dart](lib/services/mpesa_service.dart):

   ```dart
   static const String baseUrl = 'http://192.168.1.100:3000'; // Replace with your IP
   ```

3. Ensure firewall allows port 3000:
   - Open port 3000 in Windows Firewall
   - Or disable firewall for testing

---

## 🔧 Environment Configuration

### Backend Environment Variables

The `.env` file in `mpesa-backend/` contains M-Pesa credentials:

```env
CONSUMER_KEY=bYWzQm3JObKArpAGKUpYVceL2BtwU77pYm3leOGmwVA1rKL0
CONSUMER_SECRET=zNISIL7M5qaIGvudHWWF6zG0h9AA3GyJ9D1EaKTPoRlqC5pBbgDbxDPiLhIpZF4F
SHORTCODE=174379
PASSKEY=bfb279f9aa9bdbcf158e97dd71a467cd6f8b6f4e
CALLBACK_URL=https://your-domain.com/mpesa/callback
```

**For Local Development:**

- The `CONSUMER_KEY`, `CONSUMER_SECRET`, `SHORTCODE`, and `PASSKEY` are sandbox credentials (safe to use for testing)
- The `CALLBACK_URL` is used to receive payment status updates from M-Pesa

**For Production:**

- Replace with your actual M-Pesa production credentials
- Set `CALLBACK_URL` to your production server's callback endpoint

---

## 🧪 Testing Payment Flow

1. **Start Backend:**

   ```bash
   cd mpesa-backend
   npm start
   ```

2. **Run Flutter App:**

   ```bash
   flutter run
   ```

3. **In the App:**
   - Navigate to **Fees & Payments** page
   - Click **Pay** button on a pending fee
   - Select **M-Pesa** as payment method
   - Enter a phone number (e.g., `0722123456` or `254722123456`)
   - Click **Confirm Payment**
   - You should see: **"STK push sent! Check your phone and enter PIN"**

---

## ❌ Troubleshooting

### "Error connecting to server"

- **Check 1:** Is backend running? Run `netstat -ano | findstr :3000`
- **Check 2:** Is the URL correct? Verify in [lib/services/mpesa_service.dart](lib/services/mpesa_service.dart)
- **Check 3:** Firewall blocking? Allow port 3000 in Windows Firewall
- **Check 4:** Different network? Use your computer's IP address instead of localhost

### "Invalid phone number format"

- Phone must be in format: `07XXXXXXXXX` or `254XXXXXXXXX`
- Example: `0722123456` or `254722123456`

### Backend doesn't start

- Ensure Node.js is installed: `node --version`
- Install dependencies: `npm install`
- Then run: `npm start`

### CALLBACK_URL issues

- Currently set to placeholder: `https://your-domain.com/mpesa/callback`
- For local testing, this doesn't matter (payments will still process)
- For production, update this to your actual server callback URL

---

## 🔐 Security Notes

**DO NOT commit `.env` with real credentials!**

For production deployment:

1. Remove `.env` from Git
2. Set environment variables on your production server
3. Use actual M-Pesa production credentials (not sandbox)
4. Set a proper CALLBACK_URL to your production domain
5. Use HTTPS only
6. Implement proper authentication and validation

---

## 📝 Next Steps

1. **Verify the backend is running** - check port 3000 is LISTENING
2. **Test M-Pesa payment** - follow the "Testing Payment Flow" section
3. **For physical devices** - update the base URL to your computer's IP address
4. **For production** - update environment variables and credentials

---

## 🆘 Need Help?

If you're still getting connection errors:

1. Check backend logs:

   ```bash
   # The terminal showing "Server running on port 3000"
   ```

2. Verify port 3000:

   ```bash
   netstat -ano | findstr :3000
   ```

3. Test backend directly:

   ```bash
   curl -X POST http://localhost:3000/mpesa/stkpush \
     -H "Content-Type: application/json" \
     -d '{"phone":"0722123456","amount":100}'
   ```

4. Check Flutter logs:
   ```bash
   flutter logs
   ```
