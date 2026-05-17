const { getAllSalons } = require('../models/salonModel');

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
