const pool = require("./config/db");

async function checkColumns() {
    try {
        const res = await pool.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'users';
        `);
        console.log("Users table columns:");
        console.log(res.rows);
    } catch (e) {
        console.error("Failed to check columns:", e.message);
    } finally {
        process.exit();
    }
}

checkColumns();
