const express = require("express");
const router = express.Router();
const salonController = require("../controller/salonController");

router.get("/", salonController.getAllSalons);

module.exports = router;
