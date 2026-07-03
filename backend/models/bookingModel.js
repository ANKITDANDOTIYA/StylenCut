const pool = require("../config/db");

const createBooking = async (salonId, customerName, serviceName, bookingDate, bookingTime, price, barberName) => {
    const result = await pool.query(
        `INSERT INTO bookings 
        (salon_id, customer_name, service_name, booking_date, booking_time, price, barber_name)
        VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
        [salonId, customerName, serviceName, bookingDate, bookingTime, price, barberName]
    );
    return result.rows[0];
};

const getBookingsBySalon = async (salonId) => {
    const result = await pool.query(
        `SELECT b.*, u.profile_pic as customer_profile_pic 
         FROM bookings b
         LEFT JOIN users u ON b.customer_name = u.name
         WHERE b.salon_id = $1 
         ORDER BY b.created_at DESC`,
        [salonId]
    );
    return result.rows;
};

// Get all bookings for a specific customer by their name. The function takes the customer's name as a parameter, queries the bookings table to retrieve all bookings associated with that customer, and returns the results.

const getBookingsByCustomer = async (customerName) => {
    const result = await pool.query(
        `SELECT b.*, s.name as salon_name, u.profile_pic as barber_profile_pic
         FROM bookings b
         LEFT JOIN salons s ON b.salon_id = s.id
         LEFT JOIN users u ON b.barber_name = u.name AND u.role = 'barber' AND b.salon_id = u.salon_id
         WHERE b.customer_name = $1
         ORDER BY b.created_at DESC`,
        [customerName]
    );
    return result.rows;
};

const updateBookingStatus = async (bookingId, status) => {
    const result = await pool.query(
        `UPDATE bookings SET status = $1 WHERE id = $2 RETURNING *`,
        [status, bookingId]
    );
    return result.rows[0];
};

module.exports = {
    createBooking,
    getBookingsBySalon,
    getBookingsByCustomer,
    updateBookingStatus,
};
