const express = require("express");
const cors = require("cors");

const authRoutes =
require("./routes/authRoutes");
const salonRoutes = require("./routes/salonRoutes");

const app = express();


// MIDDLEWARE
app.use(cors());
app.use(express.json());


// ROUTES
app.use("/api/auth", authRoutes);
app.use("/api/salons", salonRoutes);


// SERVER
app.listen(5000, () => {

  console.log(
    "Server running on port 5000"
  );
});