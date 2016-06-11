var UserSelect = React.createClass({
    getInitialState: function() {
        return {
            value: this.props.users[0].id 
        };
    },

    render: function() {
        var props = this.props;
        var users = _.map(props.users, function(user) {
            return (
                <option value={user.id} key={user.id}>
                    {user.name}
                </option>
            );
        });
        return (
            <div>
                <p>User: <select onChange={(e) => this.setState({ value: e.target.value })}>{users}</select></p>
                <p><button onClick={() => props.selectUser(this.state.value)}>Submit</button></p>
            </div>
        );
    }
});

function CheckInPage(props) {
    return (
        <div>
            <h2>Check-in Page</h2>
            <p>
                <button onClick={props.actions.showUserSelectPage}>Check In</button>
            </p>
        </div>
    );
}

function CheckedInPage(props) {
    var users = _.map(props.checkedInUsers, function(id) {
        return _.find(props.users, { id: id });
    });
    return (
        <div>
            <h2>Checked-in Page</h2>
            <p>Users checked in: {_.pluck(users, 'name').join(', ')}</p>
            <p>
                <button onClick={props.actions.showUserSelectPage}>Check-in someone else</button>
                <button onClick={() => {
                    props.actions.resetCheckedInUsers();
                    props.actions.showCheckInPage();
                }}>Reset</button>
           </p>
        </div>
    );
}

function CheckInUserPage(props) {
    return (
        <UserSelect users={props.users} selectUser={(id) => {
            props.actions.checkInUser(id);
            props.actions.showCheckedInPage();
        }} />
    );
}

function App(props) {
    console.log(props.currentPage);
    var currentPage = props.currentPage == 'check-in' ? <CheckInPage {...props} /> :
                      props.currentPage == 'checked-in' ? <CheckedInPage {...props} /> :
                      props.currentPage == 'user-select' ? <CheckInUserPage {...props} /> :
                      null;
    return (
        <div>
            <h1>Application</h1>
            {currentPage}
        </div>
    );
}

///

var store = {
    currentPage: 'check-in',
    users: [
        { name: 'Foo', id: 1 },
        { name: 'Bar', id: 2 },
    ]
};

var actions = {
    checkInUser: function(id) {
        id = parseInt(id, 10);
        store.checkedInUsers = store.checkedInUsers || [];
        store.checkedInUsers.push(id);
    },
    resetCheckedInUsers: function() {
        store.checkedInUsers = [];
    },
    showUserSelectPage: function() {
        store.currentPage = 'user-select';
        redraw();
    },
    showCheckInPage: function() {
        store.currentPage = 'check-in';
        redraw();
    },
    showCheckedInPage: function() {
        store.currentPage = 'checked-in';
        redraw();
    }
};

function redraw() {
    ReactDOM.render(
        <App actions={actions} {...store} />,
        document.getElementById('root')
    );
}

redraw();
