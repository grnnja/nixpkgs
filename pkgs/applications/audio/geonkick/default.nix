{ lib, stdenv, fetchFromGitLab, cmake, pkg-config, libsndfile, rapidjson
, libjack2, lv2, libX11, cairo }:

stdenv.mkDerivation rec {
  pname = "geonkick";
  version = "2.8.1";

  src = fetchFromGitLab {
    owner = "iurie-sw";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-wSlZ9pVVqlrPSz20pRdcRLq6pTcibxD7326l9WY7ZDY=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libsndfile rapidjson libjack2 lv2 libX11 cairo ];

  # https://github.com/iurie-sw/geonkick/issues/120
  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with lib; {
    homepage = "https://gitlab.com/iurie-sw/geonkick";
    description = "A free software percussion synthesizer";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.magnetophon ];
  };
}
