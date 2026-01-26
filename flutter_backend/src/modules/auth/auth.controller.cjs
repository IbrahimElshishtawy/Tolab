const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { prisma } = require("../../prisma.cjs");
const { env } = require("../../config/env.cjs");

function signToken(user) {
  return jwt.sign({ id: user.id, role: user.role }, env.JWT_SECRET, { expiresIn: "7d" });
}

// POST /auth/student-login
// body: { nationalId, seatNumber }
async function studentLogin(req, res) {
  try {
    const { nationalId, seatNumber } = req.body;

    if (!nationalId || !seatNumber) {
      return res.status(400).json({ message: "nationalId and seatNumber are required" });
    }
    if (!/^\d{14}$/.test(nationalId)) {
      return res.status(400).json({ message: "Invalid nationalId (must be 14 digits)" });
    }

    const user = await prisma.user.findUnique({
      where: { nationalId_seatNumber: { nationalId, seatNumber } },
      include: { student: true },
    });

    if (!user) return res.status(404).json({ message: "Student not found" });
    if (!user.isActive) return res.status(403).json({ message: "Account disabled" });
    if (user.role !== "STUDENT") return res.status(403).json({ message: "Not a student account" });

    if (user.student?.academicStatus === "SUSPENDED") {
      return res.status(403).json({ message: "Access denied" });
    }

    const token = signToken(user);
    return res.json({
      token,
      role: user.role,
      user: { id: user.id, nationalId: user.nationalId, seatNumber: user.seatNumber },
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: "Server Error" });
  }
}

// POST /auth/staff-login
// body: { email, password }
async function staffLogin(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) return res.status(400).json({ message: "email and password are required" });

    const user = await prisma.user.findUnique({ where: { email } });

    if (!user) return res.status(404).json({ message: "User not found" });
    if (!user.isActive) return res.status(403).json({ message: "Account disabled" });
    if (!(user.role === "DOCTOR" || user.role === "ASSISTANT")) {
      return res.status(403).json({ message: "Not a staff account" });
    }

    const ok = await bcrypt.compare(password, user.passwordHash || "");
    if (!ok) return res.status(401).json({ message: "Invalid credentials" });

    const token = signToken(user);
    return res.json({ token, role: user.role, user: { id: user.id, email: user.email } });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: "Server Error" });
  }
}

// POST /auth/admin-login
// body: { username, password }
async function adminLogin(req, res) {
  try {
    const { username, password } = req.body;

    if (!username || !password) return res.status(400).json({ message: "username and password are required" });

    const user = await prisma.user.findUnique({ where: { username } });

    if (!user) return res.status(404).json({ message: "User not found" });
    if (!user.isActive) return res.status(403).json({ message: "Account disabled" });
    if (user.role !== "ADMIN") return res.status(403).json({ message: "Not an admin account" });

    const ok = await bcrypt.compare(password, user.passwordHash || "");
    if (!ok) return res.status(401).json({ message: "Invalid credentials" });

    const token = signToken(user);
    return res.json({ token, role: user.role, user: { id: user.id, username: user.username } });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: "Server Error" });
  }
}

module.exports = { studentLogin, staffLogin, adminLogin };
