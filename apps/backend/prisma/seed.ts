import { PrismaClient, LessonType, QuizQuestionType, ChallengeCategory } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const schools = [
    { name: "Government Senior Secondary School, Jaipur", district: "Jaipur", code: "RJ-JAI-001" },
    { name: "Government Girls Senior Secondary School, Kota", district: "Kota", code: "RJ-KOT-001" },
    { name: "Adarsh Vidya Mandir, Udaipur", district: "Udaipur", code: "RJ-UDP-001" }
  ];

  for (const school of schools) {
    await prisma.school.upsert({
      where: { code: school.code },
      update: school,
      create: school
    });
  }

  await prisma.adminUser.upsert({
    where: { email: "admin@swaraj.local" },
    update: {},
    create: {
      email: "admin@swaraj.local",
      name: "SWARAJ Admin",
      passwordHash: await bcrypt.hash("ChangeMe123!", 12)
    }
  });

  const modules = [
    {
      slug: "constitution-of-india",
      titleEn: "Constitution of India",
      titleHi: "भारत का संविधान",
      descriptionEn: "Learn the ideas, rights, and duties that guide India.",
      descriptionHi: "भारत को दिशा देने वाले विचारों, अधिकारों और कर्तव्यों को समझें.",
      order: 1,
      lessons: [
        ["What is a Constitution?", "संविधान क्या है?", "A constitution is the rulebook for a country. It explains how government works and what rights people have.", "संविधान देश की नियम-पुस्तक है. यह बताता है कि सरकार कैसे काम करेगी और नागरिकों के अधिकार क्या हैं."],
        ["Fundamental Rights", "मौलिक अधिकार", "Fundamental Rights protect dignity, equality, freedom, and fairness for every citizen.", "मौलिक अधिकार हर नागरिक की गरिमा, समानता, स्वतंत्रता और न्याय की रक्षा करते हैं."]
      ]
    },
    {
      slug: "structure-of-government",
      titleEn: "Structure of Government",
      titleHi: "सरकार की संरचना",
      descriptionEn: "Understand Parliament, state government, courts, and local bodies.",
      descriptionHi: "संसद, राज्य सरकार, अदालतों और स्थानीय निकायों को समझें.",
      order: 2,
      lessons: [
        ["Three Levels of Government", "सरकार के तीन स्तर", "India has union, state, and local governments so decisions can be made closer to people.", "भारत में केंद्र, राज्य और स्थानीय सरकारें हैं ताकि फैसले लोगों के करीब लिए जा सकें."],
        ["What does an MLA do?", "विधायक क्या करता है?", "An MLA represents people in the State Assembly and raises local issues.", "विधायक विधानसभा में लोगों का प्रतिनिधित्व करता है और स्थानीय मुद्दे उठाता है."]
      ]
    },
    {
      slug: "elections-and-voting",
      titleEn: "Elections & Voting",
      titleHi: "चुनाव और मतदान",
      descriptionEn: "Explore elections, voting rights, and responsible participation.",
      descriptionHi: "चुनाव, मतदान अधिकार और जिम्मेदार भागीदारी को जानें.",
      order: 3,
      lessons: [
        ["Why Voting Matters", "मतदान क्यों महत्वपूर्ण है", "Voting lets citizens choose representatives and shape public decisions.", "मतदान नागरिकों को प्रतिनिधि चुनने और सार्वजनिक फैसलों को प्रभावित करने का अवसर देता है."],
        ["Election Commission", "चुनाव आयोग", "The Election Commission conducts free and fair elections across India.", "चुनाव आयोग भारत में स्वतंत्र और निष्पक्ष चुनाव कराता है."]
      ]
    }
  ];

  for (const moduleSeed of modules) {
    const module = await prisma.module.upsert({
      where: { slug: moduleSeed.slug },
      update: {
        titleEn: moduleSeed.titleEn,
        titleHi: moduleSeed.titleHi,
        descriptionEn: moduleSeed.descriptionEn,
        descriptionHi: moduleSeed.descriptionHi,
        order: moduleSeed.order
      },
      create: {
        slug: moduleSeed.slug,
        titleEn: moduleSeed.titleEn,
        titleHi: moduleSeed.titleHi,
        descriptionEn: moduleSeed.descriptionEn,
        descriptionHi: moduleSeed.descriptionHi,
        order: moduleSeed.order
      }
    });

    for (const [index, lesson] of moduleSeed.lessons.entries()) {
      await prisma.lesson.upsert({
        where: { id: `${moduleSeed.slug}-lesson-${index + 1}` },
        update: {},
        create: {
          id: `${moduleSeed.slug}-lesson-${index + 1}`,
          moduleId: module.id,
          type: LessonType.TEXT,
          titleEn: lesson[0],
          titleHi: lesson[1],
          bodyEn: lesson[2],
          bodyHi: lesson[3],
          order: index + 1
        }
      });
    }

    const quiz = await prisma.quiz.upsert({
      where: { id: `${moduleSeed.slug}-quiz` },
      update: {},
      create: {
        id: `${moduleSeed.slug}-quiz`,
        moduleId: module.id,
        titleEn: `${moduleSeed.titleEn} Check`,
        titleHi: `${moduleSeed.titleHi} अभ्यास`
      }
    });

    await prisma.quizQuestion.upsert({
      where: { id: `${moduleSeed.slug}-q1` },
      update: {},
      create: {
        id: `${moduleSeed.slug}-q1`,
        quizId: quiz.id,
        type: QuizQuestionType.MCQ,
        promptEn: "Which option best describes civic participation?",
        promptHi: "नागरिक भागीदारी का सबसे अच्छा वर्णन कौन सा है?",
        options: ["Following public issues", "Ignoring elections", "Breaking rules", "Avoiding community work"],
        answer: "Following public issues",
        explanationEn: "Civic participation means taking informed part in public life.",
        explanationHi: "नागरिक भागीदारी का मतलब सार्वजनिक जीवन में जानकारी के साथ भाग लेना है.",
        order: 1
      }
    });
  }

  await prisma.dailyChallenge.upsert({
    where: { challengeDate: new Date("2026-05-18T00:00:00.000Z") },
    update: {},
    create: {
      challengeDate: new Date("2026-05-18T00:00:00.000Z"),
      category: ChallengeCategory.CIVIC_AWARENESS,
      questions: [
        {
          id: "dc-1",
          promptEn: "How many houses does the Indian Parliament have?",
          promptHi: "भारतीय संसद के कितने सदन हैं?",
          options: ["One", "Two", "Three", "Four"],
          answer: "Two",
          explanationEn: "Parliament has Lok Sabha and Rajya Sabha.",
          explanationHi: "संसद में लोकसभा और राज्यसभा होती हैं."
        },
        {
          id: "dc-2",
          promptEn: "True or false: Voting is a way citizens participate in democracy.",
          promptHi: "सही या गलत: मतदान लोकतंत्र में नागरिक भागीदारी का तरीका है.",
          options: ["True", "False"],
          answer: "True",
          explanationEn: "Voting helps choose representatives.",
          explanationHi: "मतदान प्रतिनिधियों को चुनने में मदद करता है."
        },
        {
          id: "dc-3",
          promptEn: "Which body conducts national elections in India?",
          promptHi: "भारत में राष्ट्रीय चुनाव कौन कराता है?",
          options: ["Election Commission", "Supreme Court", "NITI Aayog", "Municipality"],
          answer: "Election Commission",
          explanationEn: "The Election Commission conducts elections.",
          explanationHi: "चुनाव आयोग चुनाव कराता है."
        }
      ]
    }
  });

  await prisma.debate.createMany({
    data: [
      {
        topicEn: "Should voting age be 16?",
        topicHi: "क्या मतदान की उम्र 16 वर्ष होनी चाहिए?",
        forSummaryEn: "Supporters say younger citizens learn responsibility early and are affected by policy.",
        forSummaryHi: "समर्थकों का कहना है कि युवा नागरिक जल्दी जिम्मेदारी सीखते हैं और नीतियों से प्रभावित होते हैं.",
        againstSummaryEn: "Opponents say voting needs maturity, wider awareness, and stable judgment.",
        againstSummaryHi: "विरोधियों का कहना है कि मतदान के लिए परिपक्वता, व्यापक जानकारी और स्थिर निर्णय जरूरी है.",
        isActive: true
      },
      {
        topicEn: "Should civic education be mandatory?",
        topicHi: "क्या नागरिक शिक्षा अनिवार्य होनी चाहिए?",
        forSummaryEn: "It can help students understand rights, duties, and public institutions.",
        forSummaryHi: "यह छात्रों को अधिकार, कर्तव्य और सार्वजनिक संस्थाओं को समझने में मदद कर सकती है.",
        againstSummaryEn: "Schools may need flexibility to balance workload and local priorities.",
        againstSummaryHi: "स्कूलों को पाठ्यभार और स्थानीय प्राथमिकताओं में संतुलन के लिए लचीलापन चाहिए.",
        isActive: false
      }
    ],
    skipDuplicates: true
  });

  const achievements = [
    ["CONSTITUTION_MASTER", "Constitution Master", "संविधान मास्टर", "Completed the Constitution module.", "संविधान मॉड्यूल पूरा किया.", "book-open"],
    ["DEBATE_CHAMPION", "Debate Champion", "वाद-विवाद चैंपियन", "Participated in a civic debate.", "नागरिक वाद-विवाद में भाग लिया.", "messages-square"],
    ["CIVIC_HERO", "Civic Hero", "नागरिक हीरो", "Completed daily civic challenges.", "दैनिक नागरिक चुनौतियां पूरी कीं.", "shield"],
    ["DEMOCRACY_DEFENDER", "Democracy Defender", "लोकतंत्र रक्षक", "Completed the core civic journey.", "मुख्य नागरिक यात्रा पूरी की.", "award"]
  ];

  for (const [code, titleEn, titleHi, descriptionEn, descriptionHi, icon] of achievements) {
    await prisma.achievement.upsert({
      where: { code },
      update: {},
      create: { code, titleEn, titleHi, descriptionEn, descriptionHi, icon }
    });
  }
}

main()
  .finally(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
