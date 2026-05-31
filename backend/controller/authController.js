const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { findUserByEmail, createUser } = require('../models/authModel');

const pool = require('../config/db');

// SIGNUP

exports.signup = async (req, res) => {
    const client = await pool.connect();
    try {
        const {email, password, name, role, salonName, address, phoneNumber, openingTime, closingTime} = req.body;

        const existingUser = await findUserByEmail(email);

        if(existingUser) {
            return res.status(400).json({
                success: false,
                message: "User Already Exists"
            });
        }

        if (role === 'admin') {
            if (!salonName || typeof salonName !== 'string' || salonName.trim() === "") {
                return res.status(400).json({
                    success: false,
                    message: "Salon Name is required for Admin accounts"
                });
            }
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        await client.query('BEGIN');

        // Insert new user
        const userResult = await client.query(
            `INSERT INTO users (name, email, password, role)
             VALUES ($1, $2, $3, $4) RETURNING *`,
            [name, email, hashedPassword, role || 'user']
        );
        const newUser = userResult.rows[0];
        
        let newSalon = null;
        if (newUser.role === 'admin') {
            // Sanitize times: convert empty strings or whitespace to null
            let opt = (openingTime && typeof openingTime === 'string' && openingTime.trim() !== "") ? openingTime.trim() : null;
            let clt = (closingTime && typeof closingTime === 'string' && closingTime.trim() !== "") ? closingTime.trim() : null;

            // Simple validation to check if times are format-compliant.
            // If they are provided, check if Postgres will accept them. A loose regex match for standard formats:
            const timePattern = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?\s*(AM|PM)?$/i;
            if (opt && !timePattern.test(opt)) {
                opt = "09:00:00"; // fallback
            }
            if (clt && !timePattern.test(clt)) {
                clt = "20:00:00"; // fallback
            }

            const salonResult = await client.query(
                `INSERT INTO salons 
                (owner_id, name, address, phone_number, opening_time, closing_time, thumbnail_pic)
                VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
                [newUser.id, salonName.trim(), address || null, phoneNumber || null, opt, clt, null]
            );
            newSalon = salonResult.rows[0];
        }

        await client.query('COMMIT');

        res.status(201).json({
            success: true,
            message: "User Created Successfully",   
            user: newUser,
            salon: newSalon
        });
    } catch(error) {
        await client.query('ROLLBACK');
        res.status(500).json({
            success: false,
            message: "Internal Server Error",
            error: error.message
        });
    } finally {
        client.release();
    }
};


    // ================= LOGIN =================
exports.login = async (req, res) => {

  try {

    const {
      email,
      password,
    } = req.body;


    // FIND USER
    const user =
      await findUserByEmail(email);

    if(!user) {

      return res.status(401).json({
        success: false,
        message: "User not found",
      });
    }


    // CHECK PASSWORD
    const isMatch =
      await bcrypt.compare(password, user.password);

    if(!isMatch) {

      return res.status(401).json({
        success: false,
        message: "Wrong password",
      });
    }


    // JWT TOKEN
    const token = jwt.sign(
      { id: user.id },
      "secretkey",
      { expiresIn: "7d" }
    );


    res.json({

      success: true,
      message: "Login successful",
      token,
      role: user.role,
      user,
    });

  } catch(error) {
    console.log(error.message);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// UPDATE PROFILE PIC
exports.updateProfilePic = async (req, res) => {
    try {
        const { userId, email, profilePic } = req.body;
        const { updateUserProfilePic, updateUserProfilePicByEmail } = require('../models/authModel');
        
        let updatedUser;
        if (userId) {
            updatedUser = await updateUserProfilePic(userId, profilePic);
        } else if (email) {
            updatedUser = await updateUserProfilePicByEmail(email, profilePic);
        } else {
            return res.status(400).json({
                success: false,
                message: "User ID or Email is required"
            });
        }

        if (!updatedUser) {
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }
        res.status(200).json({
            success: true,
            message: "Profile picture updated in database successfully",
            user: updatedUser
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal Server Error",
            error: error.message
        });
    }
};

exports.changePassword = async (req, res) => {
    try {
        const { userId, currentPassword, newPassword } = req.body;
        const pool = require('../config/db');

        const parsedUserId = parseInt(userId, 10);
        if (isNaN(parsedUserId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid User ID format"
            });
        }

        const userQuery = await pool.query("SELECT * FROM users WHERE id = $1", [parsedUserId]);
        if (userQuery.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }

        const user = userQuery.rows[0];

        const isMatch = await bcrypt.compare(currentPassword, user.password);
        if (!isMatch) {
            return res.status(400).json({
                success: false,
                message: "Incorrect current password"
            });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        await pool.query("UPDATE users SET password = $1 WHERE id = $2", [hashedPassword, parsedUserId]);

        res.status(200).json({
            success: true,
            message: "Password changed successfully"
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal Server Error",
            error: error.message
        });
    }
};

exports.updateName = async (req, res) => {
    try {
        const { userId, name } = req.body;
        const { updateUserName } = require('../models/authModel');

        const parsedUserId = parseInt(userId, 10);
        if (isNaN(parsedUserId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid User ID format"
            });
        }

        if (!name || typeof name !== 'string' || name.trim() === "") {
            return res.status(400).json({
                success: false,
                message: "Name is required"
            });
        }

        const updatedUser = await updateUserName(parsedUserId, name.trim());

        if (!updatedUser) {
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }

        res.status(200).json({
            success: true,
            message: "Username updated successfully",
            user: updatedUser
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal Server Error",
            error: error.message
        });
    }
};
    
