const router = require("express").Router();
const auth = require("../../middleware/auth.cjs");
const requireRole = require("../../middleware/requireRole.cjs");

// 👇 لو اسم الملف عندك auth.controller.cjs جوه admin، استخدمه مؤقتًا
const c = require("./admin.controller.cjs");

router.get("/ping", auth, requireRole("ADMIN"), c.ping);

module.exports = router;
