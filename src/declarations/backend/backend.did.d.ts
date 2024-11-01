import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type LoginResult = { 'ok' : boolean } |
  { 'err' : string };
export interface _SERVICE {
  'isSessionValid' : ActorMethod<[], boolean>,
  'login' : ActorMethod<[string, string], LoginResult>,
  'logout' : ActorMethod<[], boolean>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
