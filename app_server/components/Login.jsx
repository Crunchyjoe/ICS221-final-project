const React = require('react');

class Login extends React.Component {
    constructor(props){
        super(props);
        this.state = {name: '', password: ''};
        this.handleText = this.handleText.bind(this);
        this.login = this.login.bind(this);
        this.register = this.register.bind(this);
    }

    handleText(event){
        if(event.target.id === 'userName') {
            this.setState({ name: event.target.value });
        }
        else {
            this.setState ({ password: event.target.value });
        }
    }

    register(event){
        this.props.registerCallback();
    }

    login(event){
        event.preventDefault();

        //pass control to MsgBoard and send email and password
        this.props.loginCallback({
            name: this.state.name,
            password: this.state.password
        });
    }

    render(){
        var inputStyle = {
            borderRadius: "5px"
        };
        var submitStyle = {
            borderRadius: "5px",
            backgroundColor: "BLUE",
            color: "WHITE"

        };

        var registerStyle = {
            borderRadius: "5px",
            color: "BLUE",
            backgroundColor: "WHITE",
            borderColor: "BLUE"
        };
        
        var cardStyle = {
            width: "50rem"
        };

        var notRegisterStyle = {
            background: "none",
            border: "none",
            margin: 0,
            padding: 0,
            cursor: "pointer"
        };
        
        let loginFailText;
        if (this.props.loginFail){
            loginFailText = <p className="card-text pt-1 text-danger">Failed Login Attempt.
            &nbsp;{ this.props.loginAttempts } attempts remaining.</p>
        }

        return(
            <div className="card" style={cardStyle}>
                <div className="card-body">
                    <div className="container">
                        <form method="POST" onSubmit={this.login}>
                            <div className="row">
                                <div className="col">
                                    <h3>Log in to post a Message:</h3>
                                </div>
                            </div>
                            <div className="row">
                                <div className="col">
                                    <label className="m-2" htmlFor="userName">User Name:</label>                        
                                    <input className="m-2" style={inputStyle} type="text" id="userName" placeholder="enter user name" onChange={this.handleText}></input>
                                    <label className="m-2" htmlFor="password">Password:</label>
                                    <input className="m-2" style={inputStyle} type="Password" id="password" placeholder="enter password" onChange={this.handleText}></input>
                                    <button className="m-2" type="submit" style={submitStyle}>Log In</button>
                                </div>
                            </div>
        
                        </form>
                        <div className="row">
                            <div className="col">
                                <p className="m-2" style={notRegisterStyle}>Not Registered&#63;</p>
                                <button onClick={this.register} style={registerStyle}>Register</button>
                                {loginFailText}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        )
    }
}

module.exports = Login;