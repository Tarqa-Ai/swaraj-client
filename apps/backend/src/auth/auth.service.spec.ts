import bcrypt from "bcryptjs";
import { AuthService } from "./auth.service";
import { OtpProvider } from "./otp.provider";

describe("AuthService refresh token sessions", () => {
  const jwt = {
    signAsync: jest.fn(),
    verifyAsync: jest.fn()
  };
  const prisma = {
    user: {
      findUnique: jest.fn(),
      upsert: jest.fn(),
      update: jest.fn()
    },
    adminUser: {
      findUnique: jest.fn()
    },
    otpChallenge: {
      findFirst: jest.fn(),
      update: jest.fn(),
      create: jest.fn()
    }
  };
  const otpProvider: OtpProvider = { send: jest.fn() };

  beforeEach(() => {
    jest.clearAllMocks();
    process.env.JWT_ACCESS_SECRET = "access";
    process.env.JWT_REFRESH_SECRET = "refresh";
  });

  it("hashes and stores the refresh token when OTP is verified", async () => {
    prisma.otpChallenge.findFirst.mockResolvedValue({ id: "otp-1", attempts: 0, codeHash: await bcrypt.hash("123456", 4) });
    prisma.otpChallenge.update.mockResolvedValue({});
    prisma.user.upsert.mockResolvedValue({ id: "user-1", phone: "+919999999999" });
    jwt.signAsync.mockResolvedValueOnce("access-token").mockResolvedValueOnce("refresh-token");
    prisma.user.update.mockImplementation(async ({ data }: { data: { refreshTokenHash: string } }) => ({
      id: "user-1",
      phone: "+919999999999",
      refreshTokenHash: data.refreshTokenHash
    }));

    const service = new AuthService(prisma as never, jwt as never, otpProvider);
    const result = await service.verifyOtp({ phone: "+919999999999", code: "123456" });

    expect(result.refreshToken).toBe("refresh-token");
    const storedHash = prisma.user.update.mock.calls[0][0].data.refreshTokenHash as string;
    await expect(bcrypt.compare("refresh-token", storedHash)).resolves.toBe(true);
  });

  it("rejects refresh tokens that do not match the stored hash", async () => {
    jwt.verifyAsync.mockResolvedValue({ id: "user-1", role: "STUDENT" });
    prisma.user.findUnique.mockResolvedValue({ id: "user-1", phone: "+919999999999", refreshTokenHash: await bcrypt.hash("other-token", 4) });

    const service = new AuthService(prisma as never, jwt as never, otpProvider);
    await expect(service.refresh("refresh-token")).rejects.toThrow("Invalid refresh token");
  });

  it("clears the student refresh token hash on logout", async () => {
    prisma.user.update.mockResolvedValue({});
    const service = new AuthService(prisma as never, jwt as never, otpProvider);

    await expect(service.logout("user-1", "STUDENT")).resolves.toEqual({ loggedOut: true });
    expect(prisma.user.update).toHaveBeenCalledWith({ where: { id: "user-1" }, data: { refreshTokenHash: null } });
  });
});
