function showUserSelectPage() {
    return { type: 'showUserSelectPage' };
}

function resetCheckedInUsers() {
    return { type: 'resetCheckedInUsers' };
}

function showCheckInPage() {
    return { type: 'showCheckInPage' };
}

function showCheckedInPage() {
    return { type: 'showCheckedInPage' };
}

function checkInUser(id) {
    return { type: 'checkInUser', id: id };
}

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
                <button onClick={() => dispatch(showUserSelectPage())}>Check In</button>
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
                <button onClick={() => dispatch(showUserSelectPage())}>Check-in someone else</button>
                <button onClick={() => {
                    dispatch(resetCheckedInUsers());
                    dispatch(showCheckInPage());
                }}>Reset</button>
           </p>
        </div>
    );
}

function CheckInUserPage(props) {
    return (
        <UserSelect users={props.users} selectUser={(id) => {
            dispatch(checkInUser(id));
            dispatch(showCheckedInPage());
        }} />
    );
}

function App(props) {
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

var reducers = [
    function(action) {
        console.log(action);
        switch (action.type) {
            case 'checkInUser':
                id = parseInt(action.id, 10);
                store.checkedInUsers = store.checkedInUsers || [];
                store.checkedInUsers.push(id);
                break;
            case 'resetCheckedInUsers':
                store.checkedInUsers = [];
                break;
            case 'showUserSelectPage':
                store.currentPage = 'user-select';
                redraw();
                break;
            case 'showCheckInPage':
                store.currentPage = 'check-in';
                redraw();
                break;
            case 'showCheckedInPage':
                store.currentPage = 'checked-in';
                redraw();
                break;
        }
    }
];

function dispatch(action) {
    _.each(reducers, function(reduce) {
        reduce(action);
    });
}

function redraw() {
    ReactDOM.render(
        <App {...store} />,
        document.getElementById('root')
    );
}

redraw();
