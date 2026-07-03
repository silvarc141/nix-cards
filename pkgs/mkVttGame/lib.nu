def parseCardImageNames [ cardImageNames : list<string> ] {
  $cardImageNames | each {
    let name = $in
    let parsed = $name | parse --regex '(?<game>[a-z]*)-(?<deck>[a-z]*)-(?<side>[a-z]*)(?<index>\d*)'
    $parsed | insert name $name | reject game
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
  } | reduce -f {} {|row, acc| $acc | insert $row.id $row }
}

def createDeckStruct [ cards: table, deckName: string, width: int, height: int, x: int, y: int ] {
  let cardTypes = $cards
  | insert path {|x| $"/assets/($x.name).webp"}
  | reject name
  | group-by index --prune 
  | items { |cardId,cardData| { 
    name: $"($deckName)($cardId)",
    sides: ($cardData | transpose -rd) } 
  } | transpose -rd

  {
    $"($deckName)Holder": {
      id: $"($deckName)Holder",
      type: "holder",
      x: $x,
      y: $y,
      width: $width,
      height: $height
    },
    $"($deckName)Pile": {
      id: $"($deckName)Pile",
      type: "pile",
      parent: $"($deckName)Holder"
      width: $width,
      height: $height
    },
    $"($deckName)Deck": {
      id: $"($deckName)Deck",
      type: "deck",
      parent: $"($deckName)Holder"
      cardDefaults: {
        width: $width,
        height: $height,
        color: "blue",
        enlarge: 3,
        clickRoutine: [
          {
            func: "FLIP",
            collection: "thisButton"
          }
        ],
        doubleClickRoutine: [
          {
            func: "ROTATE",
            collection: "thisButton"
          }
        ],
      },
      cardTypes: $cardTypes,
      faceTemplates: [
        { 
          objects: [
            { 
              type: "image", 
              width: $width,
              height: $height,
              dynamicProperties: {
                value: "front"
              }
            }
          ] 
        }
        {
          objects: [
            { 
              type: "image", 
              width: $width,
              height: $height,
              dynamicProperties: {
                value: "back"
              }
            }
          ] 
        },
      ],
    },
  }
}

def packageImagesAsVttGame [ imagesDir: path, outDir: path, gameName: string ] {
  let assetsDir = "staging/assets"
  mkdir $assetsDir
  let cardImageNames = ls $imagesDir | get name | path parse | get stem

  $cardImageNames | each {
    let inPath = $"($imagesDir)/($in).png"
    let outPath = $"($assetsDir)/($in).webp"
    ^cwebp $inPath -o $outPath
  }

  let cards = parseCardImageNames $cardImageNames
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
  | enumerate
  | flatten
  | each { createDeckStruct $in.cards $in.name 150 225 ($in.index * 150) 0 }
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
