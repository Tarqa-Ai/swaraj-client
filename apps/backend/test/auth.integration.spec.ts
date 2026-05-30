import { Test } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import request from "supertest";
import bcrypt from "bcryptjs";
import { AppModule } from "../src/app.module";
import { PrismaService } from "../src/prisma/prisma.service";

describe("Auth flow (integration)", () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const phone = "+919000000001";

  beforeAll(async () => {
    process.env.JWT_ACCESS_SECRET = "test-access-secret-minimum-32-characters";
    process.env.JWT_REFRESH_SECRET = "test-refresh-secret-minimum-32-characters";

    const module = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = module.createNestApplication();
    app.setGlobalPrefix("api");
    await app.init();
    prisma = module.get(PrismaService);
  });

  afterAll(async () => {
    await prisma.otpChallenge.deleteMany({ where: { phone } });
    await prisma.user.deleteMany({ where: { phone } });
    await app.close();
  });

  it("rejects verify-otp when no challenge exists", async () => {
    const res = await request(app.getHttpServer())
      .post("/api/auth/verify-otp")
      .send({ phone, code: "000000" });
    expect(res.status).toBe(400);
  });

  it("issues tokens after a valid OTP challenge", async () => {
    const code = "123456";
    const codeHash = await bcrypt.hash(code, 4);
    await prisma.otpChallenge.create({
      data: { phone, codeHash, expiresAt: new Date(Date.now() + 300_000) }
    });

    const res = await request(app.getHttpServer())
      .post("/api/auth/verify-otp")
      .send({ phone, code });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty("accessToken");
    expect(res.body).toHaveProperty("refreshToken");
  });

  it("reaches /me with a valid access token", async () => {
    const code = "234567";
    const codeHash = await bcrypt.hash(code, 4);
    await prisma.otpChallenge.create({
      data: { phone, codeHash, expiresAt: new Date(Date.now() + 300_000) }
    });

    const loginRes = await request(app.getHttpServer())
      .post("/api/auth/verify-otp")
      .send({ phone, code });

    const { accessToken } = loginRes.body as { accessToken: string };

    const meRes = await request(app.getHttpServer())
      .get("/api/me")
      .set("Authorization", `Bearer ${accessToken}`);

    expect(meRes.status).toBe(200);
    expect(meRes.body).toHaveProperty("phone", phone);
  });

  it("issues new tokens via refresh", async () => {
    const code = "345678";
    const codeHash = await bcrypt.hash(code, 4);
    await prisma.otpChallenge.create({
      data: { phone, codeHash, expiresAt: new Date(Date.now() + 300_000) }
    });

    const loginRes = await request(app.getHttpServer())
      .post("/api/auth/verify-otp")
      .send({ phone, code });

    const { refreshToken } = loginRes.body as { refreshToken: string };

    const refreshRes = await request(app.getHttpServer())
      .post("/api/auth/refresh")
      .send({ refreshToken });

    expect(refreshRes.status).toBe(201);
    expect(refreshRes.body).toHaveProperty("accessToken");
  });

  it("blocks /me after logout", async () => {
    const code = "456789";
    const codeHash = await bcrypt.hash(code, 4);
    await prisma.otpChallenge.create({
      data: { phone, codeHash, expiresAt: new Date(Date.now() + 300_000) }
    });

    const loginRes = await request(app.getHttpServer())
      .post("/api/auth/verify-otp")
      .send({ phone, code });

    const { accessToken } = loginRes.body as { accessToken: string };

    await request(app.getHttpServer())
      .post("/api/auth/logout")
      .set("Authorization", `Bearer ${accessToken}`);

    const meRes = await request(app.getHttpServer())
      .get("/api/me")
      .set("Authorization", `Bearer ${accessToken}`);

    expect(meRes.status).toBe(401);
  });

  it("enforces 60-second OTP send cooldown", async () => {
    // First send — needs a clean state (no recent challenges)
    await prisma.otpChallenge.deleteMany({ where: { phone } });

    // Create a recent challenge to simulate cooldown
    await prisma.otpChallenge.create({
      data: {
        phone,
        codeHash: await bcrypt.hash("000000", 4),
        expiresAt: new Date(Date.now() + 300_000),
        createdAt: new Date()
      }
    });

    const res = await request(app.getHttpServer())
      .post("/api/auth/send-otp")
      .send({ phone });

    expect(res.status).toBe(400);
    expect(res.body.message).toMatch(/60 seconds/);
  });
});
