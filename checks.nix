{ pkgs, pkgsSelf, ... }: {
  test-mk-vtt-game =
    let
      gameName = "testGame";
      images = pkgs.runCommand "mock-images" { } ''
        mkdir -p $out
        touch $out/${gameName}-testDeckA-front-testCard0.png
        touch $out/${gameName}-testDeckA-back-testCard0.png
        touch $out/${gameName}-testDeckA-front-testCard1.png
        touch $out/${gameName}-testDeckA-back-testCard1.png
        touch $out/${gameName}-testDeckB-front-testCard0.png
        touch $out/${gameName}-testDeckB-back-testCard0.png
        touch $out/${gameName}-testDeckB-front-testCard1.png
        touch $out/${gameName}-testDeckB-back-testCard1.png
      '';
    in
    pkgsSelf.mkVttGame { inherit gameName images; };
}
