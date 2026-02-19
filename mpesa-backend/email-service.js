const nodemailer = require('nodemailer');

// Initialize transporter with environment variables
// This uses Gmail SMTP - configure in .env file
const transporter = nodemailer.createTransport({
  service: process.env.EMAIL_SERVICE || 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD, // Use App Password for Gmail
  },
});

// Verify transporter connection
transporter.verify((error, success) => {
  if (error) {
    console.warn('Email service warning:', error.message);
  } else if (success) {
    console.log('✓ Email service ready');
  }
});

/**
 * Send email verification link to user
 * @param {string} email - User's email address
 * @param {string} fullName - User's full name
 */
async function sendVerificationEmail(email, fullName) {
  try {
    // Create a simple verification link
    // In a production app, you would generate a secure token via Firebase Admin SDK
    const verificationLink = `https://your-app.com/verify-email?email=${encodeURIComponent(email)}`;

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Verify Your Email - Student Management System',
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="UTF-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                border: 1px solid #ddd;
                border-radius: 8px;
              }
              .header {
                background: #1976D2;
                color: white;
                padding: 20px;
                text-align: center;
                border-radius: 8px 8px 0 0;
              }
              .content {
                padding: 20px;
              }
              .verification-button {
                display: inline-block;
                background: #1976D2;
                color: white;
                padding: 12px 30px;
                text-decoration: none;
                border-radius: 4px;
                margin: 20px 0;
              }
              .footer {
                background: #f5f5f5;
                padding: 15px;
                text-align: center;
                font-size: 12px;
                color: #666;
                border-radius: 0 0 8px 8px;
              }
              .note {
                background: #f0f4ff;
                border-left: 4px solid #1976D2;
                padding: 15px;
                margin: 20px 0;
                border-radius: 4px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>Email Verification</h1>
              </div>
              <div class="content">
                <p>Hi ${fullName},</p>
                <p>Thank you for registering with our Student Management System!</p>
                
                <div class="note">
                  <strong>✓ Your account has been created successfully!</strong>
                  <p>You can now log in to the application. Email verification is optional but recommended for account security.</p>
                </div>
                
                <p><strong>To verify your email:</strong></p>
                <ol>
                  <li>Log in to the Student Management System</li>
                  <li>Go to Account Settings</li>
                  <li>Click "Verify Email" button</li>
                  <li>Check your email for the verification link</li>
                </ol>
                
                <p>If you have any questions, please contact our support team.</p>
                
                <p>Best regards,<br><strong>Student Management System Team</strong></p>
              </div>
              <div class="footer">
                <p>&copy; 2026 Student Management System. All rights reserved.</p>
              </div>
            </div>
          </body>
        </html>
      `,
      text: `
        Hi ${fullName},
        
        Thank you for registering with our Student Management System!
        
        ✓ Your account has been created successfully!
        
        You can now log in to the application. Email verification is optional but recommended for account security.
        
        To verify your email:
        1. Log in to the Student Management System
        2. Go to Account Settings
        3. Click "Verify Email" button
        4. Check your email for the verification link
        
        Best regards,
        Student Management System Team
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('Verification email sent to:', email);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Error sending verification email:', error);
    throw error;
  }
}

/**
 * Send password reset email
 * @param {string} email - User's email address
 * @param {string} fullName - User's full name
 */
async function sendPasswordResetEmail(email, fullName) {
  try {
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Reset Your Password - Student Management System',
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="UTF-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                border: 1px solid #ddd;
                border-radius: 8px;
              }
              .header {
                background: #FF9800;
                color: white;
                padding: 20px;
                text-align: center;
                border-radius: 8px 8px 0 0;
              }
              .content {
                padding: 20px;
              }
              .reset-button {
                display: inline-block;
                background: #FF9800;
                color: white;
                padding: 12px 30px;
                text-decoration: none;
                border-radius: 4px;
                margin: 20px 0;
              }
              .footer {
                background: #f5f5f5;
                padding: 15px;
                text-align: center;
                font-size: 12px;
                color: #666;
                border-radius: 0 0 8px 8px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>Password Reset Request</h1>
              </div>
              <div class="content">
                <p>Hi ${fullName},</p>
                <p>We received a request to reset your password. To reset your password:</p>
                
                <ol>
                  <li>Go to the login page</li>
                  <li>Click "Forgot Password?"</li>
                  <li>Enter this email address: <strong>${email}</strong></li>
                  <li>Check your email for the reset link</li>
                  <li>Click the link to set a new password</li>
                </ol>
                
                <p><strong>Note:</strong> This link will expire in 1 hour.</p>
                
                <p>If you didn't request a password reset, you can safely ignore this email and your password will remain unchanged.</p>
                
                <p>Best regards,<br><strong>Student Management System Team</strong></p>
              </div>
              <div class="footer">
                <p>&copy; 2026 Student Management System. All rights reserved.</p>
              </div>
            </div>
          </body>
        </html>
      `,
      text: `
        Hi ${fullName},
        
        We received a request to reset your password. To reset your password:
        
        1. Go to the login page
        2. Click "Forgot Password?"
        3. Enter this email address: ${email}
        4. Check your email for the reset link
        5. Click the link to set a new password
        
        Note: This link will expire in 1 hour.
        
        If you didn't request this, you can safely ignore this email.
        
        Best regards,
        Student Management System Team
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('Password reset email sent to:', email);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Error sending password reset email:', error);
    throw error;
  }
}

/**
 * Send welcome email to new user
 * @param {string} email - User's email address
 * @param {string} fullName - User's full name
 * @param {string} role - User's role
 */
async function sendWelcomeEmail(email, fullName, role) {
  try {
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Welcome to Student Management System',
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="UTF-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                border: 1px solid #ddd;
                border-radius: 8px;
              }
              .header {
                background: linear-gradient(135deg, #1976D2 0%, #1565C0 100%);
                color: white;
                padding: 20px;
                text-align: center;
                border-radius: 8px 8px 0 0;
              }
              .content {
                padding: 20px;
              }
              .footer {
                background: #f5f5f5;
                padding: 15px;
                text-align: center;
                font-size: 12px;
                color: #666;
                border-radius: 0 0 8px 8px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>Welcome to Student Management System</h1>
              </div>
              <div class="content">
                <p>Hi ${fullName},</p>
                <p>Your account has been successfully created and verified!</p>
                
                <p><strong>Account Details:</strong></p>
                <ul>
                  <li>Email: ${email}</li>
                  <li>Role: ${role}</li>
                </ul>
                
                <p>You can now log in to your account and start using the system. If you have any questions or need assistance, please contact our support team.</p>
                
                <p>Best regards,<br>Student Management System Team</p>
              </div>
              <div class="footer">
                <p>&copy; 2026 Student Management System. All rights reserved.</p>
              </div>
            </div>
          </body>
        </html>
      `,
      text: `
        Hi ${fullName},
        
        Your account has been successfully created and verified!
        
        Account Details:
        - Email: ${email}
        - Role: ${role}
        
        You can now log in to your account.
        
        Best regards,
        Student Management System Team
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('Welcome email sent:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Error sending welcome email:', error);
    throw error;
  }
}

module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
};
