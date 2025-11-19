exports.success = (res, data = {}, message = 'Success', status = 200) => {
	return res.status(status).json({ success: true, message, data });
};

exports.error = (res, message = 'Something went wrong', status = 500, errors = null) => {
	return res.status(status).json({ success: false, message, errors });
};

exports.notFound = (res, message = 'Not found') => {
	return res.status(404).json({ success: false, message });
};
