const express = require("express");
const router = express.Router();
const salonController = require("../controller/salonController");
const upload = require("../middlewares/upload");

router.get("/", salonController.getAllSalons);
router.put("/:id", salonController.updateSalonDetails);
router.get("/:id/barbers", salonController.getBarbers);
router.post("/:id/barbers", salonController.assignBarber);
router.post("/:id/barbers/new", salonController.createBarber);
router.post("/upload", upload.single("thumbnail"), salonController.uploadThumbnail);

module.exports = router;
