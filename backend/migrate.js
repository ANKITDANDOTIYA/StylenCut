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

        // Create bookings table
        await pool.query(`
            CREATE TABLE IF NOT EXISTS bookings (
                id SERIAL PRIMARY KEY,
                salon_id INTEGER REFERENCES salons(id) ON DELETE CASCADE,
                customer_name VARCHAR(255) NOT NULL,
                service_name VARCHAR(255) NOT NULL,
                booking_date VARCHAR(100) NOT NULL,
                booking_time VARCHAR(100) NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                barber_name VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log("Created bookings table successfully.");

        console.log("Migration completed successfully.");
    } catch (e) {
        console.error("Migration failed:", e.message);
    } finally {
        process.exit();
    }
}

migrate();
