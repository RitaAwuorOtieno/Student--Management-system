const ngrok = require('ngrok');
const fs = require('fs');
const path = require('path');

async function startNgrok() {
  try {
    console.log('\n🚀 Starting ngrok tunnel...');
    
    const url = await ngrok.connect(3000);

    console.log('\n✅ ngrok tunnel started successfully!');
    console.log(`\n📡 Public Tunnel URL: ${url}`);
    console.log(`📡 Callback URL: ${url}/mpesa/callback\n`);

    // Save the URL to a file
    const callbackUrl = `${url}/mpesa/callback`;
    fs.writeFileSync(path.join(__dirname, 'NGROK_URL.txt'), `${callbackUrl}\n`);
    console.log('✅ Tunnel URL saved to NGROK_URL.txt');

    // Keep the tunnel alive
    console.log('✅ Tunnel is running. Press Ctrl+C to stop.\n');

    // Also log to console periodically
    setInterval(() => {
      console.log(`[${new Date().toLocaleTimeString()}] Tunnel active: ${url}`);
    }, 60000); // Every 60 seconds

  } catch (error) {
    console.error('❌ Error starting ngrok:', error.message);
    process.exit(1);
  }
}

// Start ngrok
startNgrok();

// Handle interruption
process.on('SIGINT', async () => {
  console.log('\n\n👋 Shutting down ngrok...');
  await ngrok.disconnect();
  process.exit(0);
});
