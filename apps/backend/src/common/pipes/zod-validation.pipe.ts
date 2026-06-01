import { BadRequestException, Injectable, PipeTransform } from "@nestjs/common";
import type { ZodSchema } from "zod";

@Injectable()
export class ZodValidationPipe<T> implements PipeTransform<unknown, T> {
  constructor(private readonly schema: ZodSchema<T>) {}

  transform(value: unknown): T {
    console.log("ZodValidationPipe input value:", JSON.stringify(value, null, 2));
    const result = this.schema.safeParse(value);
    if (!result.success) {
      console.error("ZodValidationPipe failure details:", JSON.stringify(result.error.flatten(), null, 2));
      throw new BadRequestException({
        message: "Validation failed",
        issues: result.error.flatten()
      });
    }
    return result.data;
  }
}
