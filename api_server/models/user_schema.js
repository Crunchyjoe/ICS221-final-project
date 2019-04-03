const mongoose = require('mongoose');
const bCrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        maxlength: 30,
        lowercase: true,
        unique: true
    },
    username: {
        type: String,
        required: true,
        minlength: 3,
        maxLength: 20,
        unique: true,
        trim: true
    },
    password: {
        type: String,
        required: true,
        minlength: 8,
        maxlength: 50
    }
});

userSchema.pre('save', function(next){

    bCrypt.hash(this.password, 10)
    .then( hash => {
        this.password = hash;
        next();
    })
    .catch(err => {
        console.log('Error in hashing password' + err);
        next(err);
    });
});

userSchema.methods.verifyPassword = function(inputedPlainTextPassword){
    const hashedPassword = this.password;
    return bCrypt.compare(inputedPlainTextPassword, hashedPassword);
}

module.exports = mongoose.model('user', userSchema);