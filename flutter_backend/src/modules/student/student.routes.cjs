const router = require("express").Router();
const auth = require("../../middleware/auth.cjs");
const requireRole = require("../../middleware/requireRole.cjs");
const c = require("./student.controller.cjs");

router.get("/ping", auth, requireRole("STUDENT"), c.ping);

module.exports = router;
