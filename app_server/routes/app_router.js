const express = require('express');
const router = express.Router();
var msgController = require('../controllers/msg.js');

router.get('/', msgController.getMessages);

module.exports = router;
