const pool = require("./config/db");

async function migrate() {
    try {
        console.log("Starting migration...");
        // Add thumbnail_pic to salons
        await pool.query(`ALTER TABLE salons ADD COLUMN IF NOT EXISTS thumbnail_pic TEXT;`);
        console.log("Added thumbnail_pic to salons.");
        
        // Add salon_id to users
        await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS salon_id INTEGER REFERENCES salons(id) ON DELETE SET NULL;`);
        console.log("Added salon_id to users.");

        console.log("Migration completed successfully.");
    } catch (e) {
        console.error("Migration failed:", e.message);
    } finally {
        process.exit();
    }
}

migrate();
