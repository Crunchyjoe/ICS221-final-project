const mongoose = require('mongoose');
const messageModel = mongoose.model('message');
const util = require('util');

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

const deleteAllMessages = (req, res) => {
    messageModel.deleteMany({}, (err, message) => {
      if (err){
        res.status(400).json(err);
        return;
      }
      if (!message){
        res.status(404).json({"api-msg": "could not find messages to delete"});
      }
    });

}

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

const getSingleMessage = (req, res) => {
    if (req.params && req.params.messageid) {
      messageModel
        .findById(req.params.messageid)
        .exec( (err, message) => {
          // error in executing function
          if (err) {
            res.status(400).json(err);
            return;
          }
  
          // could execute, but didn't find message
          if (!message) {
            res.status(404).json({
              "api-msg": "messageid not found"
            });
            return;
          }
  
          // found message
          res.status(200).json(message);
        });
    } else {
        // must have a message id
        res.status(400).json({
            "api-msg": "No messageid in request"
        });
    }
  };

  const deleteSingleMessage = (req, res) => {
    if (req.params && req.params.messageid) {
      messageModel
        .findById(req.params.messageid)
        .exec( (err, message) => {
          // error in executing function
          if (err) {
            res.status(400).json(err);
            return;
          }
  
          // could execute, but didn't find message
          if (!message) {
            res.status(404).json({
              "api-msg": "messageid not found"
            });
            return;
          }
  
          // found message
          message.remove();
        });
    } else {
        // must have a message id
        res.status(400).json({
            "api-msg": "No messageid in request"
        });
    }
  };

  const editSingleMessage = (req, res) => {
    console.log("made it to editsinglemessage function");
    if (req.params && req.params.messageid) {
     
      var id = mongoose.Types.ObjectId(req.params.messageid);
      console.log("messageid at editsinglemessage is: " + id);
      console.log("message at editsinglemessage is: " + JSON.stringify(req.body.messageText));
      var formattedMessage = JSON.stringify(req.body.messageText).replace(/['"]+/g, '');
      console.log("formatted message: " + formattedMessage);
      messageModel
        .updateOne({_id : id}, { $set: {msg : formattedMessage}})
        .exec( (err, message) => {
          if (err) {
            res.status(400).json(err);
            return;
          }
          if (!message){
            res.status(404).json({"api-msg": "messageid not found"});
            return;
          }
        });
    } else {
        // must have a message id
        console.log("no request params");
        res.status(400).json({
            "api-msg": "No messageid in request"
        });
    }
  };

module.exports = {
    getAllMessagesOrderedByLastPosted,
    addNewMessage,
    getSingleMessage,
    deleteSingleMessage,
    editSingleMessage,
    deleteAllMessages
}