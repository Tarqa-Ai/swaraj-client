import { DeleteObjectCommand, GetObjectCommand, PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { Injectable, NotFoundException, ServiceUnavailableException } from "@nestjs/common";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { Readable } from "node:stream";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class FileStorageService {
  constructor(private readonly prisma: PrismaService) {}

  private s3Client: S3Client | null = null;

  async put(key: string, buffer: Buffer, contentType: string) {
    const url = process.env.STORAGE_DRIVER === "s3" ? await this.putS3(key, buffer, contentType) : await this.putLocal(key, buffer);
    await this.prisma.mediaAsset.upsert({
      where: { key },
      update: { url, mimeType: contentType, sizeBytes: buffer.byteLength },
      create: { key, url, mimeType: contentType, sizeBytes: buffer.byteLength }
    });
    return url;
  }

  async get(key: string) {
    const asset = await this.prisma.mediaAsset.findUnique({ where: { key } });
    if (!asset) throw new NotFoundException("Media asset not found");
    if (process.env.STORAGE_DRIVER === "s3") {
      const body = await this.getS3(key);
      return { ...asset, body };
    }
    return { ...asset, body: await this.getLocal(key) };
  }

  async delete(key: string) {
    if (process.env.STORAGE_DRIVER === "s3") {
      await this.deleteS3(key);
    } else {
      await this.deleteLocal(key);
    }
    await this.prisma.mediaAsset.deleteMany({ where: { key } });
    return { deleted: true };
  }

  private async putLocal(key: string, buffer: Buffer) {
    const root = process.env.LOCAL_STORAGE_ROOT ?? "./uploads";
    const target = join(process.cwd(), root, key);
    await mkdir(dirname(target), { recursive: true });
    await writeFile(target, buffer);
    return `/uploads/${key}`;
  }

  private async getLocal(key: string) {
    const root = process.env.LOCAL_STORAGE_ROOT ?? "./uploads";
    return readFile(join(process.cwd(), root, key));
  }

  private async deleteLocal(key: string) {
    const root = process.env.LOCAL_STORAGE_ROOT ?? "./uploads";
    await rm(join(process.cwd(), root, key), { force: true });
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

  private async getS3(key: string) {
    const bucket = process.env.S3_BUCKET;
    if (!bucket) throw new ServiceUnavailableException("S3 storage is not configured");
    const response = await this.client().send(new GetObjectCommand({ Bucket: bucket, Key: key }));
    if (!response.Body) throw new NotFoundException("Media asset not found");
    return streamToBuffer(response.Body as Readable);
  }

  private async deleteS3(key: string) {
    const bucket = process.env.S3_BUCKET;
    if (!bucket) throw new ServiceUnavailableException("S3 storage is not configured");
    await this.client().send(new DeleteObjectCommand({ Bucket: bucket, Key: key }));
  }

  private client() {
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
    return this.s3Client;
  }
}

async function streamToBuffer(stream: Readable) {
  const chunks: Buffer[] = [];
  for await (const chunk of stream) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  return Buffer.concat(chunks);
}
