export const idlFactory = ({ IDL }) => {
  const UserID = IDL.Principal;
  const Username = IDL.Text;
  const AvatarID = IDL.Nat;
  const UserRecord = IDL.Record({
    'username' : Username,
    'userId' : UserID,
    'avatar' : AvatarID,
  });
  return IDL.Service({
    'getUserDetails' : IDL.Func([UserID], [IDL.Opt(UserRecord)], ['query']),
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
    'updateUsername' : IDL.Func([Username], [IDL.Bool, UserID], []),
  });
};
export const init = ({ IDL }) => { return []; };
