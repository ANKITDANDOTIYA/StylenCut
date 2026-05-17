const pool = require("../config/db");

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

const getAllSalons = async () => {
    const result = await pool.query(`SELECT * FROM salons`);
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
