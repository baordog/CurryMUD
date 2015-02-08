{-# OPTIONS_GHC -funbox-strict-fields -Wall -Werror #-}
{-# LANGUAGE NamedFieldPuns, OverloadedStrings, PatternSynonyms, ViewPatterns #-}

module Mud.Cmds.ExpCmds ( expCmdSet
                        , expCmds ) where

import Mud.Cmds.Util.Pla
import Mud.Data.Misc
import Mud.Data.State.ActionParams.ActionParams
import Mud.Data.State.State
import Mud.Data.State.Util.Output
import Mud.Data.State.Util.STM
import Mud.Util.Misc hiding (patternMatchFail)
import Mud.Util.Quoting
import qualified Mud.Logging as L (logPlaOut)
import qualified Mud.Util.Misc as U (patternMatchFail)

import Control.Lens.Getter (view)
import Control.Lens.Operators ((^.))
import Data.IntMap.Lazy ((!))
import Data.List ((\\), delete)
import Data.Monoid (mempty)
import qualified Data.Set as S (Set, fromList, foldr)
import qualified Data.Text as T


patternMatchFail :: T.Text -> [T.Text] -> a
patternMatchFail = U.patternMatchFail "Mud.Cmds.ExpCmds"


-----


logPlaOut :: T.Text -> Id -> [T.Text] -> MudStack ()
logPlaOut = L.logPlaOut "Mud.Cmds.ExpCmds"


-- ==================================================


expCmdSet :: S.Set ExpCmd
expCmdSet = S.fromList
    [ ExpCmd "admire"      (HasTarget "You admire @."
                                      "% admires you."
                                      "% admires @.")
    , ExpCmd "applaud"     (Versatile "You applaud enthusiastically."
                                      "% applauds enthusiastically."
                                      "You applaud enthusiastically for @."
                                      "% applauds enthusiastically for you."
                                      "% applauds enthusiastically for @.")
    , ExpCmd "astonished"  (Versatile "You are absolutely astonished."
                                      "% is absolutely astonished."
                                      "You stare at @ with an astonished expression on your face."
                                      "% stares at you with an astonished expression on & face."
                                      "% stares at @ with an astonished expression on & face.")
    , ExpCmd "avert"       (Versatile "You avert your eyes."
                                      "% averts & eyes."
                                      "You avert your eyes from @."
                                      "% averts & eyes from you."
                                      "% averts & eyes from @.")
    , ExpCmd "bawl"        (NoTarget  "You bawl like a baby."
                                      "% bawl like a baby.")
    , ExpCmd "beam"        (Versatile "You beam cheerfully."
                                      "% beams cheerfully."
                                      "You beam cheerfully at @."
                                      "% beams cheerfully at you."
                                      "% beams cheerfully at @.")
    , ExpCmd "belch"       (Versatile "You let out a deep belch."
                                      "% lets out a deep belch."
                                      "You belch purposefully at @."
                                      "% belches purposefully at you."
                                      "% belches purposefully at @.")
    , ExpCmd "blank"       (Versatile "You are hopelessly bewildered."
                                      "% is hopelessly bewildered."
                                      "You are hopelessly bewildered by @'s behavior."
                                      "% is hopelessly bewildered by your behavior."
                                      "% is hopelessly bewildered by @'s behavior.")
    , ExpCmd "blank"       (Versatile "You have a blank expression on your face."
                                      "% has a blank expression on & face."
                                      "You look blankly at @."
                                      "% looks blankly at you."
                                      "% looks blankly at @.")
    , ExpCmd "blink"       (Versatile "You blink."
                                      "% blinks."
                                      "You blink at @."
                                      "% blinks at you."
                                      "% blinks at @.")
    , ExpCmd "blush"       (NoTarget  "You blush."
                                      "% blushes.")
    , ExpCmd "boggle"      (NoTarget  "You boggle at the concept."
                                      "% boggles at the concept.")
    , ExpCmd "bow"         (Versatile "You bow."
                                      "% bows."
                                      "You bow before @."
                                      "% bows before you."
                                      "% bows before @.")
    , ExpCmd "burp"        (Versatile "You burp."
                                      "% burps."
                                      "You burp rudely at @."
                                      "% burps rudely at you."
                                      "% burps rudely at @.")
    , ExpCmd "burstlaugh"  (Versatile "You abruptly burst into laughter."
                                      "% abruptly bursts into laughter."
                                      "You abruptly burst into laughter in reaction to @."
                                      "% abruptly bursts into laughter in reaction to you."
                                      "% abruptly bursts into laughter in reaction to @.")
    , ExpCmd "cheer"       (Versatile "You cheer eagerly."
                                      "% cheers eagerly."
                                      "You eagerly cheer for @."
                                      "% eagerly cheers for you."
                                      "% eagerly cheers for @.")
    , ExpCmd "chuckle"     (Versatile "You chuckle."
                                      "% chuckles."
                                      "You chuckle at @."
                                      "% chuckles at you."
                                      "% chuckles at @.")
    , ExpCmd "chortle"     (Versatile "You chortle gleefully."
                                      "% chortles gleefully."
                                      "You chortle gleefully at @."
                                      "% chortles gleefully at you."
                                      "% chortles gleefully at @.")
    , ExpCmd "clap"        (Versatile "You clap."
                                      "% claps."
                                      "You clap for @."
                                      "% claps for you."
                                      "% claps for @.")
    , ExpCmd "closeeyes"   (NoTarget  "You close your eyes."
                                      "% closes & eyes.")
    , ExpCmd "coldsweat"   (NoTarget  "You break out in a cold sweat."
                                      "% breaks out in a cold sweat.")
    , ExpCmd "comfort"     (HasTarget "You comfort @."
                                      "% comforts you."
                                      "% comforts @.")
    , ExpCmd "confused"    (Versatile "You look utterly confused."
                                      "% looks utterly confused."
                                      "Utterly confused, you look fixedly at @."
                                      "Utterly confused, % looks fixedly at you."
                                      "Utterly confused, % looks fixedly at @.")
    , ExpCmd "cough"       (Versatile "You cough."
                                      "% coughs."
                                      "You cough loudly at @."
                                      "% coughs loudly at you."
                                      "% coughs loudly at @.")
    , ExpCmd "coverears"   (NoTarget  "You cover your ears."
                                      "% covers & ears.")
    , ExpCmd "covereyes"   (NoTarget  "You cover your eyes."
                                      "% covers & eyes.")
    , ExpCmd "covermouth"  (NoTarget  "You cover your mouth."
                                      "% covers & mouth.")
    , ExpCmd "cower"       (Versatile "You cower in fear."
                                      "% cowers in fear."
                                      "You cower in fear before @."
                                      "% cowers in fear before you."
                                      "% cowers in fear before @.")
    , ExpCmd "cringe"      (Versatile "You cringe."
                                      "% cringes."
                                      "You cringe at @."
                                      "% cringes at you."
                                      "% cringes at @.")
    , ExpCmd "cry"         (NoTarget  "You cry."
                                      "% cries.")
    , ExpCmd "cryanger"    (Versatile "You cry out in anger."
                                      "% cries out in anger."
                                      "You cry out in anger at @."
                                      "% cries out in anger at you."
                                      "% cries out in anger at @.")
    , ExpCmd "cuddle"      (HasTarget "You cuddle @."
                                      "% cuddles you."
                                      "% cuddles @.")
    , ExpCmd "curious"     (Versatile "You have a curious expression on your face."
                                      "% has a curious expression on & face."
                                      "Interested in knowing more, you flash a curious expression at @."
                                      "Interested in knowing more, % flashes a curious expression at you."
                                      "Interested in knowing more, % flashes a curious expression at @.")
    , ExpCmd "curtsey"     (Versatile "You curtsey."
                                      "% curtseys."
                                      "You curtsey to @."
                                      "% curtseys to you."
                                      "% curtseys to @.")
    , ExpCmd "curtsy"      (Versatile "You curtsy."
                                      "% curtsies."
                                      "You curtsy to @."
                                      "% curtsies to you."
                                      "% curtsies to @.")
    , ExpCmd "dance"       (Versatile "You dance around."
                                      "% dances around."
                                      "You dance with @."
                                      "% dances with you."
                                      "% dances with @.")
    , ExpCmd "daydream"    (NoTarget  "Staring off into the distance, you indulge in a daydream."
                                      "Staring off into the distance, % indulges in a daydream.")
    , ExpCmd "deepbreath"  (NoTarget  "You take a deep breath."
                                      "% takes a deep breath.")
    , ExpCmd "disappoint"  (Versatile "You are clearly disappointed."
                                      "% is clearly disappointed."
                                      "You are clearly disappointed in @."
                                      "% is clearly disappointed in you."
                                      "% is clearly disappointed in @.")
    , ExpCmd "dizzy"       (NoTarget  "Dizzy and reeling, you look as though you might pass out."
                                      "Dizzy and reeling, % looks as though ^ might pass out.")
    , ExpCmd "doublelaguh" (Versatile "You double over with laughter."
                                      "% doubles over with laughter."
                                      "You double over with laughter in reaction to @."
                                      "% doubles over with laughter in reaction to you."
                                      "% doubles over with laughter in reaction to @.")
    , ExpCmd "drool"       (NoTarget  "You drool."
                                      "% drools.")
    , ExpCmd "droop"       (NoTarget  "Your eyes droop."
                                      "%'s eyes droop.")
    , ExpCmd "embrace"     (HasTarget "You warmly embrace @."
                                      "% embraces you warmly."
                                      "% embraces @ warmly.")
    , ExpCmd "exhausted"   (NoTarget  "Exhausted, your face displays a weary expression."
                                      "Exhausted, %'s face displays a weary expression.")
    , ExpCmd "facepalm"    (NoTarget  "You facepalm."
                                      "% facepalms.")
    , ExpCmd "faint"       (NoTarget  "You faint."
                                      "% faints.")
    , ExpCmd "flex"        (Versatile "You flex your muscles."
                                      "%'s flexes & muscles."
                                      "You flex your muscles at @."
                                      "% flexes & muscles at you."
                                      "% flexes & muscles at @.")
    , ExpCmd "flop"        (NoTarget  "You flop down on the ground."
                                      "% flops down on the ground.")
    , ExpCmd "frown"       (Versatile "You frown."
                                      "% frowns."
                                      "You frown at @."
                                      "% frowns at you."
                                      "% frowns at @.")
    , ExpCmd "funnyface"   (Versatile "You make a funny face."
                                      "% makes a funny face."
                                      "You make a funny face at @."
                                      "% makes a funny face at you."
                                      "% makes a funny face at @.")
    , ExpCmd "giggle"      (Versatile "You gag."
                                      "% gags."
                                      "You gag in reaction to @."
                                      "% gags in reaction to you."
                                      "% gags in reaction to @.")
    , ExpCmd "gasp"        (Versatile "You gasp."
                                      "% gasps."
                                      "You gasp at @."
                                      "% gasps at you."
                                      "% gasps at @.")
    , ExpCmd "gawk"        (HasTarget "You gawk at @."
                                      "% gawks at you."
                                      "% gawks at @.")
    , ExpCmd "gaze"        (HasTarget "You gaze longingly at @."
                                      "% gazes longingly at you."
                                      "% gazes longingly at @.")
    , ExpCmd "giggle"      (Versatile "You giggle."
                                      "% giggles."
                                      "You giggle at @."
                                      "% giggles at you."
                                      "% giggles at @.")
    , ExpCmd "glance"      (Versatile "You glance around."
                                      "% glances around."
                                      "You glance at @."
                                      "% glances at you."
                                      "% glances at @.")
    , ExpCmd "glare"       (HasTarget "You glare at @."
                                      "% glares at you."
                                      "% glares at @.")
    , ExpCmd "greet"       (HasTarget "You greet @."
                                      "% greets you."
                                      "% greets @.")
    , ExpCmd "grin"        (Versatile "You grin."
                                      "% grins."
                                      "You grin at @."
                                      "% grins at you."
                                      "% grins at @.")
    , ExpCmd "groan"       (Versatile "You groan."
                                      "% groans."
                                      "You groan at @."
                                      "% groans at you."
                                      "% groans at @.")
    , ExpCmd "grovel"      (HasTarget "You grovel before @."
                                      "% grovels before you."
                                      "% grovels before @.")
    , ExpCmd "growl"       (Versatile "You growl menacingly."
                                      "% growls menacingly."
                                      "You growl menacingly at @."
                                      "% growls menacingly at you."
                                      "% growls menacingly at @.")
    , ExpCmd "grumble"     (NoTarget  "You grumble to yourself."
                                      "% grumbles to *.")
    , ExpCmd "guffaw"      (Versatile "You guffaw boisterously."
                                      "% guffaws boisterously."
                                      "You guffaw boisterously at @."
                                      "% guffaws boisterously at you."
                                      "% guffaws boisterously at @.")
    , ExpCmd "gulp"        (NoTarget  "You gulp."
                                      "% gulps.")
    , ExpCmd "handhips"    (NoTarget  "You put your hands on your hips."
                                      "% puts & hands on & hips.")
    , ExpCmd "hesitate"    (NoTarget  "You hesitate."
                                      "% hesitates.")
    , ExpCmd "hiccup"      (NoTarget  "You hiccup involuntarily."
                                      "% hiccups involuntarily.")
    , ExpCmd "holdhand"    (HasTarget "You hold @'s hand."
                                      "% holds your hand."
                                      "% holds @'s hand.")
    , ExpCmd "hop"         (NoTarget  "You hop up and down excitedly."
                                      "% hops up and down excitedly.")
    , ExpCmd "horf"        (Versatile "You horf all over with reckless abandon."
                                      "% horfs all over with reckless abandon."
                                      "You horf all over @ with reckless abandon."
                                      "% horfs all over you with reckless abandon."
                                      "% horfs all over @ with reckless abandon.")
    , ExpCmd "howllaugh"   (Versatile "You howl with laughter."
                                      "% howls with laughter."
                                      "You howl with laughter at @."
                                      "% howls with laughter at you."
                                      "% howls with laughter at @.")
    , ExpCmd "hug"         (HasTarget "You hug @."
                                      "% hugs you."
                                      "% hugs @.")
    , ExpCmd "hum"         (NoTarget  "You hum a merry tune."
                                      "% hums a merry tune.")
    , ExpCmd "innocent"    (NoTarget  "You try to look innocent."
                                      "% tries to look innocent.")
    , ExpCmd "jig"         (Versatile "You dance a lively jig."
                                      "% dances a lively jig."
                                      "You dance a lively jig with @."
                                      "% dances a lively jig with you."
                                      "% dances a lively jig with @.")
    , ExpCmd "joytears"    (NoTarget  "You are overcome with tears of joy."
                                      "% is overcome with tears of joy.")
    , ExpCmd "jump"        (NoTarget  "You jump up and down excitedly."
                                      "% jumps up and down excitedly.")
    , ExpCmd "inquisitive" (Versatile "You have an inquisitive expression on your face."
                                      "% has an inquisitive expression on & face."
                                      "You flash an inquisitive expression at @."
                                      "% flashes an inquisitive expression at you."
                                      "% flashes an inquisitive expression at @.")
    , ExpCmd "kiss"        (HasTarget "You kiss @."
                                      "% kisses you."
                                      "% kisses @.")
    , ExpCmd "kisscheek"   (HasTarget "You kiss @ on the cheek."
                                      "% kisses you on the cheek."
                                      "% kisses @ on the cheek.")
    , ExpCmd "kisspassion" (HasTarget "You kiss @ passionately."
                                      "% kisses you passionately."
                                      "% kisses @ passionately.")
    , ExpCmd "kneel"       (Versatile "You kneel down."
                                      "% kneels down."
                                      "You kneel down before @."
                                      "% kneels down before you."
                                      "% kneels down before @.")
    , ExpCmd "laugh"       (Versatile "You laugh."
                                      "% laughs."
                                      "You laugh at @."
                                      "% laughs at you."
                                      "% laughs at @.")
    , ExpCmd "laughheart"  (Versatile "You laugh heartily."
                                      "% laughs heartily."
                                      "You laugh heartily at @."
                                      "% laughs heartily at you."
                                      "% laughs heartily at @.")
    , ExpCmd "laydown"     (Versatile "You lay down."
                                      "% lays down."
                                      "You lay down next to @."
                                      "% lays down next to you."
                                      "% lays down next to @.")
    , ExpCmd "leap"        (NoTarget  "You leap into the air."
                                      "% leaps into the air.")
    , ExpCmd "leer"        (HasTarget "You leer at @."
                                      "% leers at you."
                                      "% leers at @.")
    , ExpCmd "licklips"    (NoTarget  "You lick your lips."
                                      "% licks & lips.")
    , ExpCmd "livid"       (NoTarget  "You are positively livid."
                                      "% is positively livid.")
    , ExpCmd "longingly"   (HasTarget "You gaze longingly at @."
                                      "% gazes longingly at you."
                                      "% gazes longingly at @.")
    , ExpCmd "losswords"   (NoTarget  "You appear to be at a loss for words."
                                      "% appears to be at a loss for words.")
    , ExpCmd "massage"     (HasTarget "You massage @."
                                      "% massages you."
                                      "% massages @.")
    , ExpCmd "moan"        (NoTarget  "You moan."
                                      "% moans.")
    , ExpCmd "mumble"      (Versatile "You mumble to yourself."
                                      "% mumbles to *."
                                      "You mumble something to @."
                                      "% mumbles something to you."
                                      "% mumbles something to @.")
    , ExpCmd "muscles"     (Versatile "You flex your muscles."
                                      "%'s flexes & muscles."
                                      "You flex your muscles at @."
                                      "% flexes & muscles at you."
                                      "% flexes & muscles at @.")
    , ExpCmd "mutter"      (Versatile "You mutter to yourself."
                                      "% mutters to *."
                                      "You mutter something to @."
                                      "% mutters something to you."
                                      "% mutters something to @.")
    , ExpCmd "nod"         (Versatile "You nod."
                                      "% nods."
                                      "You nod to @."
                                      "% nods to you."
                                      "% nods to @.")
    , ExpCmd "nodagree"    (Versatile "You nod in agreement."
                                      "% nods in agreement."
                                      "You nod in agreement to @."
                                      "% nods in agreement to you."
                                      "% nods in agreement to @.")
    , ExpCmd "nudge"       (HasTarget "You nudge @."
                                      "% nudges you."
                                      "% nudges @.")
    , ExpCmd "nuzzle"      (HasTarget "You nuzzle @ lovingly."
                                      "% nuzzles you lovingly."
                                      "% nuzzles @ lovingly.")
    , ExpCmd "openeyes"    (NoTarget  "You open your eyes."
                                      "% opens & eyes.")
    , ExpCmd "openmouth"   (Versatile "Your mouth hangs open."
                                      "%'s mouth hangs open."
                                      "Your mouth hangs open in response to @."
                                      "%'s mouth hangs open in response to you."
                                      "%'s mouth hangs open in response to @.")
    , ExpCmd "pace"        (NoTarget  "You pace around nervously."
                                      "% paces around nervously.")
    , ExpCmd "pant"        (NoTarget  "You pant."
                                      "% pants.")
    , ExpCmd "pat"         (HasTarget "You pat @ on the back."
                                      "% pats you on the back."
                                      "% pats @ on the back.")
    , ExpCmd "peer"        (HasTarget "You peer at @."
                                      "% peers at you."
                                      "% peers at @.")
    , ExpCmd "perplexed"   (NoTarget  "You are truly perplexed by the situation."
                                      "% is truly perplexed by the situation.")
    , ExpCmd "pet"         (HasTarget "You pet @."
                                      "% pets you."
                                      "% pets @.")
    , ExpCmd "picknose"    (NoTarget  "You pick your nose."
                                      "% picks & nose.")
    , ExpCmd "pinch"       (HasTarget "You pinch @."
                                      "% pinches you."
                                      "% pinches @.")
    , ExpCmd "point"       (HasTarget "You point to @."
                                      "% points to you."
                                      "% points to @.")
    , ExpCmd "poke"        (HasTarget "You poke @."
                                      "% pokes you."
                                      "% pokes @.")
    , ExpCmd "ponder"      (NoTarget  "You ponder the situation."
                                      "% ponders the situation.")
    , ExpCmd "pout"        (Versatile "You strike a pose."
                                      "% strikes a pose."
                                      "You strike a pose before @."
                                      "% strikes a pose before you."
                                      "% strikes a pose before @.")
    , ExpCmd "pounce"      (HasTarget "You pounce on @."
                                      "% pounces on you."
                                      "% pounces on @.")
    , ExpCmd "pout"        (Versatile "You pout."
                                      "% pouts."
                                      "You pout at @."
                                      "% pouts at you."
                                      "% pout at @.")
    , ExpCmd "prance"      (Versatile "You prance around."
                                      "% prances around."
                                      "You prance around @."
                                      "% prances around you."
                                      "% prances around @.")
    , ExpCmd "puke"        (Versatile "You violently puke all over."
                                      "% violently pukes all over."
                                      "You violently puke on @."
                                      "% pukes voilently on you."
                                      "% pukes voilently on @.")
    , ExpCmd "questioning" (Versatile "You have a questioning expression on your face."
                                      "% has a questioning expression on & face."
                                      "You flash a questioning expression at @."
                                      "% flashes a questioning expression at you."
                                      "% flashes a questioning expression at @.")
    , ExpCmd "raisebrow"   (Versatile "You raise an eyebrow."
                                      "% raises an eyebrow."
                                      "You raise an eyebrow at @."
                                      "% raises an eyebrow at you."
                                      "% raises an eyebrow at @.")
    , ExpCmd "raisehand"   (NoTarget  "You raise your hand."
                                      "% raises & hand.")
    , ExpCmd "reeling"     (NoTarget  "Dizzy and reeling, you look as though you might pass out."
                                      "Dizzy and reeling, % looks as though ^ might pass out.")
    , ExpCmd "rock"        (NoTarget  "You rock back and forth."
                                      "% rocks back and forth.")
    , ExpCmd "rolleyes"    (Versatile "You roll your eyes."
                                      "% rolls & eyes."
                                      "You roll your eyes at @."
                                      "% rolls & eyes at you."
                                      "% rolls & eyes at @.")
    , ExpCmd "rubeyes"     (NoTarget  "You rub your eyes."
                                      "% rubs & eyes.")
    , ExpCmd "satisfied"   (NoTarget  "You look satisfied."
                                      "% looks satisfied.")
    , ExpCmd "scratchchin" (NoTarget  "You scratch your chin."
                                      "% scratches & chin.")
    , ExpCmd "scratchhead" (NoTarget  "You scratch your head."
                                      "% scratches & head.")
    , ExpCmd "scream"      (Versatile "You unleach a high-pitched scream."
                                      "% unleashes high-pitched scream."
                                      "You scream at @."
                                      "% screams at you."
                                      "% screams at @.")
    , ExpCmd "shrieklaugh" (Versatile "You shriek with laughter."
                                      "% shrieks with laughter."
                                      "You shriek with laughter at @."
                                      "% shrieks with laughter at you."
                                      "% shrieks with laughter at @.")
    , ExpCmd "shush"       (HasTarget "You shush @."
                                      "% shushes you."
                                      "% shushed @.")
    , ExpCmd "sit"         (Versatile "You sit down."
                                      "% sits down."
                                      "You sit down next to @."
                                      "% sits down next to you."
                                      "% sit down next to @.")
    , ExpCmd "sleepy"      (NoTarget  "You look sleepy."
                                      "% looks sleepy.")
    , ExpCmd "slowclap"    (Versatile "You clap slowly, with a mocking lack of enthusiasm."
                                      "% claps slowly, with a mocking lack of enthusiasm."
                                      "With a mocking lack of enthusiasm, you clap slowly for @."
                                      "With a mocking lack of enthusiasm, % claps slowly for you."
                                      "With a mocking lack of enthusiasm, % claps slowly for @.")
    , ExpCmd "smirk"       (Versatile "You smirk."
                                      "% smirks."
                                      "You smirk at @."
                                      "% smirks at you."
                                      "% smirks at @.")
    , ExpCmd "snicker"     (Versatile "You snicker derisively."
                                      "% snickers derisively."
                                      "You snicker derisively at @."
                                      "% snickers derisively at you."
                                      "% snickers derisively at @.")
    , ExpCmd "sniffle"     (NoTarget  "You sniffle."
                                      "% sniffles.")
    , ExpCmd "snort"       (Versatile "You snort."
                                      "% snorts."
                                      "You snort at @."
                                      "% snorts at you."
                                      "% snorts at @.")
    , ExpCmd "scowl"       (Versatile "You scowl with contempt."
                                      "% scowls with contempt."
                                      "You scowl with contempt at @."
                                      "% scowls with contempt at you."
                                      "% scowls with contempt at @.")
    , ExpCmd "snore"       (NoTarget  "You snore loudly."
                                      "% snores loudly.")
    , ExpCmd "sob"         (NoTarget  "You sob."
                                      "% sobs.")
    , ExpCmd "stare"       (HasTarget "You stare at @."
                                      "% stares at you."
                                      "% stares at @.")
    , ExpCmd "stiflelaugh" (NoTarget  "You try hard to stifle a laugh."
                                      "% tries hard to stifle a laugh.")
    , ExpCmd "stifletears" (NoTarget  "You try hard to stifle your tears."
                                      "% tries hard to stifle & tears.")
    , ExpCmd "stomach"     (NoTarget  "Your stomach growls."
                                      "%'s stomach growls.")
    , ExpCmd "stretch"     (NoTarget  "You stretch your muscles."
                                      "% stretches & muscles.")
    , ExpCmd "sweat"       (NoTarget  "You break out in a sweat."
                                      "% breaks out in a sweat.")
    , ExpCmd "tears"       (NoTarget  "Tears roll down your face."
                                      "Tears roll down %'s face.")
    , ExpCmd "thumbsdown"  (Versatile "You give a thumbs down."
                                      "% gives a thumbs down."
                                      "You give a thumbs down to @."
                                      "% gives a thumbs down to you."
                                      "% gives a thumbs down to @.")
    , ExpCmd "thumbsup"    (Versatile "You give a thumbs up."
                                      "% gives a thumbs up."
                                      "You give a thumbs up to @."
                                      "% gives a thumbs up to you."
                                      "% gives a thumbs up to @.")
    , ExpCmd "tongue"      (Versatile "You stick your tongue out."
                                      "% sticks & tongue out."
                                      "You stick your tongue out at @."
                                      "% sticks & tongue out at you."
                                      "% sticks & tongue out at @.")
    , ExpCmd "unamused"    (Versatile "You are plainly unamused."
                                      "% is plainly unamused."
                                      "You are plainly unamused by @'s antics."
                                      "% is plainly unamused by your antics."
                                      "% is plainly unamused by @'s antics.")
    , ExpCmd "vomit"       (Versatile "You vomit."
                                      "% vomits."
                                      "You vomit on @."
                                      "% vomits on you."
                                      "% vomits on @.")
    , ExpCmd "watch"       (HasTarget "You watch @ with interest."
                                      "% watches you with interest."
                                      "% watches @ with interest.")
    , ExpCmd "wave"        (Versatile "You wave."
                                      "% waves."
                                      "You wave at @."
                                      "% waves at you."
                                      "% waves at @.")
    , ExpCmd "weary"       (Versatile "Exhausted, your face displays a weary expression."
                                      "Exhausted, %'s face displays a weary expression."
                                      "You cast @ a weary glance."
                                      "% casts you a weary glance."
                                      "% casts @ a weary glance.")
    , ExpCmd "whimper"     (Versatile "You whimper."
                                      "% whimpers."
                                      "You whimper at @."
                                      "% whimpers at you."
                                      "% whimpers at @.")
    , ExpCmd "wink"        (Versatile "You wink."
                                      "% winks."
                                      "You wink at @."
                                      "% winks at you."
                                      "% winks at @.")
    , ExpCmd "worried"     (Versatile "You look genuinely worried."
                                      "% looks genuinely worried."
                                      "You look genuinely worried for @."
                                      "% looks genuinely worried for you."
                                      "% looks genuinely worried for @.")
    , ExpCmd "yawn"        (Versatile "You yawn."
                                      "% yawns."
                                      "You yawn at @."
                                      "% yawns at you."
                                      "% yawns at @.") ]


expCmds :: [Cmd]
expCmds = S.foldr helper [] expCmdSet
  where
    helper (ExpCmd expCmdName expCmdType) = (Cmd { cmdName = expCmdName
                                                 , action  = expCmd expCmdType
                                                 , cmdDesc = "" } :)


-----


-- TODO: More refactoring for code reuse. Clean up.
expCmd :: ExpCmdType -> Action
expCmd (HasTarget {}) (NoArgs   _ mq cols) = wrapSend mq cols "This expressive command requires a single target."
expCmd act            (NoArgs'' i        ) = case act of
  (NoTarget  toSelf toOthers      ) -> helper toSelf toOthers
  (Versatile toSelf toOthers _ _ _) -> helper toSelf toOthers
  x                                 -> patternMatchFail "expCmd" [ showText x ]
  where
    helper toSelf toOthers = readWSTMVar >>= \ws ->
        let (d, _, _, _, _)                     = mkCapStdDesig i ws
            toSelfBrdcst                        = (nlnl toSelf, [i])
            serialized | T.head toOthers == '%' = serialize d
                       | otherwise              = serialize d { isCap = False }
            (heShe, hisHer, hisHerself)         = mkPros i ws
            toOthers'                           = T.replace "%" serialized . T.replace "^" heShe . T.replace "&" hisHer . T.replace "*" hisHerself $ toOthers
            toOthersBrdcst                      = (nlnl toOthers', i `delete` pcIds d)
        in logPlaOut (bracketQuote "exp. command") i [toSelf] >> bcast (toSelfBrdcst : [toOthersBrdcst])
expCmd (NoTarget {}) (WithArgs _ mq cols (_:_) ) = wrapSend mq cols "This expressive command may not be used with a \
                                                                    \target."
expCmd act           (OneArg   i mq cols target) = case act of
  (HasTarget     toSelf toTarget toOthers) -> helper toSelf toTarget toOthers
  (Versatile _ _ toSelf toTarget toOthers) -> helper toSelf toTarget toOthers
  x                                        -> patternMatchFail "expCmd" [ showText x ]
  where
    helper toSelf toTarget toOthers = readWSTMVar >>= \ws ->
        let (d, _, _, ri, ris@((i `delete`) -> ris')) = mkCapStdDesig i ws
            c                                         = (ws^.coinsTbl) ! ri
        in if (not . null $ ris') || (c /= mempty)
          then case resolveRmInvCoins i ws [target] ris' c of
            (_,                    [ Left  [sorryMsg] ]) -> wrapSend mq cols sorryMsg
            (_,                    Right _:_           ) -> wrapSend mq cols "Sorry, but expressive commands cannot be \
                                                                             \used with coins."
            ([ Left sorryMsg    ], _                   ) -> wrapSend mq cols sorryMsg
            ([ Right (_:_:_)    ], _                   ) -> wrapSend mq cols "Sorry, but you can only target one \
                                                                             \person at a time with expressive \
                                                                             \commands."
            ([ Right [targetId] ], _                   ) ->
              let (view sing -> targetSing) = (ws^.entTbl) ! targetId
                  onPC targetDesig =
                      let toSelf'        = T.replace "@" targetDesig toSelf
                          toSelfBrdcst   = (nlnl toSelf', [i])
                          serialized     = mkSerializedDesig d
                          (_, hisHer, _) = mkPros i ws
                          toTarget'      = T.replace "%" serialized . T.replace "&" hisHer $ toTarget
                          toTargetBrdcst = (nlnl toTarget', [targetId])
                          toOthers'      = T.replace "@" targetDesig . T.replace "%" serialized . T.replace "&" hisHer $ toOthers
                          toOthersBrdcst = (nlnl toOthers', pcIds d \\ [ i, targetId ])
                      in do
                          logPlaOut (bracketQuote "exp. command") i [ parsePCDesig i ws toSelf' ]
                          bcast $ toSelfBrdcst : toTargetBrdcst : [toOthersBrdcst]
                  onMob targetNoun =
                      let toSelf'        = T.replace "@" targetNoun toSelf
                          toSelfBrdcst   = (nlnl toSelf', [i])
                          serialized     = mkSerializedDesig d
                          (_, hisHer, _) = mkPros i ws
                          toOthers'      = T.replace "@" targetNoun . T.replace "%" serialized . T.replace "&" hisHer $ toOthers
                          toOthersBrdcst = (nlnl toOthers', i `delete` pcIds d)
                      in do
                          logPlaOut (bracketQuote "exp. command") i [toSelf']
                          bcast $ toSelfBrdcst : [toOthersBrdcst]
              in case (ws^.typeTbl) ! targetId of
                PCType  -> onPC  . serialize . mkStdDesig targetId ws targetSing False $ ris
                MobType -> onMob . theOnLower $ targetSing
                _       -> wrapSend mq cols "Sorry, but expressive commands may only target people."
            x -> patternMatchFail "expCmd helper" [ showText x ]
          else wrapSend mq cols "You don't see anyone here."
        where
          mkSerializedDesig d | T.head toOthers == '%' = serialize d
                              | otherwise              = serialize d { isCap = False }
expCmd act (ActionParams { plaMsgQueue, plaCols }) = wrapSend plaMsgQueue plaCols $ case act of
  (HasTarget {}) -> "This expressive command requires a single target."
  (Versatile {}) -> "This expressive command may be used with at most one target."
  x              -> patternMatchFail "expCmd" [ showText x ]


mkPros :: Id -> WorldState -> (T.Text, T.Text, T.Text)
mkPros i ws = let (view sex -> s) = (ws^.mobTbl) ! i in (mkThrPerPro s, mkPossPro s, mkReflexPro s)