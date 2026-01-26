const router = require("express").Router();
const c = require("./auth.controller.cjs");

router.post("/student-login", c.studentLogin);
router.post("/staff-login", c.staffLogin);
router.post("/admin-login", c.adminLogin);

module.exports = router;
