import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AvatarID = bigint;
export type UserID = Principal;
export interface UserRecord {
  'username' : Username,
  'userId' : UserID,
  'avatar' : AvatarID,
}
export type Username = string;
export interface _SERVICE {
  'getUserDetails' : ActorMethod<[UserID], [] | [UserRecord]>,
  'registerUser' : ActorMethod<[Username, AvatarID], [boolean, UserID]>,
  'searchUserByPrincipal' : ActorMethod<[UserID], [] | [UserRecord]>,
  'searchUserByUsername' : ActorMethod<[Username], Array<UserRecord>>,
  'updateAvatar' : ActorMethod<[AvatarID], [boolean, UserID]>,
  'updateUsername' : ActorMethod<[Username], [boolean, UserID]>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
