import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { Injectable, ServiceUnavailableException } from "@nestjs/common";
import { mkdir, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";

@Injectable()
export class FileStorageService {
  private s3Client: S3Client | null = null;

  async put(key: string, buffer: Buffer, contentType: string) {
    if (process.env.STORAGE_DRIVER === "s3") {
      return this.putS3(key, buffer, contentType);
    }
    return this.putLocal(key, buffer);
  }

  private async putLocal(key: string, buffer: Buffer) {
    const root = process.env.LOCAL_STORAGE_ROOT ?? "./uploads";
    const target = join(process.cwd(), root, key);
    await mkdir(dirname(target), { recursive: true });
    await writeFile(target, buffer);
    return `/uploads/${key}`;
  }

  private async putS3(key: string, buffer: Buffer, contentType: string) {
    const bucket = process.env.S3_BUCKET;
    if (!bucket) throw new ServiceUnavailableException("S3 storage is not configured");
    this.s3Client ??= new S3Client({
      region: process.env.S3_REGION ?? "ap-south-1",
      endpoint: process.env.S3_ENDPOINT,
      credentials: process.env.S3_ACCESS_KEY_ID
        ? {
            accessKeyId: process.env.S3_ACCESS_KEY_ID,
            secretAccessKey: process.env.S3_SECRET_ACCESS_KEY ?? ""
          }
        : undefined
    });
    await this.s3Client.send(new PutObjectCommand({ Bucket: bucket, Key: key, Body: buffer, ContentType: contentType }));
    return `${process.env.S3_ENDPOINT ?? `https://${bucket}.s3.amazonaws.com`}/${key}`;
  }
}
