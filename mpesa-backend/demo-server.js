require("dotenv").config();
const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

let callbackData = {};
let transactionCounter = 0;

// Mock M-Pesa STK Push for testing
// In production, this would call actual M-Pesa API
app.post("/mpesa/stkpush", async (req, res) => {
  try {
    let { phone, amount, accountReference, transactionDesc } = req.body;

    if (!phone) {
      return res.status(400).json({ message: "Phone number is required" });
    }

    // Format phone number
    phone = phone.replace(/[\s\-\(\)]/g, "");
    if (phone.startsWith("07")) {
      phone = "254" + phone.substring(1);
    } else if (phone.startsWith("01")) {
      phone = "254" + phone.substring(1);
    } else if (phone.startsWith("+254")) {
      phone = phone.substring(1);
    }

    if (!phone.startsWith("254") || phone.length !== 12) {
      return res.status(400).json({ message: "Invalid phone number format. Use 07XX or 254XX format" });
    }

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: "Valid amount is required" });
    }

    // Generate mock M-Pesa response
    transactionCounter++;
    const checkoutRequestId = `WEB_20260210_${Date.now()}`;
    const merchantRequestId = `WEB_MECH_ID_${transactionCounter}`;

    console.log(`\n📱 STK Push Request:`);
    console.log(`   Phone: ${phone}`);
    console.log(`   Amount: KES ${amount}`);
    console.log(`   Reference: ${accountReference}`);
    console.log(`   Checkout Request ID: ${checkoutRequestId}`);

    // Simulate successful STK push (in real M-Pesa, user gets prompt on phone)
    res.json({
      success: true,
      message: "STK push sent successfully",
      data: {
        CheckoutRequestID: checkoutRequestId,
        MerchantRequestID: merchantRequestId,
        ResponseCode: "0",
        ResponseDescription: "Success. Request accepted for processing",
        CustomerMessage: "STK push sent successfully. Enter PIN on your phone.",
      },
    });

    console.log(`✅ STK Push Response: Success (Checkout ID: ${checkoutRequestId})`);

  } catch (error) {
    console.error("❌ STK Push error:", error.message);
    res.status(500).json({
      success: false,
      message: "Failed to send STK push",
      error: error.message,
    });
  }
});

// Query transaction status
app.post("/mpesa/query", async (req, res) => {
  try {
    const { checkoutRequestId } = req.body;

    if (!checkoutRequestId) {
      return res.status(400).json({ message: "Checkout request ID is required" });
    }

    console.log(`\n🔍 Query Request: ${checkoutRequestId}`);

    // For demo: simulate successful payment
    const mockResponse = {
      ResponseCode: "0",
      ResponseDescription: "The service request has been accepted successfully",
      MerchantRequestID: "123456",
      CheckoutRequestID: checkoutRequestId,
      ResultCode: "0",
      ResultDesc: "Payment successful (Demo Mode)",
    };

    res.json(mockResponse);
    console.log(`✅ Query Response: Success`);

  } catch (error) {
    console.error("❌ Query error:", error.message);
    res.status(500).json({ message: "Failed to query transaction" });
  }
});

// Callback endpoint
app.post("/mpesa/callback", (req, res) => {
  console.log("\n📥 M-Pesa Callback Received:");
  console.log(JSON.stringify(req.body, null, 2));

  try {
    const result = req.body;

    if (result.CheckoutRequestID) {
      callbackData[result.CheckoutRequestID] = result;

      if (result.ResultCode === 0) {
        console.log("✅ Payment successful!");
      } else {
        console.log("❌ Payment failed:", result.ResultDesc);
      }
    }

    res.json({ ResultCode: 0, ResultDesc: "Success" });
  } catch (error) {
    console.error("❌ Callback error:", error);
    res.json({ ResultCode: 0, ResultDesc: "Success" });
  }
});

// Get transaction status
app.get("/mpesa/transaction/:checkoutRequestId", (req, res) => {
  const { checkoutRequestId } = req.params;
  const data = callbackData[checkoutRequestId];

  if (data) {
    res.json({ success: true, data });
  } else {
    // For demo: return success
    res.json({
      success: true,
      data: {
        ResultCode: 0,
        ResultDesc: "Payment successful (Demo Mode)",
        CheckoutRequestID: checkoutRequestId,
      },
    });
  }
});

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "Server running", timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("\n═══════════════════════════════════════════════════════");
  console.log("🚀 M-Pesa Backend Server Started");
  console.log("═══════════════════════════════════════════════════════");
  console.log(`Port: ${PORT}`);
  console.log(`Mode: DEMO/TESTING (using mock M-Pesa responses)`);
  console.log(`Health Check: http://localhost:${PORT}/health`);
  console.log(`STK Push: POST http://localhost:${PORT}/mpesa/stkpush`);
  console.log("═══════════════════════════════════════════════════════\n");
});
