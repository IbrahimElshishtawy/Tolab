require("dotenv/config");
const app = require("./app.cjs");
const { pool } = require("./prisma.cjs");

const port = process.env.PORT || 3000;

app.listen(port, () => console.log(`API running on http://localhost:${port}`));

process.on("SIGINT", async () => {
  await pool.end();
  process.exit(0);
});
