const express = require("express");
const cors = require("cors");

const authRoutes = require("./modules/auth/auth.routes.cjs");
const adminRoutes = require("./modules/admin/admin.routes.cjs");
const studentRoutes = require("./modules/student/student.routes.cjs");

const app = express();
app.use(cors());
app.use(express.json());

app.get("/", (req, res) => res.send("API is running ✅"));

app.use("/auth", authRoutes);
app.use("/admin", adminRoutes);
app.use("/student", studentRoutes);

module.exports = app;
