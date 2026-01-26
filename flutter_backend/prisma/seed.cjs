const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcrypt");

const prisma = new PrismaClient();

async function main() {
  await prisma.groupMember.deleteMany();
  await prisma.group.deleteMany();
  await prisma.scheduleSlot.deleteMany();
  await prisma.enrollment.deleteMany();
  await prisma.course.deleteMany();
  await prisma.student.deleteMany();
  await prisma.user.deleteMany();

  const adminPass = await bcrypt.hash("admin123", 10);
  const studentPass = await bcrypt.hash("student123", 10);

  await prisma.user.create({
    data: {
      nationalId: "11111111111111",
      factoryNumber: "F001",
      role: "ADMIN",
      isActive: true,
      passwordHash: adminPass,
    },
  });

  await prisma.user.create({
    data: {
      nationalId: "22222222222222",
      factoryNumber: "F002",
      role: "STUDENT",
      isActive: true,
      passwordHash: studentPass,
      student: {
        create: {
          academicStatus: "ACTIVE",
          level: 2,
          department: "CS",
        },
      },
    },
  });

  const course1 = await prisma.course.create({
    data: { code: "CS101", name: "Intro to CS", level: 1, department: "CS" },
  });

  const course2 = await prisma.course.create({
    data: { code: "CS201", name: "Data Structures", level: 2, department: "CS" },
  });

  await prisma.scheduleSlot.createMany({
    data: [
      { courseId: course1.id, dayOfWeek: 1, startMin: 540, endMin: 600 },
      { courseId: course2.id, dayOfWeek: 3, startMin: 600, endMin: 660 },
    ],
  });

  console.log("✅ Seed done");
  console.log("Admin login:", { nationalId: "11111111111111", factoryNumber: "F001", password: "admin123" });
  console.log("Student login:", { nationalId: "22222222222222", factoryNumber: "F002", password: "student123" });
}

main()
  .catch((e) => {
    console.error("Seed error:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
