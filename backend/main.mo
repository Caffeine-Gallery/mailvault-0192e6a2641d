import Bool "mo:base/Bool";

import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

actor {
    // Types
    type LoginResult = {
        #ok : Bool;
        #err : Text;
    };

    type Session = {
        userId: Text;
        expiry: Time.Time;
    };

    // Stable storage for upgrades
    private stable var usersEntries : [(Text, Text)] = [];
    private stable var sessionsEntries : [(Text, Session)] = [];

    // Runtime storage
    private var users = HashMap.HashMap<Text, Text>(0, Text.equal, Text.hash);
    private var sessions = HashMap.HashMap<Text, Session>(0, Text.equal, Text.hash);

    // Initialize some test users
    private func init() {
        users.put("test@example.com", "password123");
    };

    // Login function
    public shared(msg) func login(email: Text, password: Text) : async LoginResult {
        // Basic input validation
        if (Text.size(email) == 0) {
            return #err("Email is required");
        };
        
        if (Text.size(password) == 0) {
            return #err("Password is required");
        };

        // Check if user exists and password matches
        switch (users.get(email)) {
            case (?storedPassword) {
                if (password == storedPassword) {
                    // Create session
                    let sessionId = Principal.toText(msg.caller);
                    let session : Session = {
                        userId = email;
                        expiry = Time.now() + (3600 * 1000000000); // 1 hour in nanoseconds
                    };
                    sessions.put(sessionId, session);
                    
                    #ok(true)
                } else {
                    #err("Invalid password")
                }
            };
            case null {
                #err("User not found")
            };
        }
    };

    // Logout function
    public shared(msg) func logout() : async Bool {
        let sessionId = Principal.toText(msg.caller);
        sessions.delete(sessionId);
        true
    };

    // Check if session is valid
    public shared(msg) func isSessionValid() : async Bool {
        let sessionId = Principal.toText(msg.caller);
        
        switch (sessions.get(sessionId)) {
            case (?session) {
                if (session.expiry > Time.now()) {
                    true
                } else {
                    sessions.delete(sessionId);
                    false
                }
            };
            case null {
                false
            };
        }
    };

    // System functions for upgrades
    system func preupgrade() {
        // Convert HashMaps to stable arrays before upgrade
        usersEntries := Iter.toArray(users.entries());
        sessionsEntries := Iter.toArray(sessions.entries());
    };

    system func postupgrade() {
        // Reconstruct HashMaps from stable storage
        users := HashMap.fromIter<Text, Text>(
            Iter.fromArray(usersEntries), 
            0, 
            Text.equal, 
            Text.hash
        );
        
        sessions := HashMap.fromIter<Text, Session>(
            Iter.fromArray(sessionsEntries),
            0,
            Text.equal,
            Text.hash
        );

        // Clear stable storage
        usersEntries := [];
        sessionsEntries := [];

        // Initialize test data if needed
        if (users.size() == 0) {
            init();
        };
    };
}
