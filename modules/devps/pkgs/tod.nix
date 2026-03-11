{ lib, buildGoModule, fetchgit }:

buildGoModule {
  pname = "tod";
  version = "2.1.1";
  src = fetchgit {
    url = "https://code.onedev.io/onedev/tod";
    rev = "v2.1.1";
    hash = "sha256-p/iz/sEwMLRCPtN4jqeGPY7iK6jPTzwV3Pmlh7hQXZw="; 
  };
  vendorHash = "sha256-CQS24qkCtMZ0RRJ3UAiETZmJcAGpSU57z8m3jvEAUnc=";
  meta = with lib; {
    description = "Command line interface for OneDev";
    homepage = "https://code.onedev.io/onedev/tod";
    mainProgram = "tod";
  };
}