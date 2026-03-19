class ApiSessionStore {
  String? accessToken;
  String? refreshToken;

  void update({required String accessToken, required String refreshToken}) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
  }
}
