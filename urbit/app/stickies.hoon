/+  *server 
/=  tile-js
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/stickies/js/tile
  /|  /js/
      /~  ~
  ==
=,  format
|%
::  Define a type for ids
::
++  id  @ud
+$  move  (pair bone card)
+$  poke
  $%  [%launch-action [@tas path @t]]
  ==
+$  card
  $%  [%poke wire dock poke]
      [%http-response =http-event:http]
      [%connect wire binding:eyre term]
      [%diff %json json]
  ==
::  Define the state type
::
+$  state
  $%  [%0 state-zero]
  ==
::  Define an initial state with the stickies map?
::  Actually, I cargo-culted this one. Not sure why it needs to be separated from the
::  state definition.
::
+$  state-zero
  $:  =stickies
  ==
::  Define the sticky type with id, content, and is-complete properties
::
+$  sticky
  $:  =id
      content=cord
      is-complete=?
  ==
::  Define the stickies type as a map of sticky
::
+$  stickies  (map id sticky)
::  Define the command types the app will accept
::
+$  sticky-command
  :: Add sticky command has an id and content
  :: Complete sticky command just needs an id
  ::
  $%  [%add-sticky =id content=cord]
      [%complete-sticky =id]
  ==
--
|_  [bol=bowl:gall state]
++  this  .
++  bound
  |=  [wir=wire success=? binding=binding:eyre]
  ^-  (quip move _this)
  [~ this]
++  prep
  |=  old=(unit state)
  ^-  (quip move _this)
  =/  launcha
    [%launch-action [%stickies /stickiestile '/~stickies/js/tile.js']]
  :_  ?~  old  this
    this(+<+ u.old)
  :~  [ost.bol %connect / [~ /'~stickies'] %stickies]
      [ost.bol %poke /stickies [our.bol %launch] launcha]
  ==
:: When someone subscribes to the app, return the stickies map to the subscriber
:: as a json array
::
++  peer-stickiestile
  |=  pax=path
  ^-  (quip move _this)
  =/  jon=json  (pairs:enjs:format (turn ~(val by stickies) sticky-to-json-pair))
  [[ost.bol %diff %json jon]~ this]
::
++  send-tile-diff
  |=  jon=json
  ^-  (list move)
  %+  turn  (prey:pubsub:userlib /stickiestile bol)
  |=  [=bone ^]
  [bone %diff %json jon]
::  Arm to transform a sticky to json pair
::
++  sticky-to-json-pair
  |=  =sticky
  ^-  [p=@t q=json]
  :-  (scot %ud id.sticky)
  %-  pairs:enjs:format  :~
    [%id `json`n+(scot %ud id.sticky)]
    [%content `json`s+content.sticky]
    [%is-complete `json`b+is-complete.sticky]
  ==
::  Arm that accepts a sticky and returns a json array with
::  the new sticky appended to the list of existing stickies
::
++  send-sticky-diff
  |=  =sticky
  %-  send-tile-diff
  :: %-  frond:enjs:format
  :: (sticky-to-json-pair sticky)
  =/  current  (turn ~(val by stickies) sticky-to-json-pair)
  =/  new  (sticky-to-json-pair sticky)
  (pairs:enjs:format (snoc current new))
::  Arm called when a json request is received by the app.
::  First converts the received json to a command, then
::  calls the poke-sticky-command arm with the parsed command
::
++  poke-json
  |=  jon=json
  ^-  (quip move _this)
  (poke-sticky-command (json-to-command jon))
::  Accepts a command and switches on the command type and then
::  calls the appropriate handler function for that command
::
++  poke-sticky-command
  |=  command=sticky-command
  ^-  (quip move _this)
  ?-  -.command
    %add-sticky  (handle-add-sticky command)
    %complete-sticky  (handle-complete-sticky command)
  ==
::  Handles the add sticky command
::
++  handle-add-sticky
  |=  command=sticky-command
  ^-  (quip move _this)
  ::  Assert that the command type is add-sticky
  ::
  ?>  ?=(%add-sticky -.command)
  =/  props  +.command
  ::  If the id already exists in the stickies map, we cannot create a new sticky,
  ::  so do nothing.
  ::
  ?:  (~(has by stickies) id.props)
    [~ this]
  ::  Create the new sticky
  ::
  =/  new-sticky=sticky  [id=id.props content=content.props is-complete=%.n]
  ::  Return the new state to the client and updates the app state by adding
  ::  the new sticky to the map
  ::
  :-  (send-sticky-diff new-sticky)
  this(stickies (~(put by stickies) id.props new-sticky))
::  Handles the complete-sticky command
::
++  handle-complete-sticky
  |=  command=sticky-command
  ^-  (quip move _this)
  ::  Asserts that command has proper type
  ::
  ?>  ?=(%complete-sticky -.command)
  =/  props  +.command
  ::  If the id does not exist in the map, do nothing
  ::
  ?.  (~(has by stickies) id.props)
    [~ this]
  ::  Get the existing sticky and create a new sticky value with
  ::  the same content but now it is complete
  ::
  =/  existing-sticky=sticky  (~(got by stickies) id.props)
  =/  complete-sticky=sticky  [id=id.props content=content.existing-sticky is-complete=%.y]
  ::  Return the new state to the client and update the app state by replacing
  ::  the old sticky in the map
  ::
  :-  (send-sticky-diff complete-sticky)
  this(stickies (~(put by stickies) id.props complete-sticky))
::  Transforms the incoming json to appropriate command
::
++  json-to-command
  |=  jon=json
  ~&  jon
  ^-  sticky-command
  =,  dejs:format
  =<  (parse-json jon)
  |%
  ::  Creates a gate that will call different parsing functions depending
  ::  on the key of the json passed in
  ::
  ++  parse-json
    %-  of
    :~  [%add-sticky add-sticky]
        [%complete-sticky complete-sticky]
    ==
  ::  Creates a gate that will accept a json object and return a tuple with id and
  ::  content properties
  ::
  ++  add-sticky
    %-  ot
    :~  [%id ni]
        [%content so]
    ==
  ::  Creates a gate that accepts a json object and return a tuple with an id property
  ::
  ++  complete-sticky
    %-  ot
    :~  [%id ni]
    ==
  --
++  poke-handle-http-request
  %-  (require-authorization:app ost.bol move this)
  |=  =inbound-request:eyre
  ^-  (quip move _this)
  =/  request-line  (parse-request-line url.request.inbound-request)
  =/  back-path  (flop site.request-line)
  =/  name=@t
    =/  back-path  (flop site.request-line)
    ?~  back-path
      ''
    i.back-path
  ::
  ?~  back-path
    [[ost.bol %http-response not-found:app]~ this]
  ?:  =(name 'tile')
    [[ost.bol %http-response (js-response:app tile-js)]~ this]
  [[ost.bol %http-response not-found:app]~ this]
::
--
