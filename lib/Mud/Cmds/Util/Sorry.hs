{-# LANGUAGE LambdaCase, OverloadedStrings, RecordWildCards, ViewPatterns #-}

module Mud.Cmds.Util.Sorry where

import Mud.Cmds.Util.CmdPrefixes
import Mud.Data.Misc
import Mud.Data.State.MsgQueue
import Mud.Data.State.MudData
import Mud.Data.State.Util.Get
import Mud.Data.State.Util.Output
import Mud.Misc.ANSI
import Mud.TopLvlDefs.Chars
import Mud.TopLvlDefs.Misc
import Mud.Util.Quoting
import Mud.Util.Text
import Mud.Util.Wrapping

import Data.Char (toLower)
import Data.Monoid ((<>))
import qualified Data.Text as T


sorryAlreadyWielding :: MudState -> Slot -> Id -> T.Text
sorryAlreadyWielding ms sl i = let s = getSing i ms in T.concat [ "You're already wielding "
                                                                , aOrAn s
                                                                , " with your "
                                                                , pp sl
                                                                , "." ]


-----


sorryBracketedMsg :: Either T.Text a
sorryBracketedMsg = Left "You can't open or close your message with brackets."


-----


sorryChanTargetName :: T.Text -> T.Text -> T.Text
sorryChanTargetName cn n = T.concat [ "There is no one by the name of "
                                    , dblQuote n
                                    , " currently tuned in to the "
                                    , cn
                                    , " channel." ]


sorryAdminChanTargetName :: T.Text -> T.Text
sorryAdminChanTargetName = sorryChanTargetName "admin"


sorryChanTargetNameFromContext :: T.Text -> ChanContext -> T.Text
sorryChanTargetNameFromContext n (ChanContext { .. }) = sorryChanTargetName effChanName n
  where
    effChanName = maybe someCmdName dblQuote someChanName


-----


sorryConInEq :: PutOrRem -> T.Text
sorryConInEq por = let (a, b) = expand por
                   in T.concat [ "Sorry, but you can't "
                               , a
                               , " an item "
                               , b
                               , " a container in your readied equipment. Please unready the container first." ]
  where
    expand = \case Put -> ("put",    "into")
                   Rem -> ("remove", "from")


-----


sorryConnectIgnore :: T.Text
sorryConnectIgnore = sorryIgnoreLocPrefPlur "The names of the people you would like to connect"


-----


sorryDbEx :: MsgQueue -> Cols -> MudStack ()
sorryDbEx mq cols = wrapSend mq cols "There was an error when reading the database."


-----


sorryDisconnectIgnore :: T.Text
sorryDisconnectIgnore = sorryIgnoreLocPrefPlur "The names of the people you would like to disconnect"


-----


sorryEquipInvLook :: Cols -> EquipInvLookCmd -> EquipInvLookCmd -> T.Text
sorryEquipInvLook cols eilcA eilcB = wrapUnlinesNl cols . T.concat $ helper
  where
    helper = [ "You can only use the "
             , dblQuote . showText $ eilcA
             , " command to examine items in your "
             , loc eilcA
             , ". To examine items in your "
             , loc eilcB
             , ", use the "
             , dblQuote . showText $ eilcB
             , " command." ]
    loc    = \case EquipCmd -> "readied equipment"
                   InvCmd   -> "inventory"
                   LookCmd  -> "current room"


-----


sorryExpCmdName :: T.Text -> Either T.Text a
sorryExpCmdName cn = Left $ "There is no expressive command by the name of " <> dblQuote cn <> "."


sorryExpCmdRequiresTarget :: ExpCmdName -> T.Text
sorryExpCmdRequiresTarget cn = "The " <> dblQuote cn <> " expressive command requires a single target."


sorryExpCmdTooLong :: Either T.Text a
sorryExpCmdTooLong = Left "An expressive command sequence may not be more than 2 words long."


sorryExpCmdWithTarget :: ExpCmdName -> T.Text
sorryExpCmdWithTarget cn =  "The " <> dblQuote cn <> " expressive command cannot be used with a target."


-----


sorryFullClothSlotsOneSide :: Cloth -> Slot -> T.Text
sorryFullClothSlotsOneSide (pp -> c) (pp -> s) = T.concat [ "You can't wear any more "
                                                          , c
                                                          , "s on your "
                                                          , s
                                                          , "." ]


-----


sorryHostIgnore :: T.Text
sorryHostIgnore = sorryIgnoreLocPrefPlur "The PC names of the players whose host statistics you would like to see"


-----


sorryIgnoreLocPref :: T.Text -> T.Text
sorryIgnoreLocPref msg = parensQuote $ msg <> " need not be given a location prefix. The location prefix you provided \
                                              \will be ignored."


sorryIgnoreLocPrefPlur :: T.Text -> T.Text
sorryIgnoreLocPrefPlur msg = parensQuote $ msg <> " need not be given location prefixes. The location prefixes you \
                                                  \provided will be ignored."


-----


sorryIllegalChanName :: T.Text -> T.Text -> [T.Text]
sorryIllegalChanName a msg = pure . T.concat $ [ dblQuote a, " is not a legal channel name ", parensQuote msg, "." ]


-----


sorryIncog :: T.Text -> T.Text
sorryIncog cn = "You can't use the " <> dblQuote cn <> " command while incognito."


-----


sorryIndent :: MsgQueue -> Cols -> MudStack ()
sorryIndent mq cols = wrapSend mq cols "The indent amount must be less than the line length."


-----


sorryIncogChan :: MsgQueue -> Cols -> T.Text -> MudStack ()
sorryIncogChan mq cols x = wrapSend mq cols $ "You can't send a message on " <> x <> " channel while incognito."


-----


sorryInvalidRmName :: T.Text -> T.Text
sorryInvalidRmName n = T.concat [ dblQuote n
                                , " is not a valid room name. Type "
                                , quoteColor
                                , prefixAdminCmd "telerm"
                                , dfltColor
                                , " with no arguments to get a list of valid room names." ]


-----


sorryMyChansIgnore :: T.Text
sorryMyChansIgnore = sorryIgnoreLocPrefPlur "The PC names of the players whose channel information you would like to \
                                            \see"


-----


sorryNameTaken :: T.Text
sorryNameTaken = "Sorry, but that name is already taken."


-----


sorryNoMsg :: T.Text
sorryNoMsg = "You must also provide a message to send."


-----


sorryNoChans :: MsgQueue -> Cols -> MudStack ()
sorryNoChans mq cols = wrapSend mq cols "No channels exist!"


-----


sorryNoContainersHere :: T.Text
sorryNoContainersHere = "You don't see any containers here."


-----


sorryNoCoinsInEq :: T.Text
sorryNoCoinsInEq = "You don't have any coins among your readied equipment."


-----


sorryNoOneHere :: T.Text
sorryNoOneHere = "You don't see anyone here."


-----


sorryNoOneListening :: MsgQueue -> Cols -> T.Text -> MudStack ()
sorryNoOneListening mq cols n = wrapSend mq cols $ "You are the only person tuned in to the " <> n <> " channel."


-----


sorryNotConnectedChan :: ChanName -> T.Text
sorryNotConnectedChan cn = "You are not connected to a channel named " <> dblQuote cn <> "."


-----


sorryNotTunedICChan :: ChanName -> T.Text
sorryNotTunedICChan = sorryNotTunedChan "tune"


sorryNotTunedChan :: T.Text -> T.Text -> T.Text
sorryNotTunedChan x y = T.concat [ "You have tuned out the "
                                 , dblQuote y
                                 , " channel. Type "
                                 , quoteColor
                                 , x
                                 , " "
                                 , y
                                 , "=in"
                                 , dfltColor
                                 , " to tune it back in." ]


sorryNotTunedOOCChan :: T.Text -> T.Text
sorryNotTunedOOCChan = sorryNotTunedChan "set"


-----


sorryPCName :: T.Text -> T.Text
sorryPCName n = "There is no PC by the name of " <> dblQuote n <> "."


-----


sorryPCNameLoggedIn :: T.Text -> T.Text
sorryPCNameLoggedIn n = "No PC by the name of " <> dblQuote n <> " is currently logged in."


-----


sorryParseBase :: MsgQueue -> Cols -> T.Text -> MudStack ()
sorryParseBase mq cols txt = wrapSend mq cols $ dblQuote txt <> " is not a valid base."


-----


sorryParseChanId :: T.Text -> T.Text
sorryParseChanId a = dblQuote a <> " is not a valid channel ID."


-----


sorryParseId :: T.Text -> T.Text
sorryParseId a = dblQuote a <> " is not a valid ID."


-----


sorryParseIndent :: MsgQueue -> Cols -> T.Text -> MudStack ()
sorryParseIndent mq cols a = wrapSend mq cols $ dblQuote a <> " is not a valid width amount."


-----


sorryParseLineLen :: MsgQueue -> Cols -> T.Text -> MudStack ()
sorryParseLineLen mq cols a = wrapSend mq cols $ dblQuote a <> " is not a valid line length."


-----


sorryParseNum :: MsgQueue -> Cols -> T.Text -> T.Text -> MudStack ()
sorryParseNum mq cols numTxt base = wrapSend mq cols . T.concat $ [ dblQuote numTxt
                                                                  , " is not a valid number in base "
                                                                  , base
                                                                  , "." ]


-----


sorryPeepIgnore :: T.Text
sorryPeepIgnore = sorryIgnoreLocPrefPlur "The PC names of the players you wish to start or stop peeping"


-----


sorryRemoveIgnore :: T.Text
sorryRemoveIgnore = sorryIgnoreLocPrefPlur "The names of the items to be removed from a container "


-----


sorryRnt :: MsgQueue -> Cols -> MudStack ()
sorryRnt mq cols = wrapSend mq cols "Sorry, but you can only generate a random name for one PC at a time."


-----


sorryTwoWayTargetName :: ExpCmdName -> Sing -> Either T.Text a
sorryTwoWayTargetName cn s = Left . T.concat $ [ "In a telepathic message to "
                                               , s
                                               , ", the only possible target is "
                                               , s
                                               , ". Please try "
                                               , quoteColor
                                               , T.singleton expCmdChar
                                               , cn
                                               , " "
                                               , T.singleton . toLower . T.head $ s
                                               , dfltColor
                                               , " instead." ]


-----


sorryUnlinkIgnore :: T.Text
sorryUnlinkIgnore = sorryIgnoreLocPrefPlur "The names of the items to be removed from a container "


-----


sorryWrapLineLen :: MsgQueue -> Cols -> MudStack ()
sorryWrapLineLen mq cols = wrapSend mq cols . T.concat $ [ "The line length must be between "
                                                         , showText minCols
                                                         , " and "
                                                         , showText maxCols
                                                         , " characters." ]


----


sorryWtf :: T.Text
sorryWtf = quoteWith' (wtfColor, dfltColor) "He don't."
