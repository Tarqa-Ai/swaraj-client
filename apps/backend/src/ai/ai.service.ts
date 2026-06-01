import { BadRequestException, Injectable, ServiceUnavailableException } from "@nestjs/common";
import { GoogleGenerativeAI, HarmBlockThreshold, HarmCategory } from "@google/generative-ai";
import type { ExplainBody } from "./ai.schemas";

@Injectable()
export class AiService {
  private genAI: GoogleGenerativeAI | null = null;

  async explain(body: ExplainBody) {
    const genAI = this.getClient();
    const model = genAI.getGenerativeModel({
      model: process.env.GEMINI_MODEL ?? "gemini-2.0-flash-lite",
      safetySettings: [
        { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE }
      ],
      generationConfig: { temperature: 0.2, maxOutputTokens: 200 }
    });

    const languageInstruction = body.language === "hi" ? "Reply in simple Hindi." : "Reply in simple English.";
    const systemPrompt =
      "You explain Indian civics to Grade 9-12 students. Explain to a 15-year-old in simple language under 100 words. Do not be partisan. Do not act as a chatbot.";
    const userPrompt = `${languageInstruction}\n\nConcept: ${body.question}`;

    let result;
    try {
      result = await model.generateContent(`${systemPrompt}\n\n${userPrompt}`);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      if (msg.includes("SAFETY") || msg.includes("blocked")) {
        throw new BadRequestException("Question cannot be processed safely");
      }
      throw e;
    }

    const candidate = result.response.candidates?.[0];
    if (!candidate || candidate.finishReason === "SAFETY") {
      throw new BadRequestException("Question cannot be processed safely");
    }

    return {
      explanation: result.response.text().trim(),
      model: process.env.GEMINI_MODEL ?? "gemini-2.0-flash-lite"
    };
  }

  private getClient() {
    if (!process.env.GEMINI_API_KEY) {
      throw new ServiceUnavailableException("AI provider is not configured");
    }
    this.genAI ??= new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    return this.genAI;
  }
}
