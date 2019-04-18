const express = require('express');
const router = express.Router();
const passport = require('passport');

const userAPIController = require('../controllers/user-api');
const msgAPIController = require('../controllers/msg-api');

router.post('/users', userAPIController.registerNewUser);
router.get('/users/login', passport.authenticate('basic', {session: false}), userAPIController.loginUser);

router.route('/msgs')
.get(msgAPIController.getAllMessagesOrderedByLastPosted)
.post(passport.authenticate('basic', { session: false}), msgAPIController.addNewMessage)
.delete(msgAPIController.deleteAllMessages);


router.route('/msgs/:messageid').get(msgAPIController.getSingleMessage)
.delete(msgAPIController.deleteSingleMessage)
.put(msgAPIController.editSingleMessage);

module.exports = router;
