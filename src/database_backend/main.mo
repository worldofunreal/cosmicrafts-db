import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";

actor UserCanister {
    type UserID = Principal;
    type Username = Text;
    type AvatarID = Nat;
    type UserRecord = { userId: UserID; username: Username; avatar: AvatarID };

    private stable var _userRecords : [(UserID, UserRecord)] = [];
    var userRecords : HashMap.HashMap<UserID, UserRecord> = HashMap.fromIter(_userRecords.vals(), 0, Principal.equal, Principal.hash);

    // Function to register a new user with username and avatar
    public shared(msg) func registerUser(username : Username, avatar : AvatarID) : async (Bool, UserID) {
        let userId = msg.caller;
        switch (userRecords.get(userId)) {
            case (null) {
                let newUserRecord : UserRecord = { userId = userId; username = username; avatar = avatar };
                userRecords.put(userId, newUserRecord);
                return (true, userId);
            };
            case (?_) {
                return (false, userId); // User already exists
            };
        };
    };

    // Function to update the username, only the user themselves can update their username
    public shared(msg) func updateUsername(username : Username) : async (Bool, UserID) {
        let userId = msg.caller;
        switch (userRecords.get(userId)) {
            case (null) {
                return (false, userId); // User record does not exist
            };
            case (?userRecord) {
                let updatedRecord : UserRecord = { userId = userRecord.userId; username = username; avatar = userRecord.avatar };
                userRecords.put(userId, updatedRecord);
                return (true, userId);
            };
        };
    };

    // Function to update the avatar, only the user themselves can update their avatar
    public shared(msg) func updateAvatar(avatar : AvatarID) : async (Bool, UserID) {
        let userId = msg.caller;
        switch (userRecords.get(userId)) {
            case (null) {
                return (false, userId); // User record does not exist
            };
            case (?userRecord) {
                let updatedRecord : UserRecord = { userId = userRecord.userId; username = userRecord.username; avatar = avatar };
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
        var result : [UserRecord] = [];
        for ((_, userRecord) in userRecords.entries()) {
            if (userRecord.username == username) {
                result := Array.append(result, [userRecord]);
            }
        };
        return result;
    };

    // Function to search for user details by principal ID
    public query func searchUserByPrincipal(userId : UserID) : async ?UserRecord {
        return userRecords.get(userId);
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
