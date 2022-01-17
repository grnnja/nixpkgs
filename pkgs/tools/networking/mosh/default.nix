{ fetchFromGitHub
, lib
, stdenv
, fetchurl
, fetchpatch
, zlib
, protobuf
, ncurses
, pkg-config
, makeWrapper
, perlPackages
, openssl
, autoreconfHook
, openssh
, bash-completion
, withUtempter ? stdenv.isLinux
, libutempter
}:

stdenv.mkDerivation rec {
  pname = "mosh";
  version = "378dfa6aa5778cf168646ada7f52b6f4a8ec8e41";

  src = fetchFromGitHub {
    owner = "mobile-shell";
    repo = "mosh";
    rev = "378dfa6aa5778cf168646ada7f52b6f4a8ec8e41";
    sha256 = "sha256-LJssBMrICVgaZtTvZTO6bYMFO4fQ330lIUkWzDSyf7o=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config makeWrapper ];
  buildInputs = [ protobuf ncurses zlib openssl bash-completion ]
    ++ (with perlPackages; [ perl IOTty ])
    ++ lib.optional withUtempter libutempter;

  enableParallelBuilding = true;

  patches = [
    ./ssh_path.patch
    ./mosh-client_path.patch
    ./utempter_path.patch
    # Fix build with bash-completion 2.10
    ./bash_completion_datadir.patch
  ];

  postPatch = ''
    substituteInPlace scripts/mosh.pl \
      --subst-var-by ssh "${openssh}/bin/ssh" \
      --subst-var-by mosh-client "$out/bin/mosh-client"
  '';

  configureFlags = [ "--enable-completion" ]
    ++ lib.optional withUtempter "--with-utempter";

  postInstall = ''
    wrapProgram $out/bin/mosh --prefix PERL5LIB : $PERL5LIB
  '';

  CXXFLAGS = lib.optionalString stdenv.cc.isClang "-std=c++11";

  meta = with lib; {
    homepage = "https://mosh.org/";
    description = "Mobile shell (ssh replacement)";
    longDescription = ''
      Remote terminal application that allows roaming, supports intermittent
      connectivity, and provides intelligent local echo and line editing of
      user keystrokes.

      Mosh is a replacement for SSH. It's more robust and responsive,
      especially over Wi-Fi, cellular, and long-distance links.
    '';
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ viric SuperSandro2000 ];
    platforms = platforms.unix;
  };
}
