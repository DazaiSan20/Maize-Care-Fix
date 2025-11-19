const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  // Use ethereal or configure SMTP via env in production
  host: process.env.SMTP_HOST || 'smtp.example.com',
  port: process.env.SMTP_PORT ? Number(process.env.SMTP_PORT) : 587,
  secure: false,
  auth: {
    user: process.env.SMTP_USER || '',
    pass: process.env.SMTP_PASS || '',
  },
});

exports.sendEmail = async ({ to, subject, text, html }) => {
  const info = await transporter.sendMail({
    from: process.env.SMTP_FROM || 'no-reply@maizecare.local',
    to,
    subject,
    text,
    html,
  });
  return info;
};
