-- Imports

import Html
import Html.Attributes
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Maybe

-- Model

type alias Flags =
  {
    hostname: String
  }
type alias Service =
  {
    name: String,
    websockify_port: Int
  }
type alias Model =
  {
    services: List Service,
    selected_service_name: String,
    hostname: String,
    uploaded_log_url: String
  }

-- Model Initialization

init : Flags -> (Model, Cmd Msg)
init {hostname} =
  (
    {
      services =
        [
          Service "Lin Guider (Autoguider)" 6101,
          Service "PHD2 (Autoguider)" 6102,
          Service "Open Sky Imager (Camera Controller)" 6103
        ],
       selected_service_name = "Lin Guider (Autoguider)",
       hostname = hostname,
       uploaded_log_url = ""
    },
    Cmd.none
  )

-- Update

type Msg = NoOp | ServiceSelect String | UploadLogs | LogsUploaded (Result Http.Error String)

update: Msg -> Model -> (Model, Cmd Msg)

update message model =
  case message of
    NoOp ->
      (model, Cmd.none)
    ServiceSelect new_service ->
      ({ model | selected_service_name = new_service }, Cmd.none)
    UploadLogs ->
      (model, uploadLogs)
    LogsUploaded (Ok output) ->
      let
        url =
          output
          |> String.filter (\c -> c /= '\n')
      in
        ({ model | uploaded_log_url = url }, Cmd.none)
    LogsUploaded (Err error) ->
      ({ model | uploaded_log_url = (toString error) }, Cmd.none)


-- COMMANDS

uploadLogs : Cmd Msg
uploadLogs =
  let
    body = Json.Encode.object [
      ("command", Json.Encode.string "pastebinit"),
      ("args", Json.Encode.list( 
        [
          Json.Encode.string "-b",
          Json.Encode.string "sprunge.us",
          Json.Encode.string "/mnt/host/var/log/syslog"
        ]
      ))]
      |> Http.jsonBody
    url = "http://localhost:8001/api/execute_command"
  in
    Http.post url body logsUploadedDecoder
      |> Http.send LogsUploaded


logsUploadedDecoder : Json.Decode.Decoder String
logsUploadedDecoder =
  Json.Decode.field "output" Json.Decode.string


-- VIEW

view : Model -> Html.Html Msg
view model =
  let
    viewServicesList =
      Html.div [] [
        Html.p [ ] [ Html.text "Choose a service to run:" ],
        Html.ul [ Html.Attributes.class "collection" ] (
          List.map (\
            service ->
              Html.li [ Html.Attributes.class "collection-item" ] [
                if service.name == model.selected_service_name then
                  Html.text service.name
                else
                  Html.a [
                    Html.Attributes.href "javascript: return false;",
                    Html.Events.onClick (ServiceSelect service.name)
                  ] [ Html.text service.name ]
              ]
          ) model.services
        )
      ]


    viewStatusInfo =
      Html.div [] [
        Html.p [ ] [ Html.text ("Using host: " ++ model.hostname) ]
      ]

    viewUploadLogs =
      Html.p [ ] [
        Html.a [
          Html.Attributes.href "javascript: return false;",
          Html.Events.onClick UploadLogs
        ] [ Html.text "Having trouble? Click here to upload your logs." ],
        if String.length(model.uploaded_log_url) > 0 then
          Html.p [ ] [
            Html.text "Your logs have been uploaded: ",
            Html.a [
              Html.Attributes.href model.uploaded_log_url,
              Html.Attributes.target "_blank"
            ] [ Html.text model.uploaded_log_url ]
          ]
        else
          Html.text ""
      ]


    viewServiceEmbed =
      Html.iframe [
        Html.Attributes.src(
          "http://" ++ model.hostname ++ ":6080/vnc_auto.html?host=" ++ model.hostname ++ "&port=" ++ (
            List.filter (\n -> n.name == model.selected_service_name) model.services
              |> List.map .websockify_port
              |> List.head
              |> Maybe.withDefault 0
              |> toString
          )
        ),
        Html.Attributes.height 600,
        Html.Attributes.width 1000
      ] []
  in
    Html.div [ Html.Attributes.class "container" ] [
      viewServicesList,
      viewStatusInfo,
      viewUploadLogs,
      viewServiceEmbed
    ]


main : Program Flags Model Msg
main =
  Html.programWithFlags
    {
      init = init,
      view = view,
      update = update,
      subscriptions = \_ -> Sub.none
    }
