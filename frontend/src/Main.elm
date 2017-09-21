-- Imports


module Main exposing (..)

import Bootstrap.CDN
import Bootstrap.Modal
import Bootstrap.Navbar
import Html
import Html.Attributes
import Http
import JsonApi
import Json.Decode
import Json.Encode
import Maybe
import Navigation
import UrlParser exposing ((</>))
import AstrolabActivator
import Configurator
import ViewAbout
import ViewGettingStarted
import ViewNavigation
import ViewRunApplication
import ViewUploadLogs


-- Route


type Route
    = HomeRoute
    | ServiceRoute String
    | RunApplicationRoute
    | UploadLogsRoute
    | ActivateAstrolabRoute
    | GettingStartedRoute
    | NotFoundRoute


matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.map HomeRoute UrlParser.top
        , UrlParser.map RunApplicationRoute (UrlParser.s "run-application")
        , UrlParser.map ServiceRoute (UrlParser.s "services" </> UrlParser.string)
        , UrlParser.map UploadLogsRoute (UrlParser.s "upload-logs")
        , UrlParser.map GettingStartedRoute (UrlParser.s "getting-started")
        , UrlParser.map ActivateAstrolabRoute (UrlParser.s "activate")
        ]


parseLocation : Navigation.Location -> Route
parseLocation location =
    case (UrlParser.parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute



-- Model


type alias Service =
    { name : String
    , websockify_port : Int
    }


type alias Model =
    { services : List Service
    , selected_service_name : Maybe String
    , uploaded_log_url : String
    , navbarState : Bootstrap.Navbar.State
    , uploadLogsModalState : Bootstrap.Modal.State
    , uploadLogsInFlight : Bool
    , loadingAstrolabs : Bool
    , activatingAstrolab : Bool
    , route : Route
    , astrolabs : Maybe (List AstrolabActivator.Astrolab)
    , apiHost : String
    , selectedAstrolab : Maybe AstrolabActivator.Astrolab
    }



-- Model Initialization


initialState : Navigation.Location -> ( Model, Cmd Msg )
initialState location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg
    in
        ( { services =
                [ Service "Lin Guider (Autoguider)" 6101
                , Service "PHD2 (Autoguider)" 6102
                , Service "Open Sky Imager (Camera Controller)" 6103
                ]
          , selected_service_name = Nothing
          , uploaded_log_url = ""
          , navbarState = navbarState
          , uploadLogsModalState = Bootstrap.Modal.hiddenState
          , uploadLogsInFlight = False
          , loadingAstrolabs = False
          , activatingAstrolab = False
          , route = parseLocation location
          , astrolabs = Nothing
          , apiHost = Configurator.determineApiHost location
          , selectedAstrolab = Nothing
          }
        , navbarCmd
        )



-- Update


type Msg
    = NoOp
    | OnLocationChange Navigation.Location
    | UpdateRoute Route
    | StartApplication String
    | HandleStartApplication (Result Http.Error String)
    | StopApplication String
    | HandleStopApplication (Result Http.Error String)
    | CleanApplication String
    | HandleCleanApplication (Result Http.Error String)
    | ServiceSelect (Maybe String)
    | LogsUploaded (Result Http.Error String)
    | NavbarMsg Bootstrap.Navbar.State
    | UploadLogsModalMsg Bootstrap.Modal.State
    | UploadLogs
      -- Astrolab-specific messages:
    | LoadAstrolabs
    | LoadAstrolabsComplete (Result Http.Error (List JsonApi.Resource))
    | SelectAstrolab (Maybe AstrolabActivator.Astrolab)
    | ActivateAstrolab
    | ActivateAstrolabComplete (Result Http.Error JsonApi.Resource)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NoOp ->
            ( model, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                { model | route = newRoute }
                    |> update (UpdateRoute newRoute)

        UpdateRoute newRoute ->
            case newRoute of
                ServiceRoute string ->
                    { model | route = newRoute }
                        |> update (ServiceSelect (Just string))

                UploadLogsRoute ->
                    model
                        |> update (UploadLogsModalMsg Bootstrap.Modal.visibleState)

                _ ->
                    ( { model | route = newRoute }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        UploadLogsModalMsg state ->
            ( { model | uploadLogsModalState = state }, Cmd.none )

        ServiceSelect new_service ->
            case new_service of
                Nothing ->
                    ( model, Cmd.none )

                Just string ->
                    if Just string /= model.selected_service_name then
                        { model | selected_service_name = Just string }
                            |> update (UpdateRoute (ServiceRoute string))
                    else
                        ( model, Cmd.none )

        StartApplication docker_image ->
            ( model
            , Http.send HandleStartApplication (startApplication model.selectedAstrolab docker_image)
            )

        HandleStartApplication (Ok response) ->
            ( model, Cmd.none )

        HandleStartApplication (Err err) ->
            ( model, Cmd.none )

        StopApplication docker_image ->
            ( model
            , Http.send HandleStopApplication (stopApplication model.selectedAstrolab docker_image)
            )

        HandleStopApplication (Ok response) ->
            ( model, Cmd.none )

        HandleStopApplication (Err err) ->
            ( model, Cmd.none )

        CleanApplication docker_image ->
            ( model
            , Http.send HandleCleanApplication (cleanApplication model.selectedAstrolab docker_image)
            )

        HandleCleanApplication (Ok response) ->
            ( model, Cmd.none )

        HandleCleanApplication (Err err) ->
            ( model, Cmd.none )

        UploadLogs ->
            ( { model | uploadLogsInFlight = True }, uploadLogs model )

        LogsUploaded (Ok output) ->
            let
                url =
                    output
                        |> String.filter (\c -> c /= '\n')
            in
                ( { model | uploaded_log_url = url, uploadLogsInFlight = False }, Cmd.none )

        LogsUploaded (Err error) ->
            ( { model | uploaded_log_url = (toString error), uploadLogsInFlight = False }, Cmd.none )

        LoadAstrolabs ->
            ( { model | loadingAstrolabs = True }, (AstrolabActivator.loadAstrolabs model LoadAstrolabsComplete) )

        LoadAstrolabsComplete (Ok resources) ->
            ( { model
                | loadingAstrolabs = False
                , astrolabs = AstrolabActivator.parseAstrolabs resources
              }
            , Cmd.none
            )

        LoadAstrolabsComplete (Err error) ->
            Debug.log ("Error: " ++ toString error)
                ( { model | loadingAstrolabs = False, astrolabs = Nothing }, Cmd.none )

        SelectAstrolab astrolab ->
            ( { model | selectedAstrolab = astrolab }, Cmd.none )

        ActivateAstrolab ->
            model |> update NoOp

        ActivateAstrolabComplete (Ok output) ->
            model |> update NoOp

        _ ->
            model |> update NoOp



-- DECODERS


logsUploadedDecoder : Json.Decode.Decoder String
logsUploadedDecoder =
    Json.Decode.field "output" Json.Decode.string


uploadLogs : Model -> Cmd Msg
uploadLogs model =
    let
        body =
            Json.Encode.object
                [ ( "command", Json.Encode.string "pastebinit" )
                , ( "args"
                  , Json.Encode.list
                        ([ Json.Encode.string "-b"
                         , Json.Encode.string "sprunge.us"
                         , Json.Encode.string "/mnt/host/var/log/syslog"
                         ]
                        )
                  )
                ]
                |> Http.jsonBody

        url =
            "http://localhost:5000/api/execute_command"
    in
        Http.post url body logsUploadedDecoder
            |> Http.send LogsUploaded



-- APPLICATION HANDLING


applicationSpecifierEncoder : String -> Json.Encode.Value
applicationSpecifierEncoder docker_image =
    Json.Encode.object [ ( "image", Json.Encode.string docker_image ) ]


applicationSpecifierResponseDecoder : Json.Decode.Decoder String
applicationSpecifierResponseDecoder =
    Json.Decode.field "status" Json.Decode.string


startApplication : Maybe AstrolabActivator.Astrolab -> String -> Http.Request String
startApplication maybe_astrolab docker_image =
    Http.post
        (case maybe_astrolab of
            Just astrolab ->
                astrolab.local_endpoint ++ "/api/start_xapplication"

            Nothing ->
                "http://localhost"
        )
        (Http.stringBody "application/json" <| Json.Encode.encode 0 <| applicationSpecifierEncoder docker_image)
        (applicationSpecifierResponseDecoder)


stopApplication : Maybe AstrolabActivator.Astrolab -> String -> Http.Request String
stopApplication maybe_astrolab docker_image =
    Http.post
        (case maybe_astrolab of
            Just astrolab ->
                astrolab.local_endpoint ++ "/api/stop_xapplication"

            Nothing ->
                "http://localhost"
        )
        (Http.stringBody "application/json" <| Json.Encode.encode 0 <| applicationSpecifierEncoder docker_image)
        (applicationSpecifierResponseDecoder)


cleanApplication : Maybe AstrolabActivator.Astrolab -> String -> Http.Request String
cleanApplication maybe_astrolab docker_image =
    Http.post
        (case maybe_astrolab of
            Just astrolab ->
                astrolab.local_endpoint ++ "/api/clean_xapplication"

            Nothing ->
                "http://localhost"
        )
        (Http.stringBody "application/json" <| Json.Encode.encode 0 <| applicationSpecifierEncoder docker_image)
        (applicationSpecifierResponseDecoder)



-- VIEW


view : Model -> Html.Html Msg
view model =
    let
        viewServiceEmbed =
            case model.route of
                ActivateAstrolabRoute ->
                    AstrolabActivator.view ( model, SelectAstrolab )

                HomeRoute ->
                    ViewAbout.view

                GettingStartedRoute ->
                    ViewGettingStarted.view

                RunApplicationRoute ->
                    ViewRunApplication.view ( StartApplication, StopApplication, CleanApplication )

                ServiceRoute service_name ->
                    Html.iframe
                        [ Html.Attributes.src
                            (case model.selected_service_name of
                                Nothing ->
                                    ""

                                Just string ->
                                    ("http://localhost:6080/vnc_auto.html?host=localhost&port="
                                        ++ (List.filter (\n -> n.name == string) model.services
                                                |> List.map .websockify_port
                                                |> List.head
                                                |> Maybe.withDefault 0
                                                |> toString
                                           )
                                    )
                            )
                        , Html.Attributes.height 600
                        , Html.Attributes.width 1000
                        ]
                        []

                _ ->
                    Html.text "Nothing yet"
    in
        Html.div [ Html.Attributes.class "container" ]
            [ Bootstrap.CDN.stylesheet
            , ViewNavigation.view ( NavbarMsg, model, ServiceSelect, UploadLogsModalMsg, LoadAstrolabs, SelectAstrolab )
            , ViewUploadLogs.viewModal ( UploadLogsModalMsg, model, UploadLogs )
            , viewServiceEmbed
            ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Bootstrap.Navbar.subscriptions model.navbarState NavbarMsg


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = initialState
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
