const express = require("express");
const router = express.Router();
const salonController = require("../controller/salonController");
const upload = require("../middlewares/upload");

router.get("/bookings/customer/:customerName", salonController.getCustomerBookings);
router.put("/bookings/:bookingId/status", salonController.updateBookingStatus);

router.get("/", salonController.getAllSalons);
router.put("/:id", salonController.updateSalonDetails);
router.put("/:id/status", salonController.toggleSalonStatus);
router.get("/:id/barbers", salonController.getBarbers);
router.post("/:id/barbers", salonController.assignBarber);
router.post("/:id/barbers/new", salonController.createBarber);
router.put("/:id/barbers/:barberId", salonController.updateBarber);
router.get("/:id/bookings", salonController.getBookings);
router.post("/:id/bookings", salonController.createBooking);
router.post("/:id/reviews", salonController.submitReview);
router.get("/:id/reviews", salonController.getReviewsBySalon);
router.post("/upload", upload.single("thumbnail"), salonController.uploadThumbnail);

module.exports = router;
