[1mdiff --git a/api_server/controllers/user-api.js b/api_server/controllers/user-api.js[m
[1mnew file mode 100644[m
[1mindex 0000000..e7b3a9a[m
[1m--- /dev/null[m
[1m+++ b/api_server/controllers/user-api.js[m
[36m@@ -0,0 +1,65 @@[m
[32m+[m[32mconst mongoose = require('mongoose');[m
[32m+[m[32mconst userModel = mongoose.model('user');[m
[32m+[m[32mconst passport = require('passport');[m
[32m+[m[32mconst BasicStrategy = require('passport-http').BasicStrategy;[m
[32m+[m
[32m+[m[32mconst registerNewUser = (req, res) => {[m
[32m+[m[32m    userModel[m
[32m+[m[32m    .findOne({[m
[32m+[m[32m        email: req.body.email[m
[32m+[m[32m    }, (err, user) => {[m
[32m+[m[32m        if(err) {[m
[32m+[m[32m            res.status(404).json(err);[m
[32m+[m[32m            return;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m        if(user) {[m
[32m+[m[32m            res[m
[32m+[m[32m            .status(403)[m
[32m+[m[32m            .json({"api-msg": "email already exists"});[m
[32m+[m[32m            return;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    userModel[m
[32m+[m[32m    .create( req.body, (err, user) => {[m
[32m+[m[32m        if (err) {[m
[32m+[m[32m            res.status(400).json(err);[m
[32m+[m[32m        } else {[m
[32m+[m[32m            res.status(201).json(user);[m
[32m+[m[32m        }[m
[32m+[m[32m        });[m
[32m+[m[32m    });[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mpassport.use(new BasicStrategy([m
[32m+[m[32m    (email, password, done) => {[m
[32m+[m[32m        userModel[m
[32m+[m[32m        .findOne({[m
[32m+[m[32m            email: email[m
[32m+[m[32m        }, (err, user) => {[m
[32m+[m[32m            if(err) return done(err);[m
[32m+[m
[32m+[m[32m            // username wasn't found[m
[32m+[m[32m            if(!user) return done(null, false);[m
[32m+[m[32m            // user was found, see if it's a valid password[m
[32m+[m[32m            user.verifyPassword(password)[m
[32m+[m[32m            .then( result => {[m
[32m+[m[32m                if (result) return done(null, user);[m
[32m+[m[32m                else return done(null, false);[m
[32m+[m[32m            })[m
[32m+[m[32m            .catch( error=> {[m
[32m+[m[32m                console.log('Error verifying Password: ' + error);[m
[32m+[m[32m            });[m
[32m+[m[32m        });[m
[32m+[m[32m    }[m
[32m+[m[32m));[m
[32m+[m[41m    [m
[32m+[m
[32m+[m[32mconst loginUser = (req, res) => {[m
[32m+[m[32m    res.status(200).json({"api-msg": "Successfully Authenticated"});[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = {[m
[32m+[m[32m    registerNewUser,[m
[32m+[m[32m    loginUser[m
[32m+[m[32m};[m
\ No newline at end of file[m
[1mdiff --git a/api_server/db.js b/api_server/db.js[m
[1mindex fdbd5a7..6f2b36f 100644[m
[1m--- a/api_server/db.js[m
[1m+++ b/api_server/db.js[m
[36m@@ -1,7 +1,7 @@[m
 //import mongoose, connect to DB[m
 const mongoose = require('mongoose');[m
 let dbURI = 'mongodb://localhost:27017/msgsdb';[m
[31m-mongoose.connect(dbURI, { useNewUrlParser: true});[m
[32m+[m[32mmongoose.connect(dbURI, { useNewUrlParser: true, useCreateIndex: true });[m
 [m
 [m
 // mongoose DB connection handling[m
[36m@@ -17,6 +17,7 @@[m [mmongoose.connection.on('disconnected', () => {[m
 });[m
 [m
 require('./models/message_schema');[m
[32m+[m[32mrequire('./models/user_schema');[m
 [m
 [m
 [m
[1mdiff --git a/api_server/models/user_schema.js b/api_server/models/user_schema.js[m
[1mnew file mode 100644[m
[1mindex 0000000..d014667[m
[1m--- /dev/null[m
[1m+++ b/api_server/models/user_schema.js[m
[36m@@ -0,0 +1,46 @@[m
[32m+[m[32mconst mongoose = require('mongoose');[m
[32m+[m[32mconst bCrypt = require('bcrypt');[m
[32m+[m
[32m+[m[32mconst userSchema = new mongoose.Schema({[m
[32m+[m[32m    email: {[m
[32m+[m[32m        type: String,[m
[32m+[m[32m        required: true,[m
[32m+[m[32m        maxlength: 30,[m
[32m+[m[32m        lowercase: true,[m
[32m+[m[32m        unique: true[m
[32m+[m[32m    },[m
[32m+[m[32m    username: {[m
[32m+[m[32m        type: String,[m
[32m+[m[32m        required: true,[m
[32m+[m[32m        minlength: 3,[m
[32m+[m[32m        maxLength: 20,[m
[32m+[m[32m        unique: true,[m
[32m+[m[32m        trim: true[m
[32m+[m[32m    },[m
[32m+[m[32m    password: {[m
[32m+[m[32m        type: String,[m
[32m+[m[32m        required: true,[m
[32m+[m[32m        minlength: 8,[m
[32m+[m[32m        maxlength: 50[m
[32m+[m[32m    }[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32muserSchema.pre('save', function(next){[m
[32m+[m
[32m+[m[32m    bCrypt.hash(this.password, 10)[m
[32m+[m[32m    .then( hash => {[m
[32m+[m[32m        this.password = hash;[m
[32m+[m[32m        next();[m
[32m+[m[32m    })[m
[32m+[m[32m    .catch(err => {[m
[32m+[m[32m        console.log('Error in hashing password' + err);[m
[32m+[m[32m        next(err);[m
[32m+[m[32m    });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32muserSchema.methods.verifyPassword = function(inputedPlainTextPassword){[m
[32m+[m[32m    const hashedPassword = this.password;[m
[32m+[m[32m    return bCrypt.compare(inputedPlainTextPassword, hashedPassword);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = mongoose.model('user', userSchema);[m
\ No newline at end of file[m
[1mdiff --git a/api_server/routes/api_router.js b/api_server/routes/api_router.js[m
[1mindex 59ab463..dff4437 100644[m
[1m--- a/api_server/routes/api_router.js[m
[1m+++ b/api_server/routes/api_router.js[m
[36m@@ -1,10 +1,15 @@[m
 const express = require('express');[m
 const router = express.Router();[m
[32m+[m[32mconst passport = require('passport');[m
 [m
[32m+[m[32mconst userAPIController = require('../controllers/user-api');[m
 const msgAPIController = require('../controllers/msg-api');[m
 [m
[32m+[m[32mrouter.post('/users', userAPIController.registerNewUser);[m
[32m+[m[32mrouter.get('/users/login', passport.authenticate('basic', {session: false}), userAPIController.loginUser);[m
[32m+[m
 router.route('/msgs')[m
 .get(msgAPIController.getAllMessagesOrderedByLastPosted)[m
[31m-.post(msgAPIController.addNewMessage);[m
[32m+[m[32m.post(passport.authenticate('basic', { session: false}), msgAPIController.addNewMessage);[m
 [m
 module.exports = router;[m
[1mdiff --git a/app.js b/app.js[m
[1mindex c72894c..ba5c194 100644[m
[1m--- a/app.js[m
[1m+++ b/app.js[m
[36m@@ -8,7 +8,7 @@[m [mvar logger = require('morgan');[m
 require('./api_server/db');[m
 var app_router = require('./app_server/routes/app_router');[m
 var apiRouter = require('./api_server/routes/api_router');[m
[31m-[m
[32m+[m[32mconst passport = require('passport');[m
 [m
 var app = express();[m
 [m
[36m@@ -23,6 +23,7 @@[m [mapp.use(cookieParser());[m
 app.use(express.static(path.join(__dirname, 'public')));[m
 app.use('/', app_router);[m
 app.use('/api/v1', apiRouter);[m
[32m+[m[32mapp.use(passport.initialize());[m
 [m
 [m
 // catch 404 and forward to error handler[m
[1mdiff --git a/app_server/components/Login.jsx b/app_server/components/Login.jsx[m
[1mnew file mode 100644[m
[1mindex 0000000..5f2e13b[m
[1m--- /dev/null[m
[1m+++ b/app_server/components/Login.jsx[m
[36m@@ -0,0 +1,106 @@[m
[32m+[m[32mconst React = require('react');[m
[32m+[m
[32m+[m[32mclass Login extends React.Component {[m
[32m+[m[32m    constructor(props){[m
[32m+[m[32m        super(props);[m
[32m+[m[32m        this.state = {email: '', password: ''};[m
[32m+[m[32m        this.handleText = this.handleText.bind(this);[m
[32m+[m[32m        this.login = this.login.bind(this);[m
[32m+[m[32m        this.register = this.register.bind(this);[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    handleText(event){[m
[32m+[m[32m        if(event.target.id === 'email') {[m
[32m+[m[32m            this.setState({ email: event.target.value });[m
[32m+[m[32m        }[m
[32m+[m[32m        else {[m
[32m+[m[32m            this.setState ({ password: event.target.value });[m
[32m+[m[32m        }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    register(event){[m
[32m+[m[32m        this.props.registerCallback();[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    login(event){[m
[32m+[m[32m        event.preventDefault();[m
[32m+[m
[32m+[m[32m        //pass control to MsgBoard and send email and password[m
[32m+[m[32m        this.props.loginCallback({[m
[32m+[m[32m            email: this.state.email,[m
[32m+[m[32m            password: this.state.password[m
[32m+[m[32m        });[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    render(){[m
[32m+[m[32m        var inputStyle = {[m
[32m+[m[32m            borderRadius: "5px"[m
[32m+[m[32m        };[m
[32m+[m[32m        var submitStyle = {[m
[32m+[m[32m            borderRadius: "5px",[m
[32m+[m[32m            backgroundColor: "BLUE",[m
[32m+[m[32m            color: "WHITE"[m
[32m+[m
[32m+[m[32m        };[m
[32m+[m
[32m+[m[32m        var registerStyle = {[m
[32m+[m[32m            borderRadius: "5px",[m
[32m+[m[32m            color: "BLUE",[m
[32m+[m[32m            backgroundColor: "WHITE",[m
[32m+[m[32m            borderColor: "BLUE"[m
[32m+[m[32m        };[m
[32m+[m[41m        [m
[32m+[m[32m        var cardStyle = {[m
[32m+[m[32m            width: "50rem"[m
[32m+[m[32m        };[m
[32m+[m
[32m+[m[32m        var notRegisterStyle = {[m
[32m+[m[32m            background: "none",[m
[32m+[m[32m            border: "none",[m
[32m+[m[32m            margin: 0,[m
[32m+[m[32m            padding: 0,[m
[32m+[m[32m            cursor: "pointer"[m
[32m+[m[32m        };[m
[32m+[m[41m        [m
[32m+[m[32m        let loginFailText;[m
[32m+[m[32m        if (this.props.loginFail){[m
[32m+[m[32m            loginFailText = <p className="card-text pt-1 text-danger">Failed Login Attempt.[m
[32m+[m[32m            &nbsp;{ this.props.loginAttempts } attempts remaining.</p>[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        return([m
[32m+[m[32m            <div className="card" style={cardStyle}>[m
[32m+[m[32m                <div className="card-body">[m
[32m+[m[32m                    <div className="container">[m
[32m+[m[32m                        <form method="POST" onSubmit={this.login}>[m
[32m+[m[32m                            <div className="row">[m
[32m+[m[32m                                <div className="col">[m
[32m+[m[32m                                    <h3>Log in to post a Message:</h3>[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div className="row">[m
[32m+[m[32m                                <div className="col">[m
[32m+[m[32m                                    <label className="m-2" htmlFor="email">Email:</label>[m[41m                        [m
[32m+[m[32m                                    <input className="m-2" style={inputStyle} type="Email" id="email" placeholder="enter email" onChange={this.handleText}></input>[m
[32m+[m[32m                                    <label className="m-2" htmlFor="password">Password:</label>[m
[32m+[m[32m                                    <input className="m-2" style={inputStyle} type="Password" id="password" placeholder="enter password" onChange={this.handleText}></input>[m
[32m+[m[32m                                    <button className="m-2" type="submit" style={submitStyle}>Log In</button>[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                            </div>[m
[32m+[m[41m        [m
[32m+[m[32m                        </form>[m
[32m+[m[32m                        <div className="row">[m
[32m+[m[32m                            <div className="col">[m
[32m+[m[32m                                <p className="m-2" style={notRegisterStyle}>Not Registered&#63;</p>[m
[32m+[m[32m                                <button onClick={this.register} style={registerStyle}>Register</button>[m
[32m+[m[32m                                {loginFailText}[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        )[m
[32m+[m[32m    }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = Login;[m
\ No newline at end of file[m
[1mdiff --git a/app_server/components/MsgBoard.jsx b/app_server/components/MsgBoard.jsx[m
[1mindex c972b48..b7eb37d 100644[m
[1m--- a/app_server/components/MsgBoard.jsx[m
[1m+++ b/app_server/components/MsgBoard.jsx[m
[36m@@ -1,12 +1,28 @@[m
 const React = require('react');[m
 const MsgList = require('./MsgList.jsx');[m
 const NewMsg = require('./NewMsg.jsx');[m
[32m+[m[32mconst Login = require('./Login.jsx')[m
[32m+[m[32mconst Registration = require('../../client_side/Registration.jsx');[m
 [m
 class MsgBoard extends React.Component {[m
     constructor(props){[m
         super(props);[m
[31m-        this.state = {messages: this.props.messages};[m
[32m+[m[32m        this.state = {[m
[32m+[m[32m            messages: this.props.messages,[m
[32m+[m[32m            loginForm: true,[m
[32m+[m[32m            loginAttempts: 3,[m
[32m+[m[32m            loginFail: false,[m[41m [m
[32m+[m[32m            userCredentials: {[m
[32m+[m[32m                email: '',[m
[32m+[m[32m                password: ''[m
[32m+[m[32m            },[m
[32m+[m[32m            registrationForm: false,[m
[32m+[m[32m            registrationFail: false[m
[32m+[m[32m        };[m
         this.addMessage = this.addMessage.bind(this);[m
[32m+[m[32m        this.login = this.login.bind(this);[m
[32m+[m[32m        this.register = this.register.bind(this);[m
[32m+[m[32m        this.addNewUser = this.addNewUser.bind(this);[m
     }[m
 [m
     componentDidMount() {[m
[36m@@ -21,6 +37,7 @@[m [mclass MsgBoard extends React.Component {[m
 [m
     addMessage(message) {[m
         // TODO: make API call to store new message and updt state var message[m
[32m+[m[32m        const basicString = this.state.userCredentials.email + ':' + this.state.userCredentials.password;[m
         let msgs = this.state.messages;[m
 [m
         //add id attribute[m
[36m@@ -34,7 +51,8 @@[m [mclass MsgBoard extends React.Component {[m
         fetch(`${process.env.API_URL}/msgs`, {[m
             method: 'POST',[m
             headers: {[m
[31m-                'Content-Type': 'application/json'[m
[32m+[m[32m                'Content-Type': 'application/json',[m
[32m+[m[32m                'Authorization': 'Basic ' + btoa(basicString)[m
             },[m
             body: JSON.stringify(message)[m
         }).then(response => this.handleHTTPErrors(response))[m
[36m@@ -44,15 +62,116 @@[m [mclass MsgBoard extends React.Component {[m
         })[m
         .catch(error => { console.log(error); });[m
     }[m
[31m-    [m
[32m+[m
[32m+[m[32m    login(userCredentials) {[m
[32m+[m[32m        // userCredentials is passed in from Login Component[m
[32m+[m[32m        // For Basic Authentication it is username:password (but we're using email)[m
[32m+[m[32m        const basicString = userCredentials.email + ':' + userCredentials.password;[m
[32m+[m[41m        [m
[32m+[m[32m        fetch(`${process.env.API_URL}/users/login`, {[m
[32m+[m[32m            method: 'GET',[m
[32m+[m[32m            headers: {[m
[32m+[m[32m                'Authorization': 'Basic ' + btoa(basicString)[m
[32m+[m[32m            }[m
[32m+[m[32m        })[m
[32m+[m[32m        .then(response=> {[m
[32m+[m[32m        // No more login attempts, throw an error[m
[32m+[m[32m            if (this.state.loginAttempts === 0) throw 'locked out';[m
[32m+[m[32m        // OK response, credentials accepted[m
[32m+[m[32m            if (response.status === 200) {[m
[32m+[m[32m                this.setState({[m
[32m+[m[32m                    userCredentials: userCredentials,[m
[32m+[m[32m                    loginForm: false,[m
[32m+[m[32m                    loginFail: false[m
[32m+[m[32m                });[m
[32m+[m[32m            } else {[m
[32m+[m[32m        // Credentials are wrong[m
[32m+[m[32m                this.setState((state) => {[m
[32m+[m[32m                    return ({[m
[32m+[m[32m                        loginFail: true,[m
[32m+[m[32m                        loginAttempts: state.loginAttempts - 1[m
[32m+[m[32m                    });[m
[32m+[m[32m                });[m
[32m+[m[32m            }[m
[32m+[m[32m        })[m
[32m+[m[32m        .catch(error => {[m
[32m+[m[32m            console.log(error);[m
[32m+[m[32m        })[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    register(){[m
[32m+[m[32m        this.setState({[m
[32m+[m[32m            registrationForm: true[m
[32m+[m[32m        });[m
[32m+[m[32m    }[m
[32m+[m[41m        [m
[32m+[m[32m    addNewUser(userDetails) {[m
[32m+[m[32m        fetch(`${process.env.API_URL}/users`, {[m
[32m+[m[32m            method: 'POST',[m
[32m+[m[32m            headers: {[m
[32m+[m[32m                'Content-Type': 'application/json'[m
[32m+[m[32m            },[m
[32m+[m[32m            body: JSON.stringify(userDetails)[m
[32m+[m[32m        })[m
[32m+[m[32m        .then(response=> {[m
[32m+[m[32m            if (response.status === 201) {[m
[32m+[m[32m            // User successfully registered[m
[32m+[m[32m            // disable the Registration Form[m
[32m+[m[32m            this.setState({[m
[32m+[m[32m                registrationForm: false,[m
[32m+[m[32m                registrationFail: false[m
[32m+[m[32m            });[m
[32m+[m[32m            } else {[m
[32m+[m[32m            // Some Error or User already exists[m
[32m+[m[32m                this.setState({[m
[32m+[m[32m                    registrationFail: true[m
[32m+[m[32m                });[m
[32m+[m[32m            }[m
[32m+[m[32m        })[m
[32m+[m[32m        .catch(error => {[m
[32m+[m[32m            console.log(error);[m
[32m+[m[32m        });[m
[32m+[m[32m    }[m
[32m+[m[41m        [m
     render() {[m
[31m-        return ([m
[31m-            <div>[m
[31m-                <NewMsg addMsgCallback={this.addMessage} />[m
[31m-                <MsgList messages={this.state.messages}/>[m
[31m-            </div>[m
[31m-        );[m
[32m+[m[32m        if (this.state.registrationForm){[m
[32m+[m[32m            let failedRegistration;[m
[32m+[m
[32m+[m[32m            if (this.state.registrationFail){[m
[32m+[m[32m                failedRegistration =[m[41m [m
[32m+[m[32m                <p className="text-danger">[m
[32m+[m[32m                    User already registered or registration error.[m
[32m+[m[32m                </p>[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            return ([m
[32m+[m[32m                <div>[m
[32m+[m[32m                    <Registration registerNewUserCallback={this.addNewUser}/>[m
[32m+[m[32m                    {failedRegistration}[m
[32m+[m[32m                </div>[m
[32m+[m[32m            )[m
[32m+[m[32m        } else {[m
[32m+[m[32m            let form;[m
[32m+[m
[32m+[m[32m            if (this.state.loginForm) {[m
[32m+[m[32m                form = <Login registerCallback={this.register}[m
[32m+[m[32m                loginCallback={this.login}[m
[32m+[m[32m                loginFail={this.state.loginFail}[m
[32m+[m[32m                loginAttempts={this.state.loginAttempts}[m
[32m+[m[32m                />[m
[32m+[m[32m            } else {[m
[32m+[m[32m                form = <NewMsg addMsgCallback={this.addMessage} />[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            return ([m
[32m+[m[32m                <div>[m
[32m+[m[32m                    {form}[m
[32m+[m[32m                    <MsgList messages={this.state.messages} />[m
[32m+[m[32m                </div>[m
[32m+[m[32m            );[m
[32m+[m[32m        }[m
     }[m
[32m+[m[41m        [m
 }[m
 [m
 module.exports = MsgBoard;[m
[1mdiff --git a/client_side/Registration.jsx b/client_side/Registration.jsx[m
[1mnew file mode 100644[m
[1mindex 0000000..604f215[m
[1m--- /dev/null[m
[1m+++ b/client_side/Registration.jsx[m
[36m@@ -0,0 +1,361 @@[m
[32m+[m[32m'use strict';[m
[32m+[m[32m/*************************************************[m
[32m+[m[32m* Registration Component for ICS 221 Lab 7[m
[32m+[m[32m* ----------------------------------------[m
[32m+[m[32m*[m
[32m+[m[32m* Author: Jason Cumiskey[m
[32m+[m[32m*[m
[32m+[m[32m* Date: March 10, 2019[m
[32m+[m[32m*[m
[32m+[m[32m* Version: 0.1[m
[32m+[m[32m*[m
[32m+[m[32m* This Component is a registration form to be used[m
[32m+[m[32m* with Lab 7 in ICS 221.[m
[32m+[m[32m*[m
[32m+[m[32m* Notes:[m
[32m+[m[32m* - This Component is fairly complex and should[m
[32m+[m[32m* be broken down into several smaller components.[m
[32m+[m[32m* - I'll add it to my to-do list.[m
[32m+[m[32m* - Tests should be written for it (TDD)[m
[32m+[m[32m*[m
[32m+[m[32m**************************************************/[m
[32m+[m[32mconst React = require('react');[m
[32m+[m[32mconst rules = require('./rules');[m
[32m+[m[32mconst Filter = require('bad-words');[m
[32m+[m
[32m+[m[32mclass Registration extends React.Component {[m
[32m+[m[32m  constructor(props) {[m
[32m+[m[32m    super(props);[m
[32m+[m[32m    this.handleUsername = this.handleUsername.bind(this);[m
[32m+[m[32m    this.handleConfirmPassword = this.handleConfirmPassword.bind(this);[m
[32m+[m[32m    this.registerUser = this.registerUser.bind(this);[m
[32m+[m[32m    this.checkPassword = this.checkPassword.bind(this);[m
[32m+[m[32m    this.checkEmail = this.checkEmail.bind(this);[m
[32m+[m[32m    this.state = {[m
[32m+[m[32m      email: '',[m
[32m+[m[32m      user: '',[m
[32m+[m[32m      pass: '',[m
[32m+[m[32m      rpass: '',[m
[32m+[m[32m      strength: {},[m
[32m+[m[32m      allFieldsOk: {[m
[32m+[m[32m        email: false,[m
[32m+[m[32m        user: false,[m
[32m+[m[32m        pass: false,[m
[32m+[m[32m        rpass: false[m
[32m+[m[32m      }[m
[32m+[m[32m    };[m
[32m+[m[32m  }[m
[32m+[m[41m  [m
[32m+[m[32m  /* This method checks the password the user is entering.[m
[32m+[m[32m     It builds a JS object of the rules as they pass and saves[m
[32m+[m[32m     it as a state variable called strength. If the length of strength[m
[32m+[m[32m     is equivalent to the length of all the rules, then all rules have passed[m
[32m+[m[32m     and we can set fields.pass to true and update the allFieldsOk state variable.[m
[32m+[m[32m  */[m
[32m+[m[32m  checkPassword(event) {[m
[32m+[m[32m    const password = event.target.value;[m
[32m+[m[41m    [m
[32m+[m[32m    this.setState({[m
[32m+[m[32m      pass: password[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    /* build an object strength with each key matching[m
[32m+[m[32m       one of the rules. If the value is true, the password[m
[32m+[m[32m       conforms to that rule[m
[32m+[m[32m    */[m
[32m+[m[32m    let strength = {};[m
[32m+[m[32m    for (const [ ruleName, rule ] of Object.entries(rules)) {[m
[32m+[m[32m      if (rule.pattern.test(password)) {[m
[32m+[m[32m        strength[ruleName] = true;[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    this.setState({[m
[32m+[m[32m        strength: strength[m
[32m+[m[32m      },[m
[32m+[m[32m      () => {[m
[32m+[m[32m        /* This callback determines if the password[m
[32m+[m[32m         conforms to all rules by determining if the[m
[32m+[m[32m         strength object has as many keys as the rules[m
[32m+[m[32m         object. If so, then set fields.pass to true.[m
[32m+[m[32m        */[m
[32m+[m[32m        let fields = Object.assign(this.state.allFieldsOk);[m
[32m+[m[41m        [m
[32m+[m[32m        if ([m
[32m+[m[32m          Object.keys(this.state.strength).length ===[m[41m [m
[32m+[m[32m            Object.keys(rules).length[m
[32m+[m[32m        ) {[m
[32m+[m[32m          fields.pass = true;[m
[32m+[m[32m        } else {[m
[32m+[m[32m          fields.pass = false;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* This is an edge case whereby a User[m
[32m+[m[32m           has entered a 'confirm password' and[m
[32m+[m[32m           then changes the password to match/unmatch[m
[32m+[m[32m           it[m
[32m+[m[32m        */[m
[32m+[m[32m        if ( password === this.state.rpass) {[m
[32m+[m[32m          fields.rpass = true;[m
[32m+[m[32m        } else {[m
[32m+[m[32m          fields.rpass = false;[m
[32m+[m[32m        }[m
[32m+[m[41m        [m
[32m+[m[32m        this.setState({[m
[32m+[m[32m          allFieldsOk: fields[m
[32m+[m[32m        });[m
[32m+[m[32m      }[m
[32m+[m[32m    );[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[41m  [m
[32m+[m[32m  /* This method checks the email address entered against a regular expression.[m
[32m+[m[32m     If the email passes, then fields.email is set to true and the allFieldsOk[m
[32m+[m[32m     state variable is updated with the new value.[m
[32m+[m[32m  */[m
[32m+[m[32m  checkEmail(event) {[m
[32m+[m[32m    const emailRegEx = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;[m
[32m+[m
[32m+[m[32m    let email = event.target.value;[m
[32m+[m[41m    [m
[32m+[m[32m    // make it all lowercase[m
[32m+[m[32m    email = email.toLowerCase();[m
[32m+[m[41m    [m
[32m+[m[32m    let fields = Object.assign(this.state.allFieldsOk);[m[41m  [m
[32m+[m[41m    [m
[32m+[m[32m    this.setState({[m
[32m+[m[32m      email: email[m
[32m+[m[32m    }, () => {[m
[32m+[m[32m      if (emailRegEx.test(email)) {[m
[32m+[m[32m        // email passes regex[m
[32m+[m[32m        fields.email = true;[m
[32m+[m[32m      } else {[m
[32m+[m[32m        fields.email = false;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      this.setState({[m
[32m+[m[32m        allFieldsOk: fields[m
[32m+[m[32m      });[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  /* This handles the username entered. It uses the 'bad-words' module[m
[32m+[m[32m     to replace bad words with spaces. It also trims whitespace.[m
[32m+[m[32m     Then it updates the state and checks if it is between 3 and 20[m
[32m+[m[32m     characters. If so, it's valid. Update the AllFieldsOk state.[m
[32m+[m[32m  */[m
[32m+[m[32m  handleUsername(event) {[m
[32m+[m[32m    let user = event.target.value;[m
[32m+[m[32m    let filter = new Filter({ placeHolder: ' ' });[m
[32m+[m[32m    let fields = Object.assign(this.state.allFieldsOk);[m
[32m+[m
[32m+[m[32m    // any bad words are replaced with spaces[m
[32m+[m[32m    user = filter.clean(user);[m
[32m+[m[32m    // before checking length, trim whitespace[m
[32m+[m[32m    user = user.trim();[m
[32m+[m[41m    [m
[32m+[m[32m    this.setState({[m
[32m+[m[32m      user: user[m
[32m+[m[32m    }, () => {[m
[32m+[m[32m      /* Simply check that the Username[m
[32m+[m[32m         is between 3 and 20 characters[m
[32m+[m[32m      */[m
[32m+[m[32m      if (user.length > 2 && user.length < 21) {[m
[32m+[m[32m        fields.user = true;[m
[32m+[m[32m      } else {[m
[32m+[m[32m        fields.user = false;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      this.setState({[m
[32m+[m[32m        allFieldsOk: fields[m
[32m+[m[32m      });[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  /* This handles the confirm password element. It checks[m
[32m+[m[32m     to see that if it is equal to password and updates[m
[32m+[m[32m     allFieldsOk accordingly.[m
[32m+[m[32m  */[m
[32m+[m[32m  handleConfirmPassword(event) {[m
[32m+[m[32m    let fields = Object.assign(this.state.allFieldsOk);[m
[32m+[m[41m      [m
[32m+[m[32m    this.setState({[m
[32m+[m[32m      rpass: event.target.value[m
[32m+[m[32m    }, () => {[m
[32m+[m[32m      if (this.state.rpass === this.state.pass) {[m
[32m+[m[32m        fields.rpass = true;[m
[32m+[m[32m      } else {[m
[32m+[m[32m        fields.rpass = false;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      this.setState({[m
[32m+[m[32m        allFieldsOk: fields[m
[32m+[m[32m      });[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  /* We're doing nothing here other than to pass Control to[m
[32m+[m[32m     MsgBoard and give it the supplied email, username, and[m
[32m+[m[32m     password[m
[32m+[m[32m  */[m
[32m+[m[32m  registerUser(event) {[m
[32m+[m[32m    event.preventDefault();[m
[32m+[m[41m    [m
[32m+[m[32m    if (this.canRegister()) {[m
[32m+[m[32m      // pass control to MsgBoard so it can make the API Call[m
[32m+[m[32m      this.props.registerNewUserCallback({[m
[32m+[m[32m        email: this.state.email,[m
[32m+[m[32m        username: this.state.user,[m
[32m+[m[32m        password: this.state.pass[m
[32m+[m[32m      });[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  /* check if each field passes their tests. */[m
[32m+[m[32m  canRegister() {[m
[32m+[m[32m    let registerEnable = true;[m
[32m+[m[32m    for (const value of Object.values(this.state.allFieldsOk)) {[m
[32m+[m[32m      if (!value) registerEnable = false;[m
[32m+[m[32m    }[m
[32m+[m[32m    return registerEnable;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  render() {[m
[32m+[m[32m    /* This builds a new array with each rule for the password[m
[32m+[m[32m       and whether it has been completed by the user.[m
[32m+[m[32m       This will be used to strike out rules they have done.[m
[32m+[m[32m    */[m[41m [m
[32m+[m[32m    let processedRules = Object.keys(rules).map( (rule, index) => {[m
[32m+[m[32m      return {[m
[32m+[m[32m        key: index,[m
[32m+[m[32m        rule: rules[rule],[m
[32m+[m[32m        isCompleted: this.state.strength[rule] || false[m
[32m+[m[32m      }[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    return ([m
[32m+[m[32m      <div className="card col-8 my-3">[m
[32m+[m[32m        <div className="card-body">[m
[32m+[m[32m          <h4 className="card-title">Register:</h4>[m
[32m+[m[32m            <form onSubmit={this.registerUser}>[m
[32m+[m[32m            <div className="form-group row">[m
[32m+[m[32m              <label[m
[32m+[m[32m                htmlFor="email"[m
[32m+[m[32m                className="col-3 col-form-label text-right"[m
[32m+[m[32m              >[m
[32m+[m[32m                Email:[m
[32m+[m[32m              </label>[m
[32m+[m[32m              <div className="col-9">[m
[32m+[m[32m                <input[m
[32m+[m[32m                  id="email"[m
[32m+[m[32m                  type="email"[m
[32m+[m[32m                  className="form-control"[m
[32m+[m[32m                  placeholder="enter your email"[m
[32m+[m[32m                  value={this.state.email}[m
[32m+[m[32m                  onChange={this.checkEmail}[m
[32m+[m[32m                />[m
[32m+[m[32m              </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div className="col-9 offset-3">[m
[32m+[m[32m              <p className="text-danger">{ !this.state.allFieldsOk.email ? 'invalid email address' : '' }</p>[m[41m    [m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div className="form-group row">[m
[32m+[m[32m              <label htmlFor="user" className="col-3 col-form-label text-right">[m
[32m+[m[32m                Username:[m
[32m+[m[32m              </label>[m
[32m+[m[32m              <div className="col-9">[m
[32m+[m[32m                <input[m
[32m+[m[32m                  id="user"[m
[32m+[m[32m                  type="text"[m
[32m+[m[32m                  className="form-control"[m
[32m+[m[32m                  placeholder="enter a username"[m
[32m+[m[32m                  value={this.state.user}[m
[32m+[m[32m                  onChange={this.handleUsername}[m
[32m+[m[32m                />[m
[32m+[m[32m              </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div className="col-9 offset-3">[m
[32m+[m[32m              <p className="text-danger">{ !this.state.allFieldsOk.user ? 'invalid username' : '' }</p>[m[41m    [m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div className="form-group row">[m
[32m+[m[32m              <label[m
[32m+[m[32m                htmlFor="password"[m
[32m+[m[32m                className="col-3 col-form-label text-right"[m
[32m+[m[32m              >[m
[32m+[m[32m                Enter Password:[m
[32m+[m[32m              </label>[m
[32m+[m[32m              <div className="col-9">[m
[32m+[m[32m                <input[m
[32m+[m[32m                  id="password"[m
[32m+[m[32m                  type="password"[m
[32m+[m[32m                  className="form-control"[m
[32m+[m[32m                  placeholder="enter a password"[m
[32m+[m[32m                  value={this.state.pass}[m
[32m+[m[32m                  onChange={this.checkPassword}[m
[32m+[m[32m                />[m
[32m+[m[32m              </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div className="row">[m
[32m+[m[32m              <div className="col-9 offset-3">[m
[32m+[m[32m                <ul>[m
[32m+[m[32m                  {processedRules.map( processedRule => {[m
[32m+[m[32m                      if (processedRule.isCompleted) {[m
[32m+[m[32m                        return ([m
[32m+[m[32m                          <li key={processedRule.key}>[m
[32m+[m[32m                            <strike>{processedRule.rule.message}</strike>[m
[32m+[m[32m                          </li>[m
[32m+[m[32m                        )[m
[32m+[m[32m                      } else {[m
[32m+[m[32m                        return ([m
[32m+[m[32m                          <li key={processedRule.key}>[m
[32m+[m[32m                            {processedRule.rule.message}[m
[32m+[m[32m                          </li>[m
[32m+[m[32m                        )[m
[32m+[m[32m                      }[m
[32m+[m[32m                    }[m
[32m+[m[32m                  )}[m
[32m+[m[32m                </ul>[m
[32m+[m[32m              </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div className="form-group row">[m
[32m+[m[32m              <label[m
[32m+[m[32m                htmlFor="repeat-password"[m
[32m+[m[32m                className="col-3 col-form-label text-right"[m
[32m+[m[32m              >[m
[32m+[m[32m                Repeat Password:[m
[32m+[m[32m              </label>[m
[32m+[m[32m              <div className="col-9">[m
[32m+[m[32m                <input[m
[32m+[m[32m                  id="repeat-password"[m
[32m+[m[32m                  type="password"[m
[32m+[m[32m                  className="form-control"[m
[32m+[m[32m                  placeholder="repeat the password"[m
[32m+[m[32m                  value={this.state.rpass}[m
[32m+[m[32m                  onChange={this.handleConfirmPassword}[m
[32m+[m[32m                />[m
[32m+[m[32m              </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div className="col-9 offset-3">[m
[32m+[m[32m              <p className="text-danger">{ !this.state.allFieldsOk.rpass ? 'passwords don\'t match' : '' }</p>[m[41m    [m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div className="form-group row">[m
[32m+[m[32m              <div className="mx-auto">[m
[32m+[m[32m                <button[m
[32m+[m[32m                  type="submit"[m
[32m+[m[32m                  className={[m
[32m+[m[32m                    'btn btn-lg btn-primary ' +[m
[32m+[m[32m                    (this.canRegister() ? '' : 'disabled')[m
[32m+[m[32m                  }[m
[32m+[m[32m                >[m
[32m+[m[32m                  Register[m
[32m+[m[32m                </button>[m
[32m+[m[32m              </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m          </form>[m
[32m+[m[32m        </div>[m
[32m+[m[32m      </div>[m
[32m+[m[32m    );[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = Registration;[m
[1mdiff --git a/client_side/rules.js b/client_side/rules.js[m
[1mnew file mode 100644[m
[1mindex 0000000..4741abf[m
[1m--- /dev/null[m
[1m+++ b/client_side/rules.js[m
[36m@@ -0,0 +1,22 @@[m
[32m+[m[32mmodule.exports = {[m
[32m+[m[32m  upperCase: {[m
[32m+[m[32m    message: 'Must have at least one upper-case letter',[m
[32m+[m[32m    pattern: /([A-Z]+)/[m
[32m+[m[32m  },[m
[32m+[m[32m  lowerCase: {[m
[32m+[m[32m    message: 'Must have at least one lower-case letter',[m
[32m+[m[32m    pattern: /([a-z]+)/[m
[32m+[m[32m  },[m
[32m+[m[32m  special: {[m
[32m+[m[32m    message: 'Must have at least one special character !, @, #, $, %, ^, &, *, (, )',[m
[32m+[m[32m    pattern: /([!@#$%^&*()]+)/[m
[32m+[m[32m  },[m
[32m+[m[32m  number: {[m
[32m+[m[32m    message: 'Must have at least one number',[m
[32m+[m[32m    pattern: /([0-9]+)/[m
[32m+[m[32m  },[m
[32m+[m[32m  minimumChars: {[m
[32m+[m[32m    message: 'Must be at least 8 characters',[m
[32m+[m[32m    pattern: /(.{8,})/[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/package-lock.json b/package-lock.json[m
[1mindex b2b1f8a..7f256cc 100644[m
[1m--- a/package-lock.json[m
[1m+++ b/package-lock.json[m
[36m@@ -482,6 +482,11 @@[m
       "integrity": "sha512-NuHqBY1PB/D8xU6s/thBgOAiAP7HOYDQ32+BFZILJ8ivkUkAHQnWfn6WhL79Owj1qmUnoN/YPhktdIoucipkAQ==",[m
       "dev": true[m
     },[m
[32m+[m[32m    "abbrev": {[m
[32m+[m[32m      "version": "1.1.1",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/abbrev/-/abbrev-1.1.1.tgz",[m
[32m+[m[32m      "integrity": "sha512-nne9/IiQ/hzIhY6pdDnbBtz7DjPTKrY00P/zvPSm5pOFkl6xuGrGnXn/VtTNNfNtAfZ9/1RtehkszU9qcTii0Q=="[m
[32m+[m[32m    },[m
     "accepts": {[m
       "version": "1.3.5",[m
       "resolved": "https://registry.npmjs.org/accepts/-/accepts-1.3.5.tgz",[m
[36m@@ -554,8 +559,7 @@[m
     "ansi-regex": {[m
       "version": "3.0.0",[m
       "resolved": "https://registry.npmjs.org/ansi-regex/-/ansi-regex-3.0.0.tgz",[m
[31m-      "integrity": "sha1-7QMXwyIGT3lGbAKWa922Bas32Zg=",[m
[31m-      "dev": true[m
[32m+[m[32m      "integrity": "sha1-7QMXwyIGT3lGbAKWa922Bas32Zg="[m
     },[m
     "ansi-styles": {[m
       "version": "3.2.1",[m
[36m@@ -590,8 +594,16 @@[m
     "aproba": {[m
       "version": "1.2.0",[m
       "resolved": "https://registry.npmjs.org/aproba/-/aproba-1.2.0.tgz",[m
[31m-      "integrity": "sha512-Y9J6ZjXtoYh8RnXVCMOU/ttDmk1aBjunq9vO0ta5x85WDQiQfUF9sIPBITdbiiIVcBo03Hi3jMxigBtsddlXRw==",[m
[31m-      "dev": true[m
[32m+[m[32m      "integrity": "sha512-Y9J6ZjXtoYh8RnXVCMOU/ttDmk1aBjunq9vO0ta5x85WDQiQfUF9sIPBITdbiiIVcBo03Hi3jMxigBtsddlXRw=="[m
[32m+[m[32m    },[m
[32m+[m[32m    "are-we-there-yet": {[m
[32m+[m[32m      "version": "1.1.5",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/are-we-there-yet/-/are-we-there-yet-1.1.5.tgz",[m
[32m+[m[32m      "integrity": "sha512-5hYdAkZlcG8tOLujVDTgCT+uPX0VnpAH28gWsLfzpXYm7wP6mp5Q/gYyR7YQ0cKVJcXJnl3j2kpBan13PtQf6w==",[m
[32m+[m[32m      "requires": {[m
[32m+[m[32m        "delegates": "^1.0.0",[m
[32m+[m[32m        "readable-stream": "^2.0.6"[m
[32m+[m[32m      }[m
     },[m
     "arr-diff": {[m
       "version": "4.0.0",[m
[36m@@ -792,11 +804,23 @@[m
       "resolved": "https://registry.npmjs.org/babylon/-/babylon-6.18.0.tgz",[m
       "integrity": "sha512-q/UEjfGJ2Cm3oKV71DJz9d25TPnq5rhBVL2Q4fA5wcC3jcrdn7+SssEybFIxwAvvP+YCsCYNKughoF33GxgycQ=="[m
     },[m
[32m+[m[32m    "bad-words": {[m
[32m+[m[32m      "version": "3.0.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/bad-words/-/bad-words-3.0.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-FwZAyyBOzCbt2Zw6R6vjZgoK2BDVTg0XjsobRkkNlKc/jIHW49j3Kjwtwyb2hxQBZor2aQaQ/NGzf6s7888wlQ==",[m
[32m+[m[32m      "requires": {[m
[32m+[m[32m        "badwords-list": "^1.0.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "badwords-list": {[m
[32m+[m[32m      "version": "1.0.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/badwords-list/-/badwords-list-1.0.0.tgz",[m
[32m+[m[32m      "integrity": "sha1-XphW2/E0gqKVw7CzBK+51M/FxXk="[m
[32m+[m[32m    },[m
     "balanced-match": {[m
       "version": "1.0.0",[m
       "resolved": "https://registry.npmjs.org/balanced-match/-/balanced-match-1.0.0.tgz",[m
[31m-      "integrity": "sha1-ibTRmasr7kneFk6gK4nORi1xt2c=",[m
[31m-      "dev": true[m
[32m+[m[32m      "integrity": "sha1-ibTRmasr7kneFk6gK4nORi1xt2c="[m
     },[m
     "base": {[m
       "version": "0.11.2",[m
[36m@@ -873,6 +897,22 @@[m
         "safe-buffer": "5.1.2"[m
       }[m
     },[m
[32m+[m[32m    "bcrypt": {[m
[32m+[m[32m      "version": "3.0.5",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/bcrypt/-/bcrypt-3.0.5.tgz",[m
[32m+[m[32m      "integrity": "sha512-m4o91nB+Ce8696Ao4R3B/WtVWTc1Lszgd098/OIjU9D/URmdYwT3ooBs9uv1b97J5YhZweTq9lldPefTYZ0TwA==",[m
[32m+[m[32m      "requires": {[m
[32m+[m[32m        "nan": "2.13.1",[m
[32m+[m[32m        "node-pre-gyp": "0.12.0"[m
[32m+[m[32m      },[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "nan": {[m
[32m+[m[32m          "version": "2.13.1",[m
[32m+[m[32m          "resolved": "https://registry.npmjs.org/nan/-/nan-2.13.1.tgz",[m
[32m+[m[32m          "integrity": "sha512-I6YB/YEuDeUZMmhscXKxGgZlFnhsn5y0hgOZBadkzfTRrZBtJDZeg6eQf7PYMIEclwmorTKK8GztsyOUSVBREA=="[m
[32m+[m[32m        }[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "big.js": {[m
       "version": "5.2.2",[m
       "resolved": "https://registry.npmjs.org/big.js/-/big.js-5.2.2.tgz",[m
[36m@@ -917,7 +957,6 @@[m
       "version": "1.1.11",[m
       "resolved": "https://registry.npmjs.org/brace-expansion/-/brace-expansion-1.1.11.tgz",[m
       "integrity": "sha512-iCuPHDFgrHX7H2vEI/5xpz07zSHB00TpugqhmYtVmMO6518mCuRMoOYFldEBl0g187ufozdaHgWKcYFb61qGiA==",[m
[31m-      "dev": true,[m
       "requires": {[m
         "balanced-match": "^1.0.0",[m
         "concat-map": "0.0.1"[m
[36m@@ -1171,8 +1210,7 @@[m
     "chownr": {[m
       "version": "1.1.1",[m
       "resolved": "https://registry.npmjs.org/chownr/-/chownr-1.1.1.tgz",[m
[31m-      "integrity": "sha512-j38EvO5+LHX84jlo6h4UzmOwi0UgW61WRyPtJz4qaadK5eY3BTS5TY/S1Stc3Uk2lIM6TPevAlULiEJwie860g==",[m
[31m-      "dev": true[m
[32m+[m[32m      "integrity": "sha512-j38EvO5+LHX84jlo6h4UzmOwi0UgW61WRyPtJz4qaadK5eY3BTS5TY/S1Stc3Uk2lIM6TPevAlULiEJwie860g=="[m
     },[m
     "chrome-trace-event": {[m
       "version": "1.0.0",[m
[36m@@ -1237,8 +1275,7 @@[m
     "code-point-at": {[m
       "version": "1.1.0",[m
       "resolved": "https://registry.npmjs.org/code-point-at/-/code-point-at-1.1.0.tgz",[m
[31m-      "integrity": "sha1-DQcLTQQ6W+ozovGkDi7bPZpMz3c=",[m
[31m-      "dev": true[m
[32m+[m[32m      "integrity": "sha1-DQcLTQQ6W+ozovGkDi7bPZpMz3c="[m
     },[m
     "collection-visit": {[m
       "version": "1.0.0",[m
[36m@@ -1280,8 +1317,7 @@[m
     "concat-map": {[m
       "version": "0.0.1",[m
       "resolved": "https://registry.npmjs.org/concat-map/-/concat-map-0.0.1.tgz",[m
[31m-      "integrity": "sha1-2Klr13/Wjfd5OnMDajug1UBdR3s=",[m
[31m-      "dev": true[m
[32m+[m[32m      "integrity": "sha1-2Klr13/Wjfd5OnMDajug1UBdR3s="[m
     },[m
     "concat-stream": {[m
       "version": "1.6.2",[m
[36m@@ -1304,6 +1340,11 @@[m
         "date-now": "^0.1.4"[m
       }[m
     },[m
[32m+[m[32m    "console-control-strings": {[m
[32m+[m[32m      "version": "1.1.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/console-control-strings/-/console-control-strings-1.1.0.tgz",[m
[32m+[m[32m      "integrity": "sha1-PXz0Rk22RG6mRL9LOVB/mFEAjo4="[m
[32m+[m[32m    },[m
     "constantinople": {[m
       "version": "3.1.2",[m
       "resolved": "https://registry.npmjs.org/constantinople/-/constantinople-3.1.2.tgz",[m
[36m@@ -1387,8 +1428,7 @@[m
     "core-util-is": {[m
       "version": "1.0.2",[m
       "resolved": "https://registry.npmjs.org/core-util-is/-/core-util-is-1.0.2.tgz",[m
[31m-      "integrity": "sha1-tf1UIgqivFq1eqtxQMlAdUUDwac=",[m
[31m-      "dev": true[m
[32m+[m[32m      "integrity": "sha1-tf1UIgqivFq1eqtxQMlAdUUDwac="[m
     },[m
     "create-ecdh": {[m
       "version": "4.0.3",[m
[36m@@ -1497,6 +1537,11 @@[m
       "integrity": "sha1-6zkTMzRYd1y4TNGh+uBiEGu4dUU=",[m
       "dev": true[m
     },[m
[32m+[m[32m    "deep-extend": {[m
[32m+[m[32m      "version": "0.6.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/deep-extend/-/deep-extend-0.6.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-LOHxIOaPYdHlJRtCQfDIVZtfw/ufM8+rVj649RIHzcm/vGwQRXFt6OPqIFWsm2XEMrNIEtWR64sY1LEKD2vAOA=="[m
[32m+[m[32m    },[m
     "define-properties": {[m
       "version": "1.1.3",[m
       "resolved": "https://registry.npmjs.org/define-properties/-/define-properties-1.1.3.tgz",[m
[36m@@ -1553,6 +1598,11 @@[m
         }[m
       }[m
     },[m
[32m+[m[32m    "delegates": {[m
[32m+[m[32m      "version": "1.0.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/delegates/-/delegates-1.0.0.tgz",[m
[32m+[m[32m      "integrity": "sha1-hMbhWbgZBP3KWaDvRM2HDTElD5o="[m
[32m+[m[32m    },[m
     "depd": {[m
       "version": "1.1.2",[m
       "resolved": "https://registry.npmjs.org/depd/-/depd-1.1.2.tgz",[m
[36m@@ -1579,6 +1629,11 @@[m
       "integrity": "sha1-8NZtA2cqglyxtzvbP+YjEMjlUrc=",[m
       "dev": true[m
     },[m
[32m+[m[32m    "detect-libc": {[m
[32m+[m[32m      "version": "1.0.3",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/detect-libc/-/detect-libc-1.0.3.tgz",[m
[32m+[m[32m      "integrity": "sha1-+hN8S9aY7fVc1c0CrFWfkaTEups="[m
[32m+[m[32m    },[m
     "diffie-hellman": {[m
       "version": "5.0.3",[m
       "resolved": "https://registry.npmjs.org/diffie-hellman/-/diffie-hellman-5.0.3.tgz",[m
[36m@@ -2127,6 +2182,14 @@[m
         "readable-stream": "^2.0.0"[m
       }[m
     },[m
[32m+[m[32m    "fs-minipass": {[m
[32m+[m[32m      "version": "1.2.5",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/fs-minipass/-/fs-minipass-1.2.5.tgz",[m
[32m+[m[32m      "integrity": "sha512-JhBl0skXjUPCFH7x6x61gQxrKyXsxB5gcgePLZCwfyCGGsTISMoIeObbrvVeP6Xmyaudw4TT43qV2Gz+iyd2oQ==",[m
[32m+[m[32m      "requires": {[m
[32m+[m[32m        "minipass": "^2.2.1"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "fs-write-stream-atomic": {[m
       "version": "1.0.10",[m
       "resolved": "https://registry.npmjs.org/fs-write-stream-atomic/-/fs-write-stream-atomic-1.0.10.tgz",[m
[36m@@ -2142,8 +2205,7 @@[m
     "fs.realpath": {[m
       "version": "1.0.0",[m
       "resolved": "https://registry.npmjs.org/fs.realpath/-/fs.realpath-1.0.0.tgz",[m
[31m-      "integrity": "sha1-FQStJSMV