const pool = require("../config/db");

// Create a new booking in the database. The function takes various parameters such as salonId, customerName, serviceName, bookingDate, bookingTime, price, and barberName. It inserts a new record into the bookings table and returns the newly created booking.

const createSalon = async (ownerId, name, data = {}) => {
    const { address = null, phone_number = null, opening_time = null, closing_time = null, thumbnail_pic = null } = data;
    const result = await pool.query(
        `INSERT INTO salons 
        (owner_id, name, address, phone_number, opening_time, closing_time, thumbnail_pic)
        VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
        [ownerId, name, address, phone_number, opening_time, closing_time, thumbnail_pic]
    );
    return result.rows[0];
};

// getAllSalons retrieves all salons from the database along with their average rating and review count. It performs a LEFT JOIN with the reviews table to calculate the average rating and count of reviews for each salon. The results are grouped by salon ID and ordered in ascending order.

const getAllSalons = async () => {
    const result = await pool.query(`
        SELECT s.*, 
               COALESCE(ROUND(AVG(r.salon_rating), 1), 4.5)::float as rating,
               COUNT(r.id)::int as reviews_count
        FROM salons s
        LEFT JOIN reviews r ON s.id = r.salon_id
        GROUP BY s.id
        ORDER BY s.id ASC
    `);
    return result.rows;
};

const updateSalon = async (id, ownerId, name, data = {}) => {
    const { address = null, phone_number = null, opening_time = null, closing_time = null, thumbnail_pic = null } = data;
    const result = await pool.query(
        `UPDATE salons 
         SET name = $1, address = $2, phone_number = $3, opening_time = $4, closing_time = $5, thumbnail_pic = $6
         WHERE id = $7 AND owner_id = $8 RETURNING *`,
        [name, address, phone_number, opening_time, closing_time, thumbnail_pic, id, ownerId]
    );
    return result.rows[0];
};

module.exports = {
    createSalon,
    getAllSalons,
    updateSalon,
};
