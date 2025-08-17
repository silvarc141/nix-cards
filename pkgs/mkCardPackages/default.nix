{
  lib,
  runCommand,
  mkRubySquibEnv,
  ...
}: {
  cardTypes,
  graphicsDir,
  csvDir,
  fontDirs ? [],
  root ? ./.,
  variants ? [
    "pdf"
    "pdf-pnp"
    "sheet"
    "sheet-pnp"
    "images"
    "images-pnp"
    "single"
  ],
}: let
  inherit (lib) getExe concatLines;
  inherit (builtins) listToAttrs concatMap;
  baseName = baseNameOf root;

  sides = [ "front" "back" ];
  allSides = sides ++ ["both"];

  mkRunLine = variant: cardType: side: ''
    ${getExe (mkRubySquibEnv fontDirs)} \
      '${root + "/init.rb"}' \
      "$out" \
      '${graphicsDir}' \
      '${graphicsDir}/${cardType}-${side}' \
      '${variant}' \
      '${cardType}' \
      '${side}' \
      '${root}' \
      '${csvDir}/${cardType}.csv'
  '';

  mkRunCommand = name: cardTypes: sides: variant:
    runCommand name {} ''
      mkdir -p $out
      ${concatLines (map (
          cardType: (concatLines (map (mkRunLine variant cardType) sides))
        )
        cardTypes)}
    '';

  expandSide = side:
    if side == "both"
    then sides
    else [side];

  packagesMetaAll = listToAttrs (
    concatMap (
      side:
        map (variant: let
          name = "${baseName}-all-${side}-${variant}";
        in {
          inherit name;
          value = mkRunCommand name cardTypes (expandSide side) variant;
        })
        variants
    )
    allSides
  );

  packages = listToAttrs (
    concatMap (
      cardType:
        concatMap (
          side:
            map (variant: let
              name = "${baseName}-${cardType}-${side}-${variant}";
            in {
              inherit name;
              value = mkRunCommand name [cardType] (expandSide side) variant;
            })
            variants
        )
        allSides
    )
    cardTypes
  );
in
  packages // packagesMetaAll
