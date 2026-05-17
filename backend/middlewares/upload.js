const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Ensure uploads folder exists in root
const uploadDir = path.join(__dirname, "../uploads");
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Storage Configuration
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        // Create a unique filename: <timestamp>-<random>.<extension>
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

// File Filter for Images
const fileFilter = (req, file, cb) => {
    const allowedExtensions = /jpeg|jpg|png|webp/i;
    const extname = allowedExtensions.test(path.extname(file.originalname).toLowerCase());
    
    // Allow standard image mimetypes or application/octet-stream (often sent by mobile clients)
    const allowedMimeTypes = /image\/jpeg|image\/jpg|image\/png|image\/webp|application\/octet-stream/i;
    const mimetype = allowedMimeTypes.test(file.mimetype);

    if (extname && mimetype) {
        return cb(null, true);
    } else {
        cb(new Error("Only images (jpeg, jpg, png, webp) are allowed!"));
    }
};

const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

module.exports = upload;
