// Wrap firebase admin initialization and exports
const admin = require('firebase-admin');
const initFirebase = require('../config/firebase');

initFirebase();

module.exports = admin;
