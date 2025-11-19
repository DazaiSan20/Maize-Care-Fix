const admin = require('firebase-admin');
const path = require('path');
const logger = require('../utils/logger');

const initFirebase = () => {
	try {
		// Try to use JSON variables from .env first
		const serviceAccount = {
			type: 'service_account',
			project_id: process.env.FIREBASE_PROJECT_ID,
			private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
			private_key: process.env.FIREBASE_PRIVATE_KEY ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : undefined,
			client_email: process.env.FIREBASE_CLIENT_EMAIL,
			client_id: process.env.FIREBASE_CLIENT_ID,
			auth_uri: process.env.FIREBASE_AUTH_URI,
			token_uri: process.env.FIREBASE_TOKEN_URI,
			auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
			client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
		};

		// Filter out undefined values
		Object.keys(serviceAccount).forEach(key => 
			serviceAccount[key] === undefined && delete serviceAccount[key]
		);

		// If env variables not set, try to load from file
		let finalServiceAccount = serviceAccount;
		if (!process.env.FIREBASE_PROJECT_ID) {
			const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || path.resolve(__dirname, '../../maize-care-fix-firebase-adminsdk-fbsvc-ebd3575eff.json');
			finalServiceAccount = require(serviceAccountPath);
		}

		admin.initializeApp({
			credential: admin.credential.cert(finalServiceAccount),
		});
		logger.info('✅ Firebase admin initialized');
	} catch (err) {
		logger.error(`⚠️ Firebase init error: ${err.message}`);
	}
};

module.exports = initFirebase;
