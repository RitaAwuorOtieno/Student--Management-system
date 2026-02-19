require("dotenv").config();

const express = require("express");
const axios = require("axios");
const cors = require("cors");
const path = require("path");
const emailService = require("./email-service");

const app = express();

let admin;
let db;

// Initialize Firebase Admin if service account key exists
try {
  const serviceAccountPath = path.join(__dirname, "serviceAccountKey.json");
  admin = require("firebase-admin");
  const serviceAccount = require(serviceAccountPath);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  db = admin.firestore();
  console.log("✓ Firebase initialized");
} catch (error) {
  console.warn(
    "⚠️  Firebase not initialized (serviceAccountKey.json not found). Email service will work, but M-Pesa features may be limited."
  );
  admin = null;
  db = null;
}

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ---------- Helper Functions ----------

function requireFirebase(res) {
  if (!db) {
    res.status(503).json({
      success: false,
      message: "Firebase is not configured. Please set up serviceAccountKey.json",
    });
    return false;
  }
  return true;
}

function mpesaTimestamp() {
  const d = new Date();
  const pad = (n) => n.toString().padStart(2, "0");
  return (
    d.getFullYear().toString() +
    pad(d.getMonth() + 1) +
    pad(d.getDate()) +
    pad(d.getHours()) +
    pad(d.getMinutes()) +
    pad(d.getSeconds())
  );
}

function formatPhoneNumber(phone) {
  phone = phone.replace(/[\s\-\(\)]/g, "");

  if (phone.startsWith("07")) return "254" + phone.substring(1);
  if (phone.startsWith("01")) return "254" + phone.substring(1);
  if (phone.startsWith("+254")) return phone.substring(1);
  if (phone.startsWith("254")) return phone;

  return null;
}

async function getAccessToken() {
  const consumerKey = process.env.CONSUMER_KEY;
  const consumerSecret = process.env.CONSUMER_SECRET;

  if (!consumerKey || !consumerSecret) {
    throw new Error("Missing CONSUMER_KEY or CONSUMER_SECRET");
  }

  const auth = Buffer.from(`${consumerKey}:${consumerSecret}`).toString("base64");

  try {
    const response = await axios.get(
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
      {
        headers: { Authorization: `Basic ${auth}` },
        timeout: 10000,
      }
    );
    return response.data.access_token;
  } catch (error) {
    console.error("Access token error:", error.response?.data || error.message);
    throw new Error("Failed to get M-Pesa access token");
  }
}

// ---------- Routes ----------

app.get("/", (req, res) => {
  res.send("M-Pesa Backend Running");
});

// ---------- Auth Routes (Dummy) ----------

// In a real app, use a proper auth library like passport.js and JWT
app.post("/auth/login", (req, res) => {
  const { username, password } = req.body;

  // Dummy authentication logic
  if (username === 'admin' && password === 'admin123') {
    return res.json({
      success: true,
      message: "Admin login successful",
      // In a real app, this would be a real JWT
      token: "fake-admin-token",
      role: "admin",
    });
  }

  if (username === 'student' && password === 'student123') {
    return res.json({
      success: true,
      message: "Student login successful",
      token: "fake-student-token",
      role: "student",
      studentId: "dummy-student-001" // Send studentId for student users
    });
  }

  res.status(401).json({ success: false, message: "Invalid credentials" });
});


// ---------- Student CRUD API Routes ----------

// Create Student
// TODO: Add admin-only middleware
app.post("/api/students", async (req, res) => { // This should be protected
  if (!requireFirebase(res)) return;
  
  try {
    const { name, studentId, email, course, feeBalance } = req.body;
    if (!name || !studentId || !course || feeBalance === undefined) {
      return res.status(400).json({ message: "Missing required student fields." });
    }
    const student = { name, studentId, email, course, feeBalance: Number(feeBalance), dateCreated: new Date() };
    await db.collection("students").doc(studentId).set(student);
    res.status(201).json({ message: "Student created successfully", data: student });
  } catch (error) {
    console.error("Error creating student:", error);
    res.status(500).json({ message: "Failed to create student." });
  }
});

// Get All Students
// TODO: Add admin-only middleware
app.get("/api/students", async (req, res) => { // This should be protected
  if (!requireFirebase(res)) return;
  
  try {
    const snapshot = await db.collection("students").get();
    if (snapshot.empty) {
      return res.status(200).json([]);
    }
    const students = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(students);
  } catch (error) {
    console.error("Error getting students:", error);
    res.status(500).json({ message: "Failed to get students." });
  }
});

// Get Student by ID
// TODO: Add middleware to allow admin OR the specific student to access
app.get("/api/students/:id", async (req, res) => {
  if (!requireFirebase(res)) return;
  
  try {
    const studentId = req.params.id;
    const doc = await db.collection("students").doc(studentId).get();
    if (!doc.exists) {
      return res.status(404).json({ message: "Student not found." });
    }
    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error("Error getting student:", error);
    res.status(500).json({ message: "Failed to get student." });
  }
});

// Update Student
// TODO: Add admin-only middleware
app.put("/api/students/:id", async (req, res) => { // This should be protected
  if (!requireFirebase(res)) return;
  
  try {
    const studentId = req.params.id;
    const data = req.body;
    await db.collection("students").doc(studentId).update(data);
    res.status(200).json({ message: `Student ${studentId} updated successfully.` });
  } catch (error) {
    console.error("Error updating student:", error);
    res.status(500).json({ message: "Failed to update student." });
  }
});

// Delete Student
// TODO: Add admin-only middleware
app.delete("/api/students/:id", async (req, res) => { // This should be protected
  if (!requireFirebase(res)) return;
  
  try {
    const studentId = req.params.id;
    await db.collection("students").doc(studentId).delete();
    res.status(200).json({ message: `Student ${studentId} deleted successfully.` });
  } catch (error) {
    console.error("Error deleting student:", error);
    res.status(500).json({ message: "Failed to delete student." });
  }
});

// STK Push - Can be initiated by admin or student
app.post("/mpesa/stkpush", async (req, res) => {
  if (!requireFirebase(res)) return;
  
  try {
    let { phone, amount, accountReference, transactionDesc } = req.body;

    if (!phone) return res.status(400).json({ message: "Phone number is required" });

    phone = formatPhoneNumber(phone);
    if (!phone) {
      return res.status(400).json({ message: "Invalid phone number format. Use 07XX or 254XX format" });
    }

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: "A valid amount is required" });
    }

    const token = await getAccessToken();
    const timestamp = mpesaTimestamp();

    const shortcode = process.env.SHORTCODE || "174379";
    const passkey = process.env.PASSKEY;
    const callbackUrl = process.env.CALLBACK_URL;

    if (!passkey) throw new Error("Missing PASSKEY in .env");
    if (!callbackUrl) throw new Error("Missing CALLBACK_URL in .env");

    const password = Buffer.from(shortcode + passkey.trim() + timestamp).toString("base64");

console.log("Shortcode:", shortcode);
console.log("Passkey:", `"${passkey}"`, "length:", passkey.length);
console.log("Timestamp:", timestamp, "length:", timestamp.length);
console.log("Password(base64):", password);


    const stkResponse = await axios.post(
      "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
      {
        BusinessShortCode: shortcode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: Math.round(amount),
        PartyA: phone,
        PartyB: shortcode,
        PhoneNumber: phone,
        CallBackURL: callbackUrl,
        AccountReference: accountReference || "StudentFees",
        TransactionDesc: transactionDesc || "School Fees Payment",
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        timeout: 30000,
      }
    );

    const checkoutRequestId = stkResponse.data.CheckoutRequestID;

    // Save transaction details to Firestore for later lookup
    await db.collection("mpesa_transactions").doc(checkoutRequestId).set({
      studentId: accountReference,
      amount: Math.round(amount),
      phone,
      timestamp: new Date(),
      status: "initiated",
    });

    console.log("STK Push initiated:", stkResponse.data);

    res.json({
      success: true,
      message: "STK push sent successfully. Please enter your M-Pesa PIN.",
      data: stkResponse.data,
    });
  } catch (error) {
    console.error("STK Push error:", error.response?.data || error.message);
    res.status(500).json({
      success: false,
      message: error.response?.data?.errorMessage || "Mpesa STK push failed",
    });
  }
});

// STK Query
app.post("/mpesa/query", async (req, res) => {
  try {
    const { checkoutRequestId } = req.body;

    if (!checkoutRequestId) {
      return res.status(400).json({ message: "CheckoutRequestID is required" });
    }

    const token = await getAccessToken();
    const timestamp = mpesaTimestamp();

    const shortcode = process.env.SHORTCODE || "174379";
    const passkey = process.env.PASSKEY;
    const password = Buffer.from(shortcode + passkey + timestamp).toString("base64");

    const queryResponse = await axios.post(
      "https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query",
      {
        BusinessShortCode: shortcode,
        Password: password,
        Timestamp: timestamp,
        CheckoutRequestID: checkoutRequestId,
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        timeout: 30000,
      }
    );

    res.json(queryResponse.data);
  } catch (error) {
    console.error("STK Query error:", error.response?.data || error.message);
    res.status(500).json({ message: "Mpesa query failed" });
  }
});

// Callback
app.post("/mpesa/callback", async (req, res) => {
  if (!requireFirebase(res)) return;
  
  console.log("MPESA CALLBACK RECEIVED:");
  console.log(JSON.stringify(req.body, null, 2));

  try {
    const stkCallback = req.body?.Body?.stkCallback;

    if (!stkCallback) {
      console.log("Invalid callback format");
      return res.json({ ResultCode: 0, ResultDesc: "Accepted" });
    }

    const checkoutRequestId = stkCallback.CheckoutRequestID;
    const transactionRef = db.collection("mpesa_transactions").doc(checkoutRequestId);

    if (stkCallback.ResultCode === 0) {
      const items = stkCallback.CallbackMetadata?.Item || [];
      const amount = items.find(i => i.Name === "Amount")?.Value;
      const mpesaReceipt = items.find(i => i.Name === "MpesaReceiptNumber")?.Value;
      const phone = items.find(i => i.Name === "PhoneNumber")?.Value;

      console.log("✅ Payment successful");
      console.log("Amount:", amount);
      console.log("Receipt:", mpesaReceipt);
      console.log("Phone:", phone);

      // Update transaction in Firestore
      const transactionDoc = await transactionRef.get();
      if (transactionDoc.exists) {
        const { studentId } = transactionDoc.data();
        const studentRef = db.collection("students").doc(studentId);

        // Use a transaction to ensure atomicity
        await db.runTransaction(async (t) => {
          const studentDoc = await t.get(studentRef);
          if (!studentDoc.exists) {
            throw new Error(`Student with ID ${studentId} not found!`);
          }
          const currentBalance = studentDoc.data().feeBalance;
          const newBalance = currentBalance - Number(amount);

          t.update(studentRef, { feeBalance: newBalance });
          t.update(transactionRef, {
            status: "completed",
            callbackData: stkCallback,
          });
        });
        console.log(`Updated fee balance for student ${studentId}.`);
      }
    } else {
      console.log("❌ Payment failed:", stkCallback.ResultDesc);
      // Update transaction status to failed
      await transactionRef.update({
        status: "failed",
        callbackData: stkCallback,
      });
    }

    res.json({ ResultCode: 0, ResultDesc: "Accepted" });
  } catch (error) {
    console.error("Callback processing error:", error);
    res.json({ ResultCode: 0, ResultDesc: "Accepted" });
  }
});

app.get("/mpesa/token", async (req, res) => {
  try {
    const token = await getAccessToken();
    res.json({ access_token: token });
  } catch (e) {
    console.error("Token error:", e.message);
    res.status(500).json({ error: e.message });
  }
});

// Get transaction result (for Flutter polling)
app.get("/mpesa/transaction/:checkoutRequestId", async (req, res) => {
  if (!requireFirebase(res)) return;
  
  try {
    const { checkoutRequestId } = req.params;
    const doc = await db.collection("mpesa_transactions").doc(checkoutRequestId).get();

    if (doc.exists) {
      res.json({ success: true, data: doc.data() });
    } else {
      res.status(404).json({ success: false, message: "Transaction not found" });
    }
  } catch (error) {
    console.error("Error polling transaction:", error);
    res.status(500).json({ success: false, message: "Error polling transaction" });
  }
});

// ---------- Email Routes ----------

/**
 * Send verification email
 * Called after user registration
 */
app.post("/api/email/send-verification", async (req, res) => {
  try {
    const { email, fullName } = req.body;

    if (!email || !fullName) {
      return res
        .status(400)
        .json({ message: "Missing required fields: email, fullName" });
    }

    const result = await emailService.sendVerificationEmail(email, fullName);
    res.status(200).json({ success: true, ...result });
  } catch (error) {
    console.error("Error sending verification email:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send verification email",
      error: error.message,
    });
  }
});

/**
 * Send password reset email
 */
app.post("/api/email/send-password-reset", async (req, res) => {
  try {
    const { email, fullName } = req.body;

    if (!email || !fullName) {
      return res
        .status(400)
        .json({ message: "Missing required fields: email, fullName" });
    }

    const result = await emailService.sendPasswordResetEmail(email, fullName);
    res.status(200).json({ success: true, ...result });
  } catch (error) {
    console.error("Error sending password reset email:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send password reset email",
      error: error.message,
    });
  }
});

/**
 * Send welcome email
 * Called after email verification
 */
app.post("/api/email/send-welcome", async (req, res) => {
  try {
    const { email, fullName, role } = req.body;

    if (!email || !fullName || !role) {
      return res
        .status(400)
        .json({ message: "Missing required fields: email, fullName, role" });
    }

    const result = await emailService.sendWelcomeEmail(email, fullName, role);
    res.status(200).json({ success: true, ...result });
  } catch (error) {
    console.error("Error sending welcome email:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send welcome email",
      error: error.message,
    });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server running on port " + PORT);
  console.log("Callback URL for M-Pesa:", process.env.CALLBACK_URL || "Not configured in .env");
});
