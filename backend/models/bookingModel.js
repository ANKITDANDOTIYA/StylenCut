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
        `SELECT * FROM bookings WHERE salon_id = $1 ORDER BY created_at DESC`,
        [salonId]
    );
    return result.rows;
};

const getBookingsByCustomer = async (customerName) => {
    const result = await pool.query(
        `SELECT b.*, s.name as salon_name 
         FROM bookings b
         LEFT JOIN salons s ON b.salon_id = s.id
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
