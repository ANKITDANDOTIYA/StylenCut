const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { findUserByEmail, createUser } = require('../models/authModel');

// SIGNUP

exports.signup = async (req, res) => {
    try {
        const {email, password, name, role} = req.body;

        const existingUser = await findUserByEmail(email);

        if(existingUser) {
            return res.status(400).json({
                success: false,
                message: "User Already Exists"
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = await createUser(name, email, hashedPassword, role || 'user');
        res.status(201).json({
            success: true,
            message: "User Created Successfully",   
            user: newUser
        });
        } catch(error){
            res.status(500).json({
                success: false,
                message: "Internal Server Error"
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

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
    
