const mongoose = require('mongoose');
const messageModel = mongoose.model('message');

const getAllMessagesOrderedByLastPosted = (req, res) => {
    messageModel.find()
    .sort( {'_id': -1} )
    .exec( (err, messages) => {
        if (err) {
            res.status(404).json(err);
        }
        else {
            res.status(200).json(messages);
        }
    });
};

const addNewMessage = (req, res) => {
    messageModel.create( req.body, (err, message) => {
        if (err) {
            res.status(400).json(err);
        }
        else {
            res.status(201).json(message);
        }
    });
}

module.exports = {
    getAllMessagesOrderedByLastPosted,
    addNewMessage
}