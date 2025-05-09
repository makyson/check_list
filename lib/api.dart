String apilogin() {
  return versaoteste() == true
      ? 'https://7j614wps-3301.brs.devtunnels.ms'
      : 'https://7j614wps-3301.brs.devtunnels.ms'; //'https://api.manutecaoqr.com.br:8082';
}

String apitestes(String par) {
  return versaoteste() == true
      ? 'https://7j614wps-8082.brs.devtunnels.ms'
      : 'https://7j614wps-8082.brs.devtunnels.ms/$par'; //'https://api.manutecaoqr.com.br:8082';
}

String apidevimagem() {
  return 'https://7j614wps-3301.brs.devtunnels.ms/';
}

String apidevimagemnovo1() {
  return 'https://7j614wps-3301.brs.devtunnels.ms/';
}

String apidev() {
  return 'https://7j614wps-3301.brs.devtunnels.ms';
}

String apidevprod() {
  return 'https://7j614wps-3301.brs.devtunnels.ms/';
}

bool versaoteste() {
  return false;
}

/*
String apilogin() {
  return versaoteste() == true
      ? 'http://localhost:3302'
      : 'https://7j614wps-3302.brs.devtunnels.ms'; //'https://api.manutecaoqr.com.br:8082';
}

String apitestes(String par) {
  return versaoteste() == true
      ? 'http://localhost:8082'
      : 'https://7j614wps-8082.brs.devtunnels.ms/$par'; //'https://api.manutecaoqr.com.br:8082';
}

String apidevimagem() {
  return 'https://7j614wps-3302.brs.devtunnels.ms/';
}

String apidevimagemnovo1() {
  return 'https://7j614wps-3302.brs.devtunnels.ms/';
}

String apidev() {
  return 'https://7j614wps-8082.brs.devtunnels.ms';
}

String apidevprod() {
  return 'https://7j614wps-8082.brs.devtunnels.ms/';
}

bool versaoteste() {
  return true;
}
*/
