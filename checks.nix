{ pkgs, pkgsSelf, ... }: {
  test-mk-vtt-game =
    let
      gameName = "testGame";
      images = pkgs.runCommand "mock-images" { } ''
        mkdir -p $out
        PNG_DATA_1X1="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg=="
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckA-front-testCard0.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckA-back-testCard0.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckA-front-testCard1.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckA-back-testCard1.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckB-front-testCard0.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckB-back-testCard0.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckB-front-testCard1.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckB-back-testCard1.png
      '';
    in
    pkgsSelf.mkVttGame { inherit gameName images; };
}
