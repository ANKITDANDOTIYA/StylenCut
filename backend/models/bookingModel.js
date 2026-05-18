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

module.exports = {
    createBooking,
    getBookingsBySalon,
};
