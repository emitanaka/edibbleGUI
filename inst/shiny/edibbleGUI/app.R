library(shiny)
library(ggplot2)
library(edibble)
library(deggust)
library(stringr)

ui <- fluidPage(

  titlePanel("An edibble experimental design"),

  sidebarLayout(
    sidebarPanel(
      column(8,
             textInput("unit_name1", "Unit", "unit1")),
      column(4,
             numericInput("unit_value1",
                          "Number:",
                          min = 1,
                          value = 10)
             ),
      div(id = "unit_placeholder"),
      actionButton("add_unit", "Add unit factor"),
      br(), br(),
      column(5,
             textInput("trt_name1", "Treatment", "trt1")
             ),
      column(4,
            numericInput("trt_value1",
                         "Number",
                         min = 1,
                         value = 5)),
      column(3),
      div(id = "trt_placeholder"),
      actionButton("add_trt", "Add treatment factor"),
      br(), br(),
      actionButton("rerandomise", "Re-randomise"),
      actionButton("reset", "Reset")
    ),
    mainPanel(
      plotOutput("plot"),
      dataTableOutput("final")
    )
  )
)


server <- function(input, output, session) {
  index_unit <- reactiveVal(1)
  index_trt <- reactiveVal(1)

  units <- reactive({
    input
    unit_exprs <- list()
    nms <- names(input)
    unit_names <- nms[str_detect(nms, "^unit_name")]
    for(aunit_name in sort(unit_names)) {
      i <- as.numeric(str_extract(aunit_name, "[0-9]+"))
      val <- input[[paste0("unit_value", i)]]
      if(i==1) {
        unit_exprs[[input[[aunit_name]]]] <- val
      } else {
        parent <- input[[paste0("unit_name", i - 1)]]
        x <- paste("nested_in(", parent, ",", val, ")")
        unit_exprs[[input[[aunit_name]]]] <- rlang::parse_expr(x)
      }
    }

    unit_exprs
  })

  trts <- reactive({
    trt_exprs <- list()
    trt_exprs[[input$trt_name1]] <- input$trt_value1
    trt_exprs
  })

  allocation <- reactive({
    as.formula(paste(input$trt_name1, "~", input$unit_name1))
  })

  design <- reactive({
    input$rerandomise
    des <- start_design() %>%
      set_units(!!!units()) %>%
      set_trts(!!!trts()) %>%
      allocate_trts(!!!allocation()) %>%
      randomise_trts()
    des
  })

  output$final <- renderDataTable({
    serve_table(design())
  })

  output$plot <- renderPlot({
    autoplot(serve_table(design()))
  })


  observeEvent(input$add_unit, {
    last_unit_name <- paste0("unit_name", index_unit())
    last_unit_val <- paste0("unit_value", index_unit())
    insertUI(selector = "#unit_placeholder",
             where = "beforeBegin",
             ui = tagList(column(8,
                                textInput(paste0("unit_name", index_unit() + 1),
                                          paste("Nested in", names(units())[index_unit()]),
                                          paste0("unit", index_unit() + 1))),
                          column(4,
                                 numericInput(paste0("unit_value", index_unit() + 1),
                                 "",
                                 min = 1,
                                 value = 5)
                                 )))
    new_index <- index_unit() + 1
    index_unit(new_index)
  })


  # clear route
  observeEvent(input$reset, {
    # remove inserted uis
    if (index_unit() > 1) {
      lapply(2:index_unit(), function(x) {
        removeUI(selector = paste0(".col-sm-8:has(#unit_name", x, ")" ))
        removeUI(selector = paste0(".col-sm-4:has(#unit_value", x, ")" ))
        })
    }
    # reset reactive value
    index_unit(1)

  })

}


shinyApp(ui = ui, server = server)
