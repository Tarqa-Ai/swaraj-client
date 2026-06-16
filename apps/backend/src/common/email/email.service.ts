import { Injectable, Logger } from "@nestjs/common";
import nodemailer from "nodemailer";

const APP_NAME = "Swaraj";
const SAFFRON = "#FF6B1A";

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);

  private createTransporter(): nodemailer.Transporter | null {
    const host = process.env.EMAIL_HOST;
    const user = process.env.EMAIL_USER;
    const pass = process.env.EMAIL_PASS;
    if (!host || !user || !pass) return null;
    return nodemailer.createTransport({
      host,
      port: parseInt(process.env.EMAIL_PORT ?? "587"),
      secure: process.env.EMAIL_SECURE === "true",
      auth: { user, pass },
    });
  }

  private get from(): string {
    return (
      process.env.EMAIL_FROM ??
      `${APP_NAME} <${process.env.EMAIL_USER ?? "noreply@swaraj.org.in"}>`
    );
  }

  async sendOtp(to: string, otp: string): Promise<void> {
    const transporter = this.createTransporter();
    if (!transporter) {
      this.logger.warn(`[email] NOT CONFIGURED — OTP for ${to}: ${otp}`);
      return;
    }

    const html = `<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1.0"/><title>Your Swaraj OTP</title></head>
<body style="margin:0;padding:0;background-color:#f5f0e8;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f5f0e8;padding:40px 20px;">
    <tr><td align="center">
      <table width="520" cellpadding="0" cellspacing="0" border="0" style="max-width:520px;width:100%;background-color:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e8e0d0;">
        <tr><td style="height:4px;background:linear-gradient(90deg,#0a1628 0%,${SAFFRON} 50%,#0a1628 100%);font-size:0;line-height:0;">&nbsp;</td></tr>
        <tr><td style="padding:32px 40px 24px;background-color:#0a1628;">
          <table width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr>
              <td><div style="display:inline-flex;align-items:center;gap:8px;">
                <div style="background-color:${SAFFRON};border-radius:8px;width:32px;height:32px;display:inline-block;text-align:center;line-height:32px;font-size:16px;">&#9737;</div>
                <span style="font-size:20px;font-weight:900;letter-spacing:0.08em;color:#ffffff;font-family:Arial,sans-serif;">SWARAJ</span>
              </div></td>
              <td align="right"><span style="font-size:11px;color:#8892a4;letter-spacing:0.1em;text-transform:uppercase;font-weight:600;">Civic Learning Platform</span></td>
            </tr>
          </table>
        </td></tr>
        <tr><td style="padding:40px 40px 32px;">
          <p style="font-size:22px;font-weight:700;color:#0a1628;margin:0 0 12px;">Your verification code</p>
          <p style="font-size:14px;line-height:1.8;color:#5a6478;margin:0 0 32px;">Enter this 6-digit code to sign in to your Swaraj account. The code expires in <strong style="color:#0a1628;">10 minutes</strong>.</p>
          <div style="background-color:#f5f0e8;border:2px solid ${SAFFRON};border-radius:12px;padding:24px;text-align:center;margin:0 0 32px;">
            <span style="font-size:40px;font-weight:900;letter-spacing:0.3em;color:#0a1628;font-family:'Courier New',monospace;">${otp}</span>
          </div>
          <p style="font-size:13px;color:#8892a4;margin:0;">If you didn't request this code, you can safely ignore this email.</p>
        </td></tr>
        <tr><td style="padding:20px 40px;border-top:1px solid #e8e0d0;background-color:#faf7f2;">
          <p style="font-size:11px;color:#8892a4;text-align:center;margin:0;line-height:1.6;">
            &copy; ${new Date().getFullYear()} Swaraj &mdash; Civic Education Platform &nbsp;&middot;&nbsp; Viksit Bharat @ 2047
          </p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;

    try {
      this.logger.log(`[email] sending OTP to ${to}`);
      await transporter.sendMail({
        from: this.from,
        to,
        subject: `${otp} is your Swaraj verification code`,
        html,
        text: `Your Swaraj OTP is: ${otp}\n\nValid for 10 minutes. If you didn't request this, ignore this email.`,
      });
      this.logger.log(`[email] OTP delivered to ${to}`);
    } catch (err) {
      this.logger.error(`[email] SMTP error sending to ${to}: ${err}`);
      throw err;
    }
  }
}
