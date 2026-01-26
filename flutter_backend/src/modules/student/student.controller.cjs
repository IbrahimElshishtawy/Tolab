async function ping(req, res) {
  return res.json({ message: "Student OK ✅", user: req.user });
}

module.exports = { ping };
