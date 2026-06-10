import NextAuth from "next-auth";
import Google from "next-auth/providers/google";

declare module "next-auth" {
  interface Session {
    googleIdToken?: string;
  }
}


const ALLOWED_EMAIL = process.env.ALLOWED_ADMIN_EMAIL ?? "";
const googleId = process.env.GOOGLE_CLIENT_ID || undefined;
const googleSecret = process.env.GOOGLE_CLIENT_SECRET || undefined;

export const { handlers, auth, signIn, signOut } = NextAuth({
  secret: process.env.AUTH_SECRET,
  providers: [
    ...(googleId && googleSecret
      ? [Google({ clientId: googleId, clientSecret: googleSecret })]
      : [])
  ],
  callbacks: {
    async signIn({ profile }) {
      if (!ALLOWED_EMAIL) return false;
      return profile?.email === ALLOWED_EMAIL;
    },
    async jwt({ token, account }) {
      if (account?.id_token) {
        token.googleIdToken = account.id_token as string;
      }
      return token;
    },
    async session({ session, token }) {
      session.googleIdToken = (token.googleIdToken as string | undefined);
      return session;
    }
  },
  pages: {
    signIn: "/login",
    error: "/login"
  }
});
