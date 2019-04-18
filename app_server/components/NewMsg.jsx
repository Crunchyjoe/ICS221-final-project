const React = require('react');


class NewMsg extends React.Component {
    constructor(props) {
        super(props);
        this.state = {name: "", msg: ""};
        this.handleText = this.handleText.bind(this);
        this.addMessage = this.addMessage.bind(this);
        this.deleteAllMessages = this.deleteAllMessages.bind(this);
        this.renderDeleteAll = this.renderDeleteAll.bind(this);
    }

    handleText(event) {
        this.setState ({ msg: event.target.value });
    }

    addMessage(event) {
        event.preventDefault();

        //save state vars to local
        let name = this.props.name;
        let msg = this.state.msg;

        //make sure neither field is empty
        if(!name || !msg) {
            return console.error('Msg cannot be empty');
        }
        //trim whitespace
        msg = msg.trim();

        //pass control to MsgBoard to make api call
        this.props.addMsgCallback({ name: name, msg: msg });
        this.setState({clickedDeleteAll: false});
    }

    deleteAllMessages(event){
        if (this.props.adminLoggedIn){
            fetch(`${process.env.API_URL}/msgs`, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json'
                },
            })
            .catch(error => { console.log(error); });
        }
    }

    renderDeleteAll(){
        const deleteStyle = {
            borderRadius: "5px",
            color: "RED",
            backgroundColor: "WHITE",
            borderColor: "RED"
        }
        if (this.props.adminLoggedIn){
            return (
                <form onSubmit={this.addMessage}>
                    <div className="form-group">
                        <div className="row">
                            <label htmlFor="msg" className="col-7 col-form-label">
                                Enter Message:
                            </label>
                        </div>
                        <div className="row">
                            <div className="col-7">
                                <input id="msg" type="text" className="form-control"
                                    placeholder="Your Message" value={this.state.msg} onChange={this.handleText}
                                />
                            </div>
                            <div className="col-2">
                                <button type="submit" className="btn btn-primary">
                                    Post
                                </button>
                            </div>
                            <div className="col-2">
                                <button style={deleteStyle} type="button" onClick={() => this.deleteAllMessages()}>
                                    Delete all
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            )
        } else {
            return (
                <form onSubmit={this.addMessage}>
                    <div className="form-group">
                        <div className="row">
                            <label htmlFor="msg" className="col-7 col-form-label">
                                Enter Message:
                            </label>
                        </div>
                        <div className="row">
                            <div className="col-7">
                                <input id="msg" type="text" className="form-control"
                                    placeholder="Your Message" value={this.state.msg} onChange={this.handleText}
                                />
                            </div>
                            <div className="col-2">
                                <button type="submit" className="btn btn-primary">
                                    Post
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            )
        }
    }

    render() {
        return (this.renderDeleteAll());
    }
}

module.exports = NewMsg;
