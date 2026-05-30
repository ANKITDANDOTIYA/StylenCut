const express = require("express");

const router = express.Router();

const {
  signup,
  login,
  updateProfilePic,
} = require("../controller/authController");



router.post("/signup", signup);

router.post("/login", login);

router.put("/profile-pic", updateProfilePic);


module.exports = router;