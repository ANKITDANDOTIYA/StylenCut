const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({

  user: "postgres",

  host: "localhost",

  database: "styleNcut",

  password: process.env.POSTGRE_PASSWORD,

  port: process.env.POSTGRE_PORT,
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