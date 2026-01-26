require("dotenv/config");
const { PrismaClient } = require("@prisma/client");
const { Pool } = require("pg");
const { PrismaPg } = require("@prisma/adapter-pg");
const bcrypt = require("bcrypt");

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  // تنظيف البيانات (ترتيب مهم بسبب العلاقات)
  await prisma.groupMember.deleteMany();
  await prisma.group.deleteMany();
  await prisma.scheduleSlot.deleteMany();
  await prisma.enrollment.deleteMany();
  await prisma.course.deleteMany();
  await prisma.student.deleteMany();
  await prisma.user.deleteMany();

  // Passwords
  const adminPass = await bcrypt.hash("admin123", 10);
  const doctorPass = await bcrypt.hash("doctor123", 10);
  const assistantPass = await bcrypt.hash("assistant123", 10);

  // ✅ Admin (username + password)
  const admin = await prisma.user.create({
    data: {
      username: "admin",
      role: "ADMIN",
      isActive: true,
      passwordHash: adminPass,
    },
  });

  // ✅ Doctor (email + password)
  const doctor = await prisma.user.create({
    data: {
      email: "doctor@university.edu",
      role: "DOCTOR",
      isActive: true,
      passwordHash: doctorPass,
    },
  });

  // ✅ Assistant (email + password)
  const assistant = await prisma.user.create({
    data: {
      email: "assistant@university.edu",
      role: "ASSISTANT",
      isActive: true,
      passwordHash: assistantPass,
    },
  });

  // ✅ Student (nationalId + seatNumber)  — بدون password
  const studentUser = await prisma.user.create({
    data: {
      nationalId: "22222222222222",
      seatNumber: "S001",
      role: "STUDENT",
      isActive: true,
      student: {
        create: {
          academicStatus: "ACTIVE",
          level: 2,
          department: "CS",
        },
      },
    },
    include: { student: true },
  });

  // Courses + schedule
  const c1 = await prisma.course.create({
    data: { code: "CS101", name: "Intro to CS", level: 1, department: "CS" },
  });
  const c2 = await prisma.course.create({
    data: { code: "CS201", name: "Data Structures", level: 2, department: "CS" },
  });

  await prisma.scheduleSlot.createMany({
    data: [
      { courseId: c1.id, dayOfWeek: 1, startMin: 540, endMin: 600 }, // Mon 9-10
      { courseId: c2.id, dayOfWeek: 3, startMin: 600, endMin: 660 }, // Wed 10-11
    ],
  });

  console.log("✅ Seed done");
  console.log("ADMIN login:", { username: "admin", password: "admin123" });
  console.log("DOCTOR login:", { email: "doctor@university.edu", password: "doctor123" });
  console.log("ASSISTANT login:", { email: "assistant@university.edu", password: "assistant123" });
  console.log("STUDENT login:", { nationalId: "22222222222222", seatNumber: "S001" });

  console.log("IDs:", { adminId: admin.id, doctorId: doctor.id, assistantId: assistant.id, studentUserId: studentUser.id });
}

main()
  .catch((e) => {
    console.error("Seed error:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
