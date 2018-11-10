module ViewRunApplication exposing (view, RunningApplication)

import Bootstrap.Button
import Bootstrap.Form
import Bootstrap.Form.Input
import Bootstrap.Grid
import Bootstrap.Grid.Col
import Html
import Html.Attributes


type alias RunningApplication =
    { name : String
    , local_websockify_hostname : String
    , local_websockify_port : Int
    }


view :
    ( String -> msg, String -> msg, String -> msg, String -> msg, { a | runCustomApplicationImage : String } )
    -> Html.Html msg
view ( start_application_msg, stop_application_msg, clean_application_msg, set_custom_application_image_msg, model ) =
    Html.div []
        [ Html.h1 [] [ Html.text "Run a Custom Application..." ]
        , Html.p []
            [ Html.text "Any ARM-compatible Linux application can be made to run on your Astrolab! "
            , Html.a
                [ Html.Attributes.href "https://github.com/astroswarm/phd2_builder"
                , Html.Attributes.target "_blank"
                ]
                [ Html.text "Click here" ]
            , Html.text " to see how we built PHD2 for the Astrolab."
            ]
        , Html.p [] [ Html.text "To run a custom application, enter its Docker Hub image name below." ]
        , Bootstrap.Form.form []
            [ Bootstrap.Form.group []
                ([ Bootstrap.Grid.container
                    []
                    [ Bootstrap.Grid.row []
                        [ Bootstrap.Grid.col [ Bootstrap.Grid.Col.xs6 ]
                            [ Bootstrap.Form.Input.text
                                [ Bootstrap.Form.Input.id "image"
                                , Bootstrap.Form.Input.placeholder "repository/image:tag"
                                , Bootstrap.Form.Input.value model.runCustomApplicationImage
                                , Bootstrap.Form.Input.onInput set_custom_application_image_msg
                                ]
                            ]
                        , Bootstrap.Grid.col
                            [ Bootstrap.Grid.Col.xs2 ]
                            [ Bootstrap.Button.button
                                [ Bootstrap.Button.primary
                                , Bootstrap.Button.disabled (model.runCustomApplicationImage == "")
                                , Bootstrap.Button.onClick (start_application_msg model.runCustomApplicationImage)
                                ]
                                [ Html.text
                                    "Download/Start"
                                ]
                            ]
                        , Bootstrap.Grid.col
                            [ Bootstrap.Grid.Col.xs2 ]
                            [ Bootstrap.Button.button
                                [ Bootstrap.Button.warning
                                , Bootstrap.Button.disabled (model.runCustomApplicationImage == "")
                                , Bootstrap.Button.onClick (stop_application_msg model.runCustomApplicationImage)
                                ]
                                [ Html.text
                                    "Stop"
                                ]
                            ]
                        , Bootstrap.Grid.col
                            [ Bootstrap.Grid.Col.xs2 ]
                            [ Bootstrap.Button.button
                                [ Bootstrap.Button.danger
                                , Bootstrap.Button.disabled (model.runCustomApplicationImage == "")
                                , Bootstrap.Button.onClick (clean_application_msg model.runCustomApplicationImage)
                                ]
                                [ Html.text
                                    "Uninstall"
                                ]
                            ]
                        ]
                    ]
                 ]
                )
            ]
        ]
