import { Injectable, Logger, ServiceUnavailableException } from "@nestjs/common";
import axios from "axios";

export abstract class OtpProvider {
  abstract send(phone: string, code: string): Promise<void>;
}

@Injectable()
export class Msg91OtpProvider implements OtpProvider {
  private readonly logger = new Logger(Msg91OtpProvider.name);

  async send(phone: string, code: string): Promise<void> {
    if (process.env.NODE_ENV !== "production" && process.env.OTP_PROVIDER !== "msg91") {
      this.logger.log(`Development OTP for ${phone}: ${code}`);
      return;
    }

    const authKey = process.env.MSG91_AUTH_KEY;
    const templateId = process.env.MSG91_TEMPLATE_ID;
    if (!authKey || !templateId) {
      throw new ServiceUnavailableException("OTP provider is not configured");
    }

    await axios.post(
      "https://control.msg91.com/api/v5/otp",
      { template_id: templateId, mobile: phone, otp: code },
      { headers: { authkey: authKey, "content-type": "application/json" }, timeout: 8000 }
    );
  }
}
