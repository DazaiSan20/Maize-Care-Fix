module.exports = (err, req, res, next) => {
  // Basic error handler
  const status = err.status || 500;
  const message = err.message || 'Internal Server Error';
  res.status(status).json({ success: false, message });
};
