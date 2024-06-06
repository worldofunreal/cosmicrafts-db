export const idlFactory = ({ IDL }) => {
  const UserID = IDL.Principal;
  const Username = IDL.Text;
  const Description = IDL.Text;
  const RegistrationDate = IDL.Int;
  const AvatarID = IDL.Nat;
  const UserRecord = IDL.Record({
    'username' : Username,
    'userId' : UserID,
    'description' : Description,
    'registrationDate' : RegistrationDate,
    'friends' : IDL.Vec(UserID),
    'avatar' : AvatarID,
  });
  const FriendDetails = IDL.Record({
    'username' : Username,
    'userId' : UserID,
    'avatar' : AvatarID,
  });
  const UserDetails = IDL.Record({
    'user' : UserRecord,
    'friends' : IDL.Vec(FriendDetails),
  });
  return IDL.Service({
    'addFriend' : IDL.Func([UserID], [IDL.Bool, IDL.Text], []),
    'getFriendsList' : IDL.Func([], [IDL.Opt(IDL.Vec(UserID))], ['query']),
    'getUserDetails' : IDL.Func([UserID], [IDL.Opt(UserDetails)], ['query']),
    'registerUser' : IDL.Func([Username, AvatarID], [IDL.Bool, UserID], []),
    'searchUserByPrincipal' : IDL.Func(
        [UserID],
        [IDL.Opt(UserRecord)],
        ['query'],
      ),
    'searchUserByUsername' : IDL.Func(
        [Username],
        [IDL.Vec(UserRecord)],
        ['query'],
      ),
    'updateAvatar' : IDL.Func([AvatarID], [IDL.Bool, UserID], []),
    'updateDescription' : IDL.Func([Description], [IDL.Bool, UserID], []),
    'updateUsername' : IDL.Func([Username], [IDL.Bool, UserID], []),
  });
};
export const init = ({ IDL }) => { return []; };
