const React = require('react');
const MsgList = require('./MsgList.jsx');
const NewMsg = require('./NewMsg.jsx');
const Login = require('./Login.jsx')
const Registration = require('../../client_side/Registration.jsx');

class MsgBoard extends React.Component {
    constructor(props){
        super(props);
        this.state = {
            messages: this.props.messages,
            loginForm: true,
            loginAttempts: 3,
            loginFail: false, 
            userCredentials: {
                password: '',
                name: ''
            },
            registrationForm: false,
            registrationFail: false
        };
        this.addMessage = this.addMessage.bind(this);
        this.login = this.login.bind(this);
        this.register = this.register.bind(this);
        this.addNewUser = this.addNewUser.bind(this);
    }

    componentDidMount() {
        fetch(`${process.env.API_URL}/msgs`).then(response => response.json())
        .then(messages => this.setState({ messages }));
    }

    handleHTTPErrors(response) {
        if (!response.ok) throw Error (response.status + ": " + response.statusText);
        return response;
    }

    addMessage(message) {
        // TODO: make API call to store new message and updt state var message
        const basicString = this.state.userCredentials.name + ':' + this.state.userCredentials.password;
        let msgs = this.state.messages;

        //add id attribute
        message.id = msgs.length;
        //append to array
        msgs.push(message);
        //update state var
        this.setState({ messages: msgs });

        //update back-end data
        fetch(`${process.env.API_URL}/msgs`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Basic ' + btoa(basicString)
            },
            body: JSON.stringify(message)
        }).then(response => this.handleHTTPErrors(response))
        .then(result => result.json())
        .then(result => {
            this.setState({messages: [result].concat(this.state.messages)});
        })
        .catch(error => { console.log(error); });
    }

    login(userCredentials) {
        // userCredentials is passed in from Login Component
        // For Basic Authentication it is username:password (but we're using email)
        const basicString = userCredentials.name + ':' + userCredentials.password;
        
        fetch(`${process.env.API_URL}/users/login`, {
            method: 'GET',
            headers: {
                'Authorization': 'Basic ' + btoa(basicString)
            }
        })
        .then(response=> {
        // No more login attempts, throw an error
            if (this.state.loginAttempts === 0) throw 'locked out';
        // OK response, credentials accepted
            if (response.status === 200) {
                this.setState({
                    userCredentials: userCredentials,
                    loginForm: false,
                    loginFail: false
                });
            } else {
        // Credentials are wrong
                this.setState((state) => {
                    return ({
                        loginFail: true,
                        loginAttempts: state.loginAttempts - 1
                    });
                });
            }
        })
        .catch(error => {
            console.log(error);
        })
    }

    register(){
        this.setState({
            registrationForm: true
        });
    }
        
    addNewUser(userDetails) {
        fetch(`${process.env.API_URL}/users`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(userDetails)
        })
        .then(response=> {
            if (response.status === 201) {
            // User successfully registered
            // disable the Registration Form
            this.setState({
                registrationForm: false,
                registrationFail: false
            });
            } else {
            // Some Error or User already exists
                this.setState({
                    registrationFail: true
                });
            }
        })
        .catch(error => {
            console.log(error);
        });
    }
        
    render() {
        if (this.state.registrationForm){
            let failedRegistration;

            if (this.state.registrationFail){
                failedRegistration = 
                <p className="text-danger">
                    User already registered or registration error.
                </p>
            }

            return (
                <div>
                    <Registration registerNewUserCallback={this.addNewUser}/>
                    {failedRegistration}
                </div>
            )
        } else {
            let form;

            if (this.state.loginForm) {
                form = <Login registerCallback={this.register}
                loginCallback={this.login}
                loginFail={this.state.loginFail}
                loginAttempts={this.state.loginAttempts}
                />
            } else {
                form = <NewMsg name={this.state.userCredentials.name} addMsgCallback={this.addMessage} />
            }

            return (
                <div>
                    {form}
                    <MsgList messages={this.state.messages} />
                </div>
            );
        }
    }
        
}

module.exports = MsgBoard;
    
    
