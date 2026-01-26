require("dotenv/config");
const express = require("express");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");

const { PrismaClient } = require("@prisma/client");
const { Pool } = require("pg");
const { PrismaPg } = require("@prisma/adapter-pg");

const app = express();
app.use(cors());
app.use(express.json());

// Prisma (Driver Adapter)
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

app.get("/", (req, res) => res.send("API is running ✅"));

// ✅ Login (طبقًا للفلو تشارت)
app.post("/auth/login", async (req, res) => {
  try {
    const { nationalId, factoryNumber, password } = req.body;

    // 1) Validate input
    if (!nationalId || !factoryNumber || !password) {
      return res.status(400).json({ message: "nationalId, factoryNumber, password are required" });
    }
    if (!/^\d{14}$/.test(nationalId)) {
      return res.status(400).json({ message: "Invalid National ID format (must be 14 digits)" });
    }

    // 2) Check user exists
    const user = await prisma.user.findUnique({
      where: { nationalId_factoryNumber: { nationalId, factoryNumber } },
      include: { student: true },
    });

    if (!user) return res.status(404).json({ message: "User Not Found" });

    // 3) Check account active
    if (!user.isActive) return res.status(403).json({ message: "Account Disabled" });

    // 4) Password check
    const ok = await bcrypt.compare(password, user.passwordHash || "");
    if (!ok) return res.status(401).json({ message: "Invalid Credentials" });

    // 5) Student extra check
    if (user.role === "STUDENT" && user.student?.academicStatus === "SUSPENDED") {
      return res.status(403).json({ message: "Access Denied" });
    }

    // 6) Create token
    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET || "secret",
      { expiresIn: "7d" }
    );

    return res.json({
      token,
      role: user.role,
      user: {
        id: user.id,
        nationalId: user.nationalId,
        factoryNumber: user.factoryNumber,
      },
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: "Server Error" });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`API running on http://localhost:${port}`));
