const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

(async () => {
  const users = await prisma.user.findMany({ include: { student: true } });
  console.log(users);
  await prisma.$disconnect();
})();
