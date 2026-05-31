const express = require("express");

const router = express.Router();

const {
  signup,
  login,
  updateProfilePic,
  changePassword,
} = require("../controller/authController");



router.post("/signup", signup);

router.post("/login", login);

router.put("/profile-pic", updateProfilePic);

router.put("/change-password", changePassword);


module.exports = router;