const React = require('react');
const Message = require('./Message.jsx');

class MsgList extends React.Component{
    constructor(props){
        super(props);
        this.state = {
            messages: this.props.messages,
        }
        this.deleteMessage = this.deleteMessage.bind(this);
        this.editMessage = this.editMessage.bind(this);
    }

    /*static getDerivedStateFromProps(props, state) {
        if (props.messages !== state.messages) {
          console.log("props was different than state in Message");
          return {
            messages: props.messages
          };
        }
        return null;
      }*/


    deleteMessage(id, username) {
        console.log("id at MsgList.jsx is: " + id + " username at MsgList.jsx is: " + username);
        this.props.deleteMessageCallback(id, username);
    }
    
    editMessage(id, username, messageText){
        this.props.editMessageCallback(id, username, messageText);
    }

    render() {
        console.log("loggedin in msglist is: " + this.state.loggedIn);
        console.log("loggedin as props is: " + this.props.loggedIn);
        return (
            this.props.messages.map( (message, index) => 
                <Message editMessageCallback={this.editMessage} 
                deleteMessageCallback={this.deleteMessage} loggedIn={this.props.loggedIn} 
                messageName={message.name} messageID={message._id} index={index + 1} message={message.msg}/>
            )
        );
    }
}

module.exports = MsgList;