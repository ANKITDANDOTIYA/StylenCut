const pool = require("../config/db");

const createSalon = async (ownerId, name, data = {}) => {
    const { address = null, phone_number = null, opening_time = null, closing_time = null } = data;
    const result = await pool.query(
        `INSERT INTO salons 
        (owner_id, name, address, phone_number, opening_time, closing_time)
        VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
        [ownerId, name, address, phone_number, opening_time, closing_time]
    );
    return result.rows[0];
};

const getAllSalons = async () => {
    const result = await pool.query(`SELECT * FROM salons`);
    return result.rows;
};

module.exports = {
    createSalon,
    getAllSalons,
};
