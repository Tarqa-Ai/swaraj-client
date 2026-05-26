import { NestFactory } from "@nestjs/core";
import { SwaggerModule, DocumentBuilder } from "@nestjs/swagger";
import helmet from "helmet";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true });
  app.use(helmet());
  app.setGlobalPrefix("api");
  app.enableCors({
    origin: process.env.ADMIN_ORIGIN?.split(",") ?? ["http://localhost:3000"],
    credentials: true
  });

  const config = new DocumentBuilder()
    .setTitle("SWARAJ API")
    .setDescription("REST API for the SWARAJ civic education platform.")
    .setVersion("0.1.0")
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api/docs", app, document);

  await app.listen(Number(process.env.PORT ?? 4000));
}

void bootstrap();
