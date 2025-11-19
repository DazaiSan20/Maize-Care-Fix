const multer = require('multer');
const path = require('path');

// ======================================
// STORAGE
// ======================================
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // pastikan folder ada
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, 'leaf-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// ======================================
// FILE FILTER — FIX AMAN
// ======================================
// Jika mimetype tidak jelas (octet-stream), kita cek berdasarkan ekstensi.
const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();

  const allowedExt = ['.jpg', '.jpeg', '.png', '.jfif'];
  const allowedMime = ['image/jpeg', 'image/jpg', 'image/png', 'image/jfif'];

  // Jika ekstensi valid → TERIMA SAJA
  if (allowedExt.includes(ext)) {
    return cb(null, true);
  }

  // Jika ekstensi tidak valid → tolak
  console.error('❌ File ditolak:', {
    filename: file.originalname,
    mimetype: file.mimetype,
    ext
  });

  return cb(new Error('Only images (.jpg, .jpeg, .png, .jfif) are allowed!'));
};

// ======================================
// FINAL MULTER
// ======================================
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter
});

module.exports = upload;
