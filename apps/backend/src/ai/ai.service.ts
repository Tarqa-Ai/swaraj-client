import { BadRequestException, Injectable, ServiceUnavailableException } from "@nestjs/common";
import OpenAI from "openai";
import type { ExplainBody } from "./ai.schemas";

@Injectable()
export class AiService {
  private client: OpenAI | null = null;

  async explain(body: ExplainBody) {
    const client = this.getClient();
    const moderation = await client.moderations.create({
      model: process.env.OPENAI_MODERATION_MODEL ?? "omni-moderation-latest",
      input: body.question
    });
    if (moderation.results.some((result) => result.flagged)) {
      throw new BadRequestException("Question cannot be processed safely");
    }

    const languageInstruction = body.language === "hi" ? "Reply in simple Hindi." : "Reply in simple English.";
    const completion = await client.chat.completions.create({
      model: process.env.OPENAI_MODEL ?? "gpt-4.1-mini",
      temperature: 0.2,
      messages: [
        {
          role: "system",
          content:
            "You explain Indian civics to Grade 9-12 students. Explain to a 15-year-old in simple language under 100 words. Do not be partisan. Do not continue as a chatbot."
        },
        { role: "user", content: `${languageInstruction}\n\nConcept: ${body.question}` }
      ]
    });

    return {
      explanation: completion.choices[0]?.message.content?.trim() ?? "",
      model: completion.model
    };
  }

  private getClient() {
    if (!process.env.OPENAI_API_KEY) {
      throw new ServiceUnavailableException("AI provider is not configured");
    }
    this.client ??= new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
    return this.client;
  }
}
