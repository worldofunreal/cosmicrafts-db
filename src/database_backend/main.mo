import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";

actor UserCanister {
    type UserID = Principal;
    type Username = Text;
    type AvatarID = Nat;
    type UserRecord = { userId: UserID; username: Username; avatar: AvatarID; friends: [UserID] };

    private stable var _userRecords : [(UserID, UserRecord)] = [];
    var userRecords : HashMap.HashMap<UserID, UserRecord> = HashMap.fromIter(_userRecords.vals(), 0, Principal.equal, Principal.hash);

    // Function to register a new user with username and avatar
    public shared({caller : UserID}) func registerUser(username : Username, avatar : AvatarID) : async (Bool, UserID) {
        let userId = caller;
        switch (userRecords.get(userId)) {
            case (null) {
                let newUserRecord : UserRecord = { userId = userId; username = username; avatar = avatar; friends = [] };
                userRecords.put(userId, newUserRecord);
                return (true, userId);
            };
            case (?_) {
                return (false, userId); // User already exists
            };
        };
    };

    // Function to update the username, only the user themselves can update their username
    public shared({caller : UserID}) func updateUsername(username : Username) : async (Bool, UserID) {
        let userId = caller;
        switch (userRecords.get(userId)) {
            case (null) {
                return (false, userId); // User record does not exist
            };
            case (?userRecord) {
                let updatedRecord : UserRecord = { userId = userRecord.userId; username = username; avatar = userRecord.avatar; friends = userRecord.friends };
                userRecords.put(userId, updatedRecord);
                return (true, userId);
            };
        };
    };

    // Function to update the avatar, only the user themselves can update their avatar
    public shared({caller : UserID}) func updateAvatar(avatar : AvatarID) : async (Bool, UserID) {
        let userId = caller;
        switch (userRecords.get(userId)) {
            case (null) {
                return (false, userId); // User record does not exist
            };
            case (?userRecord) {
                let updatedRecord : UserRecord = { userId = userRecord.userId; username = userRecord.username; avatar = avatar; friends = userRecord.friends };
                userRecords.put(userId, updatedRecord);
                return (true, userId);
            };
        };
    };

    // Function to get user details
    public query func getUserDetails(user : UserID) : async ?UserRecord {
        return userRecords.get(user);
    };

    // Function to search for user details by username
    public query func searchUserByUsername(username : Username) : async [UserRecord] {
        let result : Buffer.Buffer<UserRecord> = Buffer.Buffer<UserRecord>(0);
        for ((_, userRecord) in userRecords.entries()) {
            if (userRecord.username == username) {
                result.add(userRecord);
            }
        };
        return Buffer.toArray(result);
    };

    // Function to search for user details by principal ID
    public query func searchUserByPrincipal(userId : UserID) : async ?UserRecord {
        return userRecords.get(userId);
    };

    // Function to add a friend by principal ID
    public shared({caller : UserID}) func addFriend(friendId : UserID) : async (Bool, Text) {
        let userId = caller;
        switch (userRecords.get(userId)) {
            case (null) {
                return (false, "User record does not exist"); // User record does not exist
            };
            case (?userRecord) {
                switch (userRecords.get(friendId)) {
                    case (null) {
                        return (false, "Friend principal not registered"); // Friend principal not registered
                    };
                    case (?_) {
                        let updatedFriends = Buffer.Buffer<UserID>(userRecord.friends.size() + 1);
                        for (friend in userRecord.friends.vals()) {
                            updatedFriends.add(friend);
                        };
                        updatedFriends.add(friendId);
                        let updatedRecord : UserRecord = { userId = userRecord.userId; username = userRecord.username; avatar = userRecord.avatar; friends = Buffer.toArray(updatedFriends) };
                        userRecords.put(userId, updatedRecord);
                        return (true, "Friend added successfully");
                    };
                };
            };
        };
    };

    // Function to get the friends list of the user
    public query({caller : UserID}) func getFriendsList() : async ?[UserID] {
        let userId = caller;
        switch (userRecords.get(userId)) {
            case (null) {
                return null; // User record does not exist
            };
            case (?userRecord) {
                return ?userRecord.friends;
            };
        };
    };

    // Pre-upgrade hook to save the state
    system func preupgrade() {
        _userRecords := Iter.toArray(userRecords.entries());
    };

    // Post-upgrade hook to restore the state
    system func postupgrade() {
        userRecords := HashMap.fromIter(_userRecords.vals(), 0, Principal.equal, Principal.hash);
    };
};
