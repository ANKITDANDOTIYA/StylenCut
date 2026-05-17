const express = require("express");
const cors = require("cors");
const path = require("path");

const authRoutes =
require("./routes/authRoutes");
const salonRoutes = require("./routes/salonRoutes");

const app = express();


// MIDDLEWARE
app.use(cors());
app.use(express.json());
// Serve static upload files
app.use("/uploads", express.static(path.join(__dirname, "uploads")));


// ROUTES
app.use("/api/auth", authRoutes);
app.use("/api/salons", salonRoutes);


// ERROR HANDLER
app.use((err, req, res, next) => {
  console.error("Express Error Handler:", err.message);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || "Internal Server Error"
  });
});

// SERVER
app.listen(5000, () => {
  console.log("Server running on port 5000");
});