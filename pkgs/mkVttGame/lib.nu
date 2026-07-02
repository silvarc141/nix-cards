def parseCardImageFiles [ dir: path ] {
  glob ($dir | path join '*.png') | path basename | each { 
    let path = $in
    let parsed = $path | parse --regex '(?<game>[a-z]*)-(?<deck>[a-z]*)-(?<side>[a-z]*)(?<index>\d*)'
    $parsed | insert "path" $path | reject game
  } | flatten
}

def createCardInstanceData [ cards: table ] {
  $cards | where side == "front" | each {
    {
      id: $"($in.deck)($in.index)Card",
      type: "card",
      deck: $"($in.deck)Deck",
      cardType: $"($in.deck)($in.index)",
      parent: $"($in.deck)Pile"
    }
  } | group-by id
}

def createDeckStruct [ cards: table, name: string, width: int, height: int, x: int, y: int ] {
  let cardTypes = $cards
  | update path {|x| $"/assets/($x.path)"}
  | group-by index --prune 
  | items { |key,value| { 
    name: $"($name)($key)", 
    sides: ($value | transpose -rd) } 
  } | transpose -rd

  {
    $"($name)Holder": {
      id: $"($name)Holder",
      type: "holder",
      x: $x,
      y: $y,
      width: $width,
      height: $height
    },
    $"($name)Pile": {
      id: $"($name)Pile",
      type: "pile",
      parent: $"($name)Holder"
    },
    $"($name)Deck": {
      id: $"($name)Deck",
      type: "deck",
      parent: $"($name)Holder"
      cardDefaults: {
        width: $width,
        height: $height,
      },
      cardTypes: $cardTypes,
      faceTemplates: [
        { 
          objects: [
            { 
              type: "image", 
              width: $width, 
              height: $height, 
              dynamicProperties: { value: "front" } 
            }
          ] 
        }
        {
          objects: [
            { 
              type: "image", 
              width: $width, 
              height: $height, 
              dynamicProperties: { value: "back" } 
            }
          ] 
        },
      ],
    },
  }
}

def packageImagesAsVttGame [ imagesDir: path, outDir: path, gameName: string ] {
  mkdir staging/assets
  glob $"($imagesDir)/*.png" | each { cp $in staging/assets/ }

  let cards = parseCardImageFiles staging/assets/
  let cardInstanceStructs = createCardInstanceData $cards

  let $baseStruct = {
    _meta: { 
      version: 21, 
      info: { 
        name: $gameName, 
      } 
    }
  };

  let deckStructs = $cards
  | group-by deck --prune 
  | transpose name cards
  | each { createDeckStruct $in.cards $in.name 150 225 0 0 }
  | reduce { |it, acc| $acc | merge $it }

  $baseStruct 
  | merge $deckStructs
  | merge $cardInstanceStructs
  | to json
  | save -f staging/0.json

  mkdir $outDir
  cd staging
  ^zip -9rq $"($outDir)/($gameName).vtt" .
}
