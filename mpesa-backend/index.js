require("dotenv").config();

const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// In-memory store (replace with Firestore/DB in production)
let callbackData = {};

// ---------- Helpers ----------
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

// STK Push
app.post("/mpesa/stkpush", async (req, res) => {
  try {
    let { phone, amount, accountReference, transactionDesc } = req.body;

    if (!phone) return res.status(400).json({ message: "Phone number is required" });

    phone = formatPhoneNumber(phone);
    if (!phone) {
      return res.status(400).json({ message: "Invalid phone number format. Use 07XX or 254XX format" });
    }

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: "Valid amount is required" });
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

    console.log("STK Push initiated:", stkResponse.data);

    res.json({
      success: true,
      message: "STK push sent successfully",
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
app.post("/mpesa/callback", (req, res) => {
  console.log("MPESA CALLBACK RECEIVED:");
  console.log(JSON.stringify(req.body, null, 2));

  try {
    const stkCallback = req.body?.Body?.stkCallback;

    if (!stkCallback) {
      console.log("Invalid callback format");
      return res.json({ ResultCode: 0, ResultDesc: "Accepted" });
    }

    const checkoutRequestId = stkCallback.CheckoutRequestID;
    callbackData[checkoutRequestId] = stkCallback;

    if (stkCallback.ResultCode === 0) {
      const items = stkCallback.CallbackMetadata?.Item || [];
      const amount = items.find(i => i.Name === "Amount")?.Value;
      const mpesaReceipt = items.find(i => i.Name === "MpesaReceiptNumber")?.Value;
      const phone = items.find(i => i.Name === "PhoneNumber")?.Value;

      console.log("✅ Payment successful");
      console.log("Amount:", amount);
      console.log("Receipt:", mpesaReceipt);
      console.log("Phone:", phone);

      // TODO: Save payment to Firestore / DB
    } else {
      console.log("❌ Payment failed:", stkCallback.ResultDesc);
    }

    res.json({ ResultCode: 0, ResultDesc: "Accepted" });
  } catch (error) {
    console.error("Callback processing error:", error);
    res.json({ ResultCode: 0, ResultDesc: "Accepted" });
  }
});

// Get transaction result (for Flutter polling)
app.get("/mpesa/transaction/:checkoutRequestId", (req, res) => {
  const { checkoutRequestId } = req.params;
  const data = callbackData[checkoutRequestId];

  if (data) {
    res.json({ success: true, data });
  } else {
    res.json({ success: false, message: "Transaction not found" });
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


const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server running on port " + PORT);
  console.log("STK Push endpoint: POST /mpesa/stkpush");
  console.log("Callback URL:", process.env.CALLBACK_URL || "Not configured");
});
