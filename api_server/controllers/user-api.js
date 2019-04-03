const mongoose = require('mongoose');
const userModel = mongoose.model('user');
const passport = require('passport');
const BasicStrategy = require('passport-http').BasicStrategy;

const registerNewUser = (req, res) => {
    userModel
    .findOne({
        email: req.body.email
    }, (err, user) => {
        if(err) {
            res.status(404).json(err);
            return;
    }

        if(user) {
            res
            .status(403)
            .json({"api-msg": "email already exists"});
            return;
    }

    userModel
    .create( req.body, (err, user) => {
        if (err) {
            res.status(400).json(err);
        } else {
            res.status(201).json(user);
        }
        });
    });
}

passport.use(new BasicStrategy(
    (username, password, done) => {
        userModel
        .findOne({
            username: username
        }, (err, user) => {
            if(err) return done(err);

            // username wasn't found
            if(!user) return done(null, false);
            // user was found, see if it's a valid password
            user.verifyPassword(password)
            .then( result => {
                if (result) return done(null, user);
                else return done(null, false);
            })
            .catch( error=> {
                console.log('Error verifying Password: ' + error);
            });
        });
    }
));
    

const loginUser = (req, res) => {
    res.status(200).json({"api-msg": "Successfully Authenticated"});
}

module.exports = {
    registerNewUser,
    loginUser
};