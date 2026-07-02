class Validators {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidNome(String nome) {
    return nome.trim().length >= 2;
  }

  static bool isValidTelefone(String telefone) {
    final telefoneLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');
    return telefoneLimpo.length >= 10 && telefoneLimpo.length <= 11;
  }
}