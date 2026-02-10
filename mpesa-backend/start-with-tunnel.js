const ngrok = require('ngrok');
require('dotenv').config();

async function start() {
  try {
    // Start ngrok tunnel
    const url = await ngrok.connect(3000);
    console.log(`✅ ngrok tunnel started at: ${url}`);
    console.log(`✅ Callback URL: ${url}/mpesa/callback`);
    
    // Update CALLBACK_URL in environment
    process.env.CALLBACK_URL = `${url}/mpesa/callback`;
    
    // Log to file for reference
    const fs = require('fs');
    fs.writeFileSync('NGROK_URL.txt', `${url}\n${url}/mpesa/callback`);
    console.log('✅ URL saved to NGROK_URL.txt');
    
    // Now start the Express server
    require('./index.js');
    
  } catch (error) {
    console.error('❌ Failed to start ngrok:', error);
    process.exit(1);
  }
}

start();
