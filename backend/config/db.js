const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
  },
});

pool.connect()
  .then(() => {
    console.log("✅ PostgreSQL connected successfully");
  })
  .catch((err) => {
    console.log("❌ Database connection failed");
    console.log(err.message);
  });

module.exports = pool;