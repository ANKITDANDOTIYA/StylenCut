const pool = require("../config/db");

const findUserByEmail = async (email) => {

    const result = await pool.query(
        "SELECT * FROM users WHERE email = $1",
        [email]
    );

    return result.rows[0];
}

const createUser = async (name,
    email,
    password,
    role
)        => {

    const result = await pool.query(
        `INSERT INTO users 
        (name, email, password, role)
        VALUES ($1, $2, $3, $4) RETURNING *`,
        [name, email, password, role]
    );
    return result.rows[0];
 };

const getBarbersBySalon = async (salonId) => {
    const result = await pool.query(
        "SELECT id, name, email, role, salon_id FROM users WHERE salon_id = $1 AND role = 'barber'",
        [salonId]
    );
    return result.rows;
};

const assignBarberToSalon = async (userId, salonId) => {
    const result = await pool.query(
        "UPDATE users SET salon_id = $1 WHERE id = $2 AND role = 'barber' RETURNING id, name, email, role, salon_id",
        [salonId, userId]
    );
    return result.rows[0];
};

const createBarberUser = async (name, email, password, salonId) => {
    const result = await pool.query(
        `INSERT INTO users 
        (name, email, password, role, salon_id)
        VALUES ($1, $2, $3, 'barber', $4) RETURNING id, name, email, role, salon_id`,
        [name, email, password, salonId]
    );
    return result.rows[0];
};

module.exports = {
    findUserByEmail,
    createUser,
    getBarbersBySalon,
    assignBarberToSalon,
    createBarberUser,
};