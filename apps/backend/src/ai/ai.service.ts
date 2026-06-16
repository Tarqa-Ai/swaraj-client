import { BadRequestException, Injectable, ServiceUnavailableException } from "@nestjs/common";
import axios from "axios";
import type { ExplainBody } from "./ai.schemas";

const TARQA_MODEL = "deepseek.v3.2";

function getTarqaUrl(): string {
  if (process.env.TARQA_BASE_URL) return `${process.env.TARQA_BASE_URL}/api/v1/ask`;
  const isProd = process.env.NODE_ENV === "production";
  const base = isProd ? "https://api.tarqaai.com" : "https://api-dev.tarqaai.com";
  return `${base}/api/v1/ask`;
}

@Injectable()
export class AiService {
  async explain(body: ExplainBody) {
    const apiKey = process.env.TARQA_API_KEY;
    if (!apiKey) {
      throw new ServiceUnavailableException("AI provider is not configured");
    }

    const languageInstruction = body.language === "hi" ? "Reply in simple Hindi." : "Reply in simple English.";
    const message =
      `You explain Indian civics to Grade 9-12 students. Explain to a 15-year-old in simple language under 100 words. Do not be partisan. Do not act as a chatbot.\n\n` +
      `${languageInstruction}\n\nConcept: ${body.question}`;

    const tarqaUrl = getTarqaUrl();
    let responseText: string;
    try {
      const { data } = await axios.post(
        `${tarqaUrl}?model=${TARQA_MODEL}`,
        { message },
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json"
          },
          timeout: 30_000
        }
      );
      responseText = data?.response ?? data?.answer ?? data?.text ?? data?.content ?? data?.message;
      if (!responseText) {
        throw new Error(`Unexpected response shape: ${JSON.stringify(data)}`);
      }
    } catch (e: unknown) {
      if (axios.isAxiosError(e) && e.response) {
        throw new BadRequestException(`AI request failed: ${e.response.status}`);
      }
      throw e;
    }

    return {
      explanation: responseText.trim(),
      model: TARQA_MODEL
    };
  }
}
