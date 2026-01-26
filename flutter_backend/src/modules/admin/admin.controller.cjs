async function ping(req, res) {
  return res.json({ message: "Admin OK ✅", user: req.user });
}

module.exports = { ping };
