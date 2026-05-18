const { getAllSalons, updateSalon } = require('../models/salonModel');
const { getBarbersBySalon, assignBarberToSalon, createBarberUser, findUserByEmail } = require('../models/authModel');
const { createBooking, getBookingsBySalon } = require('../models/bookingModel');
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
        const { name, email, password } = req.body;

        const existingUser = await findUserByEmail(email);
        if (existingUser) {
            return res.status(400).json({ success: false, message: "User Already Exists" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newBarber = await createBarberUser(name, email, hashedPassword, salonId);
        res.status(201).json({ success: true, barber: newBarber });
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
