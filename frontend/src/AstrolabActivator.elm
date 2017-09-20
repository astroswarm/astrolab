module AstrolabActivator exposing (Astrolab, loadAstrolabs, parseAstrolabs, view)

import Bootstrap.Table
import Date
import Date.Extra.Config.Config_en_us
import Date.Extra.Format
import Html
import Html.Attributes
import Html.Events
import Http
import Json.Decode
import Json.Decode.Pipeline
import JsonApi
import JsonApi.Http
import JsonApi.Resources


type alias Astrolab =
    { public_ip_address : String
    , private_ip_address : String
    , last_seen_at : String
    , country_name : String
    , region_name : String
    , city : String
    , zip_code : String
    , time_zone : String
    , latitude : Float
    , longitude : Float
    , tunnel_endpoint : String
    , local_endpoint : String
    }


loadAstrolabs : { a | apiHost : String } -> (Result Http.Error (List JsonApi.Resource) -> msg) -> Cmd msg
loadAstrolabs model load_astrolabs_complete_msg =
    JsonApi.Http.getPrimaryResourceCollection ("http://" ++ model.apiHost ++ "/v1/astrolabs")
        |> Http.send load_astrolabs_complete_msg


astrolabDecoder : Json.Decode.Decoder Astrolab
astrolabDecoder =
    Json.Decode.Pipeline.decode Astrolab
        |> Json.Decode.Pipeline.required "public-ip-address" Json.Decode.string
        |> Json.Decode.Pipeline.required "private-ip-address" Json.Decode.string
        |> Json.Decode.Pipeline.required "last-seen-at" Json.Decode.string
        |> Json.Decode.Pipeline.required "country-name" Json.Decode.string
        |> Json.Decode.Pipeline.required "region-name" Json.Decode.string
        |> Json.Decode.Pipeline.required "city" Json.Decode.string
        |> Json.Decode.Pipeline.required "zip-code" Json.Decode.string
        |> Json.Decode.Pipeline.required "time-zone" Json.Decode.string
        |> Json.Decode.Pipeline.required "latitude" Json.Decode.float
        |> Json.Decode.Pipeline.required "longitude" Json.Decode.float
        |> Json.Decode.Pipeline.required "tunnel-endpoint" Json.Decode.string
        |> Json.Decode.Pipeline.required "local-endpoint" Json.Decode.string


parseAstrolabs : List JsonApi.Resource -> Maybe (List Astrolab)
parseAstrolabs astrolabs_list =
    List.map
        (\r ->
            (JsonApi.Resources.attributes astrolabDecoder r)
        )
        astrolabs_list
        |> listOfResultsToMaybeList



-- Consider using Maybe-Extra in replace of the following two functions.
-- https://github.com/elm-community/maybe-extra/blob/4.0.0/src/Maybe/Extra.elm


listOfResultsToMaybeList : List (Result a b) -> Maybe (List b)
listOfResultsToMaybeList list =
    removeErrorFromList list
        |> Just


removeErrorFromList : List (Result a b) -> List b
removeErrorFromList list =
    case (List.reverse list) of
        (Ok a) :: xs ->
            a :: removeErrorFromList xs

        (Err b) :: xs ->
            Debug.log (toString b)
                removeErrorFromList
                xs

        [] ->
            []


view :
    ( { model | astrolabs : Maybe (List Astrolab), loadingAstrolabs : Bool }, Maybe Astrolab -> msg )
    -> Html.Html msg
view ( model, select_astrolab_msg ) =
    Html.div []
        [ Html.p []
            [ Html.text
                (if model.loadingAstrolabs then
                    "Loading unregistered Astrolabs..."
                 else
                    "Loaded."
                )
            ]
        , Html.p [] [ Html.text "Plug your Astrolab into your router and turn it on. Wait 30 seconds, and you should see it below." ]
        , Bootstrap.Table.table
            { options = [ Bootstrap.Table.hover, Bootstrap.Table.small ]
            , thead =
                Bootstrap.Table.simpleThead
                    [ Bootstrap.Table.th [] [ Html.text "Public IP" ]
                    , Bootstrap.Table.th [] [ Html.text "Private IP" ]
                    , Bootstrap.Table.th [] [ Html.text "Last Detected" ]
                    , Bootstrap.Table.th [] [ Html.text "Location" ]
                    , Bootstrap.Table.th [] [ Html.text "Select" ]
                    ]
            , tbody =
                case model.astrolabs of
                    Nothing ->
                        Bootstrap.Table.tbody [] [ Bootstrap.Table.tr [] [] ]

                    Just astrolabs ->
                        Bootstrap.Table.tbody []
                            (List.map
                                (\astrolab ->
                                    Bootstrap.Table.tr []
                                        [ Bootstrap.Table.td [] [ Html.text astrolab.public_ip_address ]
                                        , Bootstrap.Table.td [] [ Html.text astrolab.private_ip_address ]
                                        , Bootstrap.Table.td []
                                            [ Html.text
                                                (case
                                                    astrolab.last_seen_at
                                                        |> Date.fromString
                                                 of
                                                    Ok date ->
                                                        Date.Extra.Format.format Date.Extra.Config.Config_en_us.config "%a, %b %e at %l:%M %P %:z" date

                                                    Err e ->
                                                        "Unknown"
                                                )
                                            ]
                                        , Bootstrap.Table.td []
                                            [ Html.text
                                                (if astrolab.city /= "" then
                                                    (astrolab.city ++ ", " ++ astrolab.region_name)
                                                 else
                                                    astrolab.region_name
                                                )
                                            ]
                                        , Bootstrap.Table.td []
                                            [ Html.a
                                                [ Html.Attributes.href "#getting-started"
                                                , Html.Events.onClick (select_astrolab_msg (Just astrolab))
                                                ]
                                                [ Html.text "Launch" ]
                                            ]
                                        ]
                                )
                                astrolabs
                            )
            }
        ]
