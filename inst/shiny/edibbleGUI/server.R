library(shiny)
library(ggplot2)
library(edibble)
library(deggust)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    units <- reactive({
        unit_exprs <- list()
        unit_exprs[[input$unit_name]] <- input$unit_value
        unit_exprs
    })

    trts <- reactive({
        trt_exprs <- list()
        trt_exprs[[input$trt_name]] <- input$trt_value
        trt_exprs
    })

    allocation <- reactive({
        as.formula(paste(input$trt_name, "~", input$unit_name))
    })

    design <- reactive({
        input$rerandomise
        des <- start_design() %>%
            set_units(!!!units()) %>%
            set_trts(!!!trts()) %>%
            allocate_trts(!!!allocation())
        if(input$randomise) des <- randomise_trts(des)
        des
    })

    output$final <- renderDataTable({
        serve_table(design())
    })

    output$plot <- renderPlot({
        autoplot(serve_table(design()))
    })

})
