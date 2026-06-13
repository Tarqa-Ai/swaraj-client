import { BadRequestException, Injectable, ServiceUnavailableException } from "@nestjs/common";
import axios from "axios";
import type { ExplainBody } from "./ai.schemas";

const TARQA_URL = "https://api.tarqaai.com/api/v1/ask";
const TARQA_MODEL = "deepseek.v3.2";

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

    let responseText: string;
    try {
      const { data } = await axios.post(
        `${TARQA_URL}?model=${TARQA_MODEL}`,
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
