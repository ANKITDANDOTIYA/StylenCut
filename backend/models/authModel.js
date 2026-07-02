const pool = require("../config/db");

const findUserByEmail = async (email) => {

    const result = await pool.query(
        "SELECT * FROM users WHERE email = $1",
        [email]
    );

    return result.rows[0];
}

// RETURNING * is used to return the newly created user record after insertion

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

//  getBarberBySaloon function retrieves all barbers associated with a specific salon, along with their average ratings and the number of completed bookings (cuttings) they have performed. It uses SQL joins to combine data from the users, reviews, and bookings tables, filtering for users with the role of 'barber' and grouping the results by user ID. The function returns an array of barber objects with their details, ratings, and cutting counts.
const getBarbersBySalon = async (salonId) => {
    const result = await pool.query(
        `SELECT u.id, u.name, u.email, u.role, u.salon_id, u.experience, u.profile_pic, u.status, u.details,
                COALESCE(ROUND(AVG(r.barber_rating), 1), 5.0)::float as rating,
                COUNT(DISTINCT b.id)::int as cuttings_count
         FROM users u
         LEFT JOIN reviews r ON u.name = r.barber_name AND u.salon_id = r.salon_id
         LEFT JOIN bookings b ON u.name = b.barber_name AND u.salon_id = b.salon_id AND b.status = 'Completed'
         WHERE u.salon_id = $1 AND u.role = 'barber'
         GROUP BY u.id, u.status, u.details
         ORDER BY u.id ASC`,
        [salonId]
    );
    return result.rows;
};

const assignBarberToSalon = async (userId, salonId) => {
    const result = await pool.query(
        "UPDATE users SET salon_id = $1 WHERE id = $2 AND role = 'barber' RETURNING id, name, email, role, salon_id, experience, profile_pic, status, details",
        [salonId, userId]
    );
    return result.rows[0];
};

const createBarberUser = async (name, email, password, salonId, experience = null, profilePic = null) => {
    const result = await pool.query(
        `INSERT INTO users 
        (name, email, password, role, salon_id, experience, profile_pic, status)
        VALUES ($1, $2, $3, 'barber', $4, $5, $6, 'Free') RETURNING id, name, email, role, salon_id, experience, profile_pic, status, details`,
        [name, email, password, salonId, experience, profilePic]
    );
    return result.rows[0];
};

// Update the profile picture of a user by their user ID. The function takes the user ID and the new profile picture URL as parameters, updates the corresponding record in the users table, and returns the updated user record.
const updateUserProfilePic = async (userId, profilePic) => {
    const result = await pool.query(
        "UPDATE users SET profile_pic = $1 WHERE id = $2 RETURNING *",
        [profilePic, userId]
    );
    return result.rows[0];
};

// Update profile

const updateUserProfilePicByEmail = async (email, profilePic) => {
    const result = await pool.query(
        "UPDATE users SET profile_pic = $1 WHERE email = $2 RETURNING *",
        [profilePic, email]
    );
    return result.rows[0];
};

const updateUserName = async (userId, name) => {
    const result = await pool.query(
        "UPDATE users SET name = $1 WHERE id = $2 RETURNING *",
        [name, userId]
    );
    return result.rows[0];
};

// Exxport the functions

module.exports = {
    findUserByEmail,
    createUser,
    getBarbersBySalon,
    assignBarberToSalon,
    createBarberUser,
    updateUserProfilePic,
    updateUserProfilePicByEmail,
    updateUserName,
};