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

        // Add experience to users
        await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS experience INTEGER;`);
        console.log("Added experience to users.");

        // Add profile_pic to users
        await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_pic TEXT;`);
        console.log("Added profile_pic to users.");

        // Add status and details to users (for barbers)
        await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'Free';`);
        await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS details TEXT;`);
        console.log("Added status and details columns to users.");

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
                status VARCHAR(50) DEFAULT 'Pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log("Created bookings table successfully.");

        // Alter to add status if not exists (for existing tables)
        await pool.query(`ALTER TABLE bookings ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'Pending';`);
        console.log("Added status column to bookings if not exists.");

        // Create reviews table
        await pool.query(`
            CREATE TABLE IF NOT EXISTS reviews (
                id SERIAL PRIMARY KEY,
                salon_id INTEGER REFERENCES salons(id) ON DELETE CASCADE,
                barber_name VARCHAR(255) NOT NULL,
                customer_name VARCHAR(255) NOT NULL,
                salon_rating INTEGER CHECK (salon_rating >= 1 AND salon_rating <= 5),
                barber_rating INTEGER CHECK (barber_rating >= 1 AND barber_rating <= 5),
                salon_review TEXT,
                barber_review TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log("Created reviews table successfully.");

        console.log("Migration completed successfully.");
    } catch (e) {
        console.error("Migration failed:", e.message);
    } finally {
        process.exit();
    }
}

migrate();
