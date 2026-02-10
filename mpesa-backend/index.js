require("dotenv").config();
console.log("SHORTCODE:", process.env.SHORTCODE);
console.log("CONSUMER_KEY:", process.env.CONSUMER_KEY ? "LOADED" : "MISSING");
console.log("PASSKEY:", process.env.PASSKEY ? "LOADED" : "MISSING");

const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

let callbackData = {};

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
    console.error("Failed to get access token:", error.response?.data || error.message);
    throw new Error("Failed to get M-Pesa access token");
  }
}

function formatPhoneNumber(phone) {
  phone = phone.replace(/[\s\-\(\)]/g, "");
  
  if (phone.startsWith("07")) {
    return "254" + phone.substring(1);
  } else if (phone.startsWith("01")) {
    return "254" + phone.substring(1);
  } else if (phone.startsWith("+254")) {
    return phone.substring(1);
  } else if (phone.startsWith("254")) {
    return phone;
  } else {
    return null;
  }
}

app.post("/mpesa/stkpush", async (req, res) => {
  try {
    let { phone, amount, accountReference, transactionDesc } = req.body;

    if (!phone) {
      return res.status(400).json({ message: "Phone number is required" });
    }

    phone = formatPhoneNumber(phone);
    if (!phone) {
      return res.status(400).json({ message: "Invalid phone number format. Use 07XX or 254XX format" });
    }

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: "Valid amount is required" });
    }

    const token = await getAccessToken();

    const timestamp = new Date()
      .toISOString()
      .replace(/[^0-9]/g, "")
      .slice(0, -3);

    const shortcode = process.env.SHORTCODE || "174379";
    const passkey = process.env.PASSKEY;

    if (!passkey) {
      throw new Error("Missing PASSKEY in environment variables");
    }

    const password = Buffer.from(shortcode + passkey + timestamp).toString("base64");
    const callbackUrl = process.env.CALLBACK_URL;

    if (!callbackUrl) {
      throw new Error("CALLBACK_URL is required in .env file");
    }

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
        AccountReference: accountReference || "Test",
        TransactionDesc: transactionDesc || "Test payment",
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
    
    const errorMessage = error.response?.data?.errorMessage || "Mpesa STK push failed";
    
    res.status(500).json({ 
      success: false,
      message: errorMessage,
    });
  }
});

app.post("/mpesa/query", async (req, res) => {
  try {
    const { checkoutRequestId } = req.body;

    if (!checkoutRequestId) {
      return res.status(400).json({ message: "Checkout request ID is required" });
    }

    const token = await getAccessToken();

    const timestamp = new Date()
      .toISOString()
      .replace(/[^0-9]/g, "")
      .slice(0, -3);

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

app.post("/mpesa/callback", (req, res) => {
  console.log("MPESA CALLBACK RECEIVED:");
  console.log(JSON.stringify(req.body, null, 2));

  try {
    const result = req.body;
    
    if (result.ResultType !== undefined) {
      const checkoutRequestId = result.CheckoutRequestID;
      callbackData[checkoutRequestId] = result;
      
      if (result.ResultCode === 0) {
        console.log("Payment successful!");
        const stkCallback = result.Result?.CallbackMetadata?.Item || [];
        const amount = stkCallback.find(i => i.Name === "Amount")?.Value;
        const mpesaReceipt = stkCallback.find(i => i.Name === "MpesaReceiptNumber")?.Value;
        const phone = stkCallback.find(i => i.Name === "PhoneNumber")?.Value;
        
        console.log("Amount:", amount);
        console.log("Receipt:", mpesaReceipt);
        console.log("Phone:", phone);
      } else {
        console.log("Payment failed:", result.ResultDesc);
      }
    }

    res.json({ ResultCode: 0, ResultDesc: "Success" });
  } catch (error) {
    console.error("Callback processing error:", error);
    res.json({ ResultCode: 0, ResultDesc: "Success" });
  }
});

app.get("/mpesa/transaction/:checkoutRequestId", (req, res) => {
  const { checkoutRequestId } = req.params;
  const data = callbackData[checkoutRequestId];
  
  if (data) {
    res.json({ success: true, data });
  } else {
    res.json({ success: false, message: "Transaction not found" });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server running on port " + PORT);
  console.log("STK Push endpoint: POST /mpesa/stkpush");
  console.log("Callback URL: " + (process.env.CALLBACK_URL || "Not configured"));
});
