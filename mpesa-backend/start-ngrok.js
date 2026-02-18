require("dotenv").config();
const ngrok = require("@ngrok/ngrok");

(async function () {
  try {
    const port = Number(process.env.PORT || 3000);
    const authtoken = process.env.NGROK_AUTHTOKEN;

    if (!authtoken) {
      throw new Error("NGROK_AUTHTOKEN missing in .env");
    }

    // Authenticate first (required for @ngrok/ngrok)
    await ngrok.authtoken(authtoken);

    // Create an HTTP tunnel to your local server
    const listener = await ngrok.connect({
      addr: port,
      proto: "http",
    });

    // Extract the public URL (new SDK returns a Listener object)
    const publicUrl =
      typeof listener === "string"
        ? listener
        : listener.url?.() || listener.url || listener.public_url;

    console.log("✅ Ngrok tunnel started at:", publicUrl);
    console.log("📋 Set this as CALLBACK_URL in .env");
    console.log("\n💥 Press Ctrl+C to stop the tunnel");
  } catch (err) {
    console.error("❌ Error starting ngrok:", err.message);
    process.exit(1);
  }
})();
