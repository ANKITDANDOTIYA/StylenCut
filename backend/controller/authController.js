const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { findUserByEmail, createUser } = require('../models/authModel');

// SIGNUP

exports.signup = async (req, res) => {
    try {
        const {email, password, name, role, salonName, address, phoneNumber, openingTime, closingTime} = req.body;

        const existingUser = await findUserByEmail(email);

        if(existingUser) {
            return res.status(400).json({
                success: false,
                message: "User Already Exists"
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = await createUser(name, email, hashedPassword, role || 'user');
        
        let newSalon = null;
        if (newUser.role === 'admin' && salonName) {
            const { createSalon } = require('../models/salonModel');
            const data = {
                address: address,
                phone_number: phoneNumber,
                opening_time: openingTime,
                closing_time: closingTime
            };
            newSalon = await createSalon(newUser.id, salonName, data);
        }

        res.status(201).json({
            success: true,
            message: "User Created Successfully",   
            user: newUser,
            salon: newSalon
        });
        } catch(error){
            res.status(500).json({
                success: false,
                message: "Internal Server Error",
                error: error.message
            });
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
    
