import ballerina/http;
import ballerina/time;

type User record {
    readonly int id;
    string name;
    int age;
    time:Date birthDate;
    string mobileNumber;
};

table<User> key(id) users = table [
    {
        id: 1,
        name: "Joe",
        age: 30,
        birthDate: {year: 1990, month: 5, day: 5},
        mobileNumber: "0771234567"
    }
];

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

type NewUser record {
    string name;
    int age;
    time:Date birthDate;
    string mobileNumber;
};

service /social\-media on new http:Listener(9090) {
    resource function get users() returns User[]|error? {
        return users.toArray();
    }

    resource function get users/[int id]() returns User|UserNotFound|error? {
        User? user = users[id];
        if user is () {
            UserNotFound userNotFound = {
                body: {
                    message: string `id: ${id}`,
                    details: string `User with id ${id} not found`,
                    timeStamp: time:utcNow()
                }
            };
            return userNotFound;
        }
        if (user is User) {
            return user;
        }
    }

    resource function post users(NewUser newUser) returns http:Created|error? {
        User user = {
            id: users.length() + 1,
            name: newUser.name,
            age: newUser.age,
            birthDate: newUser.birthDate,
            mobileNumber: newUser.mobileNumber
        };
        users.add(user);
        return http:CREATED;

    }

    resource function put users/[int id](NewUser newUser) returns User|UserNotFound|error? {
        User? user = users[id];
        if user is User {
            user.name = newUser.name;
            user.age = newUser.age;
            user.birthDate = newUser.birthDate;
            user.mobileNumber = newUser.mobileNumber;
            return user;
        }

        if user is () {
            UserNotFound userNotFound = {
                body: {
                    message: string `id: ${id}`,
                    details: string `User with id ${id} not found`,
                    timeStamp: time:utcNow()
                }
            };
            return userNotFound;
        }
    }
    resource function delete users/[int id] () returns User|UserNotFound|error? {
        User? user = users[id];
        if user is User {
            return users.remove(id);
        }

        if user is () {
            UserNotFound userNotFound = {
                body: {
                    message: string `id: ${id}`,
                    details: string `User with id ${id} not found`,
                    timeStamp: time:utcNow()
                }
            };
            return userNotFound;
        }

    }

}
