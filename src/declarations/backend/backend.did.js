export const idlFactory = ({ IDL }) => {
  const LoginResult = IDL.Variant({ 'ok' : IDL.Bool, 'err' : IDL.Text });
  return IDL.Service({
    'isSessionValid' : IDL.Func([], [IDL.Bool], []),
    'login' : IDL.Func([IDL.Text, IDL.Text], [LoginResult], []),
    'logout' : IDL.Func([], [IDL.Bool], []),
  });
};
export const init = ({ IDL }) => { return []; };
