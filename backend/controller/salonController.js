const pool = require('../config/db');
const { getAllSalons, updateSalon } = require('../models/salonModel');
const { getBarbersBySalon, assignBarberToSalon, createBarberUser, findUserByEmail } = require('../models/authModel');
const { createBooking, getBookingsBySalon, getBookingsByCustomer, updateBookingStatus } = require('../models/bookingModel');
const bcrypt = require('bcryptjs');

exports.getAllSalons = async (req, res) => {
    try {
        const salons = await getAllSalons();
        res.status(200).json({
            success: true,
            salons,
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal Server Error",
            error: error.message
        });
    }
};

exports.updateSalonDetails = async (req, res) => {
    try {
        const salonId = req.params.id;
        const { ownerId, name, address, phone_number, opening_time, closing_time, thumbnail_pic } = req.body;
        
        const updated = await updateSalon(salonId, ownerId, name, { address, phone_number, opening_time, closing_time, thumbnail_pic });
        res.status(200).json({ success: true, salon: updated });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.getBarbers = async (req, res) => {
    try {
        const salonId = req.params.id;
        const barbers = await getBarbersBySalon(salonId);
        res.status(200).json({ success: true, barbers });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.assignBarber = async (req, res) => {
    try {
        const salonId = req.params.id;
        const { userId } = req.body;
        const barber = await assignBarberToSalon(userId, salonId);
        res.status(200).json({ success: true, barber });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.createBarber = async (req, res) => {
    try {
        const salonId = req.params.id;
        const { name, email, password, experience, profile_pic } = req.body;

        const existingUser = await findUserByEmail(email);
        if (existingUser) {
            return res.status(400).json({ success: false, message: "User Already Exists" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newBarber = await createBarberUser(
            name,
            email,
            hashedPassword,
            salonId,
            experience ? parseInt(experience) : null,
            profile_pic || null
        );
        res.status(201).json({ success: true, barber: newBarber });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.updateBarber = async (req, res) => {
    try {
        const { id: salonId, barberId } = req.params;
        const { name, email, experience, profile_pic, status, details } = req.body;

        const result = await pool.query(
            `UPDATE users 
             SET name = COALESCE($1, name), 
                 email = COALESCE($2, email), 
                 experience = COALESCE($3, experience), 
                 profile_pic = COALESCE($4, profile_pic),
                 status = COALESCE($5, status),
                 details = COALESCE($6, details)
             WHERE id = $7 AND salon_id = $8 AND role = 'barber'
             RETURNING id, name, email, role, salon_id, experience, profile_pic, status, details`,
            [name || null, email || null, experience ? parseInt(experience) : null, profile_pic || null, status || null, details || null, barberId, salonId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: "Barber not found in this salon" });
        }

        res.status(200).json({ success: true, barber: result.rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.getBookings = async (req, res) => {
    try {
        const salonId = req.params.id;
        const bookings = await getBookingsBySalon(salonId);
        res.status(200).json({ success: true, bookings });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.createBooking = async (req, res) => {
    try {
        const salonId = req.params.id;
        const { customerName, serviceName, bookingDate, bookingTime, price, barberName } = req.body;
        
        // Verify that the salon is open
        const salonQuery = await pool.query("SELECT is_open FROM salons WHERE id = $1", [salonId]);
        if (salonQuery.rows.length === 0) {
            return res.status(404).json({ success: false, message: "Salon not found" });
        }
        if (!salonQuery.rows[0].is_open) {
            return res.status(400).json({ success: false, message: "Sorry, this salon is currently closed and not accepting bookings." });
        }

        const booking = await createBooking(
            salonId,
            customerName,
            serviceName,
            bookingDate,
            bookingTime,
            price,
            barberName
        );
        res.status(201).json({ success: true, booking });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.uploadThumbnail = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, message: "No file uploaded" });
        }
        
        // Return the relative URL path of the uploaded file
        const fileUrl = `/uploads/${req.file.filename}`;
        
        res.status(200).json({
            success: true,
            url: fileUrl,
            message: "File uploaded successfully!"
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Upload failed",
            error: error.message
        });
    }
};

exports.getCustomerBookings = async (req, res) => {
    try {
        const customerName = req.params.customerName;
        const bookings = await getBookingsByCustomer(customerName);
        res.status(200).json({ success: true, bookings });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.updateBookingStatus = async (req, res) => {
    try {
        const bookingId = req.params.bookingId;
        const { status } = req.body;
        const booking = await updateBookingStatus(bookingId, status);
        res.status(200).json({ success: true, booking });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.toggleSalonStatus = async (req, res) => {
    try {
        const salonId = req.params.id;
        const { isOpen } = req.body;
        
        const result = await pool.query(
            "UPDATE salons SET is_open = $1 WHERE id = $2 RETURNING *",
            [isOpen, salonId]
        );
        
        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: "Salon not found" });
        }
        
        res.status(200).json({ success: true, salon: result.rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.submitReview = async (req, res) => {
    try {
        const salonId = req.params.id;
        const { customerName, barberName, salonRating, barberRating, salonReview, barberReview } = req.body;

        const result = await pool.query(
            `INSERT INTO reviews 
            (salon_id, barber_name, customer_name, salon_rating, barber_rating, salon_review, barber_review)
            VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [salonId, barberName, customerName, salonRating, barberRating, salonReview, barberReview]
        );

        res.status(201).json({
            success: true,
            review: result.rows[0],
            message: "Review submitted successfully!"
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};

exports.getReviewsBySalon = async (req, res) => {
    try {
        const salonId = req.params.id;
        const result = await pool.query(
            "SELECT * FROM reviews WHERE salon_id = $1 ORDER BY created_at DESC",
            [salonId]
        );
        res.status(200).json({ success: true, reviews: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error: error.message });
    }
};
