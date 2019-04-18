const React = require('react');
const MsgList = require('./MsgList.jsx');
const MsgBoard = require('./MsgBoard.jsx');

class Message extends React.Component {
    constructor(props){
        super(props);
        this.state = {
            messageName: this.props.messageName,
            messageID: this.props.messageID,
            index: this.props.index,
            message: this.props.message,
            editing: false,
            messageText: ""
        }
        this.handleDeleteButton = this.handleDeleteButton.bind(this);
        this.handleEditButton = this.handleEditButton.bind(this);
        this.handleChange = this.handleChange.bind(this);
        this.handleSaveButton = this.handleSaveButton.bind(this);
    }

    /*static getDerivedStateFromProps(props, state) {
        if (props.loggedIn !== state.loggedIn) {
          console.log("props was different than state in Message");
          return {
            loggedIn: props.loggedIn
          };
        }
        return null;
      }*/

    handleDeleteButton(event){
        console.log("username at Message.jsx is: " + this.state.messageName + " ID at Message.jsx is: " + this.state.messageID);
        this.props.deleteMessageCallback(this.state.messageID, this.state.messageName);
    }

    handleEditButton(event){
        this.setState({editing: true});
    }

    handleChange(event){
        this.setState({messageText: event.target.value});
    }

    handleCancelButton(event){
        this.setState({editing: false});
    }

    handleSaveButton(event){
        if (this.state.messageText != ""){
            this.props.editMessageCallback(this.state.messageID, this.state.messageName, this.state.messageText);
            this.setState({editing: false})
        }
    }

    loggedInReturn(loggedIn){
        const deleteStyle = {
            borderRadius: "5px",
            color: "RED",
            backgroundColor: "WHITE",
            borderColor: "RED"
        }

        const editStyle = {
            borderRadius: "5px",
            color: "BLUE",
            backgroundColor: "WHITE",
            borderColor: "BLUE"
        }

        if (this.state.editing){
            return (<table className="table table-striped table-bordered">
            <thead>
                <tr>
                    <th scope="col" className="w-15"></th>
                    <th scope="col" className="w-15"></th>
                    <th scope="col" className="w-25">#</th> 
                    <th scope="col" className="w-25">Name</th>
                    <th scope="col" className="w-50">Message</th>  
                </tr>
            </thead>
            <tbody>
                <tr key={this.state.messageID}>
                    <td><button style={deleteStyle} id="delete" onClick={() => this.handleCancelButton()}>Cancel</button></td>
                    <td><button style={deleteStyle} id="save" onClick={() => this.handleSaveButton()}>Save</button></td>
                    <td>{this.state.index}</td>
                    <td>{this.state.messageName}</td>
                    <td><input type="text" onChange={this.handleChange}></input></td>
                </tr>               
            </tbody>
            </table>)
        }
        if (loggedIn){
            console.log("loaded loggedin component");
            return (
                    <table className="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th scope="col" className="w-15"></th>
                            <th scope="col" className="w-15"></th>
                            <th scope="col" className="w-25">#</th> 
                            <th scope="col" className="w-25">Name</th>
                            <th scope="col" className="w-50">Message</th>  
                        </tr>
                    </thead>
                    <tbody>
                        <tr key={this.state.messageID}>
                            <td><button type="submit" id="delete" style={deleteStyle} onClick={() => this.handleDeleteButton()}>Delete</button></td>
                            <td><button id="edit" style={editStyle} onClick={() => this.handleEditButton()}>Edit</button></td>
                            <td>{this.state.index}</td>
                            <td>{this.state.messageName}</td>
                            <td>{this.state.message}</td>
                        </tr>               
                    </tbody>
                    </table>
            );
        } else {
            console.log("loaded notloggedin component");
            return (
                    <table className="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th scope="col" className="w-25">#</th> 
                            <th scope="col" className="w-25">Name</th>
                            <th scope="col" className="w-50">Message</th>  
                        </tr>
                    </thead>
                    <tbody>
                        <tr key={this.state.messageID}>
                            <td>{this.state.index}</td>
                            <td>{this.state.messageName}</td>
                            <td>{this.state.message}</td>
                        </tr>               
                    </tbody>
                    </table>
            );
        }
    }

    render(){
        console.log(this.state.loggedIn);
        return (this.loggedInReturn(this.props.loggedIn));
        }
    }

module.exports = Message;