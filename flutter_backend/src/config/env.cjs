// src/config/env.cjs
require("dotenv/config");

function required(name) {
  const v = process.env[name];
  if (!v || String(v).trim() === "") {
    throw new Error(`Missing required env var: ${name}`);
  }
  return v;
}

const env = {
  NODE_ENV: process.env.NODE_ENV || "development",
  PORT: Number(process.env.PORT || 3000),

  // لازم
  DATABASE_URL: required("DATABASE_URL"),
  JWT_SECRET: required("JWT_SECRET"),
};

module.exports = { env, required };
