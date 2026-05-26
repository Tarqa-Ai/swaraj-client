import { ServiceUnavailableException } from "@nestjs/common";
import { AiService } from "./ai.service";

describe("AiService", () => {
  it("returns a typed unavailable error when provider credentials are absent", async () => {
    const previous = process.env.OPENAI_API_KEY;
    delete process.env.OPENAI_API_KEY;
    await expect(new AiService().explain({ question: "What is Article 21?", language: "en" })).rejects.toBeInstanceOf(ServiceUnavailableException);
    process.env.OPENAI_API_KEY = previous;
  });
});
