import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventIntialize extends AuthEvent{
  const AuthEventIntialize();
}

class AuthEventLogIn extends AuthEvent{
  final String email;
  final String password;

  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent{
  const AuthEventLogOut();
}

class AuthEventSendEmailVerification extends AuthEvent{
  const AuthEventSendEmailVerification();
}

class AuthEventRegister extends AuthEvent{
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}

class AuthEventForgotPassowrd extends AuthEvent{
  final String? email;
  const AuthEventForgotPassowrd(this.email);
}