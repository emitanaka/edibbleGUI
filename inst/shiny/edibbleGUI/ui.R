
library(shiny)

shinyUI(fluidPage(

    titlePanel("An edibble experimental design"),

    sidebarLayout(
        sidebarPanel(
            textInput("unit_name", "Unit name", "unit"),
            numericInput("unit_value",
                        "Number of experimental units:",
                        min = 1,
                        value = 30),
            textInput("trt_name", "Treatment name", "trt"),
            numericInput("trt_value",
                         "Number of levels for the treatment:",
                         min = 1,
                         value = 5),
            checkboxInput("randomise", "Randomise experiment?", TRUE),
            actionButton("rerandomise", "Re-randomise")
        ),
        mainPanel(
            plotOutput("plot"),
            dataTableOutput("final")
        )
    )
))
